import enum
from sqlalchemy import String, Integer, Float, Boolean, Text, Enum
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class ServiceType(str, enum.Enum):
    YOGA = "yoga"
    PHYSIOTHERAPY = "physiotherapy"
    ACUPRESSURE = "acupressure"
    NURSING = "nursing"
    CAR_RIDE = "car_ride"
    MEDICINES = "medicines"
    GROCERIES = "groceries"
    DOCTOR_CONSULT = "doctor_consult"
    HOSPITAL_OPD = "hospital_opd"
    KITCHEN_WASTE = "kitchen_waste"


class DeliveryMode(str, enum.Enum):
    AT_HOME = "at_home"
    ONLINE_PRIVATE = "online_private"
    ONLINE_GROUP = "online_group"
    DELIVERY = "delivery"
    PICKUP = "pickup"


class ServiceCategory(Base):
    __tablename__ = "service_categories"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    service_type: Mapped[ServiceType] = mapped_column(Enum(ServiceType), unique=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    icon: Mapped[str] = mapped_column(String(10), default="⭐")  # Emoji icon
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    display_order: Mapped[int] = mapped_column(Integer, default=0)


class Service(Base):
    """Individual service offerings within a category."""
    __tablename__ = "services"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    category_id: Mapped[int] = mapped_column(Integer, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    delivery_mode: Mapped[DeliveryMode] = mapped_column(Enum(DeliveryMode), default=DeliveryMode.AT_HOME)
    base_price: Mapped[float] = mapped_column(Float, nullable=False)
    price_unit: Mapped[str] = mapped_column(String(20), default="per_session")  # per_session, per_hour, per_km, per_order
    duration_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
