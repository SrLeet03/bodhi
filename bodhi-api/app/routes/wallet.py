from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.payment import Wallet, WalletTransaction

router = APIRouter(prefix="/wallet", tags=["wallet"])


@router.get("/")
async def get_wallet(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """Get wallet balance and settings."""
    result = await db.execute(select(Wallet).where(Wallet.user_id == user.id))
    wallet = result.scalar_one_or_none()

    if not wallet:
        # Auto-create wallet for new users
        wallet = Wallet(user_id=user.id, balance=0)
        db.add(wallet)
        await db.commit()
        await db.refresh(wallet)

    return {
        "balance": wallet.balance,
        "auto_reload": wallet.auto_reload,
        "auto_reload_amount": wallet.auto_reload_amount,
        "auto_reload_threshold": wallet.auto_reload_threshold,
    }


@router.post("/add-funds")
async def add_funds(
    amount: float,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Add funds to wallet (family member tops up senior's wallet)."""
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")

    result = await db.execute(select(Wallet).where(Wallet.user_id == user.id))
    wallet = result.scalar_one_or_none()

    if not wallet:
        wallet = Wallet(user_id=user.id, balance=0)
        db.add(wallet)
        await db.flush()

    wallet.balance += amount
    txn = WalletTransaction(
        wallet_id=wallet.id,
        amount=amount,
        description="Funds added",
    )
    db.add(txn)
    await db.commit()

    return {"balance": wallet.balance, "added": amount}


@router.get("/transactions")
async def get_transactions(
    limit: int = 20,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get wallet transaction history."""
    result = await db.execute(select(Wallet).where(Wallet.user_id == user.id))
    wallet = result.scalar_one_or_none()
    if not wallet:
        return []

    result = await db.execute(
        select(WalletTransaction)
        .where(WalletTransaction.wallet_id == wallet.id)
        .order_by(desc(WalletTransaction.created_at))
        .limit(limit)
    )
    txns = result.scalars().all()

    return [
        {
            "id": t.id,
            "amount": t.amount,
            "description": t.description,
            "created_at": t.created_at.isoformat(),
        }
        for t in txns
    ]


@router.patch("/settings")
async def update_wallet_settings(
    auto_reload: bool | None = None,
    auto_reload_amount: float | None = None,
    auto_reload_threshold: float | None = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update wallet auto-reload settings."""
    result = await db.execute(select(Wallet).where(Wallet.user_id == user.id))
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")

    if auto_reload is not None:
        wallet.auto_reload = auto_reload
    if auto_reload_amount is not None:
        wallet.auto_reload_amount = auto_reload_amount
    if auto_reload_threshold is not None:
        wallet.auto_reload_threshold = auto_reload_threshold

    await db.commit()
    return {"message": "Settings updated"}
