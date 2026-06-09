"""
Seed the database with initial service categories, sample hospitals, and departments.
Run: python -m scripts.seed_data
"""
import asyncio
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import engine, async_session, Base
from app.models.service import ServiceCategory, Service, ServiceType, DeliveryMode
from app.models.hospital import Hospital, Department, Doctor
from app.models.user import User, UserRole


async def seed():
    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session() as db:
        # ── Service Categories ──────────────────────────────────────
        categories = [
            ServiceCategory(name="Yoga", service_type=ServiceType.YOGA, icon="🧘", display_order=1,
                            description="Expert yoga trainers at your home or online"),
            ServiceCategory(name="Physiotherapy", service_type=ServiceType.PHYSIOTHERAPY, icon="💪", display_order=2,
                            description="Licensed physiotherapists for rehabilitation"),
            ServiceCategory(name="Acupressure", service_type=ServiceType.ACUPRESSURE, icon="🖐️", display_order=3,
                            description="Traditional acupressure therapy"),
            ServiceCategory(name="Nursing Care", service_type=ServiceType.NURSING, icon="❤️", display_order=4,
                            description="Trained caregivers for daily assistance"),
            ServiceCategory(name="Hospital OPD", service_type=ServiceType.HOSPITAL_OPD, icon="🏥", display_order=5,
                            description="Book OPD appointments with priority access"),
            ServiceCategory(name="Doctor Consult", service_type=ServiceType.DOCTOR_CONSULT, icon="👨‍⚕️", display_order=6,
                            description="Video/audio consultations with specialists"),
            ServiceCategory(name="Car Ride", service_type=ServiceType.CAR_RIDE, icon="🚗", display_order=7,
                            description="Chauffeur-driven rides for errands"),
            ServiceCategory(name="Medicines", service_type=ServiceType.MEDICINES, icon="💊", display_order=8,
                            description="Medicine delivery to your doorstep"),
            ServiceCategory(name="Groceries", service_type=ServiceType.GROCERIES, icon="🛒", display_order=9,
                            description="Grocery delivery powered by Blinkit"),
            ServiceCategory(name="Kitchen Waste", service_type=ServiceType.KITCHEN_WASTE, icon="♻️", display_order=10,
                            description="Daily kitchen waste collection"),
        ]
        db.add_all(categories)
        await db.flush()

        # ── Services within categories ──────────────────────────────
        yoga_cat = categories[0]
        services = [
            # Yoga
            Service(category_id=yoga_cat.id, name="At home session", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=150, duration_minutes=60, price_unit="per_session"),
            Service(category_id=yoga_cat.id, name="Online private session", delivery_mode=DeliveryMode.ONLINE_PRIVATE,
                    base_price=80, duration_minutes=60, price_unit="per_session"),
            Service(category_id=yoga_cat.id, name="Online group session", delivery_mode=DeliveryMode.ONLINE_GROUP,
                    base_price=40, duration_minutes=60, price_unit="per_session"),
            # Nursing
            Service(category_id=categories[3].id, name="Bathing assistance", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=200, duration_minutes=60, price_unit="per_session"),
            Service(category_id=categories[3].id, name="Body cleaning", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=150, duration_minutes=45, price_unit="per_session"),
            Service(category_id=categories[3].id, name="Cooking assistance", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=180, duration_minutes=90, price_unit="per_session"),
            Service(category_id=categories[3].id, name="Massage therapy", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=250, duration_minutes=60, price_unit="per_session"),
            # Physio
            Service(category_id=categories[1].id, name="Joint mobility", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=200, duration_minutes=45, price_unit="per_session"),
            Service(category_id=categories[1].id, name="Post-surgery rehab", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=250, duration_minutes=60, price_unit="per_session"),
            Service(category_id=categories[1].id, name="Balance training", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=180, duration_minutes=30, price_unit="per_session"),
            Service(category_id=categories[1].id, name="Pain management", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=200, duration_minutes=45, price_unit="per_session"),
            # Acupressure
            Service(category_id=categories[2].id, name="Full body therapy", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=200, duration_minutes=60, price_unit="per_session"),
            Service(category_id=categories[2].id, name="Joint pain focus", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=180, duration_minutes=45, price_unit="per_session"),
            Service(category_id=categories[2].id, name="Headache & migraine", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=150, duration_minutes=30, price_unit="per_session"),
            # Car ride
            Service(category_id=categories[6].id, name="Local errand ride", delivery_mode=DeliveryMode.AT_HOME,
                    base_price=15, price_unit="per_km"),
            # Kitchen waste
            Service(category_id=categories[9].id, name="Daily pickup", delivery_mode=DeliveryMode.PICKUP,
                    base_price=15, price_unit="per_day"),
            Service(category_id=categories[9].id, name="Weekly plan", delivery_mode=DeliveryMode.PICKUP,
                    base_price=80, price_unit="per_week"),
            Service(category_id=categories[9].id, name="Monthly plan", delivery_mode=DeliveryMode.PICKUP,
                    base_price=250, price_unit="per_month"),
        ]
        db.add_all(services)

        # ── Hospitals ───────────────────────────────────────────────
        hospitals = [
            Hospital(name="Max Super Speciality", address="Civil Lines, Roorkee",
                     latitude=29.8643, longitude=77.8880, phone="+91-1332-274000",
                     has_emergency=True, offers_priority=True),
            Hospital(name="Roorkee Civil Hospital", address="Station Road, Roorkee",
                     latitude=29.8610, longitude=77.8930, phone="+91-1332-272000",
                     has_emergency=True, offers_priority=False),
            Hospital(name="Shri Mahant Indiresh Hospital", address="Dehradun Road",
                     latitude=29.8700, longitude=77.8800, phone="+91-1332-276000",
                     has_emergency=True, offers_priority=True),
            Hospital(name="Apex Nursing Home", address="Clock Tower, Roorkee",
                     latitude=29.8590, longitude=77.8870, phone="+91-1332-271000",
                     has_emergency=False, offers_priority=False),
        ]
        db.add_all(hospitals)
        await db.flush()

        # ── Departments & Doctors ───────────────────────────────────
        max_hosp = hospitals[0]
        departments = [
            Department(hospital_id=max_hosp.id, name="Cardiology"),
            Department(hospital_id=max_hosp.id, name="Orthopaedics"),
            Department(hospital_id=max_hosp.id, name="Neurology"),
            Department(hospital_id=hospitals[1].id, name="General Medicine"),
            Department(hospital_id=hospitals[1].id, name="Emergency"),
            Department(hospital_id=hospitals[2].id, name="Cardiology"),
            Department(hospital_id=hospitals[2].id, name="ENT"),
        ]
        db.add_all(departments)
        await db.flush()

        doctors = [
            Doctor(department_id=departments[0].id, name="Dr. S. Mehta",
                   qualification="MD, DM Cardiology", experience_years=15, consultation_fee=500),
            Doctor(department_id=departments[0].id, name="Dr. R. Kapoor",
                   qualification="MBBS, MD", experience_years=10, consultation_fee=400),
            Doctor(department_id=departments[1].id, name="Dr. A. Sharma",
                   qualification="MS Ortho", experience_years=12, consultation_fee=450),
            Doctor(department_id=departments[2].id, name="Dr. P. Singh",
                   qualification="DM Neurology", experience_years=8, consultation_fee=600),
            Doctor(department_id=departments[3].id, name="Dr. V. Gupta",
                   qualification="MBBS, MD", experience_years=20, consultation_fee=300),
            Doctor(department_id=departments[5].id, name="Dr. N. Joshi",
                   qualification="MD, DM Cardiology", experience_years=18, consultation_fee=550),
        ]
        db.add_all(doctors)

        # ── Demo user (for testing) ─────────────────────────────────
        demo_user = User(
            phone="+91-9876543210",
            name="Sharma ji",
            role=UserRole.SENIOR,
            address="Civil Lines, Roorkee",
            latitude=29.8643,
            longitude=77.8880,
        )
        db.add(demo_user)

        demo_family = User(
            phone="+91-9876543211",
            name="Rajesh Sharma",
            role=UserRole.FAMILY,
            address="Delhi",
        )
        db.add(demo_family)

        await db.commit()
        print("✓ Seed data inserted successfully!")
        print(f"  → {len(categories)} service categories")
        print(f"  → {len(services)} services")
        print(f"  → {len(hospitals)} hospitals")
        print(f"  → {len(departments)} departments")
        print(f"  → {len(doctors)} doctors")
        print(f"  → 2 demo users (senior: +91-9876543210, family: +91-9876543211)")


if __name__ == "__main__":
    asyncio.run(seed())
