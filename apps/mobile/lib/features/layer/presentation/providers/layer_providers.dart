import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/layer.dart';
import '../../domain/repositories/layer_repository.dart';
import '../../data/repositories_impl/local_layer_repository.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../../../core/utils/audit_logger.dart';
import '../../../../utils/logger.dart';
import '../../../../services/storage_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

import '../../../../core/providers/database_provider.dart';

final layerRepositoryProvider = Provider<LayerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalLayerRepository(db);
});

class LayerListState {
  final List<LayerRecord> layers;
  final bool isLoading;
  final String? errorMessage;

  const LayerListState({
    this.layers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LayerListState copyWith({
    List<LayerRecord>? layers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LayerListState(
      layers: layers ?? this.layers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LayerListNotifier extends StateNotifier<LayerListState> {
  final LayerRepository _layerRepository;
  final Ref _ref;
  final String _truckId;

  LayerListNotifier(this._layerRepository, this._ref, this._truckId)
      : super(const LayerListState()) {
    refresh();
  }

  /// Resolve the operator at save time. Auth state can briefly be empty while
  /// the remote session is being refreshed, so fall back to the locally synced
  /// Users table instead of writing a mock operator id.
  Future<String> _operatorName() async {
    final authenticatedUser = _ref.read(authProvider);
    if (authenticatedUser != null && authenticatedUser.name.trim().isNotEmpty) {
      return authenticatedUser.name.trim();
    }

    final db = _ref.read(databaseProvider);
    final token = await const FlutterSecureStorage()
        .read(key: StorageService.keyJwtToken);
    String? employeeId;
    if (token != null && token.isNotEmpty) {
      try {
        final claims = JwtDecoder.decode(token);
        final exp = claims['exp'];
        final tokenUsable = exp == null ||
            (exp is num &&
                DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000)
                    .isAfter(DateTime.now()));
        final subject = claims['sub'];
        if (tokenUsable && subject is String && subject.trim().isNotEmpty) {
          employeeId = subject.trim();
        }
      } catch (_) {
        // Fall back to the local active user lookup below.
      }
    }

    if (employeeId != null) {
      final matchingByEmployeeId = await (db.select(db.users)
            ..where((user) => user.employeeId.equals(employeeId!)))
          .getSingleOrNull();
      final matchingUser = matchingByEmployeeId ??
          await (db.select(db.users)
                ..where((user) => user.id.equals(employeeId!)))
              .getSingleOrNull();
      if (matchingUser != null && matchingUser.name.trim().isNotEmpty) {
        return matchingUser.name.trim();
      }
    }

    // A single active local user is unambiguous on a newly provisioned device.
    final activeUsers = await (db.select(db.users)
          ..where((user) => user.isActive.equals(true)))
        .get();
    if (activeUsers.length == 1 && activeUsers.first.name.trim().isNotEmpty) {
      return activeUsers.first.name.trim();
    }

    return employeeId ?? 'Unknown Operator';
  }

  Future<void> refresh() async {
    final hasExistingData = state.layers.isNotEmpty;
    if (!hasExistingData) state = state.copyWith(isLoading: true);
    try {
      final list = await _layerRepository.getLayersByTruck(_truckId);
      // Sort layers chronologically or by layer number ascending
      list.sort((a, b) => a.layerNumber.compareTo(b.layerNumber));
      state =
          state.copyWith(layers: list, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to read layers list.');
    }
  }

  Future<String?> saveLayer({
    required int cartonCount,
    int defectCount = 0,
    required double confidence,
    String? notes,
    String? photoPath,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final nextLayerNum =
          state.layers.isEmpty ? 1 : state.layers.last.layerNumber + 1;

      // Verify double save checks
      final exists =
          await _layerRepository.isLayerNumberExists(_truckId, nextLayerNum);
      if (exists) {
        state = state.copyWith(isLoading: false);
        return 'Layer number $nextLayerNum already registered.';
      }

      final newRecord = LayerRecord(
        id: const Uuid().v4(),
        truckId: _truckId,
        layerNumber: nextLayerNum,
        cartonCount: cartonCount,
        defectCount: defectCount,
        timestamp: DateTime.now(),
        operatorId: await _operatorName(),
        photoPath: photoPath,
        notes: notes,
        modelVersion: 'yolo11n_carton_seg_v1_3',
        averageConfidence: confidence,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _layerRepository.saveLayer(newRecord);

      // Business Rule BR-02: Automatically update parent truck total counts
      final truckRepo = _ref.read(truckRepositoryProvider);
      final currentTruck = await truckRepo.getTruckById(_truckId);
      if (currentTruck != null) {
        final updatedTruck = currentTruck.copyWith(
          totalLayers: currentTruck.totalLayers + 1,
          totalCartons: currentTruck.totalCartons + cartonCount,
          totalDefects: currentTruck.totalDefects + defectCount,
          updatedDate: DateTime.now(),
        );
        await truckRepo.updateTruck(updatedTruck);
        // Refresh the parent truck list provider to update the dashboard stats!
        _ref.read(truckListProvider.notifier).refresh();
      }

      // Update Session Progress
      await _ref
          .read(activeSessionProvider.notifier)
          .recordLayerCaptured(cartonCount, defectCount);

      // Audit Log
      AuditLogger.log(AuditEvent.layerCaptured,
          'Captured layer $nextLayerNum for truck $_truckId with $cartonCount cartons ($defectCount defective).',
          metadata: {
            'truckId': _truckId,
            'layerNumber': nextLayerNum,
            'cartonCount': cartonCount,
            'defectCount': defectCount,
          });

      await refresh();
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      AppLogger.error('Failed to save layer', e);
      return 'Failed to save layer session.';
    }
  }

  Future<String?> editNotes(String layerId, String? nextNotes) async {
    try {
      final matchIndex =
          state.layers.indexWhere((element) => element.id == layerId);
      if (matchIndex != -1) {
        final updated = state.layers[matchIndex].copyWith(
          notes: nextNotes,
          updatedAt: DateTime.now(),
        );
        await _layerRepository.updateLayer(updated);
        await refresh();
        return null;
      }
      return 'Layer not found.';
    } catch (e) {
      AppLogger.error('Failed to update notes', e);
      return 'Failed to update notes.';
    }
  }

  Future<void> deleteLayer(String id) async {
    try {
      final target = state.layers.firstWhere((element) => element.id == id);
      await _layerRepository.softDeleteLayer(id);

      // Update parent truck statistics
      final truckRepo = _ref.read(truckRepositoryProvider);
      final currentTruck = await truckRepo.getTruckById(_truckId);
      if (currentTruck != null) {
        final updatedTruck = currentTruck.copyWith(
          totalLayers: (currentTruck.totalLayers - 1).clamp(0, 99999),
          totalCartons:
              (currentTruck.totalCartons - target.cartonCount).clamp(0, 999999),
          totalDefects:
              (currentTruck.totalDefects - target.defectCount).clamp(0, 999999),
          updatedDate: DateTime.now(),
        );
        await truckRepo.updateTruck(updatedTruck);
        _ref.read(truckListProvider.notifier).refresh();
      }

      await refresh();
    } catch (e) {
      AppLogger.error('Failed to delete layer', e);
    }
  }
}

// Auto-disposed StateNotifierProvider parameterized by truckId
final layerListProvider = StateNotifierProvider.family
    .autoDispose<LayerListNotifier, LayerListState, String>((ref, truckId) {
  final repo = ref.watch(layerRepositoryProvider);
  return LayerListNotifier(repo, ref, truckId);
});
