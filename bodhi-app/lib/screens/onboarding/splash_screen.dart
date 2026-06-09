import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = ref.read(authProvider.notifier);
    final restored = await auth.tryRestoreSession();

    if (!mounted) return;
    if (restored) {
      final role = ref.read(authProvider).role;
      if (role == 'family') {
        Navigator.pushReplacementNamed(context, '/family-dashboard');
      } else if (role == 'provider') {
        Navigator.pushReplacementNamed(context, '/provider-job');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/voice-unlock');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: Stack(
        children: [
          Positioned(top: 32, left: 24, right: 24, bottom: 32, child: _LargeCornerFlourishes()),
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AcademiaColors.backgroundAlt,
                      border: Border.all(color: AcademiaColors.brass, width: 1.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AcademiaColors.brass.withValues(alpha: 0.5), width: 0.5),
                        ),
                        child: const Center(child: Text('🪷', style: TextStyle(fontSize: 48))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('BODHI', style: AcademiaTypography.display(size: 42)),
                  const SizedBox(height: 8),
                  Text(
                    'Sarve Santu Niramaya',
                    style: AcademiaTypography.heading(size: 15, color: AcademiaColors.mutedForeground)
                        .copyWith(fontStyle: FontStyle.italic, letterSpacing: 2),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(width: 200, child: OrnateDivider(glyph: '❦')),
                  const SizedBox(height: 24),
                  Text(
                    'Care, comfort & company',
                    style: AcademiaTypography.heading(size: 20).copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'at your doorstep',
                    style: AcademiaTypography.heading(size: 20).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '✶  ✶  ✶',
                style: TextStyle(color: AcademiaColors.brass.withValues(alpha: 0.4), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeCornerFlourishes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LargeFlourishPainter());
  }
}

class _LargeFlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AcademiaColors.brass.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const s = 40.0;
    canvas.drawLine(const Offset(0, s), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(s, 0), paint);
    canvas.drawLine(Offset(size.width - s, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, s), paint);
    canvas.drawLine(Offset(0, size.height - s), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(s, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - s), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - s, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
