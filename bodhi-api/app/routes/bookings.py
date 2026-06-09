import random
import string
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.booking import Booking, BookingStatus, BookingStatusLog, BookingSource
from app.models.service import ServiceType
from app.schemas.booking import BookingCreateRequest, BookingResponse, BookingRateRequest, BookingStatusUpdate

router = APIRouter(prefix="/bookings", tags=["bookings"])


def _gen_otp() -> str:
    return ''.join(random.choices(string.digits, k=4))


@router.post("/", response_model=BookingResponse)
async def create_booking(
    req: BookingCreateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new service booking."""
    senior_id = req.senior_id or user.id
    otp = _gen_otp()

    booking = Booking(
        senior_id=senior_id,
        service_type=ServiceType(req.service_type),
        service_id=req.service_id,
        status=BookingStatus.PENDING,
        source=BookingSource.FAMILY if req.senior_id and req.senior_id != user.id else BookingSource.APP,
        booked_by_user_id=user.id,
        scheduled_at=req.scheduled_at,
        address=req.address or user.address,
        latitude=req.latitude,
        longitude=req.longitude,
        base_price=0,  # Will be calculated by service layer
        otp_code=otp,
        notes=req.notes,
        preferred_gender=req.preferred_gender,
    )
    db.add(booking)
    await db.commit()
    await db.refresh(booking)

    # Log initial status
    log = BookingStatusLog(booking_id=booking.id, status=BookingStatus.PENDING)
    db.add(log)
    await db.commit()

    # Trigger async provider matching
    from app.worker.tasks import match_provider, notify_family
    match_provider.delay(booking.id)
    notify_family.delay(senior_id, "New Booking", f"A {req.service_type} service was booked")

    return BookingResponse(
        id=booking.id,
        service_type=booking.service_type.value,
        status=booking.status.value,
        scheduled_at=booking.scheduled_at,
        base_price=booking.base_price,
        otp_code=otp,
        created_at=booking.created_at,
    )


@router.get("/", response_model=list[BookingResponse])
async def list_bookings(
    status: str | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List bookings for the current user (senior sees their bookings, family sees linked senior's)."""
    query = select(Booking).where(
        (Booking.senior_id == user.id) | (Booking.booked_by_user_id == user.id)
    ).order_by(desc(Booking.created_at))

    if status:
        query = query.where(Booking.status == BookingStatus(status))

    result = await db.execute(query)
    bookings = result.scalars().all()

    return [
        BookingResponse(
            id=b.id,
            service_type=b.service_type.value,
            status=b.status.value,
            scheduled_at=b.scheduled_at,
            base_price=b.base_price,
            created_at=b.created_at,
        )
        for b in bookings
    ]


@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(booking_id: int, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Booking).where(Booking.id == booking_id))
    booking = result.scalar_one_or_none()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return BookingResponse(
        id=booking.id,
        service_type=booking.service_type.value,
        status=booking.status.value,
        scheduled_at=booking.scheduled_at,
        base_price=booking.base_price,
        otp_code=booking.otp_code if booking.senior_id == user.id else None,
        created_at=booking.created_at,
    )


@router.patch("/{booking_id}/status")
async def update_status(
    booking_id: int,
    req: BookingStatusUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update booking status (provider flow: assigned -> en_route -> arrived -> in_progress -> completed)."""
    result = await db.execute(select(Booking).where(Booking.id == booking_id))
    booking = result.scalar_one_or_none()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    new_status = BookingStatus(req.status)
    booking.status = new_status

    if new_status == BookingStatus.IN_PROGRESS:
        booking.started_at = datetime.now(timezone.utc)
    elif new_status == BookingStatus.COMPLETED:
        booking.completed_at = datetime.now(timezone.utc)

    log = BookingStatusLog(booking_id=booking.id, status=new_status, note=req.note)
    db.add(log)
    await db.commit()

    # Notify senior/family of status change
    from app.worker.tasks import notify_family
    status_labels = {
        "provider_assigned": "Provider assigned to your booking",
        "provider_en_route": "Your provider is on the way",
        "provider_arrived": "Provider has arrived",
        "in_progress": "Service has started",
        "completed": "Service completed",
    }
    label = status_labels.get(new_status.value, f"Booking status: {new_status.value}")
    notify_family.delay(booking.senior_id, "Booking Update", label)

    return {"message": f"Status updated to {new_status.value}"}


@router.post("/{booking_id}/verify-otp")
async def verify_booking_otp(
    booking_id: int,
    otp: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Provider verifies OTP at arrival."""
    result = await db.execute(select(Booking).where(Booking.id == booking_id))
    booking = result.scalar_one_or_none()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    if booking.otp_code != otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    booking.otp_verified = True
    booking.status = BookingStatus.PROVIDER_ARRIVED
    log = BookingStatusLog(booking_id=booking.id, status=BookingStatus.PROVIDER_ARRIVED, note="OTP verified")
    db.add(log)
    await db.commit()

    return {"message": "OTP verified, service can begin"}


@router.post("/{booking_id}/rate")
async def rate_booking(
    booking_id: int,
    req: BookingRateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Booking).where(Booking.id == booking_id))
    booking = result.scalar_one_or_none()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    if booking.status != BookingStatus.COMPLETED:
        raise HTTPException(status_code=400, detail="Can only rate completed bookings")

    booking.rating = req.rating
    booking.review = req.review
    await db.commit()

    # TODO: Update provider rating average
    return {"message": "Rating submitted"}
