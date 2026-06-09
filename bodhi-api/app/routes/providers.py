from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User, UserRole
from app.models.provider import Provider, ProviderService, VerificationStatus
from app.models.booking import Booking, BookingStatus
from app.models.service import ServiceType

router = APIRouter(prefix="/providers", tags=["providers"])


@router.get("/me")
async def get_provider_profile(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Get current provider's profile."""
    result = await db.execute(select(Provider).where(Provider.user_id == user.id))
    provider = result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider profile not found")

    return {
        "id": provider.id,
        "name": user.name,
        "gender": provider.gender.value,
        "verification_status": provider.verification_status.value,
        "rating": provider.rating,
        "total_jobs": provider.total_jobs,
        "is_online": provider.is_online,
    }


@router.patch("/me/online")
async def toggle_online(
    is_online: bool,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Toggle provider online/offline status."""
    result = await db.execute(select(Provider).where(Provider.user_id == user.id))
    provider = result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider profile not found")

    provider.is_online = is_online
    await db.commit()
    return {"is_online": provider.is_online}


@router.get("/me/jobs")
async def get_provider_jobs(
    status: str | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get bookings assigned to this provider."""
    result = await db.execute(select(Provider).where(Provider.user_id == user.id))
    provider = result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider profile not found")

    query = select(Booking).where(Booking.provider_id == provider.id).order_by(desc(Booking.created_at))
    if status:
        query = query.where(Booking.status == BookingStatus(status))

    result = await db.execute(query)
    bookings = result.scalars().all()

    return [
        {
            "id": b.id,
            "service_type": b.service_type.value,
            "status": b.status.value,
            "address": b.address,
            "scheduled_at": b.scheduled_at.isoformat() if b.scheduled_at else None,
            "base_price": b.base_price,
            "notes": b.notes,
        }
        for b in bookings
    ]


@router.get("/me/earnings")
async def get_earnings(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get provider earnings summary."""
    result = await db.execute(select(Provider).where(Provider.user_id == user.id))
    provider = result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=404, detail="Provider profile not found")

    result = await db.execute(
        select(Booking).where(
            Booking.provider_id == provider.id,
            Booking.status == BookingStatus.COMPLETED,
        )
    )
    completed = result.scalars().all()

    total_earnings = sum(b.final_price or b.base_price for b in completed)
    recent = completed[:10]

    return {
        "total_earnings": total_earnings,
        "total_jobs": len(completed),
        "rating": provider.rating,
        "recent_jobs": [
            {
                "id": b.id,
                "service_type": b.service_type.value,
                "amount": b.final_price or b.base_price,
                "completed_at": b.completed_at.isoformat() if b.completed_at else None,
            }
            for b in recent
        ],
    }


@router.post("/register")
async def register_provider(
    gender: str,
    bio: str | None = None,
    experience_years: int = 0,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Register as a service provider (requires user role=provider)."""
    # Check if already registered
    result = await db.execute(select(Provider).where(Provider.user_id == user.id))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Already registered as provider")

    from app.models.provider import Gender
    provider = Provider(
        user_id=user.id,
        gender=Gender(gender),
        bio=bio,
        experience_years=experience_years,
        verification_status=VerificationStatus.PENDING,
    )
    db.add(provider)
    await db.commit()
    await db.refresh(provider)

    return {
        "provider_id": provider.id,
        "status": "pending_verification",
        "message": "Your profile is under review. We'll verify your documents shortly.",
    }
