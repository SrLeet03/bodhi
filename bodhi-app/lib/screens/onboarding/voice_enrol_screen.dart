import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/academia_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../widgets/academia_widgets.dart';

class VoiceEnrolScreen extends ConsumerStatefulWidget {
  const VoiceEnrolScreen({super.key});

  @override
  ConsumerState<VoiceEnrolScreen> createState() => _VoiceEnrolScreenState();
}

class _VoiceEnrolScreenState extends ConsumerState<VoiceEnrolScreen> {
  int _currentSample = 0; // 0-based, 3 total
  bool _recording = false;

  void _startRecording() async {
    setState(() => _recording = true);

    try {
      final api = ref.read(apiServiceProvider);
      // sampleNumber is 1-based for the API
      await api.voiceEnrol(_currentSample + 1, []);
    } catch (e) {
      if (!mounted) return;
      setState(() => _recording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice enrol failed: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _recording = false;
      _currentSample++;
    });
    if (_currentSample >= 3) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/role-select');
      });
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
              const SizedBox(height: 24),
              const Overline('VOLUME I'),
              const SizedBox(height: 8),
              Text('Voice Enrolment', style: AcademiaTypography.heading(size: 26)),
              const SizedBox(height: 8),
              const OrnateDivider(),

              // Instruction card
              AcademiaCard(
                flourish: true,
                child: Column(
                  children: [
                    Text(
                      'Please repeat the phrase below',
                      style: AcademiaTypography.body(size: 15, color: AcademiaColors.mutedForeground),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Sarve Santu Niramaya"',
                      style: AcademiaTypography.heading(size: 20, color: AcademiaColors.brass)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Mic button
              VoiceMicButton(
                onPressed: _recording ? null : _startRecording,
                listening: _recording,
              ),
              const SizedBox(height: 20),

              // Waveform placeholder
              if (_recording)
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(15, (i) {
                      final heights = [8, 14, 20, 28, 34, 28, 20, 14, 8, 14, 22, 30, 22, 14, 8];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: heights[i].toDouble(),
                        decoration: BoxDecoration(
                          color: AcademiaColors.brass.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                )
              else
                const SizedBox(height: 40),

              const SizedBox(height: 16),
              Overline('RECORDING ${_currentSample + 1} OF 3'),
              const SizedBox(height: 16),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _currentSample;
                  final done = i < _currentSample;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: active ? 12 : 8,
                    height: active ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || active ? AcademiaColors.brass : AcademiaColors.muted,
                    ),
                    child: done ? const Icon(Icons.check, size: 6, color: AcademiaColors.background) : null,
                  );
                }),
              ),

              const Spacer(),

              Text(
                'Speak clearly and at your natural pace',
                style: AcademiaTypography.body(size: 14, color: AcademiaColors.mutedForeground, italic: true),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
