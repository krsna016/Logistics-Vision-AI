import 'dart:convert';
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
    var allocations = <LayerItemAllocation>[];
    try {
      allocations = (jsonDecode(data.itemAllocationsJson) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(LayerItemAllocation.fromJson)
          .where((allocation) =>
              allocation.itemName.isNotEmpty && allocation.quantity > 0)
          .toList();
    } catch (_) {
      // Fall through to the version-5 single-item compatibility value.
    }
    if (allocations.isEmpty && data.itemName?.trim().isNotEmpty == true) {
      allocations = [
        LayerItemAllocation(
            itemName: data.itemName!.trim(), quantity: data.cartonCount),
      ];
    }
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
      itemName: data.itemName,
      itemAllocations: allocations,
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
            itemName: drift.Value(layer.itemName),
            itemAllocationsJson: drift.Value(jsonEncode(layer.itemAllocations
                .map((allocation) => allocation.toJson())
                .toList())),
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
    final nextAllocationsJson = jsonEncode(layer.itemAllocations
        .map((allocation) => allocation.toJson())
        .toList());
    final allocatedCartons = layer.itemAllocations
        .fold<int>(0, (sum, allocation) => sum + allocation.quantity);
    final effectiveCartons =
        allocatedCartons > 0 ? allocatedCartons : layer.cartonCount;
    await _db.transaction(() async {
      await (_db.update(_db.layers)..where((t) => t.id.equals(layer.id)))
          .write(LayersCompanion(
        truckId: drift.Value(layer.truckId),
        layerNumber: drift.Value(layer.layerNumber),
        cartonCount: drift.Value(effectiveCartons),
        defectCount: drift.Value(layer.defectCount),
        photoPath: drift.Value(layer.photoPath),
        notes: drift.Value(layer.notes),
        itemName: drift.Value(layer.itemName),
        itemAllocationsJson: drift.Value(nextAllocationsJson),
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

      final countChanged = existing.cartonCount != effectiveCartons ||
          existing.defectCount != layer.defectCount ||
          existing.itemAllocationsJson != nextAllocationsJson;
      if (countChanged) {
        await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
              id: 'audit_layer_correct_${DateTime.now().microsecondsSinceEpoch}',
              entityId: layer.id,
              entityType: 'Layer',
              action: 'correct',
              userId: layer.operatorId,
              details: drift.Value(
                'Layer ${layer.layerNumber}: cartons '
                '${existing.cartonCount} -> $effectiveCartons, defects '
                '${existing.defectCount} -> ${layer.defectCount}. Reason: '
                '${correctionReason?.trim().isNotEmpty == true ? correctionReason!.trim() : 'Not provided'}. '
                'Items: ${existing.itemAllocationsJson} -> $nextAllocationsJson',
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
  Future<void> loadDemoData({String? operatorName}) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      final demoOperator = operatorName?.trim().isNotEmpty == true
          ? operatorName!.trim()
          : 'Logged-in User';
      Future<void> add(
          {required String id,
          required String truckId,
          required int number,
          required List<Map<String, Object>> items,
          required int defects,
          required int minutesAgo,
          required String operator,
          String? notes,
          bool deleted = false,
          double confidence = 0.94}) async {
        final cartons =
            items.fold<int>(0, (sum, item) => sum + (item['quantity']! as int));
        final timestamp = now.subtract(Duration(minutes: minutesAgo));
        await _db.into(_db.layers).insert(LayersCompanion.insert(
              id: id,
              truckId: truckId,
              layerNumber: number,
              cartonCount: cartons,
              defectCount: drift.Value(defects),
              itemName: drift.Value(items.length == 1
                  ? items.first['itemName']! as String
                  : null),
              itemAllocationsJson: drift.Value(jsonEncode(items)),
              timestamp: drift.Value(timestamp),
              operatorId: drift.Value(operator),
              modelVersion: const drift.Value('enterprise-demo-yolo26-seg'),
              averageConfidence: drift.Value(confidence),
              notes: drift.Value(notes),
              isDeleted: drift.Value(deleted),
              createdAt: drift.Value(timestamp),
              updatedAt: drift.Value(timestamp),
            ));
      }

      await add(
          id: 'demo_layer_active_1',
          truckId: 'demo_truck_active_1',
          number: 1,
          defects: 0,
          minutesAgo: 180,
          operator: demoOperator,
          notes: 'Seal verified | Count method: AI assisted',
          items: const [
            {'itemName': 'Premium Rice', 'quantity': 60},
          ]);
      await add(
          id: 'demo_layer_active_2',
          truckId: 'demo_truck_active_1',
          number: 2,
          defects: 2,
          minutesAgo: 120,
          operator: demoOperator,
          notes: 'Two dented cartons isolated for supervisor review',
          confidence: 0.87,
          items: const [
            {'itemName': 'Premium Rice', 'quantity': 20},
            {'itemName': 'Assam Tea', 'quantity': 40},
          ]);
      await add(
          id: 'demo_layer_active_3',
          truckId: 'demo_truck_active_1',
          number: 3,
          defects: 0,
          minutesAgo: 45,
          operator: demoOperator,
          notes: 'Mixed SKU layer - manually verified',
          items: const [
            {'itemName': 'Assam Tea', 'quantity': 10},
            {'itemName': 'Whole Spices', 'quantity': 30},
          ]);
      await add(
          id: 'demo_layer_complete_1',
          truckId: 'demo_truck_completed_1',
          number: 1,
          defects: 0,
          minutesAgo: 7600,
          operator: demoOperator,
          items: const [
            {'itemName': 'Consumer Electronics', 'quantity': 70}
          ]);
      await add(
          id: 'demo_layer_complete_2',
          truckId: 'demo_truck_completed_1',
          number: 2,
          defects: 0,
          minutesAgo: 7540,
          operator: demoOperator,
          items: const [
            {'itemName': 'Consumer Electronics', 'quantity': 30},
            {'itemName': 'Home Appliances', 'quantity': 20},
          ]);
      await add(
          id: 'demo_layer_complete_3',
          truckId: 'demo_truck_completed_2',
          number: 1,
          defects: 1,
          minutesAgo: 7480,
          operator: demoOperator,
          notes: 'One packaging tear recorded',
          items: const [
            {'itemName': 'Consumer Electronics', 'quantity': 40},
            {'itemName': 'Home Appliances', 'quantity': 20},
          ]);
      await add(
          id: 'demo_layer_complete_4',
          truckId: 'demo_truck_completed_2',
          number: 2,
          defects: 0,
          minutesAgo: 7420,
          operator: demoOperator,
          items: const [
            {'itemName': 'Home Appliances', 'quantity': 60}
          ]);
      await add(
          id: 'demo_layer_archived_1',
          truckId: 'demo_truck_archived',
          number: 1,
          defects: 0,
          minutesAgo: 43300,
          operator: demoOperator,
          items: const [
            {'itemName': 'Auto Parts', 'quantity': 60}
          ]);
      await add(
          id: 'demo_layer_archived_2',
          truckId: 'demo_truck_archived',
          number: 2,
          defects: 0,
          minutesAgo: 43240,
          operator: demoOperator,
          items: const [
            {'itemName': 'Auto Parts', 'quantity': 20},
            {'itemName': 'Lubricants', 'quantity': 10},
          ]);
      const enterpriseItems = [
        'Packaged Foods',
        'Personal Care',
        'Household Goods',
      ];
      var enterpriseLayerId = 1;
      for (var truckIndex = 0; truckIndex < 6; truckIndex++) {
        final layerCount = 15 + truckIndex;
        for (var layerIndex = 0; layerIndex < layerCount; layerIndex++) {
          final first = enterpriseItems[layerIndex % 3];
          final second = enterpriseItems[(layerIndex + 1) % 3];
          await add(
            id: 'demo_layer_enterprise_${enterpriseLayerId++}',
            truckId: 'demo_truck_enterprise_${truckIndex + 1}',
            number: layerIndex + 1,
            defects: layerIndex == 7 && truckIndex % 3 != 0 ? 1 : 0,
            minutesAgo: 600 - (truckIndex * 70 + layerIndex * 3),
            operator: demoOperator,
            notes: layerIndex % 7 == 0
                ? 'Mixed-item layer manually verified'
                : null,
            confidence: 0.91 + ((layerIndex % 5) * 0.01),
            items: [
              {'itemName': first, 'quantity': 25},
              {'itemName': second, 'quantity': 15},
            ],
          );
        }
      }
      await add(
          id: 'demo_layer_deleted',
          truckId: 'demo_truck_active_1',
          number: 99,
          defects: 0,
          minutesAgo: 10,
          operator: demoOperator,
          deleted: true,
          items: const [
            {'itemName': 'Premium Rice', 'quantity': 10}
          ]);

      await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
            id: 'demo_audit_correction',
            entityId: 'demo_layer_active_2',
            entityType: 'Layer',
            action: 'correct',
            userId: demoOperator,
            timestamp: drift.Value(now.subtract(const Duration(minutes: 110))),
            details: const drift.Value(
                'Layer 2: cartons 55 -> 60, defects 1 -> 2. Reason: Physical recount after damaged cartons were isolated. Items: [{"itemName":"Premium Rice","quantity":20},{"itemName":"Assam Tea","quantity":35}] -> [{"itemName":"Premium Rice","quantity":20},{"itemName":"Assam Tea","quantity":40}]'),
          ));
      await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
            id: 'demo_audit_deleted_layer',
            entityId: 'demo_layer_deleted',
            entityType: 'Layer',
            action: 'delete',
            userId: demoOperator,
            timestamp: drift.Value(now.subtract(const Duration(minutes: 9))),
            details: const drift.Value(
                'Soft-deleted test layer; excluded from totals and reports.'),
          ));
      for (var index = 1; index <= 3; index++) {
        const correctedLayerIds = [1, 16, 32];
        await _db.into(_db.auditLogs).insert(AuditLogsCompanion.insert(
              id: 'demo_audit_enterprise_$index',
              entityId: 'demo_layer_enterprise_${correctedLayerIds[index - 1]}',
              entityType: 'Layer',
              action: 'correct',
              userId: demoOperator,
              timestamp: drift.Value(
                  now.subtract(Duration(minutes: 500 - index * 40))),
              details: const drift.Value(
                'Layer 1: cartons 40 -> 40, defects 0 -> 0. '
                'Reason: Item-wise recount confirmed the layer total. '
                'Items: [{"itemName":"Packaged Foods","quantity":20},'
                '{"itemName":"Personal Care","quantity":20}] -> '
                '[{"itemName":"Packaged Foods","quantity":25},'
                '{"itemName":"Personal Care","quantity":15}]',
              ),
            ));
      }
      await _db
          .into(_db.loadingSessions)
          .insert(LoadingSessionsCompanion.insert(
            id: 'demo_session_completed',
            truckId: 'demo_truck_completed_1',
            startTime: now.subtract(const Duration(days: 5, hours: 3)),
            endTime:
                drift.Value(now.subtract(const Duration(days: 5, hours: 1))),
            operatorId: demoOperator,
            status: 'completed',
            totalLayers: const drift.Value(2),
            totalCartons: const drift.Value(120),
            totalDefects: const drift.Value(0),
            averageConfidence: const drift.Value(0.95),
            modelVersion: const drift.Value('enterprise-demo-yolo26-seg'),
          ));
      await _db
          .into(_db.digitalRegisters)
          .insert(DigitalRegistersCompanion.insert(
            id: 'demo_register_completed',
            wagonId: 'demo_wagon_completed',
            wagonNumber: 'BCNHL-699842',
            generatedBy: demoOperator,
            shift: 'Day Shift',
            verificationHash: 'DEMO-699842-VERIFIED',
            totalTrucks: 2,
            totalLayers: 4,
            totalCartons: 240,
          ));
    });
  }

  Future<void> loadLegacyDemoData() async {
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
