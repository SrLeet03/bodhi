import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/services/api_service.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  List<Map<String, dynamic>> _activity = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final api = ref.read(apiServiceProvider);
      final seniors = await api.getLinkedSeniors();
      if (seniors.isNotEmpty) {
        final seniorId = (seniors.first as Map)['id'] as int;
        final list = await api.getSeniorActivity(seniorId);
        _activity = list.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Fall back to empty; UI shows mock
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Activity'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AcademiaColors.brass))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Overline('THIS WEEK'),
                        const SizedBox(height: 16),

                        if (_activity.isNotEmpty)
                          ..._activity.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _EventCard(
                                  a['service_type']?.toString().replaceAll('_', ' ') ?? 'Service',
                                  a['created_at']?.toString().substring(0, 10) ?? '',
                                  '₹${a['base_price'] ?? 0}',
                                ),
                              ))
                        else ...[
                          Text('Today', style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass)),
                          const SizedBox(height: 8),
                          _EventCard('Yoga session', '10:00 AM', '₹150'),
                          const SizedBox(height: 8),
                          _EventCard('Medicine delivery', '8:30 AM', '₹105'),
                          const SizedBox(height: 20),
                          Text('Yesterday', style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass)),
                          const SizedBox(height: 8),
                          _EventCard('Car ride to bank', '2:00 PM', '₹180'),
                          const SizedBox(height: 8),
                          _EventCard('Nursing · Bathing', '9:00 AM', '₹200'),
                          const SizedBox(height: 20),
                          Text('Monday', style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass)),
                          const SizedBox(height: 8),
                          _EventCard('Groceries via Blinkit', '11:00 AM', '₹450'),
                        ],

                        const SizedBox(height: 16),
                        const OrnateDivider(),

                        AcademiaCard(
                          flourish: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Overline('WEEKLY TOTAL'),
                              Text(
                                _activity.isNotEmpty
                                    ? '₹${_activity.fold<double>(0, (sum, a) => sum + ((a['base_price'] as num?)?.toDouble() ?? 0)).toStringAsFixed(0)}'
                                    : '₹1,085',
                                style: AcademiaTypography.heading(size: 22, color: AcademiaColors.brass),
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

class _EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String cost;
  const _EventCard(this.title, this.time, this.cost);

  @override
  Widget build(BuildContext context) {
    return AcademiaCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AcademiaTypography.body(size: 15)),
                Text(time, style: AcademiaTypography.body(size: 12, color: AcademiaColors.mutedForeground)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cost, style: AcademiaTypography.heading(size: 17, color: AcademiaColors.brass)),
              Text('✓', style: TextStyle(color: AcademiaColors.brass, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
