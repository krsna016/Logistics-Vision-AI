import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/repositories_impl/remote_auth_repository.dart';
import 'package:mobile/features/auth/domain/entities/role.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local entry grants the complete Administrator role without a token',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      StorageService.keyJwtToken: 'stale-token',
    });
    const storage = FlutterSecureStorage();
    final notifier = AuthNotifier(
      RemoteAuthRepository(Dio(), storage),
      storage,
    );
    addTearDown(notifier.dispose);

    await notifier.enterLocalAdministrator();

    expect(notifier.state?.employeeId, 'LOCAL-ADMIN');
    expect(notifier.state?.role, Role.administrator);
    expect(notifier.state?.role.canManageUsers, isTrue);
    expect(notifier.state?.role.canManageSecurity, isTrue);
    expect(notifier.state?.role.canModifyDigitalRegisters, isTrue);
    expect(
      await storage.read(key: StorageService.keyJwtToken),
      isNull,
    );

    notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state?.role, Role.administrator);
  });
}
