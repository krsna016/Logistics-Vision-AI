import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/register/domain/entities/digital_register.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';

void main() {
  group('Digital Register Entity & Workflow Tests', () {
    test('DigitalRegister entity instantiation & copyWith works accurately', () {
      final now = DateTime.now();
      final reg = DigitalRegister(
        id: 'reg_1',
        wagonId: 'w_1',
        wagonNumber: 'W-9090',
        origin: 'Mumbai Hub',
        destination: 'Delhi Terminal',
        loadingDate: now,
        supervisor: 'Operations Lead',
        status: WagonStatus.completed,
        totalTrucks: 5,
        totalLayers: 20,
        totalCartons: 1200,
        totalDefects: 2,
        loadingDuration: const Duration(hours: 4),
        generatedAt: now,
        lastOpenedAt: now,
        exportCount: 1,
        trucks: const [],
      );

      expect(reg.wagonNumber, 'W-9090');
      expect(reg.totalCartons, 1200);
      expect(reg.status, WagonStatus.completed);

      final updated = reg.copyWith(exportCount: 2, remarks: 'Export completed');
      expect(updated.exportCount, 2);
      expect(updated.remarks, 'Export completed');
      expect(updated.wagonNumber, 'W-9090');
    });
  });
}
