import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class ProviderVerifyScreen extends ConsumerStatefulWidget {
  const ProviderVerifyScreen({super.key});

  @override
  ConsumerState<ProviderVerifyScreen> createState() => _ProviderVerifyScreenState();
}

class _ProviderVerifyScreenState extends ConsumerState<ProviderVerifyScreen> {
  final List<String> _otp = ['', '', '', ''];
  int _currentIndex = 0;
  bool _isVerifying = false;

  void _onDigit(String digit) {
    if (_currentIndex < 4 && !_isVerifying) {
      setState(() {
        _otp[_currentIndex] = digit;
        _currentIndex++;
      });
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0 && !_isVerifying) {
      setState(() {
        _currentIndex--;
        _otp[_currentIndex] = '';
      });
    }
  }

  Future<void> _verifyAndStart() async {
    setState(() => _isVerifying = true);
    final booking = ref.read(bookingProvider).activeBooking;
    final bookingId = booking?['id'] as int?;
    final otp = _otp.join();

    if (bookingId != null) {
      final ok = await ref.read(bookingProvider.notifier).verifyOtp(bookingId, otp);
      if (ok && mounted) {
        // Start service
        await ref.read(bookingProvider.notifier).updateStatus(bookingId, 'in_progress');
        if (mounted) Navigator.pushNamed(context, '/provider-earnings');
        return;
      }
    }

    if (mounted) {
      setState(() => _isVerifying = false);
      final error = ref.read(bookingProvider).error ?? 'Invalid OTP';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      setState(() {
        _otp.fillRange(0, 4, '');
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Verify Arrival'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Client info
                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        const IconMedallion(icon: Icons.person, size: 52),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sharma ji', style: AcademiaTypography.heading(size: 20)),
                            Text('Roorkee · Ground floor',
                                style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Care note
                  Container(
                    decoration: BoxDecoration(
                      color: AcademiaColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AcademiaColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AcademiaColors.brass,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Overline('CARE NOTE'),
                                const SizedBox(height: 4),
                                Text('Knee pain — avoid deep stretches', style: AcademiaTypography.body(size: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const OrnateDivider(),

                  Center(child: const Overline('ENTER VERIFICATION CODE')),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ask the senior for their 4-digit code',
                      style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 52,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AcademiaColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: i == _currentIndex ? AcademiaColors.brass : AcademiaColors.border,
                            width: i == _currentIndex ? 2 : 1,
                          ),
                        ),
                        child: Center(child: Text(_otp[i], style: AcademiaTypography.heading(size: 24))),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Numpad
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      for (var d in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])
                        GestureDetector(
                          onTap: () => _onDigit(d),
                          child: Container(
                            width: 56,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AcademiaColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AcademiaColors.border),
                            ),
                            child: Center(child: Text(d, style: AcademiaTypography.heading(size: 22))),
                          ),
                        ),
                      GestureDetector(
                        onTap: _onBackspace,
                        child: Container(
                          width: 56,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AcademiaColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AcademiaColors.border),
                          ),
                          child: const Center(
                            child: Icon(Icons.backspace_outlined, color: AcademiaColors.foreground, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: _isVerifying ? 'Verifying...' : 'Verify & start service',
                    onPressed: _currentIndex == 4 && !_isVerifying ? _verifyAndStart : null,
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Code ensures the right provider reached you',
                      style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground, italic: true),
                    ),
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
