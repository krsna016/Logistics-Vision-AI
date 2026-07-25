import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/loading_session.dart';
import '../../domain/repositories/loading_session_repository.dart';
import '../models/loading_session_model.dart';
import '../../../../utils/logger.dart';

class LocalLoadingSessionRepository implements LoadingSessionRepository {
  static const String _storageKey = 'cached_loading_sessions_v1';

  LocalLoadingSessionRepository();

  Future<void> _writeToCache(List<LoadingSession> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps = list.map((e) => LoadingSessionModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing session database cache', e, stack);
    }
  }

  Future<List<LoadingSession>> _readAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);
      if (cachedStr == null) return [];
      
      final List<dynamic> rawList = json.decode(cachedStr);
      return rawList.map((e) => LoadingSessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading sessions list', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveSession(LoadingSession session) async {
    final list = await _readAllSessions();
    final index = list.indexWhere((element) => element.id == session.id);
    if (index != -1) {
      list[index] = session;
    } else {
      list.add(session);
    }
    await _writeToCache(list);
    AppLogger.info('Saved loading session: ${session.id} status=${session.status.name}');
  }

  @override
  Future<LoadingSession?> getSessionById(String id) async {
    final list = await _readAllSessions();
    try {
      return list.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LoadingSession?> getActiveSessionForTruck(String truckId) async {
    final list = await _readAllSessions();
    try {
      return list.firstWhere((s) => s.truckId == truckId && s.status == SessionStatus.started);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LoadingSession>> getSessionsByWarehouse(String warehouseId) async {
    final list = await _readAllSessions();
    return list.where((s) => s.warehouseId == warehouseId).toList();
  }

  @override
  Future<LoadingSession?> recoverLastActiveSession() async {
    final list = await _readAllSessions();
    try {
      // Find the last session that was started or paused but not completed/cancelled
      return list.firstWhere((s) => s.status == SessionStatus.started || s.status == SessionStatus.paused);
    } catch (_) {
      return null;
    }
  }
}
