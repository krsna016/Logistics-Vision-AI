import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/session/presentation/providers/session_providers.dart';
import 'package:mobile/features/session/domain/entities/loading_session.dart';

void main() {
  group('LoadingSession Widget Tests', () {
    // Placeholder representing layout integrations
    test('State model holds valid parameters for widgets mapping', () {
      final session = LoadingSession(
        id: '123',
        truckId: 'mock_t1',
        warehouseId: 'wh_01',
        operatorId: 'op_01',
        startTime: DateTime.now(),
        status: SessionStatus.started,
        modelVersion: '1.0.0',
      );
      expect(session.status.name, equals('started'));
    });
  });
}
