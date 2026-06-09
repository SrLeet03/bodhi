import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/emergency_provider.dart';
import '../../widgets/academia_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _services = [
    _ServiceItem('Yoga', Icons.self_improvement, '/yoga'),
    _ServiceItem('Physio', Icons.fitness_center, '/physio'),
    _ServiceItem('Acupressure', Icons.pan_tool, '/acupressure'),
    _ServiceItem('Nursing', Icons.favorite, '/nursing'),
    _ServiceItem('Hospital', Icons.local_hospital, '/hospitals'),
    _ServiceItem('Doctor', Icons.medical_services, '/doctor'),
    _ServiceItem('Car Ride', Icons.directions_car, '/car'),
    _ServiceItem('Medicines', Icons.medication, '/medicines'),
    _ServiceItem('Groceries', Icons.shopping_cart, '/groceries'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userName = auth.name ?? 'User';

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
                        const Overline('NAMASTE'),
                        const SizedBox(height: 4),
                        Text(userName, style: AcademiaTypography.heading(size: 28)),
                        const SizedBox(height: 2),
                        Text(
                          'Sarve Santu Niramaya',
                          style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground, italic: true),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AcademiaColors.brass, width: 1),
                    ),
                    child: const Icon(Icons.person, color: AcademiaColors.brass),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Voice card
                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        const IconMedallion(icon: Icons.mic, size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tap and speak', style: AcademiaTypography.heading(size: 20, color: AcademiaColors.brass)),
                              Text(
                                '"Book me a yoga session"',
                                style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground, italic: true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3x3 service grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, i) {
                      final s = _services[i];
                      return ServiceTile(
                        label: s.label,
                        icon: s.icon,
                        onTap: () => Navigator.pushNamed(context, s.route),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Emergency bar
                  CrimsonButton(
                    label: 'Emergency',
                    icon: Icons.warning_amber,
                    onPressed: () async {
                      await ref.read(emergencyProvider.notifier).triggerAlert();
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/emergency');
                      }
                    },
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

class _ServiceItem {
  final String label;
  final IconData icon;
  final String route;

  const _ServiceItem(this.label, this.icon, this.route);
}
