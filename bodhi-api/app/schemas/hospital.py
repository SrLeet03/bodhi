from datetime import date, time
from pydantic import BaseModel


class HospitalResponse(BaseModel):
    id: int
    name: str
    address: str
    departments: list[str]
    distance_km: float | None = None
    offers_priority: bool
    has_emergency: bool

    class Config:
        from_attributes = True


class DoctorResponse(BaseModel):
    id: int
    name: str
    qualification: str | None
    experience_years: int
    consultation_fee: float
    department: str

    class Config:
        from_attributes = True


class OPDSlotResponse(BaseModel):
    id: int
    slot_date: date
    start_time: time
    end_time: time
    is_available: bool
    has_priority_slots: bool


class OPDBookingRequest(BaseModel):
    slot_id: int
    senior_id: int | None = None
    is_priority: bool = False


class OPDBookingResponse(BaseModel):
    id: int
    hospital_name: str
    department: str
    doctor_name: str
    slot_date: date
    start_time: time
    is_priority: bool
    token_number: str | None
    priority_fee: float
    status: str

    class Config:
        from_attributes = True
