import redis.asyncio as redis

from app.core.config import settings

_pool: redis.Redis | None = None


async def get_redis() -> redis.Redis:
    """Get or create Redis connection pool."""
    global _pool
    if _pool is None:
        _pool = redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _pool


async def close_redis():
    global _pool
    if _pool:
        await _pool.aclose()
        _pool = None


class OTPStore:
    """Redis-backed OTP store with automatic expiry."""

    KEY_PREFIX = "bodhi:otp:"

    def __init__(self, r: redis.Redis):
        self._r = r

    async def set(self, phone: str, otp: str):
        """Store OTP with TTL from settings."""
        await self._r.setex(
            f"{self.KEY_PREFIX}{phone}",
            settings.OTP_EXPIRY_SECONDS,
            otp,
        )

    async def get(self, phone: str) -> str | None:
        """Retrieve stored OTP (None if expired/missing)."""
        return await self._r.get(f"{self.KEY_PREFIX}{phone}")

    async def delete(self, phone: str):
        """Remove OTP after successful verification."""
        await self._r.delete(f"{self.KEY_PREFIX}{phone}")


async def get_otp_store() -> OTPStore:
    r = await get_redis()
    return OTPStore(r)
