import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/academia_theme.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  const MedicineScreen({super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen> {
  static const _usualMeds = [
    ('Amlodipine 5mg', 'Blood pressure', '₹45'),
    ('Metformin 500mg', 'Diabetes', '₹38'),
    ('Ecosprin 75mg', 'Heart care', '₹22'),
  ];

  Future<void> _onBookPressed() async {
    final booking = await ref.read(bookingProvider.notifier).createBooking(
      serviceType: 'medicines',
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
            const ScreenHeader(title: 'Medicines'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Upload prescription
                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        const IconMedallion(icon: Icons.document_scanner, size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Upload prescription', style: AcademiaTypography.heading(size: 18)),
                              const SizedBox(height: 4),
                              Text(
                                'Take a photo or upload from gallery',
                                style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.camera_alt, color: AcademiaColors.brass),
                      ],
                    ),
                  ),

                  const OrnateDivider(),
                  const Overline('YOUR USUAL MEDICINES'),
                  const SizedBox(height: 12),

                  ..._usualMeds.map((m) {
                    final (name, cat, price) = m;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AcademiaListRow(
                        icon: Icons.medication,
                        title: name,
                        subtitle: cat,
                        trailing: price,
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  BrassButton(
                    label: bookingState.isLoading ? 'Ordering...' : 'Reorder all medicines',
                    onPressed: bookingState.isLoading ? null : _onBookPressed,
                  ),

                  const SizedBox(height: 16),

                  // Delivery note
                  AcademiaCard(
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: AcademiaColors.brass, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery within 45 minutes',
                          style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground),
                        ),
                      ],
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
