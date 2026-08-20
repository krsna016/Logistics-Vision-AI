import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/data/services/report_file_name.dart';

void main() {
  test('removes only expired generated reports', () async {
    final directory =
        await Directory.systemTemp.createTemp('report_retention_');
    addTearDown(() => directory.delete(recursive: true));
    final now = DateTime(2026, 8, 20, 12);
    final expired = await File('${directory.path}/SmartLoad_Old_2026.pdf')
        .writeAsString('old report');
    final current = await File('${directory.path}/SmartLoad_New_2026.xlsx')
        .writeAsString('current report');
    final unrelated = await File('${directory.path}/customer.pdf')
        .writeAsString('not managed by SmartLoad');
    await expired.setLastModified(now.subtract(const Duration(days: 91)));
    await current.setLastModified(now.subtract(const Duration(days: 89)));
    await unrelated.setLastModified(now.subtract(const Duration(days: 365)));

    await pruneExpiredGeneratedReports(directory, now: now);

    expect(await expired.exists(), isFalse);
    expect(await current.exists(), isTrue);
    expect(await unrelated.exists(), isTrue);
  });
}
