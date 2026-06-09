from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.redis import close_redis
from app.routes import auth, bookings, hospitals, emergency, services
from app.routes import payments, wallet, family, providers


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    yield
    # Shutdown
    await close_redis()


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Bodhi — Sarve Santu Niramaya. On-demand senior citizen care platform.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(auth.router)
app.include_router(services.router)
app.include_router(bookings.router)
app.include_router(hospitals.router)
app.include_router(emergency.router)
app.include_router(payments.router)
app.include_router(wallet.router)
app.include_router(family.router)
app.include_router(providers.router)


@app.get("/")
async def root():
    return {
        "app": "Bodhi",
        "tagline": "Sarve Santu Niramaya",
        "version": settings.APP_VERSION,
    }


@app.get("/health")
async def health():
    return {"status": "ok"}
