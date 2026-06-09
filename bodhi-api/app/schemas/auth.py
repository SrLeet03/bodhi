from pydantic import BaseModel


class PhoneOTPRequest(BaseModel):
    phone: str


class OTPVerifyRequest(BaseModel):
    phone: str
    otp: str


class RegisterRequest(BaseModel):
    phone: str
    name: str
    role: str  # senior, family, provider
    address: str | None = None
    is_smartphone_user: bool = True


class PINSetRequest(BaseModel):
    pin: str  # 4-digit PIN


class PINVerifyRequest(BaseModel):
    phone: str
    pin: str


class VoiceEnrolRequest(BaseModel):
    sample_number: int  # 1, 2, or 3


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    role: str
    name: str
