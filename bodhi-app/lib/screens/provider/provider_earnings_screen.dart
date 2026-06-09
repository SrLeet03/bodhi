import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/academia_widgets.dart';

class ProviderEarningsScreen extends ConsumerStatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  ConsumerState<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends ConsumerState<ProviderEarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingProvider.notifier).loadBookings(status: 'completed'));
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingProvider).bookings;
    final totalEarnings = bookings.fold<double>(
      0,
      (sum, b) => sum + ((b['base_price'] as num?)?.toDouble() ?? 0),
    );

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with earnings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: AcademiaColors.backgroundAlt,
                border: Border(bottom: BorderSide(color: AcademiaColors.brass.withValues(alpha: 0.3))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Overline('YOUR EARNINGS'),
                  const SizedBox(height: 8),
                  Text(
                    bookings.isNotEmpty ? '₹${totalEarnings.toStringAsFixed(0)}' : '₹8,450',
                    style: AcademiaTypography.heading(size: 40),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This week · ${bookings.isNotEmpty ? bookings.length : 12} services',
                    style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AcademiaCard(
                    flourish: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline('NEXT PAYOUT'),
                        const SizedBox(height: 4),
                        Text('Friday, June 13 · Bank transfer', style: AcademiaTypography.body(size: 14)),
                      ],
                    ),
                  ),

                  const OrnateDivider(),
                  const Overline('RECENT SERVICES'),
                  const SizedBox(height: 12),

                  if (bookings.isNotEmpty)
                    ...bookings.take(5).map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AcademiaCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b['service_type']?.toString().replaceAll('_', ' ') ?? '',
                                        style: AcademiaTypography.body(size: 15),
                                      ),
                                      Text(
                                        b['created_at']?.toString().substring(0, 10) ?? '',
                                        style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${b['base_price'] ?? 0}',
                                  style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass),
                                ),
                              ],
                            ),
                          ),
                        ))
                  else
                    ...[
                      ('Yoga · Sharma ji', 'Today, 10 AM', '₹120'),
                      ('Yoga · Gupta ji', 'Today, 8 AM', '₹120'),
                      ('Yoga · Verma ji', 'Yesterday', '₹150'),
                      ('Yoga · Singh ji', 'Yesterday', '₹120'),
                    ].map((j) {
                      final (title, time, earn) = j;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AcademiaCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: AcademiaTypography.body(size: 15)),
                                    Text(time, style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground)),
                                  ],
                                ),
                              ),
                              Text(earn, style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass)),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 12),

                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Overline('YOUR RATING'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(5, (_) => const Icon(Icons.star, color: AcademiaColors.brass, size: 20)),
                                  const SizedBox(width: 8),
                                  Text('4.9 / 5.0', style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom nav
            Container(
              decoration: BoxDecoration(
                color: AcademiaColors.backgroundAlt,
                border: Border(top: BorderSide(color: AcademiaColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(Icons.work, 'Jobs', false),
                  _NavItem(Icons.account_balance_wallet, 'Earnings', true),
                  _NavItem(Icons.schedule, 'Schedule', false),
                  _NavItem(Icons.person, 'Profile', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AcademiaColors.brass : AcademiaColors.mutedForeground, size: 22),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AcademiaTypography.label(
              size: 8,
              color: active ? AcademiaColors.brass : AcademiaColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
