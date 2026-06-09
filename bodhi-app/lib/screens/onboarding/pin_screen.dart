import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/academia_widgets.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  bool _isVerifying = false;

  void _onKey(String key) {
    if (_isVerifying) return;

    if (key == '\u232b') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (_pin.length < 4) {
      setState(() => _pin += key);
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);

    final phone = ref.read(authProvider).phone ?? '';
    final success = await ref.read(authProvider.notifier).verifyPin(phone, _pin);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/unlock-success');
    } else {
      final error = ref.read(authProvider).error ?? 'Invalid PIN';
      setState(() => _pin = '');
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
              const SizedBox(height: 32),
              const Overline('SECURITY'),
              const SizedBox(height: 8),
              Text('Enter your PIN', style: AcademiaTypography.heading(size: 26)),
              const SizedBox(height: 8),
              const OrnateDivider(glyph: '\uD83D\uDD12'),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AcademiaColors.brass : Colors.transparent,
                      border: Border.all(color: AcademiaColors.brass, width: 1.5),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Numpad
              Expanded(
                child: _isVerifying
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNumpad(),
              ),

              Text(
                'Forgot PIN? Contact family',
                style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground, italic: true),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '\u232b'],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 80, height: 68);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () => _onKey(key),
                  child: Container(
                    width: 80,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AcademiaColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AcademiaColors.border),
                    ),
                    child: Center(
                      child: Text(
                        key,
                        style: AcademiaTypography.heading(
                          size: key == '\u232b' ? 22 : 28,
                          color: AcademiaColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
