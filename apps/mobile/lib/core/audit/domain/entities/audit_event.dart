import 'package:flutter/foundation.dart';

@immutable
class AuditEvent {
  final String id;
  final DateTime timestamp;
  final String operatorId;
  final String operatorName;
  final String action;
  final String target;
  final String? targetId;
  final String? reason;
  final Map<String, dynamic>? metadata;

  const AuditEvent({
    required this.id,
    required this.timestamp,
    this.operatorId = 'op_sys_01',
    this.operatorName = 'Anurag Sharma (Supervisor)',
    required this.action,
    required this.target,
    this.targetId,
    this.reason,
    this.metadata,
  });

  AuditEvent copyWith({
    String? id,
    DateTime? timestamp,
    String? operatorId,
    String? operatorName,
    String? action,
    String? target,
    String? targetId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) {
    return AuditEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
      action: action ?? this.action,
      target: target ?? this.target,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      metadata: metadata ?? this.metadata,
    );
  }
}
