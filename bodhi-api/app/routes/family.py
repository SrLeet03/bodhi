from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User, FamilyLink, UserRole
from app.models.booking import Booking

router = APIRouter(prefix="/family", tags=["family"])


@router.get("/seniors")
async def get_linked_seniors(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Get all seniors linked to the current family member."""
    if user.role != UserRole.FAMILY:
        raise HTTPException(status_code=403, detail="Only family members can access this")

    result = await db.execute(
        select(FamilyLink).where(FamilyLink.family_member_id == user.id)
    )
    links = result.scalars().all()

    seniors = []
    for link in links:
        senior_result = await db.execute(select(User).where(User.id == link.senior_id))
        senior = senior_result.scalar_one_or_none()
        if senior:
            seniors.append({
                "id": senior.id,
                "name": senior.name,
                "phone": senior.phone,
                "address": senior.address,
                "relationship": link.relationship_type,
                "can_book": link.can_book,
                "can_pay": link.can_pay,
            })

    return seniors


@router.post("/link")
async def link_senior(
    senior_phone: str,
    relationship: str = "child",
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Link a family member to a senior by phone number."""
    result = await db.execute(select(User).where(User.phone == senior_phone, User.role == UserRole.SENIOR))
    senior = result.scalar_one_or_none()
    if not senior:
        raise HTTPException(status_code=404, detail="Senior not found with this phone")

    # Check if already linked
    existing = await db.execute(
        select(FamilyLink).where(
            FamilyLink.senior_id == senior.id,
            FamilyLink.family_member_id == user.id,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Already linked")

    link = FamilyLink(
        senior_id=senior.id,
        family_member_id=user.id,
        relationship_type=relationship,
    )
    db.add(link)
    await db.commit()

    return {"message": f"Linked to {senior.name}", "senior_id": senior.id}


@router.get("/seniors/{senior_id}/activity")
async def get_senior_activity(
    senior_id: int,
    limit: int = 20,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get recent booking activity for a linked senior."""
    # Verify family link
    result = await db.execute(
        select(FamilyLink).where(
            FamilyLink.senior_id == senior_id,
            FamilyLink.family_member_id == user.id,
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=403, detail="Not linked to this senior")

    result = await db.execute(
        select(Booking)
        .where(Booking.senior_id == senior_id)
        .order_by(desc(Booking.created_at))
        .limit(limit)
    )
    bookings = result.scalars().all()

    return [
        {
            "id": b.id,
            "service_type": b.service_type.value,
            "status": b.status.value,
            "base_price": b.base_price,
            "final_price": b.final_price,
            "scheduled_at": b.scheduled_at.isoformat() if b.scheduled_at else None,
            "created_at": b.created_at.isoformat(),
            "rating": b.rating,
        }
        for b in bookings
    ]
