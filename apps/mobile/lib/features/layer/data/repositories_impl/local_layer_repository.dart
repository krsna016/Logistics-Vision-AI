import 'package:drift/drift.dart' as drift;
import '../../domain/entities/layer.dart';
import '../../domain/repositories/layer_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/storage/image_storage_service.dart';
import '../../../../utils/logger.dart';

class LocalLayerRepository implements LayerRepository {
  final AppDatabase _db;
  final ImageStorageService _imageStorage = ImageStorageService();

  LocalLayerRepository(this._db);

  LayerRecord _map(Layer data) {
    return LayerRecord(
      id: data.id,
      truckId: data.truckId,
      layerNumber: data.layerNumber,
      cartonCount: data.cartonCount,
      defectCount: data.defectCount,
      timestamp: data.timestamp ?? DateTime.now(),
      operatorId: data.operatorId ?? '',
      photoPath: data.photoPath,
      notes: data.notes,
      modelVersion: data.modelVersion ?? '',
      averageConfidence: data.averageConfidence,
      syncStatus: SyncStatus.values.firstWhere((e) => e.name == data.syncStatus,
          orElse: () => SyncStatus.pending),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isDeleted: data.isDeleted,
    );
  }

  @override
  Future<List<LayerRecord>> getLayersByTruck(String truckId) async {
    try {
      final rows = await (_db.select(_db.layers)
            ..where(
                (t) => t.truckId.equals(truckId) & t.isDeleted.equals(false)))
          .get();
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
            defectCount: drift.Value(layer.defectCount),
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
    AppLogger.info(
        'Saved layer number ${layer.layerNumber} for truck ${layer.truckId}');
  }

  @override
  Future<void> updateLayer(LayerRecord layer,
      {String? correctionReason}) async {
    final existing = await (_db.select(_db.layers)
          ..where((t) => t.id.equals(layer.id)))
        .getSingleOrNull();
    if (existing == null || existing.isDeleted) return;
    await _db.transaction(() async {
      await (_db.update(_db.layers)..where((t) => t.id.equals(layer.id)))
          .write(LayersCompanion(
        truckId: drift.Value(layer.truckId),
        layerNumber: drift.Value(layer.layerNumber),
        cartonCount: drift.Value(layer.cartonCount),
        defectCount: drift.Value(layer.defectCount),
        photoPath: drift.Value(layer.photoPath),
        notes: drift.Value(layer.notes),
        averageConfidence: drift.Value(layer.averageConfidence),
        timestamp: drift.Value(layer.timestamp),
        operatorId: drift.Value(layer.operatorId),
        modelVersion: drift.Value(layer.modelVersion),
        updatedAt: drift.Value(DateTime.now()),
      ));

      final activeLayers = await (_db.select(_db.layers)
            ..where((item) =>
                item.truckId.equals(layer.truckId) &
                item.isDeleted.equals(false)))
          .get();
      final totalCartons =
          activeLayers.fold<int>(0, (sum, item) => sum + item.cartonCount);
      final totalDefects =
          activeLayers.fold<int>(0, (sum, item) => sum + item.defectCount);
      final averageConfidence = activeLayers.isEmpty
          ? 0.0
          : activeLayers.fold<double>(
                  0, (sum, item) => sum + item.averageConfidence) /
              activeLayers.length;
      await (_db.update(_db.trucks)
            ..where((truck) => truck.id.equals(layer.truckId)))
          .write(TrucksCompanion(
        totalLayers: drift.Value(activeLayers.length),
        totalCartons: drift.Value(totalCartons),
        totalDefects: drift.Value(totalDefects),
        updatedAt: drift.Value(DateTime.now()),
      ));
      await (_db.update(_db.loadingSessions)
            ..where((session) =>
                session.truckId.equals(layer.truckId) &
                session.isDeleted.equals(false)))
          .write(LoadingSessionsCompanion(
        totalLayers: drift.Value(activeLayers.length),
        totalCartons: drift.Value(totalCartons),
        totalDefects: drift.Value(totalDefects),
        averageConfidence: drift.Value(averageConfidence),
        updatedAt: drift.Value(DateTime.now()),
      ));

      final countChanged = existing.cartonCount != layer.cartonCount ||
          existing.defectCount != layer.defectCount;
      if (countChanged) {
        await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
              id: 'audit_layer_correct_${DateTime.now().microsecondsSinceEpoch}',
              entityId: layer.id,
              entityType: 'Layer',
              action: 'correct',
              userId: layer.operatorId,
              details: drift.Value(
                'Layer ${layer.layerNumber}: cartons '
                '${existing.cartonCount} -> ${layer.cartonCount}, defects '
                '${existing.defectCount} -> ${layer.defectCount}. Reason: '
                '${correctionReason?.trim().isNotEmpty == true ? correctionReason!.trim() : 'Not provided'}',
              ),
            ));
      }

      await _db.into(_db.syncQueues).insert(SyncQueuesCompanion.insert(
            id: 'sync_l_${DateTime.now().microsecondsSinceEpoch}',
            entityId: layer.id,
            entityType: 'Layer',
            operation: 'UPDATE',
            payloadData: correctionReason?.trim().isNotEmpty == true
                ? '{"correctionReason":"${correctionReason!.trim().replaceAll('"', '\\"')}"}'
                : '{}',
          ));
    });
    if (existing.photoPath != null && existing.photoPath != layer.photoPath) {
      await _imageStorage.deleteImage(existing.photoPath!);
    }
    AppLogger.info('Updated layer record: ${layer.id}');
  }

  @override
  Future<void> softDeleteLayer(String id) async {
    final existing = await (_db.select(_db.layers)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null || existing.isDeleted) return;
    await _db.transaction(() async {
      await (_db.update(_db.layers)..where((t) => t.id.equals(id)))
          .write(LayersCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(DateTime.now()),
      ));
      await (_db.update(_db.detections)
            ..where((detection) => detection.layerId.equals(id)))
          .write(DetectionsCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(DateTime.now()),
      ));

      final activeLayers = await (_db.select(_db.layers)
            ..where((layer) =>
                layer.truckId.equals(existing.truckId) &
                layer.isDeleted.equals(false)))
          .get();
      final totalCartons =
          activeLayers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
      final totalDefects =
          activeLayers.fold<int>(0, (sum, layer) => sum + layer.defectCount);
      final averageConfidence = activeLayers.isEmpty
          ? 0.0
          : activeLayers.fold<double>(
                  0, (sum, layer) => sum + layer.averageConfidence) /
              activeLayers.length;

      await (_db.update(_db.trucks)
            ..where((truck) => truck.id.equals(existing.truckId)))
          .write(TrucksCompanion(
        totalLayers: drift.Value(activeLayers.length),
        totalCartons: drift.Value(totalCartons),
        totalDefects: drift.Value(totalDefects),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await (_db.update(_db.loadingSessions)
            ..where((session) =>
                session.truckId.equals(existing.truckId) &
                session.isDeleted.equals(false)))
          .write(LoadingSessionsCompanion(
        totalLayers: drift.Value(activeLayers.length),
        totalCartons: drift.Value(totalCartons),
        totalDefects: drift.Value(totalDefects),
        averageConfidence: drift.Value(averageConfidence),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
            id: 'audit_layer_delete_${DateTime.now().microsecondsSinceEpoch}',
            entityId: id,
            entityType: 'Layer',
            action: 'delete',
            userId: existing.operatorId ?? 'local_operator',
            details: drift.Value(
              'Voided layer ${existing.layerNumber}; removed '
              '${existing.cartonCount} cartons and ${existing.defectCount} defects.',
            ),
          ));

      await _db.into(_db.syncQueues).insert(SyncQueuesCompanion.insert(
            id: 'sync_l_${DateTime.now().microsecondsSinceEpoch}',
            entityId: id,
            entityType: 'Layer',
            operation: 'DELETE',
            payloadData: '{"cascadeTotals":true}',
          ));
    });
    if (existing.photoPath != null) {
      await _imageStorage.deleteImage(existing.photoPath!);
    }
    AppLogger.info('Soft deleted layer: $id');
  }

  @override
  Future<bool> isLayerNumberExists(String truckId, int layerNumber) async {
    final query = _db.select(_db.layers)
      ..where((t) =>
          t.truckId.equals(truckId) &
          t.layerNumber.equals(layerNumber) &
          t.isDeleted.equals(false));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> clearAllData() async {
    await _db.delete(_db.layers).go();
  }

  @override
  Future<void> loadDemoData() async {
    await _db.transaction(() async {
      final now = DateTime(2026, 7, 21, 18, 0);
      Future<void> insertLayer({
        required String id,
        required String truckId,
        required int layerNumber,
        required int cartons,
        required Duration age,
        required double confidence,
        String? notes,
      }) async {
        final timestamp = now.subtract(age);
        await _db.into(_db.layers).insert(LayersCompanion.insert(
              id: id,
              truckId: truckId,
              layerNumber: layerNumber,
              cartonCount: cartons,
              timestamp: drift.Value(timestamp),
              operatorId: const drift.Value('operator_demo'),
              modelVersion: const drift.Value('yolo11n_carton_seg_v1_3'),
              averageConfidence: drift.Value(confidence),
              notes: drift.Value(notes),
              createdAt: drift.Value(timestamp),
              updatedAt: drift.Value(timestamp),
            ));
      }

      const truckData =
          <({String id, List<int> quantities, List<String> items})>[
        (
          id: 'sheet_truck_1965',
          quantities: [
            55,
            55,
            55,
            55,
            55,
            55,
            55,
            55,
            55,
            56,
            35,
            35,
            35,
            35,
            69
          ],
          items: [
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Mango PP',
            'Saffron',
            'Saffron',
            'Saffron',
            'Saffron',
            'Saffron'
          ]
        ),
        (
          id: 'sheet_truck_3459',
          quantities: [
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            54,
            30
          ],
          items: [
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju',
            'P.P. Kaju'
          ]
        ),
        (
          id: 'sheet_truck_4076',
          quantities: [
            40,
            40,
            40,
            40,
            40,
            76,
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            94
          ],
          items: [
            'Saffron',
            'Saffron',
            'Saffron',
            'Saffron',
            'Saffron',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango'
          ]
        ),
        (
          id: 'sheet_truck_1671',
          quantities: [
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            57,
            37,
            37,
            135
          ],
          items: [
            'New Kaju',
            'New Kaju',
            'New Kaju',
            'New Kaju',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Saffron',
            'Saffron',
            'Saffron'
          ]
        ),
        (
          id: 'sheet_truck_628',
          quantities: [
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            70,
            45,
            65,
            27,
            50,
            50,
            75,
            63
          ],
          items: [
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Mango',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Sample PP',
            'Mango',
            'Mango'
          ]
        ),
      ];
      var layerIndex = 1;
      for (final truck in truckData) {
        for (var index = 0; index < truck.quantities.length; index++) {
          await insertLayer(
            id: 'sheet_layer_${layerIndex++}',
            truckId: truck.id,
            layerNumber: index + 1,
            cartons: truck.quantities[index],
            age: Duration(minutes: (truckData.length * 20) - layerIndex),
            confidence: 0.90 + ((index % 5) * 0.02),
            notes: truck.items[index],
          );
        }
      }
    });
  }
}
