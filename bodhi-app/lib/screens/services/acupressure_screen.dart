import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class AcupressureScreen extends ConsumerStatefulWidget {
  const AcupressureScreen({super.key});

  @override
  ConsumerState<AcupressureScreen> createState() => _AcupressureScreenState();
}

class _AcupressureScreenState extends ConsumerState<AcupressureScreen> {
  static const _therapies = [
    ('Full body acupressure', Icons.pan_tool, '60 min · Complete session', '₹300'),
    ('Head & neck relief', Icons.face, '30 min · Stress & tension', '₹180'),
    ('Back & spine therapy', Icons.swap_vert, '45 min · Posture & pain', '₹250'),
    ('Foot reflexology', Icons.do_not_step, '30 min · Pressure points', '₹200'),
    ('Joint pain focused', Icons.accessibility_new, '45 min · Arthritis care', '₹280'),
  ];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'acupressure',
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
            const ScreenHeader(title: 'Acupressure'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('TRADITIONAL HEALING AT HOME'),
                  const SizedBox(height: 16),

                  ..._therapies.map((t) {
                    final (title, icon, sub, price) = t;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(icon: icon, title: title, subtitle: sub, trailing: price),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Monthly package
                  AcademiaCard(
                    flourish: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline('MONTHLY PACKAGE'),
                        const SizedBox(height: 8),
                        Text(
                          '8 sessions · ₹1,800',
                          style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Save ₹600 vs individual bookings',
                          style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: bookingState.isLoading ? 'Booking...' : 'Book a session',
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
