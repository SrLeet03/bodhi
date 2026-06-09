# Bodhi — Sarve Santu Niramaya

On-demand senior citizen care platform for Roorkee, India. Three user roles — **Senior**, **Family Member**, and **Service Provider** — connected through a Flutter mobile app and FastAPI backend.

## Architecture

```
bodhi-api/          FastAPI backend (Python 3.11+)
bodhi-app/          Flutter frontend (Dart 3.5+)
```

### Backend Stack
- **FastAPI** + **Uvicorn** — async API server
- **PostgreSQL** + **asyncpg** — database
- **SQLAlchemy 2.0** — async ORM
- **Alembic** — database migrations
- **Redis** — OTP storage with TTL, Celery broker
- **Celery** — background tasks (provider matching, notifications)
- **JWT** — authentication (python-jose)

### Frontend Stack
- **Flutter 3.5+** with Material Design
- **Riverpod** — state management
- **Dio** — HTTP client with token interceptor
- **SharedPreferences** — session persistence
- Academia dark theme (mahogany, brass, serif typography)

## Features

| Senior | Family | Provider |
|--------|--------|----------|
| Voice/PIN unlock | Dashboard with senior activity | Job accept/decline |
| 9 home services (yoga, physio, nursing, car ride, medicine, grocery, doctor, kitchen waste, acupressure) | Wallet & payments | OTP verification at arrival |
| Hospital OPD booking | Emergency alerts | Earnings tracker |
| Real-time booking tracking | Emergency contact management | Schedule management |
| Emergency SOS button | | |

## Setup

### Prerequisites

- Python 3.11+
- Flutter SDK 3.5+
- PostgreSQL 14+
- Redis 7+

### Backend

```bash
cd bodhi-api

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your database credentials and secret key

# Create database
createdb bodhi

# Run migrations
alembic upgrade head

# Seed demo data (categories, services, hospitals, demo users)
python -m scripts.seed_data

# Start API server
uvicorn app.main:app --reload --port 8000

# (Optional) Start Celery worker for background tasks
celery -A app.worker.celery_app worker --loglevel=info
```

The API will be available at `http://localhost:8000`. Interactive docs at `http://localhost:8000/docs`.

### Frontend

```bash
cd bodhi-app

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

Update the API base URL in `lib/core/services/api_service.dart` if your backend is not running on `localhost:8000`.

### Demo Users (after seeding)

| Role | Phone |
|------|-------|
| Senior | +91-9876543210 |
| Family | +91-9876543211 |

## API Routes

| Prefix | Description |
|--------|-------------|
| `/auth` | OTP send/verify, registration, PIN, voice auth |
| `/services` | Service categories and listings |
| `/bookings` | Create, update status, rate, verify OTP |
| `/hospitals` | Hospital list, doctors, slots, OPD booking |
| `/emergency` | Trigger/resolve alerts, contacts |
| `/payments` | Create payment, confirm (cash/UPI/wallet) |
| `/wallet` | Balance, add funds, transactions |
| `/family` | Link seniors, view activity |
| `/providers` | Register, toggle online, view jobs/earnings |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string (asyncpg) |
| `SECRET_KEY` | JWT signing key |
| `REDIS_URL` | Redis connection URL |
| `SMS_API_KEY` | MSG91 API key (optional) |
| `OTP_EXPIRY_SECONDS` | OTP TTL in seconds (default: 300) |
| `BLINKIT_API_KEY` | Blinkit integration key (optional) |

## Project Structure

```
bodhi-api/
  app/
    core/         config, database, redis, security
    models/       user, booking, service, hospital, payment, emergency, provider
    routes/       auth, bookings, services, hospitals, emergency, payments, wallet, family, providers
    schemas/      pydantic request/response models
    worker/       celery app + tasks (provider matching, push notifications, SMS)
  alembic/        database migrations
  scripts/        seed_data.py

bodhi-app/
  lib/
    core/
      providers/  auth, booking, hospital, service, emergency (Riverpod)
      services/   api_service.dart (Dio HTTP client)
      theme/      academia_theme.dart
    screens/
      onboarding/ splash, voice_enrol, voice_unlock, pin, role_select, unlock_success
      home/       home_screen (senior dashboard)
      services/   yoga, physio, acupressure, nursing, car_ride, medicine, grocery, doctor, kitchen_waste
      booking/    tracking, payment, completed
      hospital/   hospital_list, opd_booking, opd_confirmed
      family/     family_dashboard, activity, emergency
      provider/   provider_job, provider_verify, provider_earnings
    widgets/      academia_widgets, screen_header
```

## License

Proprietary. All rights reserved.
