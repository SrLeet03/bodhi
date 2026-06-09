import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/academia_theme.dart';

// Onboarding
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/voice_enrol_screen.dart';
import 'screens/onboarding/role_select_screen.dart';
import 'screens/onboarding/voice_unlock_screen.dart';
import 'screens/onboarding/pin_screen.dart';
import 'screens/onboarding/unlock_success_screen.dart';

// Home
import 'screens/home/home_screen.dart';

// Services
import 'screens/services/yoga_screen.dart';
import 'screens/services/nursing_screen.dart';
import 'screens/services/physio_screen.dart';
import 'screens/services/acupressure_screen.dart';
import 'screens/services/car_ride_screen.dart';
import 'screens/services/medicine_screen.dart';
import 'screens/services/grocery_screen.dart';
import 'screens/services/kitchen_waste_screen.dart';
import 'screens/services/doctor_screen.dart';

// Booking flow
import 'screens/booking/tracking_screen.dart';
import 'screens/booking/payment_screen.dart';
import 'screens/booking/completed_screen.dart';

// Hospital / OPD
import 'screens/hospital/hospital_list_screen.dart';
import 'screens/hospital/opd_booking_screen.dart';
import 'screens/hospital/opd_confirmed_screen.dart';

// Family app
import 'screens/family/family_dashboard_screen.dart';
import 'screens/family/activity_screen.dart';
import 'screens/family/emergency_screen.dart';

// Provider app
import 'screens/provider/provider_job_screen.dart';
import 'screens/provider/provider_verify_screen.dart';
import 'screens/provider/provider_earnings_screen.dart';

void main() {
  runApp(const ProviderScope(child: BodhiApp()));
}

class BodhiApp extends StatelessWidget {
  const BodhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bodhi — Sarve Santu Niramaya',
      debugShowCheckedModeBanner: false,
      theme: AcademiaTheme.theme,
      initialRoute: '/',
      routes: {
        // ── Onboarding ──────────────────────────────────────────
        '/': (context) => const SplashScreen(),
        '/voice-enrol': (context) => const VoiceEnrolScreen(),
        '/role-select': (context) => const RoleSelectScreen(),
        '/voice-unlock': (context) => const VoiceUnlockScreen(),
        '/pin': (context) => const PinScreen(),
        '/unlock-success': (context) => const UnlockSuccessScreen(),

        // ── Home ────────────────────────────────────────────────
        '/home': (context) => const HomeScreen(),

        // ── Services (9 tiles) ──────────────────────────────────
        '/yoga': (context) => const YogaScreen(),
        '/physio': (context) => const PhysioScreen(),
        '/acupressure': (context) => const AcupressureScreen(),
        '/nursing': (context) => const NursingScreen(),
        '/car': (context) => const CarRideScreen(),
        '/medicines': (context) => const MedicineScreen(),
        '/groceries': (context) => const GroceryScreen(),
        '/doctor': (context) => const DoctorScreen(),
        '/kitchen-waste': (context) => const KitchenWasteScreen(),

        // ── Hospital / OPD ──────────────────────────────────────
        '/hospitals': (context) => const HospitalListScreen(),
        '/opd-booking': (context) => const OpdBookingScreen(),
        '/opd-confirmed': (context) => const OpdConfirmedScreen(),

        // ── Booking flow ────────────────────────────────────────
        '/tracking': (context) => const TrackingScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/completed': (context) => const CompletedScreen(),

        // ── Family app ──────────────────────────────────────────
        '/family-dashboard': (context) => const FamilyDashboardScreen(),
        '/family-activity': (context) => const ActivityScreen(),
        '/emergency': (context) => const EmergencyScreen(),

        // ── Provider app ────────────────────────────────────────
        '/provider-job': (context) => const ProviderJobScreen(),
        '/provider-verify': (context) => const ProviderVerifyScreen(),
        '/provider-earnings': (context) => const ProviderEarningsScreen(),
      },
    );
  }
}
