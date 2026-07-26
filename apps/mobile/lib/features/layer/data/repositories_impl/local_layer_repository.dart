import 'package:drift/drift.dart' as drift;
import '../../domain/entities/layer.dart';
import '../../domain/repositories/layer_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../../core/database/app_database.dart';
import '../../../../utils/logger.dart';

class LocalLayerRepository implements LayerRepository {
  final AppDatabase _db;

  LocalLayerRepository(this._db);

  LayerRecord _map(Layer data) {
    return LayerRecord(
      id: data.id,
      truckId: data.truckId,
      layerNumber: data.layerNumber,
      cartonCount: data.cartonCount,
      timestamp: data.timestamp ?? DateTime.now(),
      operatorId: data.operatorId ?? '',
      photoPath: data.photoPath,
      notes: data.notes,
      modelVersion: data.modelVersion ?? '',
      averageConfidence: data.averageConfidence,
      syncStatus: SyncStatus.values.firstWhere((e) => e.name == data.syncStatus, orElse: () => SyncStatus.pending),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isDeleted: data.isDeleted,
    );
  }

  @override
  Future<List<LayerRecord>> getLayersByTruck(String truckId) async {
    try {
      final rows = await (_db.select(_db.layers)..where((t) => t.truckId.equals(truckId) & t.isDeleted.equals(false))).get();
      return rows.map(_map).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading layer records', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveLayer(LayerRecord layer) async {
    await _db.transaction(() async {
      await _db.into(_db.layers).insert(LayersCompanion.insert(
        id: layer.id,
        truckId: layer.truckId,
        layerNumber: layer.layerNumber,
        cartonCount: layer.cartonCount,
        defectCount: const drift.Value(0), // LayerRecord domain entity has no defectCount property currently? Wait it does? Ah, let me check. No, it doesn't. We'll set to 0.
        photoPath: drift.Value(layer.photoPath),
        notes: drift.Value(layer.notes),
        averageConfidence: drift.Value(layer.averageConfidence),
        timestamp: drift.Value(layer.timestamp),
        operatorId: drift.Value(layer.operatorId),
        modelVersion: drift.Value(layer.modelVersion),
        createdAt: drift.Value(layer.createdAt),
        updatedAt: drift.Value(layer.updatedAt),
      ));

      await _db.into(_db.syncQueues).insert(SyncQueuesCompanion.insert(
        id: 'sync_l_${DateTime.now().millisecondsSinceEpoch}',
        entityId: layer.id,
        entityType: 'Layer',
        operation: 'INSERT',
        payloadData: '{}',
      ));
    });
    AppLogger.info('Saved layer number ${layer.layerNumber} for truck ${layer.truckId}');
  }

  @override
  Future<void> updateLayer(LayerRecord layer) async {
    await _db.transaction(() async {
      await (_db.update(_db.layers)..where((t) => t.id.equals(layer.id))).write(LayersCompanion(
        truckId: drift.Value(layer.truckId),
        layerNumber: drift.Value(layer.layerNumber),
        cartonCount: drift.Value(layer.cartonCount),
        photoPath: drift.Value(layer.photoPath),
        notes: drift.Value(layer.notes),
        averageConfidence: drift.Value(layer.averageConfidence),
        timestamp: drift.Value(layer.timestamp),
        operatorId: drift.Value(layer.operatorId),
        modelVersion: drift.Value(layer.modelVersion),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.syncQueues).insert(SyncQueuesCompanion.insert(
        id: 'sync_l_${DateTime.now().millisecondsSinceEpoch}',
        entityId: layer.id,
        entityType: 'Layer',
        operation: 'UPDATE',
        payloadData: '{}',
      ));
    });
    AppLogger.info('Updated layer record: ${layer.id}');
  }

  @override
  Future<void> softDeleteLayer(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.layers)..where((t) => t.id.equals(id))).write(
        const LayersCompanion(isDeleted: drift.Value(true))
      );

      await _db.into(_db.syncQueues).insert(SyncQueuesCompanion.insert(
        id: 'sync_l_${DateTime.now().millisecondsSinceEpoch}',
        entityId: id,
        entityType: 'Layer',
        operation: 'DELETE',
        payloadData: '{}',
      ));
    });
    AppLogger.info('Soft deleted layer: $id');
  }

  @override
  Future<bool> isLayerNumberExists(String truckId, int layerNumber) async {
    final query = _db.select(_db.layers)..where((t) => t.truckId.equals(truckId) & t.layerNumber.equals(layerNumber) & t.isDeleted.equals(false));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> clearAndLoadDemoData() async {
    await _db.transaction(() async {
      await _db.delete(_db.layers).go();
      
      final now = DateTime.now();
      
      await _db.into(_db.layers).insert(LayersCompanion.insert(
        id: 'mock_l1',
        truckId: 'mock_t1',
        layerNumber: 1,
        cartonCount: 24,
        timestamp: drift.Value(now.subtract(const Duration(hours: 3))),
        operatorId: const drift.Value('usr_loader_01'),
        modelVersion: const drift.Value('1.0.0-YOLOv8n'),
        averageConfidence: const drift.Value(0.94),
        createdAt: drift.Value(now.subtract(const Duration(hours: 3))),
        updatedAt: drift.Value(now.subtract(const Duration(hours: 3))),
      ));
      
      await _db.into(_db.layers).insert(LayersCompanion.insert(
        id: 'mock_l2',
        truckId: 'mock_t1',
        layerNumber: 2,
        cartonCount: 24,
        timestamp: drift.Value(now.subtract(const Duration(hours: 2))),
        operatorId: const drift.Value('usr_loader_01'),
        modelVersion: const drift.Value('1.0.0-YOLOv8n'),
        averageConfidence: const drift.Value(0.96),
        createdAt: drift.Value(now.subtract(const Duration(hours: 2))),
        updatedAt: drift.Value(now.subtract(const Duration(hours: 2))),
      ));
      
      await _db.into(_db.layers).insert(LayersCompanion.insert(
        id: 'mock_l3',
        truckId: 'mock_t1',
        layerNumber: 3,
        cartonCount: 24,
        timestamp: drift.Value(now.subtract(const Duration(hours: 1))),
        operatorId: const drift.Value('usr_loader_01'),
        modelVersion: const drift.Value('1.0.0-YOLOv8n'),
        averageConfidence: const drift.Value(0.91),
        notes: const drift.Value('Slight carton slip corrected manually'),
        createdAt: drift.Value(now.subtract(const Duration(hours: 1))),
        updatedAt: drift.Value(now.subtract(const Duration(hours: 1))),
      ));
    });
  }
}
