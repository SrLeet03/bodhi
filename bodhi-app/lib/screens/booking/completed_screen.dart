import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/academia_widgets.dart';

class CompletedScreen extends ConsumerStatefulWidget {
  const CompletedScreen({super.key});

  @override
  ConsumerState<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends ConsumerState<CompletedScreen> with SingleTickerProviderStateMixin {
  int _rating = 4;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitRatingAndGoHome() async {
    final booking = ref.read(bookingProvider).activeBooking;
    final bookingId = booking?['id'] as int?;
    if (bookingId != null) {
      await ref.read(bookingProvider.notifier).rateBooking(bookingId, _rating);
    }
    ref.read(bookingProvider.notifier).clearActive();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider).activeBooking;
    final serviceType = booking?['service_type']?.toString().replaceAll('_', ' ') ?? 'Yoga';
    final price = booking?['base_price']?.toString() ?? '150';

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AcademiaColors.brassGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AcademiaColors.brass.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 44, color: AcademiaColors.background),
                ),
              ),
              const SizedBox(height: 24),
              Text('Service complete', style: AcademiaTypography.heading(size: 24)),
              const SizedBox(height: 8),
              Text(
                '$serviceType session',
                style: AcademiaTypography.body(size: 15, color: AcademiaColors.mutedForeground),
              ),
              const SizedBox(height: 20),
              const SizedBox(width: 200, child: OrnateDivider()),
              const SizedBox(height: 20),
              const Overline('RATE YOUR EXPERIENCE'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 36,
                        color: filled ? AcademiaColors.brass : AcademiaColors.muted,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              AcademiaCard(
                flourish: true,
                child: Column(
                  children: [
                    _SummaryRow('Service', serviceType),
                    const Divider(color: AcademiaColors.border, height: 20),
                    _SummaryRow('Paid', '₹$price'),
                  ],
                ),
              ),
              const Spacer(),
              BrassButton(
                label: 'Back to home',
                onPressed: _submitRatingAndGoHome,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground)),
        Text(value, style: AcademiaTypography.body(size: 14)),
      ],
    );
  }
}
