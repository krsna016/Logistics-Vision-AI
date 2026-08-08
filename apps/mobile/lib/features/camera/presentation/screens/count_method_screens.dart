import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/storage/image_storage_service.dart';
import '../../../../utils/logger.dart';
import '../../../layer/presentation/providers/layer_providers.dart';

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

class ManualCountScreen extends ConsumerStatefulWidget {
  final String truckId;
  final VoidCallback? onAiSelected;

  const ManualCountScreen({
    super.key,
    required this.truckId,
    this.onAiSelected,
  });

  @override
  ConsumerState<ManualCountScreen> createState() => _ManualCountScreenState();
}

class _ManualCountScreenState extends ConsumerState<ManualCountScreen> {
  final _countController = TextEditingController();
  final _defectController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  final _imageStorage = ImageStorageService();
  String? _referencePhotoPath;
  bool _isSavingPhoto = false;
  bool _isSavingLayer = false;
  String? _error;

  Future<void> _switchToAi() async {
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(SystemChannels.textInput.invokeMethod<void>('TextInput.hide'));
    final onAiSelected = widget.onAiSelected;
    if (onAiSelected != null) {
      onAiSelected();
      return;
    }
    if (mounted) context.pushReplacement('/trucks/${widget.truckId}/camera');
  }

  @override
  void dispose() {
    _countController.dispose();
    _defectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureReferencePhoto() async {
    setState(() {
      _isSavingPhoto = true;
      _error = null;
    });
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
      if (mounted) setState(() => _referencePhotoPath = savedPath);
      if (previousPath != null) await _imageStorage.deleteImage(previousPath);
    } catch (error, stack) {
      AppLogger.error('Could not save manual reference photo', error, stack);
      if (mounted) {
        setState(
          () => _error = 'Could not save the reference photo. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingPhoto = false);
    }
  }

  Future<void> _removeReferencePhoto() async {
    final photoPath = _referencePhotoPath;
    if (photoPath == null || _isSavingPhoto) return;
    setState(() => _referencePhotoPath = null);
    await _imageStorage.deleteImage(photoPath);
  }

  void _adjustValue(TextEditingController controller, int delta) {
    final current = int.tryParse(controller.text.trim()) ?? 0;
    controller.text = '${(current + delta).clamp(0, 9999)}';
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _saveLayer() async {
    if (_isSavingLayer) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count < 0 || count > 9999) {
      setState(() => _error = 'Enter a whole number from 0 to 9,999.');
      return;
    }

    final defectCount = int.tryParse(_defectController.text.trim());
    if (defectCount == null || defectCount < 0 || defectCount > count) {
      setState(() => _error =
          'Defective items must be between 0 and the carton total ($count).');
      return;
    }

    setState(() {
      _isSavingLayer = true;
      _error = null;
    });
    try {
      final operatorNotes = _notesController.text.trim();
      final notes = [
        'Count method: Manual operator entry',
        if (operatorNotes.isNotEmpty) operatorNotes,
      ].join(' | ');
      final error =
          await ref.read(layerListProvider(widget.truckId).notifier).saveLayer(
                cartonCount: count,
                defectCount: defectCount,
                confidence: 0,
                notes: notes,
                photoPath: _referencePhotoPath,
              );
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _isSavingLayer = false;
          _error = error;
        });
        return;
      }
      AppLogger.info('Manual layer saved: $count cartons.');
      context.go('/trucks/${widget.truckId}');
    } catch (error, stack) {
      AppLogger.error('Failed to save manual layer', error, stack);
      if (mounted) {
        setState(() {
          _isSavingLayer = false;
          _error = 'Could not save this layer. Please try again.';
        });
      }
    }
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
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
        title: CountModeSwitcher(
          selectedMode: CountMode.manual,
          onAiSelected: _switchToAi,
          onManualSelected: () {},
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _ManualPhotoCard(
            photoPath: _referencePhotoPath,
            isBusy: _isSavingPhoto,
            onCapture: _captureReferencePhoto,
            onRemove: _removeReferencePhoto,
          ),
          const SizedBox(height: 22),
          _ManualNumberField(
            controller: _countController,
            label: 'Verified carton total',
            hint: '0',
            icon: Icons.inventory_2_outlined,
            onDecrease: () => _adjustValue(_countController, -1),
            onIncrease: () => _adjustValue(_countController, 1),
            onChanged: _clearError,
          ),
          const SizedBox(height: 14),
          _ManualNumberField(
            controller: _defectController,
            label: 'Defective items',
            hint: '0',
            icon: Icons.warning_amber_rounded,
            accentColor: AppTheme.warningColor,
            onDecrease: () => _adjustValue(_defectController, -1),
            onIncrease: () => _adjustValue(_defectController, 1),
            onChanged: _clearError,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            minLines: 1,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Add a short observation',
              prefixIcon: const Icon(Icons.notes_rounded),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.dividerColor.withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border(
              top: BorderSide(
                color: AppTheme.dividerColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _isSavingLayer ? null : _saveLayer,
              icon: _isSavingLayer
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSavingLayer ? 'Saving layer...' : 'Save Layer'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualPhotoCard extends StatelessWidget {
  final String? photoPath;
  final bool isBusy;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  const _ManualPhotoCard({
    required this.photoPath,
    required this.isBusy,
    required this.onCapture,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Material(
        color: AppTheme.surfaceColor,
        child: InkWell(
          onTap: isBusy ? null : onCapture,
          child: SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasPhoto)
                  Image.file(File(photoPath!), fit: BoxFit.cover)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF202B3A), Color(0xFF15181D)],
                      ),
                    ),
                  ),
                if (hasPhoto)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xC8000000)],
                      ),
                    ),
                  ),
                if (isBusy)
                  const Center(child: CircularProgressIndicator())
                else if (!hasPhoto)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CameraBadge(),
                      SizedBox(height: 13),
                      Text(
                        'Add layer photo',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to open the camera',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                else
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 13,
                    child: Row(
                      children: [
                        _PhotoActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Retake',
                          onTap: onCapture,
                        ),
                        const Spacer(),
                        _PhotoActionButton(
                          icon: Icons.close_rounded,
                          label: 'Remove',
                          onTap: onRemove,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.32),
            blurRadius: 24,
          ),
        ],
      ),
      child:
          const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 28),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 7),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<String> onChanged;

  const _ManualNumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.accentColor = AppTheme.primaryColor,
    required this.onDecrease,
    required this.onIncrease,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 12, 15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 56,
            child: Center(
              child: _StepButton(
                icon: Icons.remove_rounded,
                onTap: onDecrease,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 56,
            child: Center(
              child: _StepButton(
                icon: Icons.add_rounded,
                onTap: onIncrease,
                highlighted: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? AppTheme.primaryColor
          : AppTheme.backgroundColor.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

enum CountMode { ai, manual }

class CountModeSwitcher extends StatelessWidget {
  final CountMode selectedMode;
  final VoidCallback onAiSelected;
  final VoidCallback onManualSelected;

  const CountModeSwitcher({
    super.key,
    required this.selectedMode,
    required this.onAiSelected,
    required this.onManualSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Counting method',
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF484848),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CountModeOption(
              label: 'AI',
              selected: selectedMode == CountMode.ai,
              onTap: onAiSelected,
            ),
            _CountModeOption(
              label: 'Manual',
              selected: selectedMode == CountMode.manual,
              onTap: onManualSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountModeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CountModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF242424) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
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
