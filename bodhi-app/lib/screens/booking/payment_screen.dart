import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;

  static const _methods = [
    ('Cash on delivery', Icons.money, 'Pay the provider directly'),
    ('UPI / Google Pay', Icons.phone_android, 'Scan QR or use UPI ID'),
    ('Bodhi Wallet', Icons.account_balance_wallet, 'Balance: ₹500'),
  ];

  static const _methodKeys = ['cash', 'upi', 'wallet'];

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    final booking = ref.read(bookingProvider).activeBooking;
    final amount = (booking?['base_price'] as num?)?.toDouble() ?? 150.0;
    final bookingId = booking?['id'] as int?;

    try {
      await ref.read(apiServiceProvider).createPayment(
        amount: amount,
        method: _methodKeys[_selectedMethod],
        bookingId: bookingId,
      );
      if (mounted) {
        Navigator.pushNamed(context, '/completed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider).activeBooking;
    final price = booking?['base_price']?.toString() ?? '150';
    final serviceType = booking?['service_type'] ?? 'yoga';

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Payment'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Amount card
                  AcademiaCard(
                    flourish: true,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        const Overline('AMOUNT DUE'),
                        const SizedBox(height: 8),
                        Text('₹$price', style: AcademiaTypography.heading(size: 42)),
                        const SizedBox(height: 4),
                        Text(
                          '${serviceType.replaceAll('_', ' ')} service',
                          style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),

                  const OrnateDivider(),
                  const Overline('PAYMENT METHOD'),
                  const SizedBox(height: 12),

                  ...List.generate(_methods.length, (i) {
                    final (title, icon, sub) = _methods[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(
                        icon: icon,
                        title: title,
                        subtitle: sub,
                        selected: _selectedMethod == i,
                        onTap: () => setState(() => _selectedMethod = i),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: _isProcessing ? 'Processing...' : 'Confirm payment',
                    onPressed: _isProcessing ? null : _confirmPayment,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Receipt will be sent to family',
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
