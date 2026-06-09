import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/academia_widgets.dart';

class VoiceUnlockScreen extends ConsumerStatefulWidget {
  const VoiceUnlockScreen({super.key});

  @override
  ConsumerState<VoiceUnlockScreen> createState() => _VoiceUnlockScreenState();
}

class _VoiceUnlockScreenState extends ConsumerState<VoiceUnlockScreen> {
  bool _listening = false;

  void _startListening() async {
    setState(() => _listening = true);

    try {
      final api = ref.read(apiServiceProvider);
      final phone = ref.read(authProvider).phone ?? '';
      // Mock audio bytes for now; real mic integration will replace this
      await api.voiceVerify(phone, []);

      if (!mounted) return;
      setState(() => _listening = false);
      Navigator.pushReplacementNamed(context, '/unlock-success');
    } catch (e) {
      if (!mounted) return;
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice verification failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.name ?? 'User';

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: AcademiaColors.backgroundAlt,
                border: Border(bottom: BorderSide(color: AcademiaColors.brass.withValues(alpha: 0.3))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Overline('WELCOME BACK'),
                  const SizedBox(height: 8),
                  Text(userName, style: AcademiaTypography.heading(size: 32)),
                  const SizedBox(height: 4),
                  Text(
                    'Speak to unlock your Bodhi',
                    style: AcademiaTypography.body(size: 15, color: AcademiaColors.mutedForeground, italic: true),
                  ),
                ],
              ),
            ),

            // Voice mic
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Outer rings
                  if (_listening)
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AcademiaColors.brass.withValues(alpha: 0.2), width: 0.5),
                      ),
                    ),
                  VoiceMicButton(
                    onPressed: _startListening,
                    listening: _listening,
                  ),
                  const SizedBox(height: 24),
                  const Overline('TAP AND SPEAK'),
                ],
              ),
            ),

            // Fallback options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const OrnateDivider(),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/pin'),
                    child: Text('USE PIN INSTEAD', style: AcademiaTypography.button(color: AcademiaColors.brass)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Or ask a family member to unlock',
                    style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground, italic: true),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
