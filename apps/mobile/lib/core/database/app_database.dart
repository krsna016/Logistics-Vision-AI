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
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createPerformanceIndexes(m);
        await _createIntegrityIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Version 4 added the offline AI metadata/report tables and several
        // additive fields. Keep this migration data-preserving for installs
        // created by versions 1-3.
        if (from < 4) {
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

        // Version 12 retires the unused local sync outbox. It has never been
        // read or transmitted by the app, so removing it cannot affect
        // operational records.
        if (from < 12) {
          await m.database.customStatement('DROP TABLE IF EXISTS sync_queues');
        }
        // Version 13 removes the unused sync marker from every local record
        // table. The migration changes only that obsolete column; SQLite keeps
        // all operational rows and their remaining fields intact.
        if (from < 13) {
          const tablesWithLegacySyncStatus = <String>[
            'warehouses',
            'wagons',
            'trucks',
            'layers',
            'detections',
            'digital_registers',
            'loading_sessions',
            'dataset_images',
            'annotations',
            'device_sessions',
            'users',
            'report_exports',
          ];
          for (final table in tablesWithLegacySyncStatus) {
            await m.database
                .customStatement('ALTER TABLE $table DROP COLUMN sync_status');
          }
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
        if (from < 9) {
          await m.addColumn(layers, layers.croppedPhotoPath);
          await m.addColumn(layers, layers.countingRegionJson);
        }
        if (from < 10) {
          // Repair any legacy duplicate/gapped active layer numbers before
          // enforcing the per-truck invariant. Ordering is deterministic and
          // no layer, image, count, or audit record is discarded.
          await m.database.customStatement('''
            WITH ranked AS (
              SELECT id,
                     ROW_NUMBER() OVER (
                       PARTITION BY truck_id
                       ORDER BY layer_number, timestamp, created_at, id
                     ) AS next_layer_number
              FROM layers
              WHERE is_deleted = 0
            )
            UPDATE layers
            SET layer_number = (
              SELECT next_layer_number FROM ranked WHERE ranked.id = layers.id
            )
            WHERE id IN (SELECT id FROM ranked)
          ''');
          // A paused session is still the resumable session for its truck.
          // Legacy builds could create another session while one was paused;
          // keep the most recently updated session and close older duplicates.
          await m.database.customStatement('''
            WITH ranked AS (
              SELECT id,
                     ROW_NUMBER() OVER (
                       PARTITION BY truck_id
                       ORDER BY updated_at DESC, created_at DESC, id DESC
                     ) AS active_rank
              FROM loading_sessions
              WHERE is_deleted = 0 AND status IN ('started', 'paused')
            )
            UPDATE loading_sessions
            SET status = 'cancelled',
                end_time = COALESCE(end_time, CURRENT_TIMESTAMP),
                updated_at = CURRENT_TIMESTAMP
            WHERE id IN (SELECT id FROM ranked WHERE active_rank > 1)
          ''');
          await _createIntegrityIndexes(m);
        }
        if (from < 11) {
          // Persist the final verified masks with each layer so history can
          // reproduce exactly what the operator accepted during review.
          await m.addColumn(layers, layers.detectionsJson);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA busy_timeout = 5000');
        await customStatement('PRAGMA journal_mode = WAL');
        await customStatement('PRAGMA synchronous = NORMAL');
      },
    );
  }
}

Future<void> _createIntegrityIndexes(Migrator migrator) async {
  await migrator.database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_layers_unique_active_number '
    'ON layers (truck_id, layer_number) WHERE is_deleted = 0',
  );
  await migrator.database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_sessions_one_resumable_per_truck '
    "ON loading_sessions (truck_id) WHERE is_deleted = 0 AND status IN ('started', 'paused')",
  );
}

/// Foreign-key columns are not indexed automatically by SQLite. These cover
/// the filters and joins used by operational lists and analytics as local data
/// grows.
Future<void> _createPerformanceIndexes(Migrator migrator) async {
  const statements = <String>[
    'CREATE INDEX IF NOT EXISTS idx_trucks_wagon_active ON trucks (wagon_id, is_deleted, is_archived)',
    'CREATE INDEX IF NOT EXISTS idx_layers_truck_active_time ON layers (truck_id, is_deleted, timestamp)',
    'CREATE INDEX IF NOT EXISTS idx_detections_layer_active ON detections (layer_id, is_deleted)',
    'CREATE INDEX IF NOT EXISTS idx_loading_sessions_truck_active ON loading_sessions (truck_id, is_deleted)',
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
