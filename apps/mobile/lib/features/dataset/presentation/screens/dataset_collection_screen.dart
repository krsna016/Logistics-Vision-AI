import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dataset_providers.dart';
import '../../../../utils/logger.dart';

class DatasetCollectionScreen extends ConsumerStatefulWidget {
  const DatasetCollectionScreen({super.key});

  @override
  ConsumerState<DatasetCollectionScreen> createState() => _DatasetCollectionScreenState();
}

class _DatasetCollectionScreenState extends ConsumerState<DatasetCollectionScreen> {
  bool _isCaptured = false;
  String? _tempCapturedPath;
  final _notesCtrl = TextEditingController();

  // Simulated live exposure / sharpness parameters
  double _currentSharpness = 84.0;
  double _currentExposure = 120.0;
  double _currentBrightness = 135.0;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onCapture() {
    setState(() {
      _isCaptured = true;
      _tempCapturedPath = '/tmp/dataset_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    AppLogger.info('Dataset photo captured. Navigating to save confirmation.');
  }

  Future<void> _onSave() async {
    if (_tempCapturedPath == null) return;
    
    await ref.read(datasetListProvider.notifier).captureNewItem(
          brightness: _currentBrightness,
          exposure: _currentExposure,
          sharpness: _currentSharpness,
          warehouseId: 'warehouse_north',
          truckId: 'truck_scan_01',
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
          tempPhotoPath: _tempCapturedPath!,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dataset training photo saved successfully.')),
      );
      setState(() {
        _isCaptured = false;
        _tempCapturedPath = null;
        _notesCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double qualityScore = ((_currentSharpness / 100.0) * 0.6) + ((1.0 - ((_currentExposure - 128.0).abs() / 128.0)) * 0.4);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dataset Collector'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Underlay: Capture feed viewport (or preview container)
            _tempCapturedPath != null
                ? const Center(child: Icon(Icons.check_circle_outline, size: 100, color: Colors.green))
                : Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.white10, Colors.black],
                        radius: 0.95,
                      ),
                    ),
                  ),

            // Top Quality HUD panel
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHudIndicator('SHARPNESS', '${_currentSharpness.toStringAsFixed(0)}%'),
                    _buildHudIndicator('EXPOSURE', '${_currentExposure.toStringAsFixed(0)} lux'),
                    _buildHudIndicator('QUALITY', '${(qualityScore * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),

            // Center Guide Crosshair Overlay
            if (!_isCaptured)
              Center(
                child: Container(
                  width: size.width * 0.75,
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.6), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white60),
                          ),
                          child: const Icon(Icons.add, color: Colors.white60, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            // Save confirmation dialog popover
            if (_isCaptured)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Review Training Image',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Describe box types, stack patterns, defects...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isCaptured = false;
                                  _tempCapturedPath = null;
                                });
                              },
                              child: const Text('Retake'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Photo'),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

            // Capture FAB Trigger
            if (!_isCaptured)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    heroTag: 'dataset_capture_fab',
                    onPressed: _onCapture,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildHudIndicator(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
