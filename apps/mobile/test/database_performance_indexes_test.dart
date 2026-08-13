import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';

void main() {
  test('creates the operational query indexes on a fresh database', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final indexes = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final names = indexes.map((row) => row.data['name'] as String).toSet();

    expect(
        names,
        containsAll(<String>{
          'idx_trucks_wagon_active',
          'idx_layers_truck_active_time',
          'idx_detections_layer_active',
          'idx_loading_sessions_truck_active',
          'idx_sync_queues_retry',
          'idx_audit_logs_time_entity',
          'idx_layers_unique_active_number',
        }));

    final foreignKeys =
        await database.customSelect('PRAGMA foreign_keys').getSingle();
    final journalMode =
        await database.customSelect('PRAGMA journal_mode').getSingle();
    expect(foreignKeys.data.values.single, 1);
    // In-memory SQLite cannot use WAL, but the pragma must be successfully
    // configured and report a valid mode.
    expect(journalMode.data.values.single, isIn(<Object?>['memory', 'wal']));
  });
}
