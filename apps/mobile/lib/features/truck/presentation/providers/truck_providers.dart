import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/truck.dart';
import '../../domain/repositories/truck_repository.dart';
import '../../data/repositories_impl/local_truck_repository.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';

final truckRepositoryProvider = Provider<TruckRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalTruckRepository(db);
});

class TruckListState {
  final List<Truck> trucks;
  final String searchQuery;
  final TruckStatus? statusFilter;
  final String sortBy; // 'date', 'number', 'cartons'
  final bool isLoading;
  final String? errorMessage;

  const TruckListState({
    this.trucks = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.sortBy = 'date',
    this.isLoading = false,
    this.errorMessage,
  });

  List<Truck> get processedTrucks {
    var list = [...trucks];

    // 1. Apply Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list
          .where((t) =>
              t.truckNumber.toLowerCase().contains(query) ||
              t.driverName.toLowerCase().contains(query) ||
              t.company.toLowerCase().contains(query))
          .toList();
    }

    // 2. Apply Status Filter
    if (statusFilter != null) {
      list = list.where((t) => t.status == statusFilter).toList();
    }

    // 3. Apply Sorting
    if (sortBy == 'number') {
      list.sort((a, b) => a.truckNumber.compareTo(b.truckNumber));
    } else if (sortBy == 'cartons') {
      list.sort((a, b) =>
          b.totalCartons.compareTo(a.totalCartons)); // Descending total cartons
    } else {
      list.sort((a, b) =>
          b.createdDate.compareTo(a.createdDate)); // Descending chronological
    }

    return list;
  }

  TruckListState copyWith({
    List<Truck>? trucks,
    String? searchQuery,
    TruckStatus? statusFilter,
    String? sortBy,
    bool? isLoading,
    String? errorMessage,
    bool clearStatusFilter = false,
  }) {
    return TruckListState(
      trucks: trucks ?? this.trucks,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TruckListNotifier extends StateNotifier<TruckListState> {
  final TruckRepository _repository;
  final Ref _ref;

  TruckListNotifier(this._repository, this._ref) : super(const TruckListState()) {
    refresh();
  }

  Future<void> refresh() async {
    final hasExistingData = state.trucks.isNotEmpty;
    if (!hasExistingData) state = state.copyWith(isLoading: true);
    try {
      final list = (await _repository.getActiveTrucks())
          .where((truck) => !truck.isArchived)
          .toList();
      state =
          state.copyWith(trucks: list, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to read truck list.');
    }
  }

  Future<String?> createTruck({
    required String truckNumber,
    required String vehicleNumber,
    required String driverName,
    String? driverMobile,
    required String company,
    required String warehouse,
    String? notes,
    String? wagonId,
  }) async {
    final cleanNum = truckNumber.trim();
    if (cleanNum.isEmpty) return 'Truck number is required.';

    final exists =
        await _repository.isTruckNumberExists(cleanNum, wagonId: wagonId);
    if (exists) return 'Truck number already exists.';

    final newTruck = Truck(
      id: const Uuid().v4(),
      truckNumber: cleanNum,
      vehicleNumber: vehicleNumber.trim(),
      driverName: driverName.trim(),
      driverMobile: driverMobile?.trim(),
      company: company.trim(),
      warehouse: warehouse.trim(),
      status: TruckStatus.loading,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      notes: notes,
      wagonId: wagonId,
    );

    await _repository.createTruck(newTruck);
    await refresh();
    return null; // Return null if success
  }

  Future<String?> editTruck(Truck updated, {bool allowArchived = false}) async {
    if (updated.isArchived && !allowArchived) {
      return 'Cannot edit archived trucks from the active workflow.';
    }

    final exists = await _repository.isTruckNumberExists(updated.truckNumber,
        excludeId: updated.id, wagonId: updated.wagonId);
    if (exists) return 'Truck number already in use by another session.';

    await _repository.updateTruck(updated);
    await refresh();
    return null;
  }

  Future<void> archiveTruck(String id) async {
    await _repository.archiveTruck(id);
    await refresh();
  }

  Future<void> deleteTruck(String id) async {
    // Capture the wagon before deletion. Once the truck is soft-deleted it is
    // no longer possible to resolve its parent from the active truck list.
    final truck = await _repository.getTruckById(id);
    final wagonId = truck?.wagonId;
    await _repository.softDeleteTruck(id);
    await refresh();
    if (wagonId != null) {
      // FutureProvider caches inventory totals, so invalidating alone can
      // leave Wagon Details showing the old value until a later rebuild.
      _ref.invalidate(wagonInventoryProvider(wagonId));
      await _ref.read(wagonInventoryProvider(wagonId).future);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(TruckStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter, clearStatusFilter: false);
    }
  }

  void setSortOption(String option) {
    state = state.copyWith(sortBy: option);
  }
}

final truckListProvider =
    StateNotifierProvider.autoDispose<TruckListNotifier, TruckListState>((ref) {
  final repo = ref.watch(truckRepositoryProvider);
  return TruckListNotifier(repo, ref);
});

// Provider to watch statistics across the active trucks
final truckStatsProvider = Provider.autoDispose<(int, int, int)>((ref) {
  final listState = ref.watch(truckListProvider);
  final activeList = listState.trucks;

  final int loadingCount =
      activeList.where((t) => t.status == TruckStatus.loading).length;
  final int completedCount =
      activeList.where((t) => t.status == TruckStatus.completed).length;
  final int totalCartons = activeList.fold(0, (sum, t) => sum + t.totalCartons);

  return (loadingCount, completedCount, totalCartons);
});
