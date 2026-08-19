import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/camera_notifier.dart';
import '../providers/camera_state.dart';
import '../providers/inference_notifier.dart';
import '../../domain/entities/detection.dart';
import '../../../layer/domain/entities/ai_result.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../layer/data/models/layer_model.dart';
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/storage/image_storage_service.dart';
import '../../../../core/ai_engine/models/ai_model.dart';
import '../../../../core/ai_engine/models/ai_model.dart';
import '../../../../utils/logger.dart';
import 'dart:convert';

/// Split Layer Mode Camera Screen
/// 
/// Guides user to take a Left and Right picture of a wide layer.
class SplitLayerCameraScreen extends ConsumerStatefulWidget {
  const SplitLayerCameraScreen({super.key});

  @override
  ConsumerState<SplitLayerCameraScreen> createState() =>
      _SplitLayerCameraScreenState();
}

class _SplitLayerCameraScreenState extends ConsumerState<SplitLayerCameraScreen> {
  final _imageStorage = ImageStorageService();

  int _step = 1;
  bool _isCapturing = false;
  String _processingMessage = '';

  String? _leftPhotoPath;
  int _leftCount = 0;
  String? _leftNotes;
  Map<String, int> _leftAllocations = {};
  List<Detection> _leftDetections = [];

  bool _torchOn = false;
  final _picker = ImagePicker();

  Future<void> _pickGalleryImage(String truckId) async {
    AppLogger.info('OPERATOR ACTION: Opened Photo Gallery (Split Camera)');
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    
    setState(() {
      _isCapturing = true;
      _processingMessage = 'Loading gallery photo...';
    });
    
    try {
      final bytes = await File(image.path).readAsBytes();
      final savedPath = await _imageStorage.saveImageBytes(bytes, 'split_part${_step}_$truckId');
      
      if (!mounted) return;
      // We still pass a dummy aiResult because the screen requires one instantly.
      final dummyResult = AIResult(
        detections: const [],
        count: 0,
        averageConfidence: 0.9,
        processingTimeMs: 0,
        modelVersion: AIModel.activeVersion,
        inferenceTimestamp: DateTime.now(),
        frameSize: const Size(720, 1280),
      );

      final reviewData = await context.push<Map<String, dynamic>>(
        '/trucks/$truckId/review', 
        extra: {
          'aiResult': dummyResult,
          'photoPath': savedPath,
          'auditPhotoPath': savedPath,
          'countingRegion': null,
          'returnResultOnly': true, 
        },
      );
      
      if (reviewData == null) {
        if (mounted) setState(() => _isCapturing = false);
        return;
      }

      await _processReviewData(reviewData, savedPath, truckId);
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery pick failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleTorch(CameraController? controller) async {
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final next = !_torchOn;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } catch (_) {}
  }

  Future<void> _capturePart(CameraController controller, String truckId) async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final photo = await controller.takePicture();

      final bytes = await File(photo.path).readAsBytes();
      final savedPath = await _imageStorage.saveImageBytes(bytes, 'split_part${_step}_$truckId');
      
      try {
        await File(photo.path).delete();
      } catch (_) {}

      if (!mounted) return;
      
      Future<AIResult> finalResultLoader() async {
        final detections = await ref.read(inferenceNotifierProvider.notifier).finalizeCapturedImageBytes(bytes);
        return AIResult(
          detections: detections,
          count: detections.length,
          averageConfidence: 0.9,
          processingTimeMs: 0,
          modelVersion: AIModel.activeVersion,
          inferenceTimestamp: DateTime.now(),
          frameSize: const Size(720, 1280),
        );
      }

      // We still pass a dummy aiResult because the screen requires one instantly.
      final dummyResult = AIResult(
        detections: const [],
        count: 0,
        averageConfidence: 0.9,
        processingTimeMs: 0,
        modelVersion: AIModel.activeVersion,
        inferenceTimestamp: DateTime.now(),
        frameSize: const Size(720, 1280),
      );

      if (mounted) setState(() => _isCapturing = false);

      final reviewData = await context.push<Map<String, dynamic>>(
        '/trucks/$truckId/review', 
        extra: {
          'aiResult': dummyResult,
          'photoPath': savedPath,
          'finalResultLoader': finalResultLoader,
          'returnResultOnly': true,
        },
      );

      if (reviewData == null) {
        // User pressed back without confirming
        if (mounted) setState(() => _isCapturing = false);
        return;
      }

      await _processReviewData(reviewData, savedPath, truckId);
    } catch (e) {
      AppLogger.error('Capture failed', e, null);
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _processingMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _processReviewData(Map<String, dynamic> reviewData, String savedPath, String truckId) async {
    if (_step == 1) {
      if (mounted) {
        setState(() {
          _leftPhotoPath = savedPath;
          _leftCount = reviewData['count'] as int;
          _leftAllocations = reviewData['allocations'] as Map<String, int>? ?? {};
          _leftDetections = (reviewData['detections'] as List<Detection>?) ?? [];
          _leftNotes = reviewData['notes'] as String?;
          _step = 2;
          _isCapturing = false;
          _processingMessage = '';
        });
      }
    } else {
      // Step 2 complete. Save it completely.
      final rightCount = reviewData['count'] as int;
      final rightAllocations = reviewData['allocations'] as Map<String, int>? ?? {};
      final rightDetections = (reviewData['detections'] as List<Detection>?) ?? [];
      final totalCount = _leftCount + rightCount;
      
      // Merge allocations
      final mergedAllocations = <String, int>{};
      for (final entry in _leftAllocations.entries) {
        mergedAllocations[entry.key] = (mergedAllocations[entry.key] ?? 0) + entry.value;
      }
      for (final entry in rightAllocations.entries) {
        mergedAllocations[entry.key] = (mergedAllocations[entry.key] ?? 0) + entry.value;
      }

      final rightNotes = reviewData['notes'] as String?;
      final combinedNotesList = [_leftNotes, rightNotes].where((n) => n != null && n.trim().isNotEmpty).toList();
      final combinedNotesString = combinedNotesList.join(' | ');

      final splitJson = jsonEncode({
        'isSplit': true,
        'part1Path': _leftPhotoPath,
        'part1Count': _leftCount,
        'part1Detections': _leftDetections.map(LayerModel.detectionToJson).toList(),
        'part2Path': savedPath,
        'part2Count': rightCount,
        'part2Detections': rightDetections.map(LayerModel.detectionToJson).toList(),
      });

      // We must save the full layer here.
      setState(() => _processingMessage = 'Saving combined layer...');
      
      final error = await ref.read(layerListProvider(truckId).notifier).saveLayer(
        cartonCount: totalCount,
        defectCount: (reviewData['defectCount'] as int? ?? 0),
        confidence: 0.9,
        notes: combinedNotesString.isEmpty 
            ? '[SPLIT_DATA]:$splitJson' 
            : '$combinedNotesString | [SPLIT_DATA]:$splitJson',
        itemAllocations: mergedAllocations.entries
            .map((e) => LayerItemAllocation(itemName: e.key, quantity: e.value))
            .toList(),
        photoPath: _leftPhotoPath,
        croppedPhotoPath: null,
        detections: [],
      );

      if (error == null) {
        AppLogger.info('Split Layer saved: $totalCount cartons.');
        if (mounted) context.go('/trucks/$truckId');
      } else {
        throw Exception(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final controller = cameraState.controller;
    final truckId = GoRouterState.of(context).pathParameters['id'] ?? '';

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _step == 2) {
          setState(() => _step = 1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (controller != null && controller.value.isInitialized)
              Positioned.fill(child: CameraPreview(controller)),

            if (_isCapturing)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primaryColor),
                        const SizedBox(height: 20),
                        Text(_processingMessage, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),

            if (!_isCapturing) ...[
              Positioned(
                top: 50, left: 20, right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        if (_step == 1) Navigator.pop(context);
                        else setState(() => _step = 1);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'SPLIT LAYER • Part $_step of 2',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Positioned(
                bottom: 120, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Text(
                    _step == 1 
                      ? 'Capture the LEFT side of the layer.' 
                      : 'Capture the RIGHT side of the layer.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 28,
                left: 28,
                right: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoundSplitButton(
                      icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      tooltip: _torchOn ? 'Turn flash off' : 'Turn flash on',
                      onTap: () => _toggleTorch(controller),
                    ),
                    Semantics(
                      button: true,
                      label: 'Capture layer',
                      child: GestureDetector(
                        onTap: () => _capturePart(controller!, truckId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 82,
                          height: 82,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RoundSplitButton(
                      icon: Icons.photo_library_outlined,
                      tooltip: 'Gallery',
                      onTap: () => _pickGalleryImage(truckId),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
class _RoundSplitButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundSplitButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onTap == null ? 0.42 : 1,
      duration: const Duration(milliseconds: 160),
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.58),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(icon.codePoint),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
