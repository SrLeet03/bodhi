import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/hospital_provider.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class HospitalListScreen extends ConsumerStatefulWidget {
  const HospitalListScreen({super.key});

  @override
  ConsumerState<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends ConsumerState<HospitalListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hospitalProvider.notifier).loadHospitals());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalProvider);

    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Hospitals & Clinics'),
            Expanded(
              child: state.isLoading && state.hospitals.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AcademiaColors.brass))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Overline('ONBOARDED FACILITIES NEAR YOU'),
                        const SizedBox(height: 12),

                        // Search
                        GestureDetector(
                          onTap: () {
                            // TODO: Open search
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  'Search hospitals...',
                                  style: AcademiaTypography.body(color: AcademiaColors.mutedForeground, italic: true),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (state.hospitals.isEmpty && !state.isLoading)
                          Center(
                            child: Text(
                              'No hospitals found',
                              style: AcademiaTypography.body(color: AcademiaColors.mutedForeground),
                            ),
                          )
                        else
                          ...state.hospitals.map((h) => _HospitalCard(hospital: h)),

                        if (state.error != null) ...[
                          const SizedBox(height: 12),
                          Text(state.error!, style: AcademiaTypography.body(size: 13, color: AcademiaColors.crimson)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final name = hospital['name'] ?? '';
    final departments = (hospital['departments'] as List?)?.join(' · ') ?? '';
    final hasPriority = hospital['offers_priority'] == true;
    final distance = hospital['distance_km'] != null ? '${hospital['distance_km']} km' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AcademiaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: AcademiaTypography.heading(size: 17))),
                if (hasPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AcademiaColors.brass,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 12, color: AcademiaColors.background),
                        const SizedBox(width: 2),
                        Text('PRIORITY', style: AcademiaTypography.label(size: 7, color: AcademiaColors.background)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(departments, style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(distance, style: AcademiaTypography.body(size: 13, color: AcademiaColors.brass)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/opd-booking', arguments: hospital),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AcademiaColors.brassGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('BOOK OPD', style: AcademiaTypography.label(size: 8, color: AcademiaColors.background)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
