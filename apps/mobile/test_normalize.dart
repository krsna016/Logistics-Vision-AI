import 'dart:convert';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/utils/field_normalizer.dart';

Future<void> _normalizeImportedData(AppDatabase database) async {
  // Wagons
  final wagons = await database.select(database.wagons).get();
  for (final w in wagons) {
    // parse json
    List<dynamic> items = jsonDecode(w.itemManifestJson);
    List<Map<String, dynamic>> updatedItems = [];
    for (var item in items) {
      if (item is Map<String, dynamic>) {
        item['name'] = FieldNormalizer.title(item['name']?.toString() ?? '');
        updatedItems.add(item);
      }
    }
    final jsonStr = jsonEncode(updatedItems);
    
    await database.update(database.wagons).replace(
      w.copyWith(
        wagonNumber: FieldNormalizer.code(w.wagonNumber),
        origin: drift.Value(FieldNormalizer.title(w.origin ?? '')),
        destination: drift.Value(FieldNormalizer.title(w.destination ?? '')),
        remarks: drift.Value(FieldNormalizer.text(w.remarks)),
        itemManifestJson: drift.Value(jsonStr),
      ),
    );
  }
}
