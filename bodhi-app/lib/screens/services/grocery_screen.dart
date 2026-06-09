import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class GroceryScreen extends ConsumerStatefulWidget {
  const GroceryScreen({super.key});

  @override
  ConsumerState<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends ConsumerState<GroceryScreen> {
  static const _categories = [
    ('Atta & Dal', Icons.grain, 'Staples'),
    ('Dairy & Eggs', Icons.egg, 'Fresh daily'),
    ('Fruits', Icons.apple, 'Seasonal picks'),
    ('Vegetables', Icons.eco, 'Farm fresh'),
    ('Snacks', Icons.cookie, 'Tea-time treats'),
    ('Beverages', Icons.local_cafe, 'Tea, coffee, juices'),
  ];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'groceries',
    );
    if (booking != null && mounted) {
      Navigator.pushNamed(context, '/tracking');
    } else if (mounted) {
      final error = ref.read(bookingProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Groceries'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Powered by Blinkit',
                    style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground, italic: true),
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AcademiaColors.backgroundAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AcademiaColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AcademiaColors.mutedForeground, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Search for items...',
                          style: AcademiaTypography.body(color: AcademiaColors.mutedForeground, italic: true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Overline('CATEGORIES'),
                  const SizedBox(height: 12),

                  // 2-column grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final (name, icon, sub) = _categories[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AcademiaColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AcademiaColors.border, width: 0.8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: AcademiaColors.brass, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(name, style: AcademiaTypography.heading(size: 14)),
                                  Text(
                                    'View all >',
                                    style: AcademiaTypography.body(size: 11, color: AcademiaColors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Delivery note
                  AcademiaCard(
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AcademiaColors.brass, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery in 10-15 minutes',
                          style: AcademiaTypography.body(size: 14, color: AcademiaColors.brass),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  BrassButton(
                    label: bookingState.isLoading ? 'Ordering...' : 'View full catalogue',
                    onPressed: bookingState.isLoading ? null : _onBookPressed,
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
