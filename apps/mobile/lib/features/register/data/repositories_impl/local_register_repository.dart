import 'package:flutter/foundation.dart';
import '../../domain/entities/digital_register.dart';
import '../../domain/repositories/register_repository.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../wagon/domain/repositories/wagon_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/domain/repositories/truck_repository.dart';

class LocalRegisterRepository implements RegisterRepository {
  final WagonRepository wagonRepo;
  final TruckRepository truckRepo;
  final Map<String, int> _exportCounts = {};
  final Map<String, DateTime> _lastOpened = {};
  final Map<String, String> _customRemarks = {};

  LocalRegisterRepository({
    required this.wagonRepo,
    required this.truckRepo,
  });

  @override
  Future<List<DigitalRegister>> getAllRegisters() async {
    final wagons = await wagonRepo.getActiveWagons();
    final allTrucks = await truckRepo.getActiveTrucks();

    final List<DigitalRegister> registers = [];

    for (final wagon in wagons) {
      final wagonTrucks = allTrucks.where((t) => t.wagonId == wagon.id && !t.isDeleted).toList();
      
      final totalLayers = wagonTrucks.fold(0, (sum, t) => sum + t.totalLayers);
      final totalCartons = wagonTrucks.fold(0, (sum, t) => sum + t.totalCartons);
      final totalDefects = wagonTrucks.fold(0, (sum, t) => sum + t.totalDefects);

      // Duration calculation estimate
      Duration duration = const Duration(hours: 3, minutes: 45);
      if (wagonTrucks.isNotEmpty) {
        final earliest = wagonTrucks.map((t) => t.createdDate).reduce((a, b) => a.isBefore(b) ? a : b);
        final latest = wagonTrucks.map((t) => t.updatedDate).reduce((a, b) => a.isAfter(b) ? a : b);
        final diff = latest.difference(earliest);
        if (diff.inMinutes > 5) {
          duration = diff;
        }
      }

      registers.add(
        DigitalRegister(
          id: 'reg_${wagon.id}',
          wagonId: wagon.id,
          wagonNumber: wagon.wagonNumber,
          origin: wagon.origin,
          destination: wagon.destination,
          loadingDate: wagon.loadingDate,
          supervisor: 'Anurag Sharma (Supervisor)',
          remarks: _customRemarks[wagon.id] ?? wagon.remarks ?? 'Manual correction applied for Layer 3.',
          status: wagon.status,
          totalTrucks: wagonTrucks.length,
          totalLayers: totalLayers,
          totalCartons: totalCartons,
          totalDefects: totalDefects,
          loadingDuration: duration,
          generatedAt: wagon.updatedAt,
          lastOpenedAt: _lastOpened[wagon.id] ?? wagon.updatedAt,
          exportCount: _exportCounts[wagon.id] ?? 2,
          trucks: wagonTrucks,
        ),
      );
    }

    return registers;
  }

  @override
  Future<DigitalRegister?> getRegisterById(String id) async {
    final registers = await getAllRegisters();
    try {
      return registers.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DigitalRegister?> getRegisterByWagonId(String wagonId) async {
    final registers = await getAllRegisters();
    try {
      return registers.firstWhere((r) => r.wagonId == wagonId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateRemarks(String registerId, String remarks) async {
    final reg = await getRegisterById(registerId);
    if (reg != null) {
      _customRemarks[reg.wagonId] = remarks;
    }
  }

  @override
  Future<void> incrementExportCount(String registerId) async {
    final reg = await getRegisterById(registerId);
    if (reg != null) {
      _exportCounts[reg.wagonId] = (_exportCounts[reg.wagonId] ?? 0) + 1;
    }
  }

  @override
  Future<void> updateLastOpened(String registerId) async {
    final reg = await getRegisterById(registerId);
    if (reg != null) {
      _lastOpened[reg.wagonId] = DateTime.now();
    }
  }
}
