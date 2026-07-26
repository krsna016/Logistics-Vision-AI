import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync/connectivity_service.dart';
import '../sync/sync_manager.dart';
import 'database_provider.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final manager = SyncManager(db, connectivity);
  ref.onDispose(() => manager.dispose());
  return manager;
});
