import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class DoctorScreen extends ConsumerStatefulWidget {
  const DoctorScreen({super.key});

  @override
  ConsumerState<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends ConsumerState<DoctorScreen> {
  static const _options = [
    ('Video consultation', Icons.videocam, 'Talk to a doctor now', '₹200'),
    ('Audio call', Icons.phone, 'Voice-only consultation', '₹150'),
    ('Book for later', Icons.calendar_today, 'Schedule a call', '₹200'),
  ];

  static const _specialities = [
    ('General physician', Icons.medical_services),
    ('Cardiologist', Icons.favorite),
    ('Orthopaedic', Icons.accessibility_new),
    ('Neurologist', Icons.psychology),
    ('Dermatologist', Icons.face),
    ('ENT specialist', Icons.hearing),
  ];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'doctor_consult',
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
            const ScreenHeader(title: 'Doctor Consult'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('ON CALL CONSULTATION'),
                  const SizedBox(height: 16),

                  ..._options.map((o) {
                    final (title, icon, sub, price) = o;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(icon: icon, title: title, subtitle: sub, trailing: price),
                    );
                  }),

                  const OrnateDivider(),
                  const Overline('SELECT SPECIALITY'),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                    ),
                    itemCount: _specialities.length,
                    itemBuilder: (context, i) {
                      final (name, icon) = _specialities[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AcademiaColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AcademiaColors.border, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: AcademiaColors.brass, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: AcademiaTypography.body(size: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Emergency doctor
                  AcademiaCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AcademiaColors.crimson,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.emergency, color: AcademiaColors.foreground, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency doctor', style: AcademiaTypography.heading(size: 16)),
                              Text(
                                'Connect instantly · No wait',
                                style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: AcademiaColors.crimson, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  BrassButton(
                    label: bookingState.isLoading ? 'Booking...' : 'Start consultation now',
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
