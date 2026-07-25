import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/wagon/domain/entities/wagon.dart';
import 'package:mobile/features/wagon/data/models/wagon_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wagon Management Domain and DTO Tests', () {
    final now = DateTime.now();

    test('Wagon entity constructor maps fields and copyWith works correctly', () {
      final wagon = Wagon(
        id: 'w123',
        wagonNumber: 'W-9988-AB',
        origin: 'Austin',
        destination: 'Dallas',
        loadingDate: now,
        expectedTruckCount: 5,
        completedTruckCount: 2,
        status: WagonStatus.planning,
        createdAt: now,
        updatedAt: now,
      );

      expect(wagon.id, equals('w123'));
      expect(wagon.wagonNumber, equals('W-9988-AB'));
      expect(wagon.status, equals(WagonStatus.planning));

      final updated = wagon.copyWith(status: WagonStatus.loading, completedTruckCount: 3);
      expect(updated.status, equals(WagonStatus.loading));
      expect(updated.completedTruckCount, equals(3));
      expect(updated.id, equals('w123')); // unmutated fields persist
    });

    test('WagonModel JSON serialization maps keys accurately', () {
      final wagon = Wagon(
        id: 'w456',
        wagonNumber: 'W-1002-CD',
        origin: 'San Jose',
        destination: 'Chicago',
        loadingDate: now,
        expectedTruckCount: 8,
        completedTruckCount: 4,
        status: WagonStatus.completed,
        remarks: 'Sample remarks',
        createdAt: now,
        updatedAt: now,
      );

      final jsonMap = WagonModel.toJson(wagon);
      expect(jsonMap['id'], equals('w456'));
      expect(jsonMap['wagonNumber'], equals('W-1002-CD'));
      expect(jsonMap['status'], equals('completed'));
      expect(jsonMap['remarks'], equals('Sample remarks'));

      final parsed = WagonModel.fromJson(jsonMap);
      expect(parsed.id, equals(wagon.id));
      expect(parsed.wagonNumber, equals(wagon.wagonNumber));
      expect(parsed.status, equals(wagon.status));
      expect(parsed.remarks, equals(wagon.remarks));
    });
  });
}
