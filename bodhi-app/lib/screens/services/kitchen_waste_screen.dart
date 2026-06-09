import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class KitchenWasteScreen extends ConsumerStatefulWidget {
  const KitchenWasteScreen({super.key});

  @override
  ConsumerState<KitchenWasteScreen> createState() => _KitchenWasteScreenState();
}

class _KitchenWasteScreenState extends ConsumerState<KitchenWasteScreen> {
  int _selectedPlan = 0; // 0=daily, 1=weekly, 2=monthly

  static const _plans = [
    ('Daily', '₹15/day', 'Pay per pickup'),
    ('Weekly', '₹80/week', 'Save ₹25/week'),
    ('Monthly', '₹250/month', 'Best value — save ₹200'),
  ];

  static const _timeSlots = [
    ('6:00 – 7:00 AM', Icons.wb_twilight),
    ('7:00 – 8:00 AM', Icons.wb_sunny),
    ('8:00 – 9:00 AM', Icons.light_mode),
  ];

  int _selectedSlot = 0;

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'kitchen_waste',
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
            const ScreenHeader(title: 'Kitchen Waste'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // How it works
                  AcademiaCard(
                    flourish: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline('HOW IT WORKS'),
                        const SizedBox(height: 12),
                        _StepRow('1', 'Keep waste at your door by chosen time'),
                        const SizedBox(height: 8),
                        _StepRow('2', 'Our collector picks it up daily'),
                        const SizedBox(height: 8),
                        _StepRow('3', 'Wet & dry waste segregated for you'),
                      ],
                    ),
                  ),

                  const OrnateDivider(),

                  // Plan selection
                  const Overline('CHOOSE A PLAN'),
                  const SizedBox(height: 12),

                  ...List.generate(_plans.length, (i) {
                    final (name, price, desc) = _plans[i];
                    final selected = _selectedPlan == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = i),
                        child: AcademiaCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AcademiaColors.brass : AcademiaColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AcademiaColors.brass,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(name, style: AcademiaTypography.heading(size: 16)),
                                        const Spacer(),
                                        Text(price, style: AcademiaTypography.heading(size: 16, color: AcademiaColors.brass)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const OrnateDivider(),

                  // Pickup time
                  const Overline('PREFERRED PICKUP TIME'),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_timeSlots.length, (i) {
                      final (time, icon) = _timeSlots[i];
                      final selected = _selectedSlot == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? AcademiaColors.brass.withValues(alpha: 0.15) : AcademiaColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? AcademiaColors.brass : AcademiaColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 18, color: selected ? AcademiaColors.brass : AcademiaColors.mutedForeground),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: AcademiaTypography.body(
                                  size: 14,
                                  color: selected ? AcademiaColors.brass : AcademiaColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Eco note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AcademiaColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AcademiaColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: AcademiaColors.brass, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waste is composted locally — your contribution helps keep Roorkee green.',
                            style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: bookingState.isLoading ? 'Subscribing...' : 'Subscribe now',
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

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  const _StepRow(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AcademiaColors.brass, width: 1.5),
          ),
          child: Center(
            child: Text(number, style: AcademiaTypography.label(size: 11, color: AcademiaColors.brass)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text, style: AcademiaTypography.body(size: 14)),
          ),
        ),
      ],
    );
  }
}
