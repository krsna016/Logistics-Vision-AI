import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';

void main() {
  final now = DateTime(2026, 8, 12);

  Wagon wagonWithManifest() => Wagon(
        id: 'wagon-1',
        wagonNumber: 'W1',
        origin: 'A',
        destination: 'B',
        loadingDate: now,
        expectedTruckCount: 1,
        completedTruckCount: 1,
        status: WagonStatus.loading,
        items: const [
          WagonItem(name: 'Item A', quantity: 50),
          WagonItem(name: 'Item B', quantity: 30),
        ],
        createdAt: now,
        updatedAt: now,
      );

  test('a manifest wagon requires every item to be loaded exactly', () {
    final wagon = wagonWithManifest();

    expect(wagon.isManifestReconciled(const {'Item A': 50, 'Item B': 29}),
        isFalse);
    expect(wagon.isManifestReconciled(const {'Item A': 51, 'Item B': 30}),
        isFalse);
    expect(
        wagon.isManifestReconciled(const {'Item A': 50, 'Item B': 30}), isTrue);
  });

  test('a wagon without a manifest does not require item reconciliation', () {
    final wagon = wagonWithManifest().copyWith(items: const []);

    expect(wagon.isManifestReconciled(const {}), isTrue);
  });
}
