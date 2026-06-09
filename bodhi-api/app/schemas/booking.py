from datetime import datetime
from pydantic import BaseModel


class BookingCreateRequest(BaseModel):
    service_type: str
    service_id: int | None = None
    senior_id: int | None = None  # If family member is booking
    scheduled_at: datetime | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    notes: str | None = None
    preferred_gender: str | None = None
    delivery_mode: str = "at_home"


class BookingResponse(BaseModel):
    id: int
    service_type: str
    status: str
    provider_name: str | None = None
    scheduled_at: datetime | None = None
    base_price: float
    otp_code: str | None = None
    created_at: datetime

    class Config:
        from_attributes = True


class BookingRateRequest(BaseModel):
    rating: int  # 1-5
    review: str | None = None


class BookingStatusUpdate(BaseModel):
    status: str
    note: str | None = None
