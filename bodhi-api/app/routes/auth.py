import random

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import hash_password, verify_password, create_access_token, get_current_user
from app.core.redis import OTPStore, get_otp_store
from app.models.user import User, VoicePrint, UserRole
from app.schemas.auth import (
    PhoneOTPRequest, OTPVerifyRequest, RegisterRequest,
    PINSetRequest, PINVerifyRequest, VoiceEnrolRequest, TokenResponse,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/send-otp")
async def send_otp(req: PhoneOTPRequest, otp_store: OTPStore = Depends(get_otp_store)):
    """Send OTP to phone number for login/registration."""
    otp = f"{random.randint(1000, 9999)}"
    await otp_store.set(req.phone, otp)
    # TODO: Integrate SMS gateway (MSG91, Twilio, etc.)
    return {"message": "OTP sent", "otp_debug": otp}  # Remove otp_debug in production


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    req: OTPVerifyRequest,
    db: AsyncSession = Depends(get_db),
    otp_store: OTPStore = Depends(get_otp_store),
):
    """Verify OTP and return JWT. Creates user if first time."""
    stored = await otp_store.get(req.phone)
    if not stored or stored != req.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    await otp_store.delete(req.phone)

    result = await db.execute(select(User).where(User.phone == req.phone))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="User not registered. Call /auth/register first.")

    token = create_access_token({"sub": str(user.id), "role": user.role.value})
    return TokenResponse(access_token=token, user_id=user.id, role=user.role.value, name=user.name)


@router.post("/register", response_model=TokenResponse)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register a new user (senior, family, or provider)."""
    existing = await db.execute(select(User).where(User.phone == req.phone))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Phone already registered")

    user = User(
        phone=req.phone,
        name=req.name,
        role=UserRole(req.role),
        address=req.address,
        is_smartphone_user=req.is_smartphone_user,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    token = create_access_token({"sub": str(user.id), "role": user.role.value})
    return TokenResponse(access_token=token, user_id=user.id, role=user.role.value, name=user.name)


@router.post("/set-pin")
async def set_pin(req: PINSetRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Set a 4-digit PIN for fallback authentication."""
    if len(req.pin) != 4 or not req.pin.isdigit():
        raise HTTPException(status_code=400, detail="PIN must be exactly 4 digits")
    user.pin_hash = hash_password(req.pin)
    await db.commit()
    return {"message": "PIN set successfully"}


@router.post("/verify-pin", response_model=TokenResponse)
async def verify_pin(req: PINVerifyRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate with phone + PIN (fallback when voice fails)."""
    result = await db.execute(select(User).where(User.phone == req.phone))
    user = result.scalar_one_or_none()
    if not user or not user.pin_hash:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not verify_password(req.pin, user.pin_hash):
        raise HTTPException(status_code=401, detail="Invalid PIN")

    token = create_access_token({"sub": str(user.id), "role": user.role.value})
    return TokenResponse(access_token=token, user_id=user.id, role=user.role.value, name=user.name)


@router.post("/voice/enrol")
async def voice_enrol(
    sample_number: int,
    audio: UploadFile = File(...),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Upload a voice sample for enrolment (3 samples needed)."""
    if sample_number not in (1, 2, 3):
        raise HTTPException(status_code=400, detail="sample_number must be 1, 2, or 3")

    # TODO: Process audio, extract embedding, store to S3
    path = f"voice_prints/{user.id}/sample_{sample_number}.wav"

    # Upsert voice print record
    result = await db.execute(
        select(VoicePrint).where(VoicePrint.user_id == user.id, VoicePrint.sample_number == sample_number)
    )
    vp = result.scalar_one_or_none()
    if vp:
        vp.embedding_path = path
    else:
        vp = VoicePrint(user_id=user.id, embedding_path=path, sample_number=sample_number)
        db.add(vp)
    await db.commit()

    # Check if all 3 samples collected
    result = await db.execute(select(VoicePrint).where(VoicePrint.user_id == user.id))
    count = len(result.scalars().all())

    return {"message": f"Sample {sample_number} recorded", "samples_collected": count, "enrolment_complete": count >= 3}


@router.post("/voice/verify", response_model=TokenResponse)
async def voice_verify(
    phone: str,
    audio: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Authenticate using voice. Compares against stored voiceprint."""
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # TODO: Extract embedding from audio, compare with stored embeddings
    # For now, always succeed (replace with real voice matching)
    match_score = 0.92  # Placeholder

    if match_score < 0.85:
        raise HTTPException(status_code=401, detail="Voice not recognized")

    token = create_access_token({"sub": str(user.id), "role": user.role.value})
    return TokenResponse(access_token=token, user_id=user.id, role=user.role.value, name=user.name)
