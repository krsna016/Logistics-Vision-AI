import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/truck.dart';
import '../providers/truck_providers.dart';

class TruckFormDialog extends ConsumerStatefulWidget {
  final Truck? existingTruck;
  final String? wagonId;

  const TruckFormDialog({super.key, this.existingTruck, this.wagonId});

  @override
  ConsumerState<TruckFormDialog> createState() => _TruckFormDialogState();
}

class _TruckFormDialogState extends ConsumerState<TruckFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _truckNumberCtrl;
  late TextEditingController _vehicleNumberCtrl;
  late TextEditingController _driverNameCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _warehouseCtrl;
  late TextEditingController _notesCtrl;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTruck;
    _truckNumberCtrl = TextEditingController(text: t?.truckNumber ?? '');
    _vehicleNumberCtrl = TextEditingController(text: t?.vehicleNumber ?? '');
    _driverNameCtrl = TextEditingController(text: t?.driverName ?? '');
    _companyCtrl = TextEditingController(text: t?.company ?? '');
    _warehouseCtrl = TextEditingController(text: t?.warehouse ?? 'Austin Fulfillment South');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _truckNumberCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _driverNameCtrl.dispose();
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
        truckNumber: _truckNumberCtrl.text,
        vehicleNumber: _vehicleNumberCtrl.text,
        driverName: _driverNameCtrl.text,
        company: _companyCtrl.text,
        warehouse: _warehouseCtrl.text,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        wagonId: widget.wagonId,
      );
    } else {
      final updated = widget.existingTruck!.copyWith(
        truckNumber: _truckNumberCtrl.text.trim(),
        vehicleNumber: _vehicleNumberCtrl.text.trim(),
        driverName: _driverNameCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        warehouse: _warehouseCtrl.text.trim(),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );
      error = await notifier.editTruck(updated);
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

    return AlertDialog(
      title: Text(isEdit ? 'Modify Truck Session' : 'Register New Truck'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: _truckNumberCtrl,
                decoration: const InputDecoration(labelText: 'Truck Number (License)*', hintText: 'e.g. TX-9908-AB'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Truck number is required.';
                  if (val.trim().length < 3) return 'Too short.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vehicleNumberCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle Number*', hintText: 'e.g. V-101'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _driverNameCtrl,
                decoration: const InputDecoration(labelText: 'Driver Name*', hintText: 'Full name'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyCtrl,
                decoration: const InputDecoration(labelText: 'Carrier Company*', hintText: 'e.g. Swift Carriers'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warehouseCtrl,
                decoration: const InputDecoration(labelText: 'Warehouse Facility*'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }
}
