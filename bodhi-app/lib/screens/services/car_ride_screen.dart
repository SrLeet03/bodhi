import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class CarRideScreen extends ConsumerStatefulWidget {
  const CarRideScreen({super.key});

  @override
  ConsumerState<CarRideScreen> createState() => _CarRideScreenState();
}

class _CarRideScreenState extends ConsumerState<CarRideScreen> {
  static const _destinations = [
    ('Market / Shopping', Icons.shopping_bag, 'Nearby markets'),
    ('Bank', Icons.account_balance, 'Banking services'),
    ('Hospital / Clinic', Icons.local_hospital, 'Medical visits'),
    ('Temple / Religious', Icons.temple_hindu, 'Places of worship'),
    ('Custom destination', Icons.pin_drop, 'Enter your address'),
  ];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'car_ride',
    );
    if (booking != null && mounted) {
      Navigator.pushNamed(context, '/tracking');
    } else if (mounted) {
      final error = ref.read(bookingProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Car Ride'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('CHAUFFEUR DRIVEN SERVICE'),
                  const SizedBox(height: 8),
                  Text('Where would you like to go?', style: AcademiaTypography.heading(size: 20)),
                  const SizedBox(height: 16),

                  ..._destinations.map((d) {
                    final (title, icon, sub) = d;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(icon: icon, title: title, subtitle: sub),
                    );
                  }),

                  const OrnateDivider(),

                  // Pricing card
                  AcademiaCard(
                    flourish: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline('PRICING'),
                        const SizedBox(height: 8),
                        Text(
                          '₹15/km · Minimum ₹100 · Wait time ₹2/min',
                          style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: bookingState.isLoading ? 'Booking...' : 'Call a car',
                    onPressed: bookingState.isLoading ? null : _onBookPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
