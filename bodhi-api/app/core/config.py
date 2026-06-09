from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "Bodhi API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://bodhi:bodhi@localhost:5432/bodhi"

    # Auth
    SECRET_KEY: str = "change-me-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    ALGORITHM: str = "HS256"

    # Voice auth
    VOICE_SAMPLE_MIN_DURATION: float = 2.0  # seconds
    VOICE_MATCH_THRESHOLD: float = 0.85

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # External APIs
    BLINKIT_API_KEY: str = ""
    BLINKIT_API_URL: str = ""

    # SMS / OTP
    SMS_API_KEY: str = ""
    OTP_EXPIRY_SECONDS: int = 300

    # Emergency
    EMERGENCY_AMBULANCE_NUMBER: str = "108"

    class Config:
        env_file = ".env"


settings = Settings()
