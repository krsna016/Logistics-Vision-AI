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
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          // Development workaround: Just recreate everything on schema changes
          for (final table in allTables) {
            try {
              await m.deleteTable(table.actualTableName);
            } catch (e) {
              // Ignore if it doesn't exist
            }
            await m.createTable(table);
          }
        }
      },
    );
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
