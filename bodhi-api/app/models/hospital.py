import enum
from datetime import datetime, date, time, timezone
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Date, Time, Enum, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Hospital(Base):
    __tablename__ = "hospitals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    address: Mapped[str] = mapped_column(Text, nullable=False)
    city: Mapped[str] = mapped_column(String(50), default="Roorkee")
    latitude: Mapped[float | None] = mapped_column(nullable=True)
    longitude: Mapped[float | None] = mapped_column(nullable=True)
    phone: Mapped[str | None] = mapped_column(String(15), nullable=True)
    has_emergency: Mapped[bool] = mapped_column(Boolean, default=False)
    offers_priority: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    departments: Mapped[list["Department"]] = relationship(back_populates="hospital", cascade="all, delete-orphan")


class Department(Base):
    __tablename__ = "departments"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    hospital_id: Mapped[int] = mapped_column(ForeignKey("hospitals.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    hospital: Mapped["Hospital"] = relationship(back_populates="departments")
    doctors: Mapped[list["Doctor"]] = relationship(back_populates="department", cascade="all, delete-orphan")


class Doctor(Base):
    __tablename__ = "doctors"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    qualification: Mapped[str | None] = mapped_column(String(200), nullable=True)
    experience_years: Mapped[int] = mapped_column(Integer, default=0)
    consultation_fee: Mapped[float] = mapped_column(Float, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    department: Mapped["Department"] = relationship(back_populates="doctors")
    slots: Mapped[list["OPDSlot"]] = relationship(back_populates="doctor", cascade="all, delete-orphan")


class OPDSlot(Base):
    __tablename__ = "opd_slots"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    doctor_id: Mapped[int] = mapped_column(ForeignKey("doctors.id"), nullable=False, index=True)
    slot_date: Mapped[date] = mapped_column(Date, nullable=False)
    start_time: Mapped[time] = mapped_column(Time, nullable=False)
    end_time: Mapped[time] = mapped_column(Time, nullable=False)
    max_patients: Mapped[int] = mapped_column(Integer, default=1)
    booked_count: Mapped[int] = mapped_column(Integer, default=0)
    priority_slots: Mapped[int] = mapped_column(Integer, default=2)  # Reserved priority slots
    priority_booked: Mapped[int] = mapped_column(Integer, default=0)
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)

    doctor: Mapped["Doctor"] = relationship(back_populates="slots")


class OPDBooking(Base):
    __tablename__ = "opd_bookings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    senior_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    slot_id: Mapped[int] = mapped_column(ForeignKey("opd_slots.id"), nullable=False)
    booked_by_user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    is_priority: Mapped[bool] = mapped_column(Boolean, default=False)
    priority_fee: Mapped[float] = mapped_column(Float, default=0)
    token_number: Mapped[str | None] = mapped_column(String(10), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="confirmed")  # confirmed, cancelled, completed
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
