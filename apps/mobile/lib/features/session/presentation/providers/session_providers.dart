import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/loading_session.dart';
import '../../domain/repositories/loading_session_repository.dart';
import '../../data/repositories_impl/local_loading_session_repository.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../../core/utils/audit_logger.dart';
import '../../../../utils/logger.dart';

import '../../../../core/providers/database_provider.dart';

final loadingSessionRepositoryProvider =
    Provider<LoadingSessionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalLoadingSessionRepository(db);
});

class ActiveSessionState {
  final LoadingSession? activeSession;
  final bool isRecovering;
  final String? errorMessage;

  const ActiveSessionState({
    this.activeSession,
    this.isRecovering = false,
    this.errorMessage,
  });

  ActiveSessionState copyWith({
    LoadingSession? activeSession,
    bool? isRecovering,
    String? errorMessage,
  }) {
    return ActiveSessionState(
      activeSession: activeSession ?? this.activeSession,
      isRecovering: isRecovering ?? this.isRecovering,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  final LoadingSessionRepository _repository;
  final Ref _ref;

  ActiveSessionNotifier(this._repository, this._ref)
      : super(const ActiveSessionState()) {
    autoRecoverSession();
  }

  /// Automatically scans local records to recover an interrupted started/paused session.
  Future<void> autoRecoverSession() async {
    state = state.copyWith(isRecovering: true);
    try {
      final recovered = await _repository.recoverLastActiveSession();
      if (recovered != null) {
        AppLogger.info(
            'Auto-recovered unclosed loading session: ${recovered.id}');
        state =
            ActiveSessionState(activeSession: recovered, isRecovering: false);
      } else {
        state = state.copyWith(isRecovering: false);
      }
    } catch (e, stack) {
      AppLogger.error('Error recovering session', e, stack);
      state = state.copyWith(
          isRecovering: false,
          errorMessage: 'Failed to recover active session.');
    }
  }

  Future<String?> startSession({
    required String truckId,
    required String warehouseId,
  }) async {
    try {
      // Each truck may have its own active session. If this truck already has
      // one, make it the current working session instead of blocking the user.
      final existingActive =
          await _repository.getActiveSessionForTruck(truckId);
      if (existingActive != null) {
        state = ActiveSessionState(activeSession: existingActive);
        return null;
      }

      final newSession = LoadingSession(
        id: const Uuid().v4(),
        truckId: truckId,
        warehouseId: warehouseId,
        operatorId: 'usr_loader_01', // Mock user profile
        startTime: DateTime.now(),
        status: SessionStatus.started,
        modelVersion: 'yolo11n_carton_seg_v1_3',
      );

      await _repository.saveSession(newSession);
      state = ActiveSessionState(activeSession: newSession);
      AppLogger.info(
          'Started loading session ${newSession.id} for truck $truckId');
      AuditLogger.log(AuditEvent.truckCreated,
          'Started loading session for truck $truckId');
      return null;
    } catch (e, stack) {
      AppLogger.error('Failed to start session', e, stack);
      return 'Failed to start session.';
    }
  }

  Future<void> pauseSession() async {
    final session = state.activeSession;
    if (session == null || session.status != SessionStatus.started) return;

    final updated = session.copyWith(status: SessionStatus.paused);
    await _repository.saveSession(updated);
    state = state.copyWith(activeSession: updated);
    AppLogger.info('Paused loading session: ${session.id}');
  }

  Future<void> resumeSession() async {
    final session = state.activeSession;
    if (session == null || session.status != SessionStatus.paused) return;

    final updated = session.copyWith(status: SessionStatus.started);
    await _repository.saveSession(updated);
    state = state.copyWith(activeSession: updated);
    AppLogger.info('Resumed loading session: ${session.id}');
  }

  Future<void> recordLayerCaptured(int cartonCount, int defectCount) async {
    final session = state.activeSession;
    if (session == null) return;

    final updated = session.copyWith(
      totalLayers: session.totalLayers + 1,
      totalCartons: session.totalCartons + cartonCount,
      totalDefects: session.totalDefects + defectCount,
    );
    await _repository.saveSession(updated);
    state = state.copyWith(activeSession: updated);
    AppLogger.info('Updated session stats for: ${session.id}');
  }

  Future<void> completeSession() async {
    final session = state.activeSession;
    if (session == null) return;

    final updated = session.copyWith(
      status: SessionStatus.completed,
      endTime: DateTime.now(),
    );

    await _repository.saveSession(updated);
    state = const ActiveSessionState(); // Clear active session

    // Auto-update parent truck status to completed
    final truckRepo = _ref.read(truckRepositoryProvider);
    final currentTruck = await truckRepo.getTruckById(session.truckId);
    if (currentTruck != null) {
      await truckRepo.updateTruck(currentTruck.copyWith(
        status: TruckStatus.completed,
        completedDate: DateTime.now(),
      ));
      _ref.read(truckListProvider.notifier).refresh();
    }
    AppLogger.info('Completed loading session: ${session.id}');
    AuditLogger.log(AuditEvent.truckCompleted,
        'Completed loading session for truck ${session.truckId} with ${session.totalCartons} cartons.');
  }

  Future<void> cancelSession() async {
    final session = state.activeSession;
    if (session == null) return;

    final updated = session.copyWith(
      status: SessionStatus.cancelled,
      endTime: DateTime.now(),
    );

    await _repository.saveSession(updated);
    state = const ActiveSessionState(); // Clear active session
    AppLogger.info('Cancelled loading session: ${session.id}');
  }
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) {
  final repo = ref.watch(loadingSessionRepositoryProvider);
  return ActiveSessionNotifier(repo, ref);
});
