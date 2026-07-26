import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/session/domain/entities/loading_session.dart';
import 'package:mobile/features/session/data/models/loading_session_model.dart';
import 'package:mobile/features/session/data/repositories_impl/local_loading_session_repository.dart';
import 'package:mobile/features/session/presentation/providers/session_providers.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';
import 'package:mobile/features/truck/presentation/providers/truck_providers.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoadingSession Model Serialization Tests', () {
    test('fromJson and toJson map fields accurately without data loss', () {
      final now = DateTime.parse('2026-07-25T14:00:00Z');
      final session = LoadingSession(
        id: 'session_uuid',
        truckId: 'truck_uuid',
        warehouseId: 'warehouse_uuid',
        operatorId: 'operator_01',
        startTime: now,
        status: SessionStatus.started,
        totalLayers: 5,
        totalCartons: 120,
        modelVersion: '1.0.0-YOLOv8n',
      );

      final json = LoadingSessionModel.toJson(session);
      final mappedSession = LoadingSessionModel.fromJson(json);

      expect(mappedSession.id, equals(session.id));
      expect(mappedSession.status, equals(session.status));
      expect(mappedSession.totalCartons, equals(session.totalCartons));
      expect(mappedSession.duration, equals(session.duration));
    });
  });

  group('LocalLoadingSessionRepository & Recovery Tests', () {
    late AppDatabase db;
    late LocalLoadingSessionRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalLoadingSessionRepository(db);
    });
    
    tearDown(() async {
      await db.close();
    });

    test('recoverLastActiveSession returns null if no started/paused session exists', () async {
      final session = await repository.recoverLastActiveSession();
      expect(session, isNull);
    });

    test('recoverLastActiveSession successfully returns interrupted session on start', () async {
      final interruptedSession = LoadingSession(
        id: 'interrupted_uuid',
        truckId: 'mock_t1',
        warehouseId: 'wh_01',
        operatorId: 'usr_01',
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        status: SessionStatus.started,
        modelVersion: '1.0.0-YOLOv8n',
      );

      await repository.saveSession(interruptedSession);
      
      final recovered = await repository.recoverLastActiveSession();
      expect(recovered, isNotNull);
      expect(recovered!.id, equals('interrupted_uuid'));
    });
  });

  group('ActiveSessionNotifier State Transition Tests', () {
    late AppDatabase db;
    late LocalLoadingSessionRepository sessionRepo;
    late LocalTruckRepository truckRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sessionRepo = LocalLoadingSessionRepository(db);
      truckRepo = LocalTruckRepository(db);
      await truckRepo.clearAndLoadDemoData();
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          loadingSessionRepositoryProvider.overrideWithValue(sessionRepo),
          truckRepositoryProvider.overrideWithValue(truckRepo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('Starting a session sets state to started and completeSession updates parent truck to completed', () async {
      final container = makeContainer();
      final notifier = container.read(activeSessionProvider.notifier);

      // Verify no active session initial state
      expect(container.read(activeSessionProvider).activeSession, isNull);

      // Start new session
      final error = await notifier.startSession(truckId: 'mock_t1', warehouseId: 'wh_01');
      expect(error, isNull);

      final active = container.read(activeSessionProvider).activeSession;
      expect(active, isNotNull);
      expect(active!.status, equals(SessionStatus.started));

      // Pause session
      await notifier.pauseSession();
      expect(container.read(activeSessionProvider).activeSession!.status, equals(SessionStatus.paused));

      // Resume session
      await notifier.resumeSession();
      expect(container.read(activeSessionProvider).activeSession!.status, equals(SessionStatus.started));

      // Complete session
      await notifier.completeSession();
      expect(container.read(activeSessionProvider).activeSession, isNull);

      // Verify parent truck status transitioned to completed
      final parentTruck = await truckRepo.getTruckById('mock_t1');
      expect(parentTruck!.status.name, equals('completed'));
    });
  });
}
