import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ai_engine/ai_camera_settings.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/ai_camera_settings_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../../../../theme/app_theme.dart';
import '../../../camera/presentation/providers/inference_notifier.dart';

class AiCameraSettingsScreen extends ConsumerStatefulWidget {
  const AiCameraSettingsScreen({super.key});

  @override
  ConsumerState<AiCameraSettingsScreen> createState() =>
      _AiCameraSettingsScreenState();
}

class _AiCameraSettingsScreenState
    extends ConsumerState<AiCameraSettingsScreen> {
  double _confidence = AiCameraSettings.confidence.value;
  double _iou = AiCameraSettings.iou.value;
  double _quality = AiCameraSettings.cropQuality.value.toDouble();
  bool _masks = AiCameraSettings.detailedMasks.value;
  int _threads = AiCameraSettings.processingThreads.value;
  bool _showId = AiCameraSettings.showDatabaseIds.value;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await ref.read(aiCameraSettingsLoaderProvider.future);
      if (!mounted) return;
      setState(() {
        _confidence = AiCameraSettings.confidence.value;
        _iou = AiCameraSettings.iou.value;
        _quality = AiCameraSettings.cropQuality.value.toDouble();
        _masks = AiCameraSettings.detailedMasks.value;
        _threads = AiCameraSettings.processingThreads.value;
        _showId = AiCameraSettings.showDatabaseIds.value;
      });
    } catch (_) {
      // Invalid legacy settings must never prevent this page from opening.
      _apply();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply() => AiCameraSettings.apply(
        confidenceValue: _confidence,
        iouValue: _iou,
        cropQualityValue: _quality.round(),
        detailedMasksValue: _masks,
        processingThreadsValue: _threads,
        showDatabaseIdsValue: _showId,
      );

  Future<void> _save() async {
    if (_saving) return;
    final previousThreads = AiCameraSettings.processingThreads.value;
    _apply();
    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      final value = jsonEncode({
        'confidence': AiCameraSettings.confidence.value,
        'iou': AiCameraSettings.iou.value,
        'quality': AiCameraSettings.cropQuality.value,
        'masks': AiCameraSettings.detailedMasks.value,
        'processingThreads': AiCameraSettings.processingThreads.value,
        'modelInputSize': AiCameraSettings.modelInputSize,
        'showIds': AiCameraSettings.showDatabaseIds.value,
      });
      await db.into(db.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(key: 'ai_camera', value: value),
          );

      final inferenceState = ref.read(inferenceNotifierProvider);
      if (previousThreads != AiCameraSettings.processingThreads.value &&
          inferenceState.isModelLoaded) {
        await ref.read(inferenceNotifierProvider.notifier).reloadModel();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved locally.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not apply settings. Please try again.'),
        backgroundColor: AppTheme.errorColor,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reset() async {
    setState(() {
      _confidence = .27;
      _iou = .70;
      _quality = 98;
      _masks = true;
      _threads = 4;
      _showId = false;
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(0x1F1976D2),
                child: Icon(Icons.psychology_alt_rounded,
                    color: AppTheme.primaryColor),
              ),
              title: Text('High-accuracy carton model',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                'Fixed at 960 × 960 so every capture uses the verified high-detail model.',
              ),
              trailing:
                  Icon(Icons.verified_rounded, color: AppTheme.successColor),
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('DISPLAY SETTINGS'),
          const SizedBox(height: 8),
          AppCard(
            child: SwitchListTile.adaptive(
              title: const Text('Show Database IDs', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Display fingerprint IDs across all cards for debugging or manual lookups.'),
              value: _showId,
              onChanged: (val) => setState(() => _showId = val),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('COUNTING CONTROLS'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                _slider(
                  title: 'Confidence threshold',
                  description:
                      'Minimum certainty required before a carton is counted.',
                  value: _confidence,
                  minimum: .05,
                  maximum: 1,
                  divisions: 95,
                  onChanged: (value) => setState(() => _confidence = value),
                  label: '${(_confidence * 100).round()}%',
                ),
                const Divider(height: 24),
                _slider(
                  title: 'Overlap (IoU) threshold',
                  description:
                      'Controls when overlapping detections are treated as duplicates.',
                  value: _iou,
                  minimum: .20,
                  maximum: .95,
                  divisions: 75,
                  onChanged: (value) => setState(() => _iou = value),
                  label: '${(_iou * 100).round()}%',
                ),
                const Divider(height: 24),
                _slider(
                  title: 'Crop JPEG quality',
                  description:
                      'Quality of the selected carton-area image. The original audit photo remains unchanged.',
                  value: _quality,
                  minimum: 85,
                  maximum: 100,
                  divisions: 15,
                  onChanged: (value) => setState(() => _quality = value),
                  label: '${_quality.round()}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('PERFORMANCE & DETAIL'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('AI processing power',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                  'High performance uses more CPU power to finish analysis sooner.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  style: SegmentedButton.styleFrom(
                    side: BorderSide.none,
                    foregroundColor: AppTheme.textSecondary,
                    selectedForegroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: .06),
                    selectedBackgroundColor:
                        AppTheme.primaryColor.withValues(alpha: .82),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  segments: const [
                    ButtonSegment<int>(
                      value: 2,
                      icon: Icon(Icons.battery_5_bar_rounded),
                      label: Text('Balanced'),
                    ),
                    ButtonSegment<int>(
                      value: 4,
                      icon: Icon(Icons.bolt_rounded),
                      label: Text('High'),
                    ),
                  ],
                  selected: {_threads},
                  onSelectionChanged: (values) =>
                      setState(() => _threads = values.first),
                ),
                const Divider(height: 28),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _masks,
                  onChanged: (value) => setState(() => _masks = value),
                  title: const Text('Detailed carton outlines'),
                  subtitle: const Text(
                    'Shows precise carton shapes. Turning this off can reduce post-processing time.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle('EASY GUIDE'),
          const SizedBox(height: 8),
          const AppCard(
            child: Column(
              children: [
                _GuideItem(
                  icon: Icons.center_focus_strong_rounded,
                  title: 'Confidence',
                  text:
                      'Lower finds more possible cartons but may add false counts. Higher rejects uncertain cartons. At 100%, almost every real detection may be rejected. Recommended: 27%.',
                ),
                Divider(height: 20),
                _GuideItem(
                  icon: Icons.layers_rounded,
                  title: 'Overlap / IoU',
                  text:
                      'Higher keeps more nearby overlapping cartons. Lower removes more duplicate boxes but can remove cartons packed very close together. Recommended: 70%.',
                ),
                Divider(height: 20),
                _GuideItem(
                  icon: Icons.high_quality_rounded,
                  title: 'Crop JPEG quality',
                  text:
                      'Higher produces a sharper selected-area file but takes more storage and a little more encoding time. It never changes the original full-quality audit image. Recommended: 98%.',
                ),
                Divider(height: 20),
                _GuideItem(
                  icon: Icons.bolt_rounded,
                  title: 'Processing power',
                  text:
                      'High uses four AI CPU workers for quicker results and more power. Balanced uses two workers for less heat and battery use.',
                ),
                Divider(height: 20),
                _GuideItem(
                  icon: Icons.gesture_rounded,
                  title: 'Detailed outlines',
                  text:
                      'Keep enabled when you want precise carton boundaries during review. Disable only when faster post-processing matters more than shape detail.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Applying settings…' : 'Save locally'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _saving ? null : _reset,
            child: const Text('Reset recommended settings'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4),
      );

  Widget _slider({
    required String title,
    required String description,
    required double value,
    required double minimum,
    required double maximum,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Slider(
          value: value,
          min: minimum,
          max: maximum,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(text,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
