import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/emergency_provider.dart';
import '../../widgets/academia_widgets.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(emergencyProvider.notifier).loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyProvider);
    final alert = state.activeAlert;
    final familyNotified = alert?['family_notified'] == true;
    final ambulanceDispatched = alert?['ambulance_dispatched'] == true;

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Crimson header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(gradient: AcademiaColors.crimsonGradient),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber, size: 44, color: AcademiaColors.foreground),
                  const SizedBox(height: 8),
                  Text('EMERGENCY ALERT', style: AcademiaTypography.label(size: 16, color: AcademiaColors.foreground)),
                  const SizedBox(height: 4),
                  Text(
                    alert != null ? 'Emergency alert active' : 'Sharma ji activated emergency',
                    style: AcademiaTypography.body(size: 14, color: AcademiaColors.foreground),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('RESPONSE STATUS'),
                  const SizedBox(height: 16),

                  _StatusStep('Alert sent to family', familyNotified),
                  _StatusStep('Ambulance dispatched', ambulanceDispatched),
                  _StatusStep('ETA: 8 minutes', false, isActive: true),
                  _StatusStep('Hospital notified', false, isLast: true),

                  const SizedBox(height: 8),
                  const OrnateDivider(),

                  const Overline('EMERGENCY CONTACTS'),
                  const SizedBox(height: 12),

                  if (state.contacts.isNotEmpty)
                    ...state.contacts.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AcademiaListRow(
                            icon: Icons.phone,
                            title: c['name'] ?? '',
                            subtitle: c['phone'] ?? '',
                            onTap: () {},
                          ),
                        ))
                  else ...[
                    AcademiaListRow(icon: Icons.local_hospital, title: 'Ambulance', subtitle: '108', onTap: () {}),
                    const SizedBox(height: 8),
                    AcademiaListRow(icon: Icons.phone, title: 'Son: Rajesh', subtitle: '+91-98765...', onTap: () {}),
                    const SizedBox(height: 8),
                    AcademiaListRow(icon: Icons.medical_services, title: 'Dr. Mehta', subtitle: '+91-97654...', onTap: () {}),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: CrimsonButton(
                label: state.isLoading ? 'Cancelling...' : 'Cancel alert',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final alertId = alert?['alert_id'] as int?;
                        if (alertId != null) {
                          await ref.read(emergencyProvider.notifier).resolveAlert(alertId);
                        }
                        if (mounted) Navigator.pop(context);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool isActive;
  final bool isLast;
  const _StatusStep(this.label, this.done, {this.isActive = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: isActive ? 22 : 18,
                  height: isActive ? 22 : 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done || isActive ? AcademiaColors.brass : Colors.transparent,
                    border: !done && !isActive ? Border.all(color: AcademiaColors.border, width: 1.5) : null,
                  ),
                  child: done ? const Icon(Icons.check, size: 10, color: AcademiaColors.background) : null,
                ),
                if (!isLast)
                  Container(width: 1.5, height: 32, color: done ? AcademiaColors.brass : AcademiaColors.border),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                if (isActive) ...[
                  const SizedBox(height: 2),
                  const Overline('IN PROGRESS'),
                ],
                SizedBox(height: isLast ? 0 : 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
