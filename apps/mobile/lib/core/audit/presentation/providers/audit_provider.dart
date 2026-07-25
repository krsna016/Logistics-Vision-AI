import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/audit_event.dart';

class AuditState {
  final List<AuditEvent> events;

  const AuditState({this.events = const []});

  List<AuditEvent> get sortedEvents {
    final list = [...events];
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  AuditNotifier() : super(const AuditState()) {
    _seedInitialEvents();
  }

  void _seedInitialEvents() {
    final now = DateTime.now();
    state = AuditState(
      events: [
        AuditEvent(
          id: 'aud_1',
          timestamp: now.subtract(const Duration(hours: 3)),
          action: 'Created Wagon',
          target: 'Wagon W-10866',
          reason: 'Scheduled inbound train shipment',
        ),
        AuditEvent(
          id: 'aud_2',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
          action: 'Truck Registered',
          target: 'Truck MH12AB1234',
          reason: 'Driver checked in at Gate 2',
        ),
        AuditEvent(
          id: 'aud_3',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
          action: 'Layer 1 Captured',
          target: 'Truck MH12AB1234 (58 Cartons)',
          reason: 'AI scanning scan completed',
        ),
        AuditEvent(
          id: 'aud_4',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
          action: 'Layer 2 Captured',
          target: 'Truck MH12AB1234 (61 Cartons)',
          reason: 'AI scanning scan completed',
        ),
        AuditEvent(
          id: 'aud_5',
          timestamp: now.subtract(const Duration(minutes: 45)),
          action: 'Register Exported',
          target: 'Digital Register W-10866',
          reason: 'PDF report generated for transport invoice',
        ),
      ],
    );
  }

  void logEvent({
    required String action,
    required String target,
    String? targetId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) {
    final event = AuditEvent(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      action: action,
      target: target,
      targetId: targetId,
      reason: reason,
      metadata: metadata,
    );

    state = AuditState(events: [event, ...state.events]);
  }

  List<AuditEvent> getEventsForTarget(String targetId) {
    return state.events.where((e) => e.targetId == targetId || e.target.contains(targetId)).toList();
  }
}

final auditProvider = StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  return AuditNotifier();
});
