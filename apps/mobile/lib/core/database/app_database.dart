import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Warehouses,
  Wagons,
  Trucks,
  Layers,
  Detections,
  DigitalRegisters,
  LoadingSessions,
  AuditLogs,
  SyncQueues,
  DatasetImages,
  ImageMetadata,
  ImageQuality,
  Annotations,
  DatasetExports,
  ModelHistory,
  DeviceSessions,
  ReportExports,
  Users,
  Settings
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createPerformanceIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Version 4 added the offline AI metadata/report tables and several
        // additive fields. Keep this migration data-preserving for installs
        // created by versions 1-3.
        if (from < 4) {
          await m.addColumn(syncQueues, syncQueues.version);
          await m.addColumn(syncQueues, syncQueues.priority);
          await m.addColumn(syncQueues, syncQueues.createdAt);
          await m.addColumn(syncQueues, syncQueues.updatedAt);
          await m.database.customStatement(
              "UPDATE sync_queues SET status = 'queued' WHERE status = 'pending'");

          await m.addColumn(datasetImages, datasetImages.wagonId);
          await m.addColumn(datasetImages, datasetImages.layerNumber);
          await m.addColumn(datasetImages, datasetImages.approvalStatus);
          await m.addColumn(datasetImages, datasetImages.rejectReason);
          await m.addColumn(datasetImages, datasetImages.operatorId);
          await m.addColumn(datasetImages, datasetImages.timestamp);
          await m.addColumn(datasetImages, datasetImages.isExported);

          // employee_id did not exist before v4 and must be backfilled before
          // it can be represented as a required Drift column.
          await m.database.customStatement(
              "ALTER TABLE users ADD COLUMN employee_id TEXT NOT NULL DEFAULT ''");
          await m.addColumn(users, users.isActive);
          await m.addColumn(users, users.failedLoginAttempts);
          await m.addColumn(users, users.lockedUntil);

          await m.createTable(imageMetadata);
          await m.createTable(imageQuality);
          await m.createTable(annotations);
          await m.createTable(datasetExports);
          await m.createTable(modelHistory);
          await m.createTable(deviceSessions);
          await m.createTable(reportExports);
        }
        if (from < 5) {
          await m.addColumn(wagons, wagons.itemManifestJson);
          await m.addColumn(layers, layers.itemName);
        }
        if (from < 6) {
          await m.addColumn(layers, layers.itemAllocationsJson);
        }
        if (from < 7) {
          await m.database
              .customStatement("UPDATE users SET role = CASE LOWER(role) "
                  "WHEN 'admin' THEN 'administrator' "
                  "WHEN 'administrator' THEN 'administrator' "
                  "ELSE 'supervisor' END");
        }
        if (from < 8) {
          await _createPerformanceIndexes(m);
        }
      },
    );
  }
}

/// Foreign-key columns are not indexed automatically by SQLite. These cover
/// the filters and joins used by operational lists, analytics and the sync
/// retry queue as local data grows.
Future<void> _createPerformanceIndexes(Migrator migrator) async {
  const statements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_trucks_wagon_active ON trucks (wagon_id, is_deleted, is_archived)',
    'CREATE INDEX IF NOT EXISTS idx_layers_truck_active_time ON layers (truck_id, is_deleted, timestamp)',
    'CREATE INDEX IF NOT EXISTS idx_detections_layer_active ON detections (layer_id, is_deleted)',
    'CREATE INDEX IF NOT EXISTS idx_loading_sessions_truck_active ON loading_sessions (truck_id, is_deleted)',
    'CREATE INDEX IF NOT EXISTS idx_sync_queues_retry ON sync_queues (status, retry_count, priority, queued_at)',
    'CREATE INDEX IF NOT EXISTS idx_audit_logs_time_entity ON audit_logs (timestamp, entity_id)',
  ];
  for (final statement in statements) {
    await migrator.database.customStatement(statement);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smartload_offline.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
