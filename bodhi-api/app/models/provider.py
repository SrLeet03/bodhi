import enum
from datetime import datetime, time, timezone
from sqlalchemy import String, Integer, Float, Boolean, DateTime, Time, Enum, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class VerificationStatus(str, enum.Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"


class Gender(str, enum.Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"


class Provider(Base):
    __tablename__ = "providers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, nullable=False)
    gender: Mapped[Gender] = mapped_column(Enum(Gender), nullable=False)
    verification_status: Mapped[VerificationStatus] = mapped_column(
        Enum(VerificationStatus), default=VerificationStatus.PENDING
    )
    police_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    aadhaar_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    experience_years: Mapped[int] = mapped_column(Integer, default=0)
    rating: Mapped[float] = mapped_column(Float, default=5.0)
    total_jobs: Mapped[int] = mapped_column(Integer, default=0)
    latitude: Mapped[float | None] = mapped_column(nullable=True)
    longitude: Mapped[float | None] = mapped_column(nullable=True)
    is_online: Mapped[bool] = mapped_column(Boolean, default=False)

    user: Mapped["User"] = relationship()  # noqa: F821
    services: Mapped[list["ProviderService"]] = relationship(back_populates="provider", cascade="all, delete-orphan")
    availability: Mapped[list["ProviderAvailability"]] = relationship(back_populates="provider", cascade="all, delete-orphan")


class ProviderService(Base):
    """Which services a provider offers."""
    __tablename__ = "provider_services"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    provider_id: Mapped[int] = mapped_column(ForeignKey("providers.id"), nullable=False)
    service_id: Mapped[int] = mapped_column(Integer, nullable=False)

    provider: Mapped["Provider"] = relationship(back_populates="services")


class ProviderAvailability(Base):
    __tablename__ = "provider_availability"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    provider_id: Mapped[int] = mapped_column(ForeignKey("providers.id"), nullable=False)
    day_of_week: Mapped[int] = mapped_column(Integer, nullable=False)  # 0=Mon, 6=Sun
    start_time: Mapped[time] = mapped_column(Time, nullable=False)
    end_time: Mapped[time] = mapped_column(Time, nullable=False)

    provider: Mapped["Provider"] = relationship(back_populates="availability")
