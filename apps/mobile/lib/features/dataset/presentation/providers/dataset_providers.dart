import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/dataset_item.dart';
import '../../domain/repositories/dataset_repository.dart';
import '../../data/repositories_impl/local_dataset_repository.dart';
import '../../../../utils/logger.dart';

final datasetRepositoryProvider = Provider<DatasetRepository>((ref) {
  return LocalDatasetRepository();
});

class DatasetListState {
  final List<DatasetItem> allItems;
  final List<DatasetItem> filteredItems;
  final bool isLoading;
  final String? filterWarehouse;
  final String? filterTruck;
  final String? errorMessage;
  final String? exportZipPath;

  const DatasetListState({
    this.allItems = const [],
    this.filteredItems = const [],
    this.isLoading = false,
    this.filterWarehouse,
    this.filterTruck,
    this.errorMessage,
    this.exportZipPath,
  });

  DatasetListState copyWith({
    List<DatasetItem>? allItems,
    List<DatasetItem>? filteredItems,
    bool? isLoading,
    String? filterWarehouse,
    String? filterTruck,
    String? errorMessage,
    String? exportZipPath,
  }) {
    return DatasetListState(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      isLoading: isLoading ?? this.isLoading,
      filterWarehouse: filterWarehouse ?? this.filterWarehouse,
      filterTruck: filterTruck ?? this.filterTruck,
      errorMessage: errorMessage ?? this.errorMessage,
      exportZipPath: exportZipPath ?? this.exportZipPath,
    );
  }
}

class DatasetListNotifier extends StateNotifier<DatasetListState> {
  final DatasetRepository _repository;

  DatasetListNotifier(this._repository) : super(const DatasetListState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getAllItems();
      state = state.copyWith(allItems: list, filteredItems: _applyFilters(list), isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load dataset collections.');
    }
  }

  List<DatasetItem> _applyFilters(List<DatasetItem> list) {
    var result = List<DatasetItem>.from(list);
    if (state.filterWarehouse != null && state.filterWarehouse!.isNotEmpty) {
      result = result.where((e) => e.warehouseId.toLowerCase().contains(state.filterWarehouse!.toLowerCase())).toList();
    }
    if (state.filterTruck != null && state.filterTruck!.isNotEmpty) {
      result = result.where((e) => e.truckId != null && e.truckId!.toLowerCase().contains(state.filterTruck!.toLowerCase())).toList();
    }
    return result;
  }

  void setFilters({String? warehouse, String? truck}) {
    state = state.copyWith(filterWarehouse: warehouse, filterTruck: truck);
    state = state.copyWith(filteredItems: _applyFilters(state.allItems));
  }

  Future<void> captureNewItem({
    required double brightness,
    required double exposure,
    required double sharpness,
    required String warehouseId,
    String? truckId,
    String? notes,
    required String tempPhotoPath,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    
    final item = DatasetItem(
      id: id,
      timestamp: now,
      phoneModel: 'Warehouse Mobile Scanner v1',
      cameraResolution: '3840x2160',
      orientation: 'portrait',
      brightness: brightness,
      exposure: exposure,
      sharpness: sharpness,
      warehouseId: warehouseId,
      truckId: truckId,
      operatorId: 'usr_collector_01',
      notes: notes,
      imagePath: tempPhotoPath,
      metadataPath: '/tmp/metadata_$id.json',
    );

    await _repository.saveItem(item);
    await refresh();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    await refresh();
  }

  Future<void> triggerZipExport() async {
    state = state.copyWith(isLoading: true, exportZipPath: null);
    try {
      final path = await _repository.exportToZip(state.filteredItems);
      state = state.copyWith(isLoading: false, exportZipPath: path);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Export failed.');
    }
  }
}

final datasetListProvider = StateNotifierProvider<DatasetListNotifier, DatasetListState>((ref) {
  final repo = ref.watch(datasetRepositoryProvider);
  return DatasetListNotifier(repo);
});
