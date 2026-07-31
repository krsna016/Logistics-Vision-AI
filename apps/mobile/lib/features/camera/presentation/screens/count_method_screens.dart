import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_theme.dart';
import '../../../layer/domain/entities/ai_result.dart';
import '../../../../core/storage/image_storage_service.dart';

class CountMethodSelectionScreen extends StatelessWidget {
  final String truckId;

  const CountMethodSelectionScreen({super.key, required this.truckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/wagons'),
        ),
        title: const Text('Choose Counting Method'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            const Icon(Icons.inventory_2_outlined,
                size: 58, color: AppTheme.primaryColor),
            const SizedBox(height: 18),
            const Text(
              'Count this layer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how the carton count will be recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 34),
            _MethodCard(
              icon: Icons.camera_alt_outlined,
              title: 'AI Camera',
              subtitle:
                  'Use live detection and verify the result before saving.',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/trucks/$truckId/camera/live'),
            ),
            const SizedBox(height: 16),
            _MethodCard(
              icon: Icons.edit_note_outlined,
              title: 'Manual Count',
              subtitle:
                  'Enter the verified carton total directly and continue to review.',
              color: AppTheme.warningColor,
              onTap: () => context.push('/trucks/$truckId/manual-count'),
            ),
            const Spacer(),
            Text(
              'The selected method is recorded with the layer review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class ManualCountScreen extends StatefulWidget {
  final String truckId;

  const ManualCountScreen({super.key, required this.truckId});

  @override
  State<ManualCountScreen> createState() => _ManualCountScreenState();
}

class _ManualCountScreenState extends State<ManualCountScreen> {
  final _countController = TextEditingController();
  final _defectController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  final _imageStorage = ImageStorageService();
  String? _referencePhotoPath;
  bool _isSavingPhoto = false;
  String? _error;

  @override
  void dispose() {
    _countController.dispose();
    _defectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureReferencePhoto() async {
    setState(() => _isSavingPhoto = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image == null) return;
      final savedPath = await _imageStorage.saveImage(
        File(image.path),
        'manual_layer_${widget.truckId}',
      );
      final previousPath = _referencePhotoPath;
      setState(() => _referencePhotoPath = savedPath);
      if (previousPath != null) {
        await _imageStorage.deleteImage(previousPath);
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = 'Could not save the reference photo. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isSavingPhoto = false);
    }
  }

  void _continue() {
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count < 0 || count > 9999) {
      setState(() => _error = 'Enter a whole number from 0 to 9,999.');
      return;
    }

    final defectCount = int.tryParse(_defectController.text.trim());
    if (defectCount == null || defectCount < 0 || defectCount > count) {
      setState(() => _error =
          'Defective boxes must be between 0 and the total boxes ($count).');
      return;
    }

    final result = AIResult(
      detections: const [],
      count: count,
      defectCount: defectCount,
      averageConfidence: 0,
      processingTimeMs: 0,
      modelVersion: 'MANUAL_COUNT',
      inferenceTimestamp: DateTime.now(),
      frameSize: const Size(720, 1280),
    );
    context.push('/trucks/${widget.truckId}/review', extra: {
      'aiResult': result,
      'photoPath': _referencePhotoPath,
      'manualNotes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/wagons'),
        ),
        title: const Text('Manual Count'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.35)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fact_check_outlined, color: AppTheme.warningColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Count the cartons physically, then enter the verified total below. This count will be marked as manual in the layer record.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _isSavingPhoto ? null : _captureReferencePhoto,
            icon: _isSavingPhoto
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt_outlined),
            label: Text(_referencePhotoPath == null
                ? 'Capture Layer Reference Photo'
                : 'Retake Reference Photo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          if (_referencePhotoPath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    Image.file(File(_referencePhotoPath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reference photo will be saved with this layer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          TextField(
            controller: _countController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Verified carton total',
              hintText: 'e.g. 48',
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _defectController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Defective boxes (included in total)',
              hintText: 'e.g. 2',
              helperText:
                  'These boxes are already included in the total above.',
              prefixIcon: Icon(Icons.warning_amber_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Add a reason or observation',
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _continue,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: 0.16),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
