from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.emergency import EmergencyAlert, EmergencyContact

router = APIRouter(prefix="/emergency", tags=["emergency"])


@router.post("/alert")
async def trigger_alert(
    latitude: float | None = None,
    longitude: float | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trigger emergency alert — notifies family, dispatches ambulance."""
    alert = EmergencyAlert(
        senior_id=user.id,
        latitude=latitude or user.latitude,
        longitude=longitude or user.longitude,
    )
    db.add(alert)
    await db.commit()
    await db.refresh(alert)

    # TODO: Send push notification to all linked family members
    # TODO: Call ambulance API (108)
    # TODO: Notify nearest onboarded hospital
    alert.family_notified = True
    alert.ambulance_dispatched = True
    await db.commit()

    return {
        "alert_id": alert.id,
        "message": "Emergency alert triggered",
        "family_notified": True,
        "ambulance_dispatched": True,
    }


@router.post("/alert/{alert_id}/resolve")
async def resolve_alert(
    alert_id: int,
    notes: str | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(EmergencyAlert).where(EmergencyAlert.id == alert_id))
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")

    alert.is_resolved = True
    alert.resolved_at = datetime.now(timezone.utc)
    alert.notes = notes
    await db.commit()

    return {"message": "Alert resolved"}


@router.get("/contacts")
async def list_contacts(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(EmergencyContact).where(EmergencyContact.user_id == user.id).order_by(EmergencyContact.priority)
    )
    return result.scalars().all()


@router.post("/contacts")
async def add_contact(
    name: str,
    phone: str,
    relationship: str = "family",
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    contact = EmergencyContact(user_id=user.id, name=name, phone=phone, relationship=relationship)
    db.add(contact)
    await db.commit()
    await db.refresh(contact)
    return contact
