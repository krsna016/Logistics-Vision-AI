import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/role.dart';

void main() {
  test('only administrators can modify Digital Registers', () {
    expect(Role.administrator.canModifyDigitalRegisters, isTrue);
    expect(Role.manager.canModifyDigitalRegisters, isFalse);
    expect(Role.supervisor.canModifyDigitalRegisters, isFalse);
    expect(Role.operator.canModifyDigitalRegisters, isFalse);
  });
}
