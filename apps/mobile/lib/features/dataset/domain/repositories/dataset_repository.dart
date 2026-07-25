import '../entities/dataset_item.dart';

abstract class DatasetRepository {
  /// Save a collected training image and its metadata JSON.
  Future<void> saveItem(DatasetItem item);

  /// Fetch all collected dataset items.
  Future<List<DatasetItem>> getAllItems();

  /// Delete a collected dataset item and its associated files from disk.
  Future<void> deleteItem(String id);

  /// Export selected items into a single ZIP archive containing images and metadata JSONs.
  /// Returns the absolute path of the generated ZIP file.
  Future<String> exportToZip(List<DatasetItem> items);
}
