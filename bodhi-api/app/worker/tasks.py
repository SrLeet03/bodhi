"""
Celery tasks for async operations.

Run worker: celery -A app.worker.celery_app worker --loglevel=info
"""
import asyncio
import logging

from app.worker.celery_app import celery_app

logger = logging.getLogger(__name__)


@celery_app.task(name="match_provider")
def match_provider(booking_id: int):
    """
    Find and assign the nearest available provider for a booking.

    Logic:
    1. Query all verified providers offering this service type
    2. Filter by online status and availability for the scheduled time
    3. If preferred_gender is set, filter accordingly
    4. Sort by distance from booking address
    5. Assign the closest available provider
    6. Update booking status to PROVIDER_ASSIGNED
    7. Send push notification to provider
    """
    logger.info(f"Matching provider for booking #{booking_id}")

    # Run async DB operations in sync celery context
    asyncio.run(_match_provider_async(booking_id))


async def _match_provider_async(booking_id: int):
    from sqlalchemy import select
    from app.core.database import async_session
    from app.models.booking import Booking, BookingStatus, BookingStatusLog
    from app.models.provider import Provider, ProviderService, VerificationStatus

    async with async_session() as db:
        result = await db.execute(select(Booking).where(Booking.id == booking_id))
        booking = result.scalar_one_or_none()
        if not booking or booking.status != BookingStatus.PENDING:
            logger.warning(f"Booking #{booking_id} not found or not pending")
            return

        # Find verified, online providers
        query = (
            select(Provider)
            .where(
                Provider.verification_status == VerificationStatus.VERIFIED,
                Provider.is_online == True,
            )
        )

        # Gender preference filter
        if booking.preferred_gender:
            from app.models.provider import Gender
            query = query.where(Provider.gender == Gender(booking.preferred_gender))

        result = await db.execute(query)
        providers = result.scalars().all()

        if not providers:
            logger.warning(f"No available providers for booking #{booking_id}")
            # TODO: Send notification to admin / expand search radius
            return

        # Simple distance sort (Euclidean for now, replace with haversine)
        if booking.latitude and booking.longitude:
            providers.sort(key=lambda p: (
                ((p.latitude or 0) - booking.latitude) ** 2 +
                ((p.longitude or 0) - booking.longitude) ** 2
            ))

        chosen = providers[0]
        booking.provider_id = chosen.id
        booking.status = BookingStatus.PROVIDER_ASSIGNED

        log = BookingStatusLog(
            booking_id=booking.id,
            status=BookingStatus.PROVIDER_ASSIGNED,
            note=f"Assigned to provider #{chosen.id}",
        )
        db.add(log)
        await db.commit()

        logger.info(f"Booking #{booking_id} assigned to provider #{chosen.id}")

        # Send push notification to provider
        send_push_notification.delay(
            chosen.user_id,
            "New booking assigned",
            f"You have a new {booking.service_type.value} booking",
        )


@celery_app.task(name="send_push_notification")
def send_push_notification(user_id: int, title: str, body: str):
    """
    Send FCM push notification to a user's device.

    TODO: Integrate with Firebase Cloud Messaging
    1. Look up user's FCM token from DB
    2. Send notification via Firebase Admin SDK
    """
    logger.info(f"[PUSH] To user #{user_id}: {title} — {body}")
    # TODO: Implement FCM integration
    # from firebase_admin import messaging
    # message = messaging.Message(
    #     notification=messaging.Notification(title=title, body=body),
    #     token=user_fcm_token,
    # )
    # messaging.send(message)


@celery_app.task(name="send_sms")
def send_sms(phone: str, message: str):
    """
    Send SMS to a phone number.

    TODO: Integrate with MSG91 or Twilio
    """
    logger.info(f"[SMS] To {phone}: {message}")
    # TODO: Implement SMS gateway
    # import httpx
    # httpx.post("https://api.msg91.com/...", json={...})


@celery_app.task(name="notify_family")
def notify_family(senior_id: int, event_type: str, details: str):
    """Send push notifications to all linked family members of a senior."""
    logger.info(f"[FAMILY] Notifying family of senior #{senior_id}: {event_type}")
    asyncio.run(_notify_family_async(senior_id, event_type, details))


async def _notify_family_async(senior_id: int, event_type: str, details: str):
    from sqlalchemy import select
    from app.core.database import async_session
    from app.models.user import FamilyLink

    async with async_session() as db:
        result = await db.execute(
            select(FamilyLink).where(
                FamilyLink.senior_id == senior_id,
                FamilyLink.receives_alerts == True,
            )
        )
        links = result.scalars().all()

        for link in links:
            send_push_notification.delay(
                link.family_member_id,
                event_type,
                details,
            )
