import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/layer.dart';
import '../../../camera/domain/entities/detection.dart';
import '../../domain/repositories/layer_repository.dart';
import '../../data/repositories_impl/local_layer_repository.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../../../core/utils/audit_logger.dart';
import '../../../../utils/logger.dart';
import '../../../../services/storage_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/ai_engine/models/ai_model.dart';

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
        final tokenUsable = exp is num &&
            DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000)
                .isAfter(DateTime.now());
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
    List<LayerItemAllocation> itemAllocations = const [],
    String? photoPath,
    String? croppedPhotoPath,
    CountingRegion? countingRegion,
    List<Detection> detections = const [],
  }) async {
    if (cartonCount <= 0 || cartonCount > 9999) {
      return 'Enter a carton count from 1 to 9,999.';
    }
    if (defectCount < 0 || defectCount > cartonCount) {
      return 'Defective cartons must be between 0 and $cartonCount.';
    }
    final positiveAllocations = itemAllocations
        .where((allocation) => allocation.quantity > 0)
        .toList(growable: false);
    if (positiveAllocations.map((item) => item.itemName).toSet().length !=
        positiveAllocations.length) {
      return 'Each item can appear only once in the layer breakdown.';
    }
    if (positiveAllocations.isNotEmpty &&
        positiveAllocations.fold<int>(
                0, (sum, allocation) => sum + allocation.quantity) !=
            cartonCount) {
      return 'Item quantities must total exactly $cartonCount cartons.';
    }
    state = state.copyWith(isLoading: true);
    try {
      // Always query the database for the true max layer number.
      // The in-memory state.layers may be stale or empty if the provider
      // was not refreshed (e.g. navigating from manual count control center).
      final dbMax = await _layerRepository.getMaxLayerNumber(_truckId);
      final stateMax = state.layers.isEmpty ? 0 : state.layers.last.layerNumber;
      final nextLayerNum = (dbMax > stateMax ? dbMax : stateMax) + 1;

      // Verify double save checks
      final exists =
          await _layerRepository.isLayerNumberExists(_truckId, nextLayerNum);
      if (exists) {
        state = state.copyWith(isLoading: false);
        return 'Layer number $nextLayerNum already registered.';
      }

      final truckRepo = _ref.read(truckRepositoryProvider);
      final currentTruck = await truckRepo.getTruckById(_truckId);
      final wagonId = currentTruck?.wagonId;
      if (wagonId != null) {
        final wagon =
            await _ref.read(wagonRepositoryProvider).getWagonById(wagonId);
        if (wagon != null && wagon.items.isNotEmpty) {
          final allocations = positiveAllocations;
          if (allocations.isEmpty) {
            state = state.copyWith(isLoading: false);
            return 'Enter the item breakdown for this layer.';
          }
          final allocatedTotal = allocations.fold<int>(
              0, (sum, allocation) => sum + allocation.quantity);
          if (allocatedTotal != cartonCount) {
            state = state.copyWith(isLoading: false);
            return 'Item quantities must total exactly $cartonCount cartons.';
          }
          final loaded = await _ref
              .read(wagonRepositoryProvider)
              .getLoadedItemQuantities(wagonId);
          for (final allocation in allocations) {
            final matches =
                wagon.items.where((item) => item.name == allocation.itemName);
            if (matches.isEmpty) {
              state = state.copyWith(isLoading: false);
              return 'Choose items only from the wagon manifest.';
            }
            final remaining =
                matches.first.quantity - (loaded[allocation.itemName] ?? 0);
            if (allocation.quantity > remaining) {
              state = state.copyWith(isLoading: false);
              return 'Only $remaining cartons of ${allocation.itemName} remain in the wagon.';
            }
          }
        }
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
        croppedPhotoPath: croppedPhotoPath,
        countingRegion: countingRegion,
        detections: detections,
        notes: notes,
        itemName:
            itemAllocations.length == 1 ? itemAllocations.first.itemName : null,
        itemAllocations: itemAllocations,
        modelVersion: AIModel.activeVersion,
        averageConfidence: confidence,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _layerRepository.saveLayer(newRecord);

      // The repository atomically recalculates truck/session aggregates with
      // the layer insert. Refresh provider state from those committed rows.
      _ref.read(truckListProvider.notifier).refresh();
      await _ref
          .read(activeSessionProvider.notifier)
          .refreshTotalsForTruck(_truckId);

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
      if (wagonId != null) {
        _ref.invalidate(wagonInventoryProvider(wagonId));
      }
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      AppLogger.error('Failed to save layer', e);
      return 'Failed to save layer session.';
    }
  }


  String? _preserveSplitData(String? newNotes, String? oldNotes) {
    if (oldNotes == null || !oldNotes.contains('[SPLIT_DATA]:')) return newNotes;
    final splitData = oldNotes.substring(oldNotes.indexOf('[SPLIT_DATA]:'));
    if (newNotes == null || newNotes.trim().isEmpty) return splitData;
    return '${newNotes.trim()} | $splitData';
  }

  Future<String?> editNotes(String layerId, String? nextNotes) async {
    try {
      final matchIndex =
          state.layers.indexWhere((element) => element.id == layerId);
      if (matchIndex != -1) {
        final current = state.layers[matchIndex];
        final updatedNotes = _preserveSplitData(nextNotes, current.notes);
        final updated = current.copyWith(
          notes: updatedNotes,
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

  Future<String?> updateLayerDetections(
    String layerId,
    List<Detection> detections, {
    int? cartonCountOverride,
    String? notesOverride,
  }) async {
    try {
      final index = state.layers.indexWhere((layer) => layer.id == layerId);
      if (index < 0) return 'Layer not found.';
      final current = state.layers[index];
      final cartonCount = cartonCountOverride ?? detections.length;
      final resizedAllocations = _resizeAllocations(
        current.itemAllocations,
        cartonCount,
      );
      final updated = current.copyWith(
        cartonCount: cartonCount,
        defectCount: current.defectCount.clamp(0, cartonCount),
        detections: List<Detection>.of(detections),
        itemAllocations: resizedAllocations,
        notes: notesOverride ?? current.notes,
        itemName: resizedAllocations.length == 1
            ? resizedAllocations.first.itemName
            : current.itemName,
        updatedAt: DateTime.now(),
      );
      await _layerRepository.updateLayer(
        updated,
        correctionReason: 'Verified boxes updated from Layer History',
      );
      await _ref
          .read(activeSessionProvider.notifier)
          .refreshTotalsForTruck(_truckId);
      await _ref.read(truckListProvider.notifier).refresh();
      await refresh();
      final truck =
          await _ref.read(truckRepositoryProvider).getTruckById(_truckId);
      if (truck?.wagonId != null) {
        final wagonId = truck!.wagonId!;
        _ref.invalidate(wagonInventoryProvider(wagonId));
        await _ref.read(wagonInventoryProvider(wagonId).future);
      }
      return null;
    } catch (error) {
      AppLogger.error('Failed to update verified layer boxes', error);
      return 'Failed to save verified boxes.';
    }
  }

  List<LayerItemAllocation> _resizeAllocations(
    List<LayerItemAllocation> current,
    int cartonCount,
  ) {
    if (current.isEmpty || cartonCount == 0) return const [];
    var remaining = cartonCount;
    final result = <LayerItemAllocation>[];
    for (var index = 0; index < current.length && remaining > 0; index++) {
      final allocation = current[index];
      final isLast = index == current.length - 1;
      final quantity = isLast
          ? remaining
          : (allocation.quantity < remaining ? allocation.quantity : remaining);
      if (quantity > 0) {
        result.add(LayerItemAllocation(
          itemName: allocation.itemName,
          quantity: quantity,
        ));
        remaining -= quantity;
      }
    }
    if (remaining > 0 && result.isNotEmpty) {
      final last = result.removeLast();
      result.add(LayerItemAllocation(
        itemName: last.itemName,
        quantity: last.quantity + remaining,
      ));
    }
    return result;
  }

  Future<String?> correctLayer({
    required String layerId,
    required int cartonCount,
    required int defectCount,
    String? notes,
    required List<LayerItemAllocation> itemAllocations,
    required String reason,
    String? photoPath,
    List<Detection>? detections,
  }) async {
    if (cartonCount < 0 || defectCount < 0 || defectCount > cartonCount) {
      return 'Enter valid carton and defect counts.';
    }
    if (reason.trim().isEmpty) return 'Correction reason is required.';
    try {
      final index = state.layers.indexWhere((layer) => layer.id == layerId);
      if (index < 0) return 'Layer not found.';
      final current = state.layers[index];
      final allocations =
          itemAllocations.where((item) => item.quantity > 0).toList();
      final allocatedTotal = allocations.fold<int>(
          0, (sum, allocation) => sum + allocation.quantity);
      final truck =
          await _ref.read(truckRepositoryProvider).getTruckById(_truckId);
      if (truck?.wagonId != null) {
        final wagon = await _ref
            .read(wagonRepositoryProvider)
            .getWagonById(truck!.wagonId!);
        if (wagon != null && wagon.items.isNotEmpty) {
          if (allocations.map((item) => item.itemName).toSet().length !=
              allocations.length) {
            return 'Each item can appear only once in the layer breakdown.';
          }
          final loaded = await _ref
              .read(wagonRepositoryProvider)
              .getLoadedItemQuantities(truck.wagonId!);
          final currentByItem = {
            for (final allocation in current.itemAllocations)
              allocation.itemName: allocation.quantity,
          };
          if (currentByItem.isEmpty &&
              current.itemName?.trim().isNotEmpty == true) {
            currentByItem[current.itemName!.trim()] = current.cartonCount;
          }
          for (final allocation in allocations) {
            final matches = wagon.items
                .where((item) => item.name == allocation.itemName)
                .toList();
            if (matches.isEmpty) {
              return 'Choose items only from the wagon manifest.';
            }
            final availableForLayer = matches.first.quantity -
                (loaded[allocation.itemName] ?? 0) +
                (currentByItem[allocation.itemName] ?? 0);
            if (allocation.quantity > availableForLayer) {
              return 'Only $availableForLayer cartons of ${allocation.itemName} are available for this layer.';
            }
          }
        }
      }
      final updatedNotes = _preserveSplitData(notes, current.notes);
      final updated = current.copyWith(
        cartonCount: allocatedTotal > 0 ? allocatedTotal : cartonCount,
        defectCount: defectCount,
        notes: updatedNotes,
        itemName: allocations.length == 1
            ? allocations.first.itemName
            : current.itemName,
        itemAllocations: allocations,
        photoPath: photoPath ?? current.photoPath,
        detections: detections ?? current.detections,
        updatedAt: DateTime.now(),
      );
      await _layerRepository.updateLayer(
        updated,
        correctionReason: reason.trim(),
      );
      await _ref
          .read(activeSessionProvider.notifier)
          .refreshTotalsForTruck(_truckId);
      await _ref.read(truckListProvider.notifier).refresh();
      await refresh();
      if (truck?.wagonId != null) {
        final wagonId = truck!.wagonId!;
        _ref.invalidate(wagonInventoryProvider(wagonId));
        await _ref.read(wagonInventoryProvider(wagonId).future);
      }
      return null;
    } catch (error) {
      AppLogger.error('Failed to correct layer', error);
      return 'Failed to save layer correction.';
    }
  }

  Future<void> deleteLayer(String id) async {
    try {
      await _layerRepository.softDeleteLayer(id);
      await _ref
          .read(activeSessionProvider.notifier)
          .refreshTotalsForTruck(_truckId);
      await _ref.read(truckListProvider.notifier).refresh();
      await refresh();
      final truck =
          await _ref.read(truckRepositoryProvider).getTruckById(_truckId);
      if (truck?.wagonId != null) {
        _ref.invalidate(wagonInventoryProvider(truck!.wagonId!));
      }
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
