from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.models.service import ServiceCategory, Service

router = APIRouter(prefix="/services", tags=["services"])


@router.get("/categories")
async def list_categories(db: AsyncSession = Depends(get_db)):
    """List all active service categories (the 9 tiles on home screen)."""
    result = await db.execute(
        select(ServiceCategory).where(ServiceCategory.is_active == True).order_by(ServiceCategory.display_order)
    )
    return result.scalars().all()


@router.get("/categories/{service_type}/services")
async def list_services(service_type: str, db: AsyncSession = Depends(get_db)):
    """List individual services within a category."""
    result = await db.execute(
        select(ServiceCategory).where(ServiceCategory.service_type == service_type)
    )
    category = result.scalar_one_or_none()
    if not category:
        return []

    result = await db.execute(
        select(Service).where(Service.category_id == category.id, Service.is_active == True)
    )
    return result.scalars().all()
