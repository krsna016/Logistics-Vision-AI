import '../entities/wagon.dart';

abstract class WagonRepository {
  Future<List<Wagon>> getActiveWagons();
  Future<Wagon?> getWagonById(String id);
  Future<void> createWagon(Wagon wagon);
  Future<void> updateWagon(Wagon wagon);
  Future<void> deleteWagon(String id);
  Future<bool> isWagonNumberExists(String wagonNumber, {String? excludeId});
  Future<void> clearAndLoadDemoData();
}
