import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/academia_widgets.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  int _selected = 0;
  bool _isSubmitting = false;

  static const _roles = [
    _Role('Senior Citizen', Icons.person, 'I need care services', 'senior'),
    _Role('Family Member', Icons.family_restroom, 'I care for a loved one', 'family'),
    _Role('Service Provider', Icons.work, 'I offer care services', 'provider'),
  ];

  Future<void> _onContinue() async {
    setState(() => _isSubmitting = true);

    final success = await ref.read(authProvider.notifier).register(
          phone: ref.read(authProvider).phone ?? '',
          name: 'User',
          role: _roles[_selected].key,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/voice-unlock');
    } else {
      final error = ref.read(authProvider).error ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Overline('VOLUME II'),
              const SizedBox(height: 8),
              Text('Who are you?', style: AcademiaTypography.heading(size: 28)),
              const SizedBox(height: 8),
              const OrnateDivider(),
              const SizedBox(height: 16),

              // Role cards
              ...List.generate(_roles.length, (i) {
                final role = _roles[i];
                final sel = _selected == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : () => setState(() => _selected = i),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: sel ? AcademiaColors.muted : AcademiaColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel ? AcademiaColors.brass : AcademiaColors.border,
                          width: sel ? 2 : 0.8,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              IconMedallion(icon: role.icon, size: 56),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(role.title, style: AcademiaTypography.heading(size: 20)),
                                    const SizedBox(height: 4),
                                    Text(
                                      role.description,
                                      style: AcademiaTypography.body(
                                        size: 14,
                                        color: AcademiaColors.mutedForeground,
                                        italic: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (sel) ...[
                            // Corner flourishes
                            Positioned(top: 0, left: 0, child: _SmallFlourish(topLeft: true)),
                            Positioned(top: 0, right: 0, child: _SmallFlourish(topRight: true)),
                            Positioned(bottom: 0, left: 0, child: _SmallFlourish(bottomLeft: true)),
                            Positioned(bottom: 0, right: 0, child: _SmallFlourish(bottomRight: true)),
                            // Wax seal
                            Positioned(
                              top: -4,
                              right: -4,
                              child: WaxSeal(icon: Icons.check, size: 28),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              BrassButton(
                label: _isSubmitting ? 'Registering...' : 'Continue',
                onPressed: _isSubmitting ? null : _onContinue,
              ),

              const SizedBox(height: 16),
              Text(
                'You can change this later in settings',
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

class _SmallFlourish extends StatelessWidget {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  const _SmallFlourish({this.topLeft = false, this.topRight = false, this.bottomLeft = false, this.bottomRight = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 14),
      painter: _FlourishPainter(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight),
    );
  }
}

class _FlourishPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;
  _FlourishPainter({this.topLeft = false, this.topRight = false, this.bottomLeft = false, this.bottomRight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AcademiaColors.brass.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final s = size.width;
    if (topLeft) {
      canvas.drawLine(Offset(0, s), Offset.zero, paint);
      canvas.drawLine(Offset.zero, Offset(s, 0), paint);
    } else if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(s, 0), paint);
      canvas.drawLine(Offset(s, 0), Offset(s, s), paint);
    } else if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, s), paint);
      canvas.drawLine(Offset(0, s), Offset(s, s), paint);
    } else if (bottomRight) {
      canvas.drawLine(Offset(s, 0), Offset(s, s), paint);
      canvas.drawLine(Offset(0, s), Offset(s, s), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Role {
  final String title;
  final IconData icon;
  final String description;
  final String key;
  const _Role(this.title, this.icon, this.description, this.key);
}
