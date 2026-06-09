import enum
from datetime import datetime, timezone
from sqlalchemy import String, Integer, Boolean, DateTime, Enum, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class UserRole(str, enum.Enum):
    SENIOR = "senior"
    FAMILY = "family"
    PROVIDER = "provider"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    phone: Mapped[str] = mapped_column(String(15), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), nullable=False)
    pin_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    city: Mapped[str] = mapped_column(String(50), default="Roorkee")
    latitude: Mapped[float | None] = mapped_column(nullable=True)
    longitude: Mapped[float | None] = mapped_column(nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_smartphone_user: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    # Relationships
    voice_prints: Mapped[list["VoicePrint"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    family_links: Mapped[list["FamilyLink"]] = relationship(
        back_populates="senior", foreign_keys="FamilyLink.senior_id"
    )


class VoicePrint(Base):
    """Stored voice embeddings for voice-based authentication."""
    __tablename__ = "voice_prints"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    embedding_path: Mapped[str] = mapped_column(String(500), nullable=False)  # S3/local path to voice embedding
    sample_number: Mapped[int] = mapped_column(Integer, nullable=False)  # 1, 2, or 3
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user: Mapped["User"] = relationship(back_populates="voice_prints")


class FamilyLink(Base):
    """Links a family member to a senior citizen they care for."""
    __tablename__ = "family_links"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    senior_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    family_member_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    relationship_type: Mapped[str] = mapped_column(String(30), default="child")  # child, spouse, relative
    can_book: Mapped[bool] = mapped_column(Boolean, default=True)
    can_pay: Mapped[bool] = mapped_column(Boolean, default=True)
    receives_alerts: Mapped[bool] = mapped_column(Boolean, default=True)

    senior: Mapped["User"] = relationship(back_populates="family_links", foreign_keys=[senior_id])
    family_member: Mapped["User"] = relationship(foreign_keys=[family_member_id])
