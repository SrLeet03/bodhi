import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/hospital_provider.dart';
import '../../widgets/academia_widgets.dart';
import '../../widgets/screen_header.dart';

class OpdBookingScreen extends ConsumerStatefulWidget {
  const OpdBookingScreen({super.key});

  @override
  ConsumerState<OpdBookingScreen> createState() => _OpdBookingScreenState();
}

class _OpdBookingScreenState extends ConsumerState<OpdBookingScreen> {
  int _selectedDay = 1;
  int _selectedSlot = -1;
  bool _priorityEnabled = true;
  bool _isBooking = false;

  static const _days = [
    ('Mon', '12'),
    ('Tue', '13'),
    ('Wed', '14'),
    ('Thu', '15'),
  ];

  static const _slots = [
    ('9:30', true),
    ('10:00', false),
    ('10:30', true),
    ('11:00', true),
    ('11:30', false),
    ('12:00', true),
  ];

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    final state = ref.read(hospitalProvider);
    // Use real slot ID if available from API, else use mock index
    final slotId = state.slots.isNotEmpty && _selectedSlot < state.slots.length
        ? state.slots[_selectedSlot]['id'] as int
        : _selectedSlot + 1;

    final result = await ref.read(hospitalProvider.notifier).bookOpd(
      slotId,
      priority: _priorityEnabled,
    );
    setState(() => _isBooking = false);

    if (result != null && mounted) {
      Navigator.pushNamed(context, '/opd-confirmed');
    } else if (mounted) {
      final error = ref.read(hospitalProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Booking failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AcademiaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Max Super Speciality'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Overline('CARDIOLOGY · DR. S. MEHTA'),
                  const SizedBox(height: 16),
                  Text('Pick a day', style: AcademiaTypography.heading(size: 20)),
                  const SizedBox(height: 12),

                  // Day chips
                  Row(
                    children: List.generate(_days.length, (i) {
                      final (day, date) = _days[i];
                      final sel = _selectedDay == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDay = i),
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: sel ? AcademiaColors.brass : AcademiaColors.backgroundAlt,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: sel ? AcademiaColors.brass : AcademiaColors.border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day.toUpperCase(),
                                  style: AcademiaTypography.label(
                                    size: 9,
                                    color: sel ? AcademiaColors.background : AcademiaColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: AcademiaTypography.heading(
                                    size: 22,
                                    color: sel ? AcademiaColors.background : AcademiaColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const OrnateDivider(),
                  const Overline('AVAILABLE SLOTS'),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (context, i) {
                      final (time, avail) = _slots[i];
                      final sel = _selectedSlot == i;
                      return GestureDetector(
                        onTap: avail ? () => setState(() => _selectedSlot = i) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: sel ? AcademiaColors.brass : avail ? AcademiaColors.backgroundAlt : AcademiaColors.muted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: sel ? AcademiaColors.brass : AcademiaColors.border),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: AcademiaTypography.heading(
                                size: 16,
                                color: sel ? AcademiaColors.background : avail ? AcademiaColors.foreground : AcademiaColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Priority booking card
                  AcademiaCard(
                    flourish: true,
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AcademiaColors.brass, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Priority booking', style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass)),
                              const SizedBox(height: 2),
                              Text(
                                'Skip the queue · +₹200 or free on Bodhi Plus',
                                style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _priorityEnabled,
                          onChanged: (v) => setState(() => _priorityEnabled = v),
                          activeColor: AcademiaColors.brass,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  BrassButton(
                    label: _isBooking ? 'Booking...' : 'Confirm OPD Slot',
                    onPressed: _selectedSlot >= 0 && !_isBooking ? _confirmBooking : null,
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
