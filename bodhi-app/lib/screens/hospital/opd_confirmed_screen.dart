import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/hospital_provider.dart';
import '../../widgets/academia_widgets.dart';

class OpdConfirmedScreen extends ConsumerWidget {
  const OpdConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opdBooking = ref.watch(hospitalProvider).opdBooking;
    final hospital = opdBooking?['hospital_name'] ?? 'Max Super Speciality';
    final department = opdBooking?['department'] ?? 'Cardiology';
    final doctor = opdBooking?['doctor_name'] ?? 'Dr. S. Mehta';
    final token = opdBooking?['token_number'] ?? 'P-04';
    final isPriority = opdBooking?['is_priority'] == true;
    final slotDate = opdBooking?['slot_date'] ?? 'Tue, 13 June';
    final startTime = opdBooking?['start_time'] ?? '9:30 AM';

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AcademiaColors.brassGradient,
                  boxShadow: [
                    BoxShadow(color: AcademiaColors.brass.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.calendar_today, size: 40, color: AcademiaColors.background),
              ),

              const SizedBox(height: 24),
              Text('OPD Confirmed', style: AcademiaTypography.heading(size: 26)),
              const SizedBox(height: 12),

              if (isPriority)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AcademiaColors.brass,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 14, color: AcademiaColors.background),
                      const SizedBox(width: 4),
                      Text(
                        'PRIORITY · $token',
                        style: AcademiaTypography.label(size: 9, color: AcademiaColors.background),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              const SizedBox(width: 200, child: OrnateDivider()),
              const SizedBox(height: 20),

              AcademiaCard(
                flourish: true,
                child: Column(
                  children: [
                    _DetailRow('HOSPITAL', hospital),
                    const SizedBox(height: 12),
                    _DetailRow('DEPARTMENT', department),
                    const SizedBox(height: 12),
                    _DetailRow('DOCTOR', doctor),
                    const SizedBox(height: 12),
                    _DetailRow('DATE & TIME', '$slotDate · $startTime'),
                    const SizedBox(height: 12),
                    _DetailRow('TOKEN', '$token${isPriority ? ' (Priority)' : ''}'),
                  ],
                ),
              ),

              const Spacer(),

              BrassButton(label: 'Add to calendar', icon: Icons.calendar_today, onPressed: () {}),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/car'),
                child: Text('BOOK A CAR TO HOSPITAL', style: AcademiaTypography.button(color: AcademiaColors.brass)),
              ),
              const SizedBox(height: 16),
              Text(
                'Reminder will be sent 1 hour before',
                style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground, italic: true),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
