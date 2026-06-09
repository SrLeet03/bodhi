import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class NursingScreen extends ConsumerStatefulWidget {
  const NursingScreen({super.key});

  @override
  ConsumerState<NursingScreen> createState() => _NursingScreenState();
}

class _NursingScreenState extends ConsumerState<NursingScreen> {
  int _selectedGender = 0;

  static const _services = [
    ('Bathing assistance', Icons.bathtub, '₹200'),
    ('Body cleaning', Icons.cleaning_services, '₹150'),
    ('Cooking assistance', Icons.restaurant, '₹180'),
    ('Massage therapy', Icons.spa, '₹250'),
  ];

  static const _genderPrefs = ['Female', 'Male', 'No preference'];
  static const _genderValues = ['female', 'male', null];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'nursing',
      preferredGender: _genderValues[_selectedGender],
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
            const ScreenHeader(title: 'Nursing Care'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Verification badge
                  AcademiaCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AcademiaColors.brass, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'All caregivers are verified & trained',
                          style: AcademiaTypography.body(size: 14, color: AcademiaColors.brass),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Overline('SELECT A SERVICE'),
                  const SizedBox(height: 12),

                  ...List.generate(_services.length, (i) {
                    final (title, icon, price) = _services[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(icon: icon, title: title, trailing: price),
                    );
                  }),

                  const OrnateDivider(),

                  const Overline('CAREGIVER PREFERENCE'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_genderPrefs.length, (i) {
                      final sel = _selectedGender == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AcademiaColors.brass : AcademiaColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: sel ? AcademiaColors.brass : AcademiaColors.border),
                            ),
                            child: Text(
                              _genderPrefs[i].toUpperCase(),
                              style: AcademiaTypography.label(
                                size: 9,
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
                    label: bookingState.isLoading ? 'Booking...' : 'Book caregiver',
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
