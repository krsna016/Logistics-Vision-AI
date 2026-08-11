import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/digital_register.dart';
import '../../domain/repositories/register_repository.dart';
import '../../data/repositories_impl/local_register_repository.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

enum RegisterDateFilter {
  all,
  today,
  thisWeek,
  thisMonth;

  String get displayName {
    switch (this) {
      case RegisterDateFilter.all:
        return 'All Dates';
      case RegisterDateFilter.today:
        return 'Today';
      case RegisterDateFilter.thisWeek:
        return 'This Week';
      case RegisterDateFilter.thisMonth:
        return 'This Month';
    }
  }
}

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final wagonRepo = ref.watch(wagonRepositoryProvider);
  final truckRepo = ref.watch(truckRepositoryProvider);
  final layerRepo = ref.watch(layerRepositoryProvider);
  final user = ref.watch(authProvider);
  return LocalRegisterRepository(
    wagonRepo: wagonRepo,
    truckRepo: truckRepo,
    layerRepo: layerRepo,
    supervisorName: user?.name,
  );
});

class RegisterListState {
  final List<DigitalRegister> registers;
  final String searchQuery;
  final RegisterDateFilter dateFilter;
  final WagonStatus? statusFilter;
  final bool isLoading;
  final String? errorMessage;

  const RegisterListState({
    this.registers = const [],
    this.searchQuery = '',
    this.dateFilter = RegisterDateFilter.all,
    this.statusFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  List<DigitalRegister> get processedRegisters {
    var list = [...registers];

    // 1. Search filter: Wagon Number, Origin, Destination, Truck Number, Date
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list.where((r) {
        final matchesWagon = r.wagonNumber.toLowerCase().contains(query);
        final matchesOrigin = r.origin.toLowerCase().contains(query);
        final matchesDest = r.destination.toLowerCase().contains(query);
        final matchesTruck =
            r.trucks.any((t) => t.truckNumber.toLowerCase().contains(query));
        final matchesDate = r.loadingDate.toString().contains(query);
        return matchesWagon ||
            matchesOrigin ||
            matchesDest ||
            matchesTruck ||
            matchesDate;
      }).toList();
    }

    // 2. Status filter
    if (statusFilter != null) {
      list = list.where((r) => r.status == statusFilter).toList();
    }

    // 3. Date filter
    final now = DateTime.now();
    if (dateFilter == RegisterDateFilter.today) {
      list = list
          .where((r) =>
              r.loadingDate.year == now.year &&
              r.loadingDate.month == now.month &&
              r.loadingDate.day == now.day)
          .toList();
    } else if (dateFilter == RegisterDateFilter.thisWeek) {
      final weekAgo = now.subtract(const Duration(days: 7));
      list = list.where((r) => r.loadingDate.isAfter(weekAgo)).toList();
    } else if (dateFilter == RegisterDateFilter.thisMonth) {
      list = list
          .where((r) =>
              r.loadingDate.year == now.year &&
              r.loadingDate.month == now.month)
          .toList();
    }

    // Sort: Latest generated first
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  RegisterListState copyWith({
    List<DigitalRegister>? registers,
    String? searchQuery,
    RegisterDateFilter? dateFilter,
    WagonStatus? statusFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearStatusFilter = false,
  }) {
    return RegisterListState(
      registers: registers ?? this.registers,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterListNotifier extends StateNotifier<RegisterListState> {
  final RegisterRepository _repository;
  final bool canModify;

  RegisterListNotifier(this._repository, {required this.canModify})
      : super(const RegisterListState()) {
    refresh();
  }

  Future<void> refresh() async {
    final hasExistingData = state.registers.isNotEmpty;
    if (!hasExistingData) state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getAllRegisters();
      if (!mounted) return;
      state =
          state.copyWith(registers: list, isLoading: false, errorMessage: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to read digital registers.');
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateFilter(RegisterDateFilter filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void setStatusFilter(WagonStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter, clearStatusFilter: false);
    }
  }

  Future<void> updateRemarks(String registerId, String remarks) async {
    if (!canModify) return;
    await _repository.updateRemarks(registerId, remarks);
    await refresh();
  }

  Future<void> recordExport(String registerId) async {
    await _repository.incrementExportCount(registerId);
    await refresh();
  }

  Future<void> recordOpen(String registerId) async {
    await _repository.updateLastOpened(registerId);
    await refresh();
  }
}

final registerListProvider =
    StateNotifierProvider.autoDispose<RegisterListNotifier, RegisterListState>(
        (ref) {
  final repo = ref.watch(registerRepositoryProvider);
  final canModify =
      ref.watch(authProvider)?.role.canModifyDigitalRegisters ?? false;
  return RegisterListNotifier(repo, canModify: canModify);
});
