import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/academia_widgets.dart';

class UnlockSuccessScreen extends ConsumerStatefulWidget {
  const UnlockSuccessScreen({super.key});

  @override
  ConsumerState<UnlockSuccessScreen> createState() => _UnlockSuccessScreenState();
}

class _UnlockSuccessScreenState extends ConsumerState<UnlockSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _homeRouteForRole(String? role) {
    switch (role) {
      case 'family':
        return '/family-dashboard';
      case 'provider':
        return '/provider-job';
      default:
        return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.name ?? 'User';
    final homeRoute = _homeRouteForRole(authState.role);

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Brass check emblem
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AcademiaColors.brassGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AcademiaColors.brass.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 48, color: AcademiaColors.background),
                ),
              ),

              const SizedBox(height: 32),
              Text('Welcome, $userName', style: AcademiaTypography.heading(size: 26)),
              const SizedBox(height: 8),
              Text(
                'Voice verified successfully',
                style: AcademiaTypography.body(size: 16, color: AcademiaColors.mutedForeground, italic: true),
              ),

              const SizedBox(height: 24),
              const SizedBox(width: 200, child: OrnateDivider()),
              const SizedBox(height: 24),

              // Greeting card
              AcademiaCard(
                flourish: true,
                child: Column(
                  children: [
                    const Overline("TODAY'S GREETING"),
                    const SizedBox(height: 8),
                    Text(
                      'May wellness and peace be with you',
                      style: AcademiaTypography.body(size: 16, italic: true),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              BrassButton(
                label: 'Enter Bodhi',
                onPressed: () => Navigator.pushReplacementNamed(context, homeRoute),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
