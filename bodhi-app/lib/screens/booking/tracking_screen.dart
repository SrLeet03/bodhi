import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  static const _statusOrder = [
    'pending',
    'provider_assigned',
    'provider_en_route',
    'provider_arrived',
    'in_progress',
    'completed',
  ];

  static const _statusLabels = {
    'pending': 'Booking confirmed',
    'provider_assigned': 'Provider assigned',
    'provider_en_route': 'On the way',
    'provider_arrived': 'Arrived',
    'in_progress': 'Session in progress',
    'completed': 'Session complete',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider).activeBooking;
    final currentStatus = booking?['status'] ?? 'provider_en_route';
    final serviceType = booking?['service_type'] ?? 'yoga';
    final currentIdx = _statusOrder.indexOf(currentStatus).clamp(0, _statusOrder.length - 1);

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Tracking'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Service summary
                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        const IconMedallion(icon: Icons.self_improvement, size: 44),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${serviceType[0].toUpperCase()}${serviceType.substring(1).replaceAll('_', ' ')} session',
                              style: AcademiaTypography.heading(size: 18),
                            ),
                            Text(
                              booking?['provider_name'] ?? 'Finding provider...',
                              style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Overline('STATUS'),
                  const SizedBox(height: 16),

                  // Progress steps
                  ...List.generate(_statusOrder.length, (i) {
                    final done = i < currentIdx;
                    final isActive = i == currentIdx;
                    return _StepRow(
                      label: _statusLabels[_statusOrder[i]] ?? _statusOrder[i],
                      done: done,
                      isActive: isActive,
                      isLast: i == _statusOrder.length - 1,
                      showNow: isActive,
                    );
                  }),

                  const SizedBox(height: 16),

                  // ETA card
                  AcademiaCard(
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: AcademiaColors.brass, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          currentStatus == 'completed'
                              ? 'Service completed'
                              : 'Provider is on the way',
                          style: AcademiaTypography.body(size: 15, color: AcademiaColors.brass),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (currentStatus == 'completed')
                    BrassButton(
                      label: 'Rate & pay',
                      onPressed: () => Navigator.pushNamed(context, '/payment'),
                    )
                  else
                    OutlinedButton(
                      onPressed: () {},
                      child: Text('CONTACT PROVIDER', style: AcademiaTypography.button(color: AcademiaColors.brass)),
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
  final String label;
  final bool done, isActive, isLast, showNow;

  const _StepRow({
    required this.label,
    required this.done,
    this.isActive = false,
    this.isLast = false,
    this.showNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: isActive ? 24 : 20,
                height: isActive ? 24 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || isActive ? AcademiaColors.brass : Colors.transparent,
                  border: !done && !isActive ? Border.all(color: AcademiaColors.border, width: 1.5) : null,
                ),
                child: done ? const Icon(Icons.check, size: 12, color: AcademiaColors.background) : null,
              ),
              if (!isLast)
                Container(width: 1.5, height: 40, color: done ? AcademiaColors.brass : AcademiaColors.border),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AcademiaTypography.body(
                    size: 16,
                    color: done || isActive ? AcademiaColors.foreground : AcademiaColors.mutedForeground,
                  ),
                ),
                if (showNow) ...[
                  const SizedBox(height: 4),
                  const Overline('NOW'),
                ],
                SizedBox(height: isLast ? 0 : 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
