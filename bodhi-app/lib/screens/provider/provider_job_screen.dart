import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/academia_widgets.dart';

class ProviderJobScreen extends ConsumerWidget {
  const ProviderJobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider).activeBooking;
    final serviceType = booking?['service_type']?.toString().replaceAll('_', ' ') ?? 'Yoga Session';
    final address = booking?['address'] ?? 'Roorkee, 1.2 km away';
    final price = booking?['base_price']?.toString() ?? '120';
    final bookingId = booking?['id'] as int?;

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: AcademiaColors.backgroundAlt,
                border: Border(bottom: BorderSide(color: AcademiaColors.brass.withValues(alpha: 0.3))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Overline('NEW REQUEST'),
                  const SizedBox(height: 4),
                  Text('Incoming booking', style: AcademiaTypography.heading(size: 22)),
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
                        Row(
                          children: [
                            const IconMedallion(icon: Icons.self_improvement, size: 48),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(serviceType, style: AcademiaTypography.heading(size: 20)),
                                Text('At home · 1 hour',
                                    style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AcademiaColors.border, height: 1),
                        const SizedBox(height: 16),
                        _DetailRow('CLIENT', 'Sharma ji'),
                        const SizedBox(height: 14),
                        _DetailRow('LOCATION', address),
                        const SizedBox(height: 14),
                        _DetailRow('TIME', '10:00 AM today'),
                        const SizedBox(height: 14),
                        _DetailRow('EARNINGS', '₹$price'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: BrassButton(
                          label: 'Accept',
                          onPressed: () async {
                            if (bookingId != null) {
                              await ref.read(bookingProvider.notifier).updateStatus(bookingId, 'provider_en_route');
                            }
                            if (context.mounted) Navigator.pushNamed(context, '/provider-verify');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                          child: Text('DECLINE', style: AcademiaTypography.button(color: AcademiaColors.brass)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Auto-decline in 45 seconds',
                      style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground, italic: true),
                    ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Overline(label),
        const SizedBox(height: 2),
        Text(value, style: AcademiaTypography.body(size: 15)),
      ],
    );
  }
}
