import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/role.dart';

void main() {
  test('the app exposes only Administrator and Supervisor roles', () {
    expect(Role.values, [Role.supervisor, Role.administrator]);
    expect(Role.supervisor.displayName, 'Supervisor');
    expect(Role.administrator.displayName, 'Administrator');
  });

  test('legacy roles migrate to the least-privilege operational role', () {
    expect(parseRole('Admin'), Role.administrator);
    expect(parseRole('Administrator'), Role.administrator);
    expect(parseRole('Manager'), Role.supervisor);
    expect(parseRole('Operator'), Role.supervisor);
    expect(parseRole('unknown'), Role.supervisor);
  });

  test('only Administrator can modify historical Digital Registers', () {
    expect(Role.administrator.canModifyDigitalRegisters, isTrue);
    expect(Role.supervisor.canModifyDigitalRegisters, isFalse);
    expect(Role.supervisor.canManageWagons, isTrue);
    expect(Role.supervisor.canCompleteWagons, isTrue);
    expect(Role.supervisor.canExportReports, isTrue);
  });
}
