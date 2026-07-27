import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wagon_providers.dart';

class CreateWagonSheet extends ConsumerStatefulWidget {
  const CreateWagonSheet({super.key});

  @override
  ConsumerState<CreateWagonSheet> createState() => _CreateWagonSheetState();
}

class _CreateWagonSheetState extends ConsumerState<CreateWagonSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _originCtrl;
  late TextEditingController _destinationCtrl;
  late TextEditingController _expectedTrucksCtrl;
  late TextEditingController _remarksCtrl;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController();
    _originCtrl = TextEditingController(text: 'Austin Fulfillment South');
    _destinationCtrl = TextEditingController();
    _expectedTrucksCtrl = TextEditingController(text: '5');
    _remarksCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _originCtrl.dispose();
    _destinationCtrl.dispose();
    _expectedTrucksCtrl.dispose();
    _remarksCtrl.dispose();
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
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final expectedCount = int.tryParse(_expectedTrucksCtrl.text) ?? 5;
    final notifier = ref.read(wagonListProvider.notifier);

    final error = await notifier.createWagon(
      wagonNumber: _numberCtrl.text,
      origin: _originCtrl.text.trim().isEmpty ? 'NIL' : _originCtrl.text,
      destination: _destinationCtrl.text.trim().isEmpty ? 'NIL' : _destinationCtrl.text,
      loadingDate: _selectedDate,
      expectedTruckCount: expectedCount,
      remarks: _remarksCtrl.text.isEmpty ? 'NIL' : _remarksCtrl.text,
    );

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
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: bottomInset + 24.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              const Text(
                'Register New Wagon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),

              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Wagon Number*',
                  hintText: 'e.g. W-8890-TX',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required.' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _originCtrl,
                decoration: const InputDecoration(labelText: 'Origin Facility (Optional)'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _destinationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destination Depot (Optional)',
                  hintText: 'e.g. Chicago Logistics Terminal',
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _expectedTrucksCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Expected Trucks (Optional)'),
                      validator: (val) {
                        if (val != null && val.isNotEmpty && int.tryParse(val) == null) return 'Invalid number.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _remarksCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Remarks (Optional)'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Wagon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
