from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.hospital import Hospital, Department, Doctor, OPDSlot, OPDBooking
from app.schemas.hospital import (
    HospitalResponse, DoctorResponse, OPDSlotResponse,
    OPDBookingRequest, OPDBookingResponse,
)

router = APIRouter(prefix="/hospitals", tags=["hospitals"])


@router.get("/", response_model=list[HospitalResponse])
async def list_hospitals(
    search: str | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List onboarded hospitals near the user."""
    query = select(Hospital).where(Hospital.is_active == True).options(selectinload(Hospital.departments))
    if search:
        query = query.where(Hospital.name.ilike(f"%{search}%"))

    result = await db.execute(query)
    hospitals = result.scalars().unique().all()

    return [
        HospitalResponse(
            id=h.id,
            name=h.name,
            address=h.address,
            departments=[d.name for d in h.departments if d.is_active],
            offers_priority=h.offers_priority,
            has_emergency=h.has_emergency,
        )
        for h in hospitals
    ]


@router.get("/{hospital_id}/doctors", response_model=list[DoctorResponse])
async def list_doctors(
    hospital_id: int,
    department: str | None = None,
    db: AsyncSession = Depends(get_db),
):
    """List doctors at a hospital, optionally filtered by department."""
    query = (
        select(Doctor)
        .join(Department)
        .where(Department.hospital_id == hospital_id, Doctor.is_active == True)
    )
    if department:
        query = query.where(Department.name.ilike(f"%{department}%"))

    result = await db.execute(query.options(selectinload(Doctor.department)))
    doctors = result.scalars().all()

    return [
        DoctorResponse(
            id=d.id,
            name=d.name,
            qualification=d.qualification,
            experience_years=d.experience_years,
            consultation_fee=d.consultation_fee,
            department=d.department.name,
        )
        for d in doctors
    ]


@router.get("/doctors/{doctor_id}/slots", response_model=list[OPDSlotResponse])
async def list_slots(
    doctor_id: int,
    slot_date: date | None = None,
    db: AsyncSession = Depends(get_db),
):
    """List available OPD slots for a doctor."""
    query = select(OPDSlot).where(OPDSlot.doctor_id == doctor_id, OPDSlot.is_available == True)
    if slot_date:
        query = query.where(OPDSlot.slot_date == slot_date)

    result = await db.execute(query.order_by(OPDSlot.slot_date, OPDSlot.start_time))
    slots = result.scalars().all()

    return [
        OPDSlotResponse(
            id=s.id,
            slot_date=s.slot_date,
            start_time=s.start_time,
            end_time=s.end_time,
            is_available=s.booked_count < s.max_patients,
            has_priority_slots=s.priority_booked < s.priority_slots,
        )
        for s in slots
    ]


@router.post("/opd/book", response_model=OPDBookingResponse)
async def book_opd(
    req: OPDBookingRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Book an OPD slot, optionally with priority."""
    result = await db.execute(
        select(OPDSlot)
        .where(OPDSlot.id == req.slot_id)
        .options(selectinload(OPDSlot.doctor).selectinload(Doctor.department).selectinload(Department.hospital))
    )
    slot = result.scalar_one_or_none()
    if not slot:
        raise HTTPException(status_code=404, detail="Slot not found")

    if slot.booked_count >= slot.max_patients:
        raise HTTPException(status_code=409, detail="Slot is fully booked")

    if req.is_priority and slot.priority_booked >= slot.priority_slots:
        raise HTTPException(status_code=409, detail="No priority slots available")

    senior_id = req.senior_id or user.id
    priority_fee = 200.0 if req.is_priority else 0

    # Generate token number
    prefix = "P" if req.is_priority else "T"
    token_num = slot.priority_booked + 1 if req.is_priority else slot.booked_count + 1
    token = f"{prefix}-{token_num:02d}"

    booking = OPDBooking(
        senior_id=senior_id,
        slot_id=slot.id,
        booked_by_user_id=user.id,
        is_priority=req.is_priority,
        priority_fee=priority_fee,
        token_number=token,
    )
    db.add(booking)

    slot.booked_count += 1
    if req.is_priority:
        slot.priority_booked += 1

    await db.commit()
    await db.refresh(booking)

    doctor = slot.doctor
    dept = doctor.department
    hospital = dept.hospital

    return OPDBookingResponse(
        id=booking.id,
        hospital_name=hospital.name,
        department=dept.name,
        doctor_name=doctor.name,
        slot_date=slot.slot_date,
        start_time=slot.start_time,
        is_priority=booking.is_priority,
        token_number=booking.token_number,
        priority_fee=booking.priority_fee,
        status=booking.status,
    )
