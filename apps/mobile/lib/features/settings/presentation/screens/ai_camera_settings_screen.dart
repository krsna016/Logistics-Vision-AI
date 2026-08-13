import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai_engine/ai_camera_settings.dart';
import '../../../camera/presentation/providers/inference_notifier.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../../../../theme/app_theme.dart';

class AiCameraSettingsScreen extends ConsumerStatefulWidget {
  const AiCameraSettingsScreen({super.key});

  @override
  ConsumerState<AiCameraSettingsScreen> createState() =>
      _AiCameraSettingsScreenState();
}

class _AiCameraSettingsScreenState
    extends ConsumerState<AiCameraSettingsScreen> {
  double _confidence = AiCameraSettings.confidence.value;
  int _inputSize = AiCameraSettings.inputSize.value;
  double _iou = AiCameraSettings.iou.value;
  double _quality = AiCameraSettings.cropQuality.value.toDouble();
  bool _masks = AiCameraSettings.detailedMasks.value;
  bool _timings = AiCameraSettings.showTimings.value;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await (ref.read(databaseProvider).select(
              ref.read(databaseProvider).settings,
            )..where((s) => s.key.equals('ai_camera')))
        .get();
    if (!mounted) return;
    if (rows.isNotEmpty) {
      final data = jsonDecode(rows.first.value) as Map<String, dynamic>;
      setState(() {
        _confidence = (data['confidence'] as num?)?.toDouble() ?? _confidence;
        _inputSize = (data['inputSize'] as num?)?.toInt() == 640 ? 640 : 960;
        _iou = (data['iou'] as num?)?.toDouble() ?? _iou;
        _quality = (data['quality'] as num?)?.toDouble() ?? _quality;
        _masks = data['masks'] as bool? ?? _masks;
        _timings = data['timings'] as bool? ?? _timings;
      });
      _apply();
    }
    setState(() => _loading = false);
  }

  void _apply() => AiCameraSettings.apply(
        confidenceValue: _confidence,
        inputSizeValue: _inputSize,
        iouValue: _iou,
        cropQualityValue: _quality.round(),
        detailedMasksValue: _masks,
        showTimingsValue: _timings,
      );

  Future<void> _save() async {
    final previousInputSize = AiCameraSettings.inputSize.value;
    _apply();
    if (mounted) setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final value = jsonEncode({
      'confidence': _confidence,
      'inputSize': _inputSize,
      'iou': _iou,
      'quality': _quality.round(),
      'masks': _masks,
      'timings': _timings,
    });
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'ai_camera', value: value),
        );
    if (previousInputSize != AiCameraSettings.inputSize.value) {
      try {
        await ref.read(inferenceNotifierProvider.notifier).reloadModel();
      } catch (_) {
        // The current model remains available if a device cannot load the
        // selected packaged variant.
      }
    }
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI camera settings saved locally.')),
      );
    }
  }

  Future<void> _reset() async {
    setState(() {
      _confidence = .27;
      _iou = .70;
      _quality = 96;
      _masks = true;
      _timings = false;
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('AI Camera Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AI PROCESSING',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                _slider(
                    'Confidence threshold',
                    _confidence,
                    .10,
                    .80,
                    (v) => setState(() => _confidence = v),
                    _confidence.toStringAsFixed(2)),
                _slider('Overlap (IoU) threshold', _iou, .30, .95,
                    (v) => setState(() => _iou = v), _iou.toStringAsFixed(2)),
                _slider('Crop JPEG quality', _quality, 85, 100,
                    (v) => setState(() => _quality = v), '${_quality.round()}'),
                SwitchListTile.adaptive(
                  value: _masks,
                  onChanged: (v) => setState(() => _masks = v),
                  title: const Text('Detailed outlines and masks'),
                  subtitle: const Text('More detail, slightly more processing'),
                ),
                SwitchListTile.adaptive(
                  value: _timings,
                  onChanged: (v) => setState(() => _timings = v),
                  title: const Text('Show timing diagnostics'),
                  subtitle: const Text('Useful for performance audits'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('MODEL INPUT',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.aspect_ratio,
                      color: AppTheme.primaryColor),
                  title: const Text('960 × 960'),
                  selected: _inputSize == 960,
                  onTap: () => setState(() => _inputSize = 960),
                  subtitle: const Text(
                      'Required by the currently loaded ONNX model.'),
                  trailing: const Icon(Icons.check_circle,
                      color: AppTheme.successColor),
                ),
                ListTile(
                  selected: _inputSize == 640,
                  onTap: () => setState(() => _inputSize = 640),
                  leading: const Icon(Icons.speed),
                  title: const Text('640 × 640'),
                  subtitle: const Text(
                      'Fast model variant; verify accuracy on operational carton photos.'),
                  trailing: Icon(_inputSize == 640
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off),
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
          TextButton(
              onPressed: _reset,
              child: const Text('Reset recommended settings')),
        ],
      ),
    );
  }

  Widget _slider(String title, double value, double min, double max,
      ValueChanged<double> onChanged, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        Slider(
            value: value,
            min: min,
            max: max,
            divisions: 100,
            onChanged: onChanged),
      ],
    );
  }
}
