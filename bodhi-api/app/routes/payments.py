from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.payment import Payment, PaymentMethod, PaymentStatus, Wallet, WalletTransaction

router = APIRouter(prefix="/payments", tags=["payments"])


@router.post("/")
async def create_payment(
    amount: float,
    method: str,
    booking_id: int | None = None,
    opd_booking_id: int | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a payment record. For wallet payments, deducts from balance."""
    payment_method = PaymentMethod(method)

    if payment_method == PaymentMethod.WALLET:
        result = await db.execute(select(Wallet).where(Wallet.user_id == user.id))
        wallet = result.scalar_one_or_none()
        if not wallet or wallet.balance < amount:
            raise HTTPException(status_code=400, detail="Insufficient wallet balance")
        wallet.balance -= amount
        txn = WalletTransaction(
            wallet_id=wallet.id,
            amount=-amount,
            description=f"Payment for booking #{booking_id or opd_booking_id}",
        )
        db.add(txn)

    payment = Payment(
        user_id=user.id,
        amount=amount,
        method=payment_method,
        status=PaymentStatus.COMPLETED if payment_method == PaymentMethod.CASH else PaymentStatus.PENDING,
        booking_id=booking_id,
        opd_booking_id=opd_booking_id,
    )
    db.add(payment)
    await db.commit()
    await db.refresh(payment)

    # TODO: For UPI, initiate Razorpay order and return payment link
    return {
        "payment_id": payment.id,
        "amount": payment.amount,
        "method": payment.method.value,
        "status": payment.status.value,
    }


@router.post("/{payment_id}/confirm")
async def confirm_payment(
    payment_id: int,
    transaction_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Confirm a UPI/online payment with transaction ID (webhook or client callback)."""
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    payment.status = PaymentStatus.COMPLETED
    payment.transaction_id = transaction_id
    await db.commit()
    return {"message": "Payment confirmed", "status": "completed"}
