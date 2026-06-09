import enum
from datetime import datetime, timezone
from sqlalchemy import String, Integer, Float, DateTime, Enum, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.service import ServiceType


class BookingStatus(str, enum.Enum):
    PENDING = "pending"
    PROVIDER_ASSIGNED = "provider_assigned"
    PROVIDER_EN_ROUTE = "provider_en_route"
    PROVIDER_ARRIVED = "provider_arrived"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class BookingSource(str, enum.Enum):
    APP = "app"            # Senior booked via app
    VOICE = "voice"        # Senior booked via voice command
    FAMILY = "family"      # Family member booked
    CALL_CENTER = "call_center"  # Call center agent booked


class Booking(Base):
    __tablename__ = "bookings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    senior_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    provider_id: Mapped[int | None] = mapped_column(ForeignKey("providers.id"), nullable=True)
    service_type: Mapped[ServiceType] = mapped_column(Enum(ServiceType), nullable=False)
    service_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[BookingStatus] = mapped_column(Enum(BookingStatus), default=BookingStatus.PENDING)
    source: Mapped[BookingSource] = mapped_column(Enum(BookingSource), default=BookingSource.APP)
    booked_by_user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    # Scheduling
    scheduled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    duration_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # Location
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    latitude: Mapped[float | None] = mapped_column(nullable=True)
    longitude: Mapped[float | None] = mapped_column(nullable=True)

    # Pricing
    base_price: Mapped[float] = mapped_column(Float, nullable=False)
    final_price: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Verification
    otp_code: Mapped[str | None] = mapped_column(String(6), nullable=True)
    otp_verified: Mapped[bool] = mapped_column(default=False)

    # Preferences
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)  # Care notes, allergies, etc.
    preferred_gender: Mapped[str | None] = mapped_column(String(10), nullable=True)

    # Rating
    rating: Mapped[int | None] = mapped_column(Integer, nullable=True)  # 1-5
    review: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # Relationships
    status_logs: Mapped[list["BookingStatusLog"]] = relationship(back_populates="booking", cascade="all, delete-orphan")


class BookingStatusLog(Base):
    __tablename__ = "booking_status_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    booking_id: Mapped[int] = mapped_column(ForeignKey("bookings.id"), nullable=False, index=True)
    status: Mapped[BookingStatus] = mapped_column(Enum(BookingStatus), nullable=False)
    changed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    note: Mapped[str | None] = mapped_column(Text, nullable=True)

    booking: Mapped["Booking"] = relationship(back_populates="status_logs")
