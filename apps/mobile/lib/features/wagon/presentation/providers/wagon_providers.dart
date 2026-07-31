import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/wagon.dart';
import '../../domain/repositories/wagon_repository.dart';
import '../../data/repositories_impl/local_wagon_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../truck/domain/repositories/truck_repository.dart';

import '../../../../core/providers/database_provider.dart';

final wagonRepositoryProvider = Provider<WagonRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalWagonRepository(db);
});

class WagonListState {
  final List<Wagon> wagons;
  final String searchQuery;
  final WagonStatus? statusFilter;
  final bool isLoading;
  final String? errorMessage;

  const WagonListState({
    this.wagons = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  List<Wagon> get processedWagons {
    var list = [...wagons];

    // 1. Apply Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list
          .where((w) =>
              w.wagonNumber.toLowerCase().contains(query) ||
              w.origin.toLowerCase().contains(query) ||
              w.destination.toLowerCase().contains(query))
          .toList();
    }

    // 2. Apply Status Filter
    if (statusFilter != null) {
      list = list.where((w) => w.status == statusFilter).toList();
    }

    // Sort: Loading first, then Planning, then Completed, descending chronological
    list.sort((a, b) {
      if (a.status == WagonStatus.loading && b.status != WagonStatus.loading) {
        return -1;
      }
      if (b.status == WagonStatus.loading && a.status != WagonStatus.loading) {
        return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  WagonListState copyWith({
    List<Wagon>? wagons,
    String? searchQuery,
    WagonStatus? statusFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearStatusFilter = false,
  }) {
    return WagonListState(
      wagons: wagons ?? this.wagons,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WagonListNotifier extends StateNotifier<WagonListState> {
  final WagonRepository _repository;
  final TruckRepository _truckRepository;

  WagonListNotifier(this._repository, this._truckRepository)
      : super(const WagonListState()) {
    refresh();
  }

  Future<void> refresh() async {
    final hasExistingData = state.wagons.isNotEmpty;
    if (!hasExistingData) state = state.copyWith(isLoading: true);
    try {
      final list = (await _repository.getActiveWagons())
          .where((wagon) => wagon.status != WagonStatus.archived)
          .toList();
      final allTrucks = await _truckRepository.getActiveTrucks();

      // Calculate dynamic completed counts based on current trucks state
      final updatedList = list.map((wagon) {
        final completed = allTrucks
            .where((t) =>
                t.wagonId == wagon.id && t.status == TruckStatus.completed)
            .length;
        if (wagon.completedTruckCount != completed) {
          final updated = wagon.copyWith(completedTruckCount: completed);
          _repository.updateWagon(updated);
          return updated;
        }
        return wagon;
      }).toList();

      state = state.copyWith(
          wagons: updatedList, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to read wagon records.');
    }
  }

  Future<String?> createWagon({
    required String wagonNumber,
    required String origin,
    required String destination,
    required DateTime loadingDate,
    required int expectedTruckCount,
    String? remarks,
  }) async {
    final cleanNum = wagonNumber.trim();
    if (cleanNum.isEmpty) return 'Wagon number is required.';

    final newWagon = Wagon(
      id: const Uuid().v4(),
      wagonNumber: cleanNum,
      origin: origin.trim(),
      destination: destination.trim(),
      loadingDate: loadingDate,
      expectedTruckCount: expectedTruckCount,
      completedTruckCount: 0,
      status: WagonStatus.planning,
      remarks: remarks?.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.createWagon(newWagon);
    await refresh();
    return null;
  }

  Future<void> updateWagonStatus(String id, WagonStatus newStatus) async {
    final wagon = await _repository.getWagonById(id);
    if (wagon != null) {
      final updated =
          wagon.copyWith(status: newStatus, updatedAt: DateTime.now());
      await _repository.updateWagon(updated);
      await refresh();
    }
  }

  Future<void> updateWagon(Wagon wagon) async {
    await _repository.updateWagon(wagon.copyWith(updatedAt: DateTime.now()));
    await refresh();
  }

  Future<void> deleteWagon(String id) async {
    await _repository.deleteWagon(id);
    await refresh();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(WagonStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter, clearStatusFilter: false);
    }
  }
}

// Global wagon list provider
final wagonListProvider =
    StateNotifierProvider.autoDispose<WagonListNotifier, WagonListState>((ref) {
  final repo = ref.watch(wagonRepositoryProvider);
  final truckRepo = ref.watch(truckRepositoryProvider);
  return WagonListNotifier(repo, truckRepo);
});

// Computed wagon stats provider: (activeWagonsCount, completedWagonsCount, todayCartons, todayTrucksCount)
final wagonStatsProvider = Provider.autoDispose<(int, int, int, int)>((ref) {
  final wagonState = ref.watch(wagonListProvider);
  final truckState = ref.watch(truckListProvider);

  final activeWagons =
      wagonState.wagons.where((w) => w.status == WagonStatus.loading).length;
  final completedWagons =
      wagonState.wagons.where((w) => w.status == WagonStatus.completed).length;

  final activeWagonIds = wagonState.wagons.map((w) => w.id).toSet();
  final validTrucks = truckState.trucks
      .where((t) => !t.isDeleted && activeWagonIds.contains(t.wagonId))
      .toList();

  final totalTrucks = validTrucks.length;
  final totalCartons = validTrucks.fold(0, (sum, t) => sum + t.totalCartons);

  return (activeWagons, completedWagons, totalCartons, totalTrucks);
});
