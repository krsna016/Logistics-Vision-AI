import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/truck.dart';
import '../providers/truck_providers.dart';
import '../screens/vehicle_number_scanner_screen.dart';
import '../../../../theme/app_theme.dart';

class TruckFormDialog extends ConsumerStatefulWidget {
  final Truck? existingTruck;
  final String? wagonId;
  final bool allowArchivedEdit;

  const TruckFormDialog({
    super.key,
    this.existingTruck,
    this.wagonId,
    this.allowArchivedEdit = false,
  });

  @override
  ConsumerState<TruckFormDialog> createState() => _TruckFormDialogState();
}

class _TruckFormDialogState extends ConsumerState<TruckFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _vehicleNumberCtrl;
  late TextEditingController _driverNameCtrl;
  late TextEditingController _driverMobileCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _warehouseCtrl;
  late TextEditingController _notesCtrl;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTruck;

    _vehicleNumberCtrl = TextEditingController(text: t?.vehicleNumber ?? '');
    _driverNameCtrl = TextEditingController(text: t?.driverName ?? '');
    _driverMobileCtrl = TextEditingController(text: t?.driverMobile ?? '');
    _companyCtrl = TextEditingController(text: t?.company ?? '');
    _warehouseCtrl = TextEditingController(text: t?.warehouse ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _vehicleNumberCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverMobileCtrl.dispose();
    _companyCtrl.dispose();
    _warehouseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    String? error;
    final notifier = ref.read(truckListProvider.notifier);

    if (widget.existingTruck == null) {
      error = await notifier.createTruck(
        truckNumber: _vehicleNumberCtrl.text,
        vehicleNumber: _vehicleNumberCtrl.text,
        driverName:
            _driverNameCtrl.text.trim().isEmpty ? 'NIL' : _driverNameCtrl.text,
        driverMobile: _driverMobileCtrl.text.trim().isEmpty
            ? 'NIL'
            : _driverMobileCtrl.text,
        company: _companyCtrl.text.trim().isEmpty ? 'NIL' : _companyCtrl.text,
        warehouse:
            _warehouseCtrl.text.trim().isEmpty ? 'NIL' : _warehouseCtrl.text,
        notes: _notesCtrl.text.isEmpty ? 'NIL' : _notesCtrl.text,
        wagonId: widget.wagonId,
      );
    } else {
      final updated = widget.existingTruck!.copyWith(
        truckNumber: _vehicleNumberCtrl.text.trim(),
        vehicleNumber: _vehicleNumberCtrl.text.trim(),
        driverName: _driverNameCtrl.text.trim().isEmpty
            ? 'NIL'
            : _driverNameCtrl.text.trim(),
        driverMobile: _driverMobileCtrl.text.trim().isEmpty
            ? 'NIL'
            : _driverMobileCtrl.text.trim(),
        company:
            _companyCtrl.text.trim().isEmpty ? 'NIL' : _companyCtrl.text.trim(),
        warehouse: _warehouseCtrl.text.trim().isEmpty
            ? 'NIL'
            : _warehouseCtrl.text.trim(),
        notes: _notesCtrl.text.isEmpty ? 'NIL' : _notesCtrl.text,
      );
      error = await notifier.editTruck(
        updated,
        allowArchived: widget.allowArchivedEdit,
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _errorMessage = error;
      });

      if (error == null) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTruck != null;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return AnimatedPadding(
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
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
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
                    isEdit ? 'Modify Truck Session' : 'Register New Truck',
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
                    controller: _vehicleNumberCtrl,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Number*',
                      hintText: 'e.g. V-101',
                      suffixIcon: IconButton(
                        tooltip: 'Open vehicle number scanner',
                        onPressed: _isSaving ? null : _scanVehicleNumber,
                        icon: const Icon(Icons.document_scanner_outlined),
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Required.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _driverNameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Driver Name (Optional)',
                        hintText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _driverMobileCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Driver Mobile Number',
                        hintText: 'e.g. +91 9876543210'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _companyCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Carrier Company (Optional)',
                        hintText: 'e.g. Swift Carriers'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _warehouseCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Warehouse Facility (Optional)',
                        hintText: 'e.g. Austin Fulfillment South'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Notes (Optional)'),
                  ),
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
                        : Text(isEdit ? 'Update Truck' : 'Register Truck'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanVehicleNumber() async {
    final scannedNumber = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const VehicleNumberScannerScreen()),
    );
    if (!mounted || scannedNumber == null || scannedNumber.trim().isEmpty) {
      return;
    }
    setState(() {
      _vehicleNumberCtrl.text = scannedNumber;
      _vehicleNumberCtrl.selection = TextSelection.collapsed(
        offset: _vehicleNumberCtrl.text.length,
      );
    });
  }
}
