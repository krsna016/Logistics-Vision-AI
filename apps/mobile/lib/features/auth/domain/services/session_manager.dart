import 'dart:async';
import 'package:flutter/foundation.dart';
import '../entities/session.dart';
import '../entities/user.dart';

abstract class SessionManager {
  ValueListenable<Session?> get currentSession;
  
  /// Initializes a session for a successfully logged-in user.
  Future<void> startSession(User user);
  
  /// Terminates the current session.
  Future<void> endSession();
  
  /// Records user activity to reset the idle timer.
  void recordActivity();
  
  /// Locks the current session due to inactivity or explicit request.
  Future<void> lockSession();
  
  /// Unlocks the session.
  Future<void> unlockSession();
}
