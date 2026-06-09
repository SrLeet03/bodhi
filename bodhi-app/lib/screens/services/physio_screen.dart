import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class PhysioScreen extends ConsumerStatefulWidget {
  const PhysioScreen({super.key});

  @override
  ConsumerState<PhysioScreen> createState() => _PhysioScreenState();
}

class _PhysioScreenState extends ConsumerState<PhysioScreen> {
  int _selectedDuration = 1;

  static const _therapies = [
    ('Post-surgery recovery', Icons.healing, 'Guided rehabilitation', '₹350'),
    ('Joint & muscle pain', Icons.fitness_center, 'Targeted relief therapy', '₹300'),
    ('Mobility exercises', Icons.directions_walk, 'Strength & flexibility', '₹250'),
    ('Stroke rehabilitation', Icons.psychology, 'Neuro-motor recovery', '₹400'),
  ];

  static const _durations = ['30 MIN', '45 MIN', '60 MIN'];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'physiotherapy',
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
            const ScreenHeader(title: 'Physiotherapy'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('AT YOUR HOME, BY A CERTIFIED THERAPIST'),
                  const SizedBox(height: 12),

                  // Trust badge
                  AcademiaCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AcademiaColors.brass, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Licensed physiotherapists · Home visits',
                          style: AcademiaTypography.body(size: 13, color: AcademiaColors.brass),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Overline('SELECT THERAPY TYPE'),
                  const SizedBox(height: 12),

                  ..._therapies.map((t) {
                    final (title, icon, sub, price) = t;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(icon: icon, title: title, subtitle: sub, trailing: price),
                    );
                  }),

                  const OrnateDivider(),
                  const Overline('SESSION DURATION'),
                  const SizedBox(height: 12),

                  Row(
                    children: List.generate(_durations.length, (i) {
                      final sel = _selectedDuration == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDuration = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? AcademiaColors.brass : AcademiaColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: sel ? AcademiaColors.brass : AcademiaColors.border),
                            ),
                            child: Text(
                              _durations[i],
                              style: AcademiaTypography.label(
                                size: 10,
                                color: sel ? AcademiaColors.background : AcademiaColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),
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
