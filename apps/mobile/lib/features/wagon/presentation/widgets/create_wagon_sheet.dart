import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wagon_providers.dart';
import '../../domain/entities/wagon.dart';
import '../screens/wagon_number_scan_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../../truck/data/services/scanner_camera_warmup.dart';
import '../../../../core/presentation/widgets/unsaved_changes_guard.dart';
import '../../../../core/utils/formatters.dart';

class CreateWagonSheet extends ConsumerStatefulWidget {
  final Wagon? existingWagon;

  const CreateWagonSheet({super.key, this.existingWagon});

  @override
  ConsumerState<CreateWagonSheet> createState() => _CreateWagonSheetState();
}

class _CreateWagonSheetState extends ConsumerState<CreateWagonSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _originCtrl;
  late TextEditingController _destinationCtrl;
  late TextEditingController _remarksCtrl;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isDirty = false;
  String? _errorMessage;
  final List<_ItemControllers> _items = [];

  @override
  void initState() {
    super.initState();
    final wagon = widget.existingWagon;
    _numberCtrl = TextEditingController(text: wagon?.wagonNumber.toIdentifierFormat());
    _originCtrl = TextEditingController(text: wagon?.origin.toTitleCase() ?? '');
    _destinationCtrl = TextEditingController(text: wagon?.destination?.toTitleCase());
    _remarksCtrl = TextEditingController(text: wagon?.remarks?.toSentenceCase());
    _selectedDate = wagon?.loadingDate ?? DateTime.now();
    _items.addAll((wagon?.items ?? const <WagonItem>[]).map(
      (item) => _ItemControllers(item.name.toTitleCase(), item.quantity.toString()),

    ));
    if (_items.isEmpty) _items.add(_ItemControllers('', ''));
    for (final controller in [
      _numberCtrl,
      _originCtrl,
      _destinationCtrl,
      _remarksCtrl,
    ]) {
      controller.addListener(_markDirty);
    }
    for (final item in _items) {
      _listenToItem(item);
    }
    // Let the sheet transition finish before opening the native camera. Starting
    // Camera2 during the route animation produces a visible hitch on Android.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (mounted) unawaited(ScannerCameraWarmup.prepare());
      });
    });
  }

  void _markDirty() {
    if (!_isDirty && mounted) setState(() => _isDirty = true);
  }

  void _listenToItem(_ItemControllers item) {
    item.name.addListener(_markDirty);
    item.quantity.addListener(_markDirty);
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _remarksCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    unawaited(ScannerCameraWarmup.release());
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isDirty = true;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final manifest = _manifestItems();
    final normalizedNames =
        manifest.map((item) => item.name.toLowerCase()).toList();
    if (normalizedNames.toSet().length != normalizedNames.length) {
      setState(() => _errorMessage = 'Each item name must be unique.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final notifier = ref.read(wagonListProvider.notifier);

    final error = widget.existingWagon == null
        ? await notifier.createWagon(
            wagonNumber: _numberCtrl.text.toIdentifierFormat(),
            origin: _originCtrl.text.trim().isEmpty ? 'NIL' : _originCtrl.text.trim().toTitleCase(),
            destination: _destinationCtrl.text.trim().isEmpty ? 'NIL' : _destinationCtrl.text.trim().toTitleCase(),
            loadingDate: _selectedDate,
            remarks: _remarksCtrl.text.isEmpty ? 'NIL' : _remarksCtrl.text.trim().toSentenceCase(),
            items: manifest,
          )
        : await _updateExistingWagon(notifier, manifest);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _errorMessage = error;
        if (error == null) _isDirty = false;
      });

      if (error == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> _scanWagonNumber() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const WagonNumberScanScreen()),
    );
    if (result != null && mounted) {
      _numberCtrl.text = result;
      _numberCtrl.selection = TextSelection.collapsed(
        offset: _numberCtrl.text.length,
      );
    }
  }

  Future<String?> _updateExistingWagon(
      WagonListNotifier notifier, List<WagonItem> items) async {
    final current = widget.existingWagon!;
    return notifier.updateWagon(current.copyWith(
      wagonNumber: _numberCtrl.text.toIdentifierFormat(),
      origin: _originCtrl.text.trim().isEmpty ? 'NIL' : _originCtrl.text.trim().toTitleCase(),
      destination: _destinationCtrl.text.trim().isEmpty ? 'NIL' : _destinationCtrl.text.trim().toTitleCase(),
      loadingDate: _selectedDate,
      expectedTruckCount: 0,
      remarks: _remarksCtrl.text.trim().isEmpty ? 'NIL' : _remarksCtrl.text.trim().toSentenceCase(),
      items: items,
    ));
  }

  List<WagonItem> _manifestItems() => _items
      .where((row) => row.name.text.trim().isNotEmpty)
      .map((row) => WagonItem(
            name: row.name.text.trim().toTitleCase(),
            quantity: int.parse(row.quantity.text.trim()),
          ))
      .toList();

  void _addItem() => setState(() {
        final item = _ItemControllers('', '');
        _listenToItem(item);
        _items.add(item);
        _isDirty = true;
      });

  void _removeItem(int index) {
    setState(() {
      final removed = _items.removeAt(index);
      removed.dispose();
      if (_items.isEmpty) {
        final item = _ItemControllers('', '');
        _listenToItem(item);
        _items.add(item);
      }
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _isDirty,
      isSaving: _isSaving,
      message: 'The wagon details and item manifest have not been saved.',
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Theme.of(context)
                  .inputDecorationTheme
                  .copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppTheme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.errorColor),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppTheme.errorColor,
                        width: 1.5,
                      ),
                    ),
                  ),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pull Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      widget.existingWagon == null
                          ? 'Register New Wagon'
                          : 'Edit Wagon',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                    TextFormField(
                      controller: _numberCtrl,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [UpperCaseNoSpaceTextFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Wagon Number*',
                        hintText: 'e.g. BCNAHSM131142324907',
                        suffixIcon: IconButton(
                          onPressed: _isSaving ? null : _scanWagonNumber,
                          icon: const Icon(Icons.document_scanner_outlined),
                          tooltip: 'Scan wagon number',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Required.'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _originCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [TitleCaseTextFormatter()],
                      decoration: const InputDecoration(
                          labelText: 'Origin Facility (Optional)',
                          hintText: 'e.g. Austin Fulfillment South'),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _destinationCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [TitleCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Destination Depot (Optional)',
                        hintText: 'e.g. Chicago Logistics Terminal',
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.dividerColor),
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _remarksCtrl,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [SentenceCaseTextFormatter()],
                      decoration: const InputDecoration(
                          labelText: 'Remarks (Optional)'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Wagon Item Manifest',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        TextButton.icon(
                          onPressed: _isSaving ? null : _addItem,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const Text(
                      'Enter the carton quantity received in this wagon for every item.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_items.length, (index) {
                      final row = _items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: row.name,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [TitleCaseTextFormatter()],
                                decoration: InputDecoration(
                                  labelText: 'Item ${index + 1}',
                                  hintText: 'e.g. Item A',
                                ),
                                validator: (value) {
                                  final quantityEntered =
                                      row.quantity.text.trim().isNotEmpty;
                                  if (quantityEntered &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Enter item name.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: row.quantity,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cartons',
                                  hintText: '0',
                                ),
                                validator: (value) {
                                  final nameEntered =
                                      row.name.text.trim().isNotEmpty;
                                  if (!nameEntered &&
                                      (value == null || value.trim().isEmpty)) {
                                    return null;
                                  }
                                  final quantity =
                                      int.tryParse(value?.trim() ?? '');
                                  if (quantity == null || quantity <= 0) {
                                    return 'Enter > 0.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  _isSaving ? null : () => _removeItem(index),
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.errorColor),
                              tooltip: 'Remove item',
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(widget.existingWagon == null
                              ? 'Create Wagon'
                              : 'Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemControllers {
  final TextEditingController name;
  final TextEditingController quantity;

  _ItemControllers(String itemName, String itemQuantity)
      : name = TextEditingController(text: itemName),
        quantity = TextEditingController(text: itemQuantity);

  void dispose() {
    name.dispose();
    quantity.dispose();
  }
}
