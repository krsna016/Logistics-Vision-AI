import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('bundled SQLite engine provides encryption support', () {
    final database = sqlite3.openInMemory();
    addTearDown(database.close);

    expect(database.select('PRAGMA cipher'), isNotEmpty);
  });
}
