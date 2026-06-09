import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/emergency_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/academia_widgets.dart';

class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends ConsumerState<FamilyDashboardScreen> {
  List<Map<String, dynamic>> _seniors = [];
  Map<String, dynamic>? _wallet;
  List<Map<String, dynamic>> _activity = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ref.read(apiServiceProvider);
    try {
      final seniors = await api.getLinkedSeniors();
      _seniors = seniors.cast<Map<String, dynamic>>();
      if (_seniors.isNotEmpty) {
        final seniorId = _seniors.first['id'] as int;
        final activity = await api.getSeniorActivity(seniorId);
        _activity = activity.cast<Map<String, dynamic>>();
      }
      _wallet = await api.getWallet();
    } catch (_) {
      // Fall back to mock data
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final seniorName = _seniors.isNotEmpty ? _seniors.first['name'] : "Sharma ji";
    final walletBalance = _wallet?['balance']?.toString() ?? '2,500';

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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Overline('FAMILY COMPANION'),
                        const SizedBox(height: 4),
                        Text("$seniorName's care", style: AcademiaTypography.heading(size: 24)),
                        const SizedBox(height: 4),
                        Text(
                          'All is well today',
                          style: AcademiaTypography.body(size: 15, color: AcademiaColors.brass, italic: true),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4A7C59)),
                    child: const Icon(Icons.check, size: 12, color: AcademiaColors.foreground),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAction(Icons.phone, 'Call'),
                      const SizedBox(width: 10),
                      _QuickAction(Icons.account_balance_wallet, 'Add funds'),
                      const SizedBox(width: 10),
                      _QuickAction(Icons.pin_drop, 'Location'),
                      const SizedBox(width: 10),
                      _QuickAction(Icons.notifications, 'Alerts'),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const OrnateDivider(),

                  const Overline("TODAY'S ACTIVITY"),
                  const SizedBox(height: 12),

                  if (_activity.isNotEmpty)
                    ..._activity.take(3).map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AcademiaListRow(
                            icon: Icons.check_circle_outline,
                            title: a['service_type']?.toString().replaceAll('_', ' ') ?? '',
                            subtitle: a['status'] ?? '',
                          ),
                        ))
                  else ...[
                    AcademiaListRow(icon: Icons.self_improvement, title: 'Yoga session booked', subtitle: '10:00 AM'),
                    const SizedBox(height: 8),
                    AcademiaListRow(icon: Icons.medication, title: 'Medicine delivered', subtitle: '8:30 AM'),
                    const SizedBox(height: 8),
                    AcademiaListRow(icon: Icons.wb_sunny, title: 'Good morning check', subtitle: '7:00 AM'),
                  ],

                  const SizedBox(height: 20),

                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Overline('BODHI WALLET'),
                              const SizedBox(height: 4),
                              Text('₹$walletBalance', style: AcademiaTypography.heading(size: 24, color: AcademiaColors.brass)),
                            ],
                          ),
                        ),
                        Text(
                          'Auto-reload enabled',
                          style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  CrimsonButton(
                    label: 'Emergency alert',
                    icon: Icons.warning_amber,
                    onPressed: () async {
                      await ref.read(emergencyProvider.notifier).triggerAlert();
                      if (context.mounted) Navigator.pushNamed(context, '/emergency');
                    },
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
                  _NavItem(Icons.dashboard, 'Home', true),
                  _NavItem(Icons.timeline, 'Activity', false, onTap: () => Navigator.pushNamed(context, '/family-activity')),
                  _NavItem(Icons.account_balance_wallet, 'Wallet', false),
                  _NavItem(Icons.settings, 'Settings', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AcademiaColors.backgroundAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AcademiaColors.border, width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AcademiaColors.brass, size: 22),
            const SizedBox(height: 6),
            Text(label.toUpperCase(), style: AcademiaTypography.label(size: 8)),
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
  final VoidCallback? onTap;
  const _NavItem(this.icon, this.label, this.active, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
