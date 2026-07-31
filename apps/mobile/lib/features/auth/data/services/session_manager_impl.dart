import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/session_manager.dart';

class SessionManagerImpl implements SessionManager {
  final ValueNotifier<Session?> _sessionNotifier =
      ValueNotifier<Session?>(null);
  Timer? _idleTimer;
  static const Duration _idleTimeout = Duration(minutes: 15);

  @override
  ValueListenable<Session?> get currentSession => _sessionNotifier;

  @override
  Future<void> startSession(User user) async {
    _sessionNotifier.value = Session(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      loginTime: DateTime.now(),
      lastActivity: DateTime.now(),
      deviceName: 'SmartLoad-Device',
    );
    _startIdleTimer();
  }

  @override
  Future<void> endSession() async {
    _idleTimer?.cancel();
    _sessionNotifier.value = null;
  }

  @override
  void recordActivity() {
    if (_sessionNotifier.value != null && !_sessionNotifier.value!.isLocked) {
      _sessionNotifier.value =
          _sessionNotifier.value!.copyWith(lastActivity: DateTime.now());
      _startIdleTimer();
    }
  }

  @override
  Future<void> lockSession() async {
    _idleTimer?.cancel();
    if (_sessionNotifier.value != null) {
      _sessionNotifier.value = _sessionNotifier.value!.copyWith(isLocked: true);
    }
  }

  @override
  Future<void> unlockSession() async {
    if (_sessionNotifier.value != null) {
      _sessionNotifier.value = _sessionNotifier.value!.copyWith(
        isLocked: false,
        lastActivity: DateTime.now(),
      );
      _startIdleTimer();
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, () {
      lockSession();
    });
  }
}
