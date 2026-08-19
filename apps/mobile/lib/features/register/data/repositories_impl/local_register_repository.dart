import '../../domain/entities/digital_register.dart';
import '../../domain/repositories/register_repository.dart';
import '../../../wagon/domain/repositories/wagon_repository.dart';
import '../../../truck/domain/repositories/truck_repository.dart';
import '../../../layer/domain/repositories/layer_repository.dart';
import '../../../layer/domain/entities/layer.dart';

class LocalRegisterRepository implements RegisterRepository {
  final WagonRepository wagonRepo;
  final TruckRepository truckRepo;
  final LayerRepository layerRepo;
  final String? supervisorName;
  final Map<String, int> _exportCounts = {};
  final Map<String, DateTime> _lastOpened = {};
  final Map<String, String> _customRemarks = {};

  LocalRegisterRepository({
    required this.wagonRepo,
    required this.truckRepo,
    required this.layerRepo,
    this.supervisorName,
  });

  @override
  Future<List<DigitalRegister>> getAllRegisters() async {
    final wagons = await wagonRepo.getActiveWagons();
    final allTrucks = await truckRepo.getActiveTrucks();

    final List<DigitalRegister> registers = [];

    for (final wagon in wagons) {
      final wagonTrucks = allTrucks
          .where((t) => t.wagonId == wagon.id && !t.isDeleted)
          .toList();

      final totalLayers = wagonTrucks.fold(0, (sum, t) => sum + t.totalLayers);
      final totalCartons =
          wagonTrucks.fold(0, (sum, t) => sum + t.totalCartons);
      final totalDefects =
          wagonTrucks.fold(0, (sum, t) => sum + t.totalDefects);
      final layersByTruck = <String, List<LayerRecord>>{};
      for (final truck in wagonTrucks) {
        layersByTruck[truck.id] = await layerRepo.getLayersByTruck(truck.id);
      }
      final loadedByItem = await wagonRepo.getLoadedItemQuantities(wagon.id);
      final itemBalances = wagon.items
          .map((item) => RegisterItemBalance(
                itemName: item.name,
                manifest: item.quantity,
                loaded: loadedByItem[item.name] ?? 0,
              ))
          .toList(growable: false);

      // Only report an interval supported by local operational records.  A
      // fabricated fallback made new or short operations appear to have taken
      // 3h45m in the digital register and its exports.
      Duration duration = Duration.zero;
      if (wagonTrucks.isNotEmpty) {
        final earliest = wagonTrucks
            .map((t) => t.createdDate)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final latest = wagonTrucks
            .map((t) => t.completedDate ?? t.updatedDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        duration = latest.isAfter(earliest)
            ? latest.difference(earliest)
            : Duration.zero;
      }

      registers.add(
        DigitalRegister(
          id: 'reg_${wagon.id}',
          wagonId: wagon.id,
          wagonNumber: wagon.wagonNumber,
          origin: wagon.origin,
          destination: wagon.destination,
          loadingDate: wagon.loadingDate,
          supervisor: supervisorName?.trim().isNotEmpty == true
              ? supervisorName!.trim()
              : 'Not provided',
          remarks: _customRemarks[wagon.id] ?? wagon.remarks,
          status: wagon.status,
          totalTrucks: wagonTrucks.length,
          totalLayers: totalLayers,
          totalCartons: totalCartons,
          totalDefects: totalDefects,
          loadingDuration: duration,
          generatedAt: wagon.updatedAt,
          lastOpenedAt: _lastOpened[wagon.id] ?? wagon.updatedAt,
          exportCount: _exportCounts[wagon.id] ?? 0,
          trucks: wagonTrucks,
          itemBalances: itemBalances,
          layersByTruck: layersByTruck,
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
      final wagon = await wagonRepo.getWagonById(reg.wagonId);
      if (wagon != null) {
        await wagonRepo.updateWagon(
          wagon.copyWith(remarks: remarks, updatedAt: DateTime.now()),
        );
      }
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
