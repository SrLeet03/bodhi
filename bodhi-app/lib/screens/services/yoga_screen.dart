import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class YogaScreen extends ConsumerStatefulWidget {
  const YogaScreen({super.key});

  @override
  ConsumerState<YogaScreen> createState() => _YogaScreenState();
}

class _YogaScreenState extends ConsumerState<YogaScreen> {
  int _selectedOption = 0;
  int _selectedPlan = 0;

  static const _options = [
    ('At home', 'Personal session', '₹150'),
    ('Online, private', 'Video call session', '₹80'),
    ('Online, group', 'Shared session', '₹40'),
  ];

  static const _plans = ['Single', 'Weekly', 'Monthly'];

  static const _deliveryModes = ['at_home', 'online_private', 'online_group'];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'yoga',
      deliveryMode: _deliveryModes[_selectedOption],
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
            const ScreenHeader(title: 'Yoga Session'),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('AT YOUR HOME, BY AN EXPERT TRAINER'),
                  const SizedBox(height: 12),
                  Text('How would you like it?', style: AcademiaTypography.heading(size: 22)),
                  const SizedBox(height: 16),

                  // Options
                  ...List.generate(_options.length, (i) {
                    final (title, sub, price) = _options[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(
                        icon: Icons.self_improvement,
                        title: title,
                        subtitle: sub,
                        trailing: price,
                        selected: _selectedOption == i,
                        onTap: () => setState(() => _selectedOption = i),
                      ),
                    );
                  }),

                  const OrnateDivider(),

                  const Overline('PLAN'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_plans.length, (i) {
                      final sel = _selectedPlan == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPlan = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? AcademiaColors.brass : AcademiaColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: sel ? AcademiaColors.brass : AcademiaColors.border),
                            ),
                            child: Text(
                              _plans[i].toUpperCase(),
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
                    label: bookingState.isLoading ? 'Booking...' : 'Choose a time',
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
