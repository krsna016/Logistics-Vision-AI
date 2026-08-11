import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'report_template_service_impl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../wagon/domain/entities/wagon.dart';

List<WagonItem> _decodeWagonItems(String raw) {
  try {
    return (jsonDecode(raw) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(WagonItem.fromJson)
        .where((item) => item.name.isNotEmpty && item.quantity > 0)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

Map<String, String> parseLayerCorrectionDetails(String? details) {
  if (details == null || details.trim().isEmpty) {
    return const {
      'before': 'Not recorded',
      'after': 'Not recorded',
      'reason': 'Not provided',
    };
  }
  final match = RegExp(
    r'cartons\s+(\d+)\s*->\s*(\d+),\s*defects\s+(\d+)\s*->\s*(\d+)\.\s*Reason:\s*(.*?)(?:\.\s*Items:\s*(\[.*\])\s*->\s*(\[.*\]))?$',
    caseSensitive: false,
  ).firstMatch(details.trim());
  if (match == null) {
    return {
      'before': 'Previous values unavailable',
      'after': 'Correction recorded',
      'reason': details.trim(),
    };
  }

  final beforeItems = _formatCorrectionItems(match.group(6));
  final afterItems = _formatCorrectionItems(match.group(7));
  final beforeLines = <String>[
    'Cartons: ${match.group(1)}',
    if (beforeItems.isNotEmpty) 'Items:\n$beforeItems',
    'Defects: ${match.group(3)}',
  ];
  final afterLines = <String>[
    'Cartons: ${match.group(2)}',
    if (afterItems.isNotEmpty) 'Items:\n$afterItems',
    'Defects: ${match.group(4)}',
  ];
  return {
    'before': beforeLines.join('\n'),
    'after': afterLines.join('\n'),
    'reason': match.group(5)?.trim().isNotEmpty == true
        ? match.group(5)!.trim()
        : 'Not provided',
  };
}

String _formatCorrectionItems(String? rawJson) {
  if (rawJson == null || rawJson.trim().isEmpty) return '';
  try {
    final allocations = jsonDecode(rawJson) as List<dynamic>;
    return allocations
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final name = (item['itemName'] as String? ?? '').trim();
          final quantity = (item['quantity'] as num? ?? 0).toInt();
          return name.isEmpty ? '' : '$name: $quantity cartons';
        })
        .where((line) => line.isNotEmpty)
        .join('\n');
  } catch (_) {
    return '';
  }
}

pw.Widget? _truckLayerCellBuilder(int column, dynamic data, int row) {
  if (column != 2) return null;
  final rawItems = data.toString().trim();
  if (rawItems.isEmpty || rawItems == 'N/A') {
    return pw.Text('-', style: const pw.TextStyle(color: PdfColors.grey600));
  }

  final items = rawItems
      .split(' + ')
      .map((value) => value.split(':'))
      .where((parts) => parts.length >= 2)
      .toList(growable: false);
  if (items.isEmpty) return pw.Text(rawItems);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      for (var index = 0; index < items.length; index++) ...[
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                items[index].first.trim(),
                style: pw.TextStyle(
                  color: PdfColors.blue800,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
              ),
            ),
            pw.Text(
              '${items[index].sublist(1).join(':').trim()} cartons',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
          ],
        ),
        if (index != items.length - 1)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Divider(height: 0.5, color: PdfColors.blue100),
          ),
      ],
    ],
  );
}

String formatCorrectionChanges(String before, String after) {
  Map<String, String> values(String text) {
    final result = <String, String>{};
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line == 'Items:') continue;
      final separator = line.indexOf(':');
      if (separator <= 0) continue;
      final key = line.substring(0, separator).trim();
      final value = line
          .substring(separator + 1)
          .trim()
          .replaceFirst(RegExp(r'\s+cartons$'), '');
      result[key] = value;
    }
    return result;
  }

  final previous = values(before);
  final current = values(after);
  final keys = <String>{...previous.keys, ...current.keys};
  const priority = ['Cartons', 'Defects'];
  final itemKeys = keys.where((key) => !priority.contains(key)).toList()
    ..sort();
  if (itemKeys.isNotEmpty) {
    previous['Cartons'] = itemKeys
        .fold<int>(
          0,
          (sum, key) => sum + (int.tryParse(previous[key] ?? '') ?? 0),
        )
        .toString();
    current['Cartons'] = itemKeys
        .fold<int>(
          0,
          (sum, key) => sum + (int.tryParse(current[key] ?? '') ?? 0),
        )
        .toString();
  }
  final ordered = ['Cartons', ...itemKeys, 'Defects'];
  return ordered
      .where((key) => keys.contains(key))
      .map((key) => '$key: ${previous[key] ?? 0} -> ${current[key] ?? 0}')
      .join('\n');
}

String _reportValue(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text.toUpperCase() == 'NIL' || text == 'N/A'
      ? 'Not provided'
      : text;
}

class PdfReportServiceImpl implements PdfReportService {
  static Future<Uint8List?>? _cachedReportLogoBytes;
  final AppDatabase _db;
  final String? supervisorName;

  PdfReportServiceImpl(this._db, {this.supervisorName});

  String get _supervisor => supervisorName?.trim().isNotEmpty == true
      ? supervisorName!.trim()
      : 'Not provided';

  static Future<Uint8List?> _loadReportLogoBytes() {
    return _cachedReportLogoBytes ??= _readReportLogoBytes();
  }

  static Future<Uint8List?> _readReportLogoBytes() async {
    try {
      final data = await rootBundle.load('assets/images/report_logo.png');
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<File> _savePdfBytes(Uint8List bytes, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${prefix}_$timestamp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _layerItem(Layer? layer) {
    if (layer == null) return '';
    final allocations = _layerAllocations(layer);
    if (allocations.isNotEmpty) {
      return allocations.entries
          .map((item) => '${item.key}: ${item.value}')
          .join(' + ');
    }
    return layer.itemName?.trim().isNotEmpty == true
        ? layer.itemName!.trim()
        : layer.notes?.split('|').first.trim() ?? '';
  }

  Map<String, int> _layerAllocations(Layer layer) {
    final result = <String, int>{};
    try {
      final values = jsonDecode(layer.itemAllocationsJson) as List<dynamic>;
      for (final value in values.whereType<Map<String, dynamic>>()) {
        final name = (value['itemName'] as String? ?? '').trim();
        final quantity = (value['quantity'] as num? ?? 0).toInt();
        if (name.isNotEmpty && quantity > 0) result[name] = quantity;
      }
    } catch (_) {
      // Use the single-item compatibility field below.
    }
    if (result.isEmpty && layer.itemName?.trim().isNotEmpty == true) {
      result[layer.itemName!.trim()] = layer.cartonCount;
    }
    return result;
  }

  String _operatorNotesForReport(String? notes) {
    if (notes == null || notes.trim().isEmpty) return 'No notes';
    final operatorNotes = notes
        .split('|')
        .map((part) => part.trim())
        .where((part) =>
            part.isNotEmpty &&
            !part.startsWith('AI count:') &&
            !part.startsWith('Count method:'))
        .join(' | ');
    return operatorNotes.isEmpty ? 'No notes' : operatorNotes;
  }

  @override
  Future<File> generateTruckReport({required String truckId}) async {
    final truck = await (_db.select(_db.trucks)
          ..where((t) => t.id.equals(truckId) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.truckId.equals(truckId) & l.isDeleted.equals(false))
          ..orderBy([(l) => drift.OrderingTerm.asc(l.layerNumber)]))
        .get();

    if (truck == null) throw Exception('Truck not found');

    final layerIds = layers.map((layer) => layer.id).toList(growable: false);
    final correctionLogs = layerIds.isEmpty
        ? <AuditLog>[]
        : await (_db.select(_db.auditLogs)
              ..where((log) =>
                  log.entityId.isIn(layerIds) &
                  log.entityType.equals('Layer') &
                  log.action.equals('correct'))
              ..orderBy([(log) => drift.OrderingTerm.asc(log.timestamp)]))
            .get();
    final layerNumberById = {
      for (final layer in layers) layer.id: layer.layerNumber,
    };
    final reportData = <String, Object?>{
      'truckNumber': truck.truckNumber,
      'generatedDate': DateTime.now().toString().split(' ')[0],
      'vehicleNumber': truck.vehicleNumber,
      'driverName': truck.driverName,
      'driverMobile': truck.driverMobile ?? 'N/A',
      'company': truck.company,
      'warehouse': truck.warehouse,
      'status': truck.status,
      'totalLayers': layers.length,
      'totalCartons':
          layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount),
      'totalDefects':
          layers.fold<int>(0, (sum, layer) => sum + layer.defectCount),
      'layers': layers
          .map<Map<String, Object?>>(
            (layer) => {
              'layerNumber': layer.layerNumber,
              'cartonCount': layer.cartonCount,
              'defectCount': layer.defectCount,
              'itemName': _layerItem(layer).isEmpty ? 'N/A' : _layerItem(layer),
              'timestamp': layer.timestamp.toString().split('.')[0],
              'operator': layer.operatorId ?? 'N/A',
              'operatorNotes': _operatorNotesForReport(layer.notes),
            },
          )
          .toList(growable: false),
      'corrections': correctionLogs.map<Map<String, Object?>>((log) {
        final correction = parseLayerCorrectionDetails(log.details);
        return {
          'layerNumber': layerNumberById[log.entityId] ?? 'N/A',
          'timestamp': log.timestamp.toString().split('.')[0],
          'operator': log.userId,
          'before': correction['before']!,
          'after': correction['after']!,
          'reason': correction['reason']!,
        };
      }).toList(growable: false),
    };
    final logoBytes = await _loadReportLogoBytes();
    final supervisor = _supervisor;
    final bytes = await _runPdfWorker(
      type: 'truck',
      report: reportData,
      logoBytes: logoBytes,
      supervisor: supervisor,
    );
    return _savePdfBytes(bytes, 'TRUCK_${truck.truckNumber}');
  }

  @override
  Future<File> generateWagonReport({required String wagonId}) async {
    final wagon = await (_db.select(_db.wagons)
          ..where((w) => w.id.equals(wagonId) & w.isDeleted.equals(false)))
        .getSingleOrNull();
    if (wagon == null) throw Exception('Wagon not found');

    final trucks = await (_db.select(_db.trucks)
          ..where((t) => t.wagonId.equals(wagonId) & t.isDeleted.equals(false))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
        .get();
    final truckIds = trucks.map((truck) => truck.id).toList(growable: false);
    final layers = truckIds.isEmpty
        ? <Layer>[]
        : await (_db.select(_db.layers)
              ..where(
                  (l) => l.truckId.isIn(truckIds) & l.isDeleted.equals(false))
              ..orderBy([
                (l) => drift.OrderingTerm.asc(l.truckId),
                (l) => drift.OrderingTerm.asc(l.layerNumber),
              ]))
            .get();
    final layersByTruck = <String, List<Layer>>{
      for (final truck in trucks)
        truck.id: layers.where((layer) => layer.truckId == truck.id).toList(),
    };
    final loadedByItem = <String, int>{};
    for (final layer in layers) {
      for (final allocation in _layerAllocations(layer).entries) {
        loadedByItem[allocation.key] =
            (loadedByItem[allocation.key] ?? 0) + allocation.value;
      }
    }
    final manifest = (jsonDecode(wagon.itemManifestJson) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((item) {
      final name = item['name'] as String? ?? '';
      final total = (item['quantity'] as num? ?? 0).toInt();
      final loaded = loadedByItem[name] ?? 0;
      return <String, Object?>{
        'name': name,
        'total': total,
        'loaded': loaded,
        'remaining': total - loaded,
      };
    }).toList(growable: false);
    final reportData = <String, Object?>{
      'wagonNumber': wagon.wagonNumber,
      'loadingDate': wagon.loadingDate.toString().split(' ')[0],
      'status': wagon.status,
      'origin': wagon.origin,
      'destination': wagon.destination,
      'remarks': wagon.remarks ?? '',
      'items': manifest,
      'trucks': trucks
          .map<Map<String, Object?>>(
            (truck) => {
              'truckNumber': truck.truckNumber,
              'vehicleNumber': truck.vehicleNumber,
              'driverName': truck.driverName,
              'driverMobile': truck.driverMobile ?? 'N/A',
              'totalLayers': layersByTruck[truck.id]!.length,
              'totalCartons': layersByTruck[truck.id]!
                  .fold<int>(0, (sum, layer) => sum + layer.cartonCount),
              'totalDefects': layersByTruck[truck.id]!
                  .fold<int>(0, (sum, layer) => sum + layer.defectCount),
              'status': truck.status,
            },
          )
          .toList(growable: false),
    };
    final logoBytes = await _loadReportLogoBytes();
    final supervisor = _supervisor;
    final bytes = await _runPdfWorker(
      type: 'wagon',
      report: reportData,
      logoBytes: logoBytes,
      supervisor: supervisor,
    );
    return _savePdfBytes(bytes, 'WAGON_${wagon.wagonNumber}');
  }

  @override
  Future<File> generateDigitalRegisterReport({required String wagonId}) async {
    final wagon = await (_db.select(_db.wagons)
          ..where((w) => w.id.equals(wagonId) & w.isDeleted.equals(false)))
        .getSingleOrNull();
    if (wagon == null) throw Exception('Wagon not found');
    final register = await (_db.select(_db.digitalRegisters)
          ..where((r) => r.wagonId.equals(wagonId) & r.isDeleted.equals(false)))
        .getSingleOrNull();

    final trucks = await (_db.select(_db.trucks)
          ..where((t) => t.wagonId.equals(wagonId) & t.isDeleted.equals(false))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
        .get();
    final truckIds = trucks.map((truck) => truck.id).toList();
    final layers = truckIds.isEmpty
        ? <Layer>[]
        : await (_db.select(_db.layers)
              ..where(
                  (l) => l.truckId.isIn(truckIds) & l.isDeleted.equals(false))
              ..orderBy([
                (l) => drift.OrderingTerm.asc(l.truckId),
                (l) => drift.OrderingTerm.asc(l.layerNumber),
              ]))
            .get();
    final totalCartons =
        layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
    final totalDefects =
        layers.fold<int>(0, (sum, layer) => sum + layer.defectCount);
    final manifest = _decodeWagonItems(wagon.itemManifestJson);
    final loadedByItem = <String, int>{};
    for (final layer in layers) {
      for (final entry in _layerAllocations(layer).entries) {
        loadedByItem[entry.key] = (loadedByItem[entry.key] ?? 0) + entry.value;
      }
    }
    final layerIds = layers.map((layer) => layer.id).toList();
    final audits = layerIds.isEmpty
        ? <AuditLog>[]
        : await (_db.select(_db.auditLogs)
              ..where((log) =>
                  log.entityId.isIn(layerIds) & log.action.equals('correct'))
              ..orderBy([(log) => drift.OrderingTerm.asc(log.timestamp)]))
            .get();
    final layerNumberById = {
      for (final layer in layers) layer.id: layer.layerNumber,
    };
    final rowCount = layers.isEmpty
        ? 0
        : layers
            .map((layer) => layer.layerNumber)
            .reduce((first, second) => first > second ? first : second);

    final reportData = <String, Object?>{
      'origin': wagon.origin,
      'destination': wagon.destination,
      'wagonNumber': wagon.wagonNumber,
      'loadingDate': wagon.loadingDate.toString().split(' ')[0],
      'remarks': wagon.remarks ?? '',
      'registerId': register?.id,
      'totalCartons': totalCartons,
      'totalDefects': totalDefects,
      'rowCount': rowCount,
      'items': manifest
          .map((item) => {
                'name': item.name,
                'manifest': item.quantity,
                'loaded': loadedByItem[item.name] ?? 0,
                'remaining': item.quantity - (loadedByItem[item.name] ?? 0),
              })
          .toList(growable: false),
      'trucks': trucks.map<Map<String, Object?>>(
        (truck) {
          final truckLayers = layers
              .where((layer) => layer.truckId == truck.id)
              .toList(growable: false);
          return {
            'id': truck.id,
            'truckNumber': truck.truckNumber,
            'vehicleNumber': truck.vehicleNumber,
            'driverName': truck.driverName,
            'status': truck.status,
            'totalLayers': truckLayers.length,
            'totalCartons': truckLayers.fold<int>(
                0, (sum, layer) => sum + layer.cartonCount),
            'totalDefects': truckLayers.fold<int>(
                0, (sum, layer) => sum + layer.defectCount),
            'layers': truckLayers
                .map((layer) => {
                      'number': layer.layerNumber,
                      'cartons': layer.cartonCount,
                      'items': _layerItem(layer),
                      'cartonCount': layer.cartonCount,
                      'item': _layerItem(layer),
                      'defects': layer.defectCount,
                      'operator': layer.operatorId,
                      'notes': _operatorNotesForReport(layer.notes),
                      'added': layer.timestamp?.toString().split('.')[0] ?? '',
                    })
                .toList(growable: false),
          };
        },
      ).toList(growable: false),
      'corrections': audits.map((audit) {
        final parsed = parseLayerCorrectionDetails(audit.details);
        return {
          'layer': layerNumberById[audit.entityId] ?? 0,
          'when': audit.timestamp.toString().split('.')[0],
          'operator': audit.userId,
          'changes': formatCorrectionChanges(
              parsed['before'] ?? '', parsed['after'] ?? ''),
          'reason': parsed['reason'] ?? 'Not provided',
        };
      }).toList(growable: false),
    };
    final logoBytes = await _loadReportLogoBytes();
    final supervisor = _supervisor;
    final bytes = await _runPdfWorker(
      type: 'digitalRegister',
      report: reportData,
      logoBytes: logoBytes,
      supervisor: supervisor,
    );
    return _savePdfBytes(bytes, 'WAGON_$wagonId');
  }

  @override
  Future<File> generateAnalyticsReport() async {
    final wagons = await (_db.select(_db.wagons)
          ..where((wagon) => wagon.isDeleted.equals(false)))
        .get();
    final allActiveTrucks = await (_db.select(_db.trucks)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final activeWagonIds = wagons.map((wagon) => wagon.id).toSet();
    final trucks = allActiveTrucks
        .where((truck) =>
            truck.wagonId == null || activeWagonIds.contains(truck.wagonId))
        .toList(growable: false);
    final validTruckIds = trucks.map((truck) => truck.id).toSet();
    final allActiveLayers = await (_db.select(_db.layers)
          ..where((l) => l.isDeleted.equals(false)))
        .get();
    final layers = allActiveLayers
        .where((layer) => validTruckIds.contains(layer.truckId))
        .toList(growable: false);

    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);
    final totalDefects = layers.fold<int>(0, (sum, l) => sum + l.defectCount);
    final avgConfidence = layers.isEmpty
        ? 0.0
        : layers.fold<double>(0.0, (sum, l) => sum + l.averageConfidence) /
            layers.length;

    final reportData = <String, Object?>{
      'generatedAt': DateTime.now().toString().split('.')[0],
      'totalWagons': wagons.length,
      'totalTrucks': trucks.length,
      'totalLayers': layers.length,
      'totalCartons': totalCartons,
      'totalDefects': totalDefects,
      'averageConfidence': avgConfidence,
      'trucks': trucks
          .take(50)
          .map<Map<String, Object?>>(
            (truck) => {
              'truckNumber': truck.truckNumber,
              'vehicleNumber': truck.vehicleNumber,
              'driverName': truck.driverName,
              'totalCartons': truck.totalCartons,
              'totalDefects': truck.totalDefects,
              'status': truck.status,
              'completedDate':
                  truck.completedDate?.toString().split('.')[0] ?? 'N/A',
            },
          )
          .toList(growable: false),
    };
    final logoBytes = await _loadReportLogoBytes();
    final supervisor = _supervisor;
    final bytes = await _runPdfWorker(
      type: 'analytics',
      report: reportData,
      logoBytes: logoBytes,
      supervisor: supervisor,
    );
    return _savePdfBytes(bytes, 'ENTERPRISE_ANALYTICS');
  }
}

Future<Uint8List> _runPdfWorker({
  required String type,
  required Map<String, Object?> report,
  required Uint8List? logoBytes,
  required String supervisor,
}) {
  return compute<Map<String, Object?>, Uint8List>(
    _dispatchPdfBuild,
    <String, Object?>{
      'type': type,
      'report': report,
      'logoBytes': logoBytes,
      'supervisor': supervisor,
    },
    debugLabel: '$type-pdf-report',
  );
}

Future<Uint8List> _dispatchPdfBuild(Map<String, Object?> task) {
  final report =
      (task['report']! as Map<Object?, Object?>).cast<String, Object?>();
  final logoBytes = task['logoBytes'] as Uint8List?;
  final supervisor = task['supervisor']! as String;
  switch (task['type']) {
    case 'truck':
      return _buildTruckPdfBytes(report, logoBytes, supervisor);
    case 'wagon':
      return _buildWagonPdfBytes(report, logoBytes, supervisor);
    case 'digitalRegister':
      return _buildDigitalRegisterPdfBytes(report, logoBytes, supervisor);
    case 'analytics':
      return _buildAnalyticsPdfBytes(report, logoBytes, supervisor);
    default:
      throw ArgumentError.value(task['type'], 'type', 'Unknown PDF report');
  }
}

Future<Uint8List> _buildWagonPdfBytes(
  Map<String, Object?> report,
  Uint8List? logoBytes,
  String supervisor,
) async {
  final trucks = (report['trucks']! as List)
      .cast<Map<Object?, Object?>>()
      .map((truck) => truck.cast<String, Object?>())
      .toList(growable: false);
  final items = _reportMaps(report['items']);
  final totalCartons = trucks.fold<int>(
    0,
    (sum, truck) => sum + (truck['totalCartons']! as int),
  );
  final totalDefects = trucks.fold<int>(
    0,
    (sum, truck) => sum + (truck['totalDefects']! as int),
  );
  final totalLayers = trucks.fold<int>(
    0,
    (sum, truck) => sum + (truck['totalLayers']! as int),
  );
  final logo = logoBytes == null ? null : pw.MemoryImage(logoBytes);
  final wagonNumber = report['wagonNumber']! as String;
  final loadingDate = report['loadingDate']! as String;
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => ReportTemplateServiceImpl.buildHeader(
        title: 'Wagon Loading Report',
        logo: logo,
        reference: wagonNumber,
        date: loadingDate,
      ),
      footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
      build: (context) => [
        pw.Text(
          'Wagon Details',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Wagon Number: $wagonNumber'),
            pw.Text('Status: ${report['status']}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('From: ${_reportValue(report['origin'])}'),
            pw.Text('To: ${_reportValue(report['destination'])}'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Loading Date: $loadingDate'),
            pw.Text('Supervisor: $supervisor'),
          ],
        ),
        pw.SizedBox(height: 20),
        if (items.isNotEmpty) ...[
          pw.Text('Item Inventory',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: const ['Item', 'Total', 'Loaded', 'Remaining'],
            data: items
                .map((item) => [
                      item['name'].toString(),
                      item['total'].toString(),
                      item['loaded'].toString(),
                      item['remaining'].toString(),
                    ])
                .toList(growable: false),
          ),
          pw.SizedBox(height: 20),
        ],
        pw.Text(
          'Truck Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: context,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headerStyle:
              pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 8),
          headers: const [
            'Vehicle Number',
            'Driver',
            'Phone',
            'Layers',
            'Cartons',
            'Defects',
            'Status',
          ],
          data: trucks
              .map(
                (truck) => [
                  truck['vehicleNumber'].toString(),
                  truck['driverName'].toString(),
                  truck['driverMobile'].toString(),
                  truck['totalLayers'].toString(),
                  truck['totalCartons'].toString(),
                  truck['totalDefects'].toString(),
                  truck['status'].toString(),
                ],
              )
              .toList(growable: false),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            color: PdfColors.grey100,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text(
                'Total Trucks: ${trucks.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total Layers: $totalLayers',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total Cartons: $totalCartons',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total Defects: $totalDefects',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Remarks: ${report['remarks']}'),
        pw.SizedBox(height: 28),
        ReportTemplateServiceImpl.buildSignatures(supervisorName: supervisor),
      ],
    ),
  );
  return pdf.save();
}

Future<Uint8List> _buildTruckPdfBytes(
  Map<String, Object?> report,
  Uint8List? logoBytes,
  String supervisor,
) async {
  final layers = _reportMaps(report['layers']);
  final corrections = _reportMaps(report['corrections']);
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => ReportTemplateServiceImpl.buildHeader(
        title: 'Truck Loading Report',
        logo: logoBytes == null ? null : pw.MemoryImage(logoBytes),
        reference: _reportValue(report['vehicleNumber']),
        date: report['generatedDate'].toString(),
        useTruckIcon: true,
      ),
      footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
      build: (context) => [
        pw.Text('Details',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Vehicle Number: ${report['vehicleNumber']}'),
          pw.Text('Driver: ${_reportValue(report['driverName'])}'),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Driver Phone: ${_reportValue(report['driverMobile'])}'),
          pw.Text('Company: ${_reportValue(report['company'])}'),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Warehouse: ${_reportValue(report['warehouse'])}'),
          pw.Text('Status: ${report['status']}'),
        ]),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Supervisor: $supervisor'),
        ),
        pw.SizedBox(height: 28),
        pw.Text('Layers Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: context,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headerStyle:
              pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          cellBuilder: _truckLayerCellBuilder,
          cellDecoration: (column, data, row) => pw.BoxDecoration(
            color: column == 2 ? PdfColors.blue50 : PdfColors.white,
          ),
          headers: const [
            'Layer',
            'Cartons',
            'Items',
            'Def.',
            'Notes',
            'Added',
            'Operator',
          ],
          columnWidths: const {
            0: pw.FlexColumnWidth(0.7),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(2.7),
            3: pw.FlexColumnWidth(0.65),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(2.1),
            6: pw.FlexColumnWidth(1.7),
          },
          data: layers
              .map((layer) => [
                    layer['layerNumber'].toString(),
                    layer['cartonCount'].toString(),
                    layer['itemName'].toString(),
                    layer['defectCount'].toString(),
                    layer['operatorNotes'].toString(),
                    layer['timestamp'].toString(),
                    layer['operator'].toString(),
                  ])
              .toList(growable: false),
        ),
        pw.SizedBox(height: 18),
        pw.Text('Layer Correction History',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if (corrections.isEmpty)
          pw.Text('No layer corrections recorded.')
        else
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle:
                pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 7),
            headers: const [
              'Layer',
              'Changed At',
              'Operator',
              'Changes',
              'Reason',
            ],
            columnWidths: const {
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(1.7),
              2: pw.FlexColumnWidth(1.4),
              3: pw.FlexColumnWidth(3.4),
              4: pw.FlexColumnWidth(1.8),
            },
            data: corrections
                .map((correction) => [
                      correction['layerNumber'].toString(),
                      correction['timestamp'].toString(),
                      correction['operator'].toString(),
                      formatCorrectionChanges(
                        correction['before'].toString(),
                        correction['after'].toString(),
                      ),
                      correction['reason'].toString(),
                    ])
                .toList(growable: false),
          ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            color: PdfColors.grey100,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text('Total Layers: ${report['totalLayers']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Cartons: ${report['totalCartons']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Defects: ${report['totalDefects']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        ReportTemplateServiceImpl.buildSignatures(supervisorName: supervisor),
      ],
    ),
  );
  return pdf.save();
}

Future<Uint8List> _buildDigitalRegisterPdfBytes(
  Map<String, Object?> report,
  Uint8List? logoBytes,
  String supervisor,
) async {
  if (report.containsKey('items')) {
    return _buildDigitalRegisterPdfBytesV2(report, logoBytes, supervisor);
  }
  final trucks = _reportMaps(report['trucks']);
  final rowCount = report['rowCount']! as int;
  final tableRows = <List<String>>[
    [
      'S.NO.',
      for (final truck in trucks) ...[
        'VEHICLE: ${truck['vehicleNumber']}',
        '',
      ],
    ],
    [
      '',
      for (var index = 0; index < trucks.length; index++) ...['QTY', 'ITEM'],
    ],
  ];
  for (var row = 0; row < rowCount; row++) {
    tableRows.add([
      '${row + 1}',
      for (final truck in trucks) ...[
        ..._digitalRegisterCells(truck, row),
      ],
    ]);
  }

  final pdf = pw.Document();
  final logo = logoBytes == null ? null : pw.MemoryImage(logoBytes);
  final registerId = report['registerId'];
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.fromLTRB(24, 22, 24, 22),
      build: (context) => [
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          if (logo != null) ...[
            pw.Image(logo, width: 28, height: 28),
            pw.SizedBox(width: 7),
          ],
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('VINAYAK LOGISTICS',
                style:
                    pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.Text('SmartLoad System',
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ]),
        ]),
        pw.SizedBox(height: 5),
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.8)),
          padding: const pw.EdgeInsets.all(6),
          child: pw.Row(children: [
            for (final text in [
              'FROM: ${report['origin']}',
              'TO: ${report['destination']}',
              'WAGON NO: ${report['wagonNumber']}',
              'WAGON QTY: ${report['totalCartons']}',
              'UNLOADING DATE: ${report['loadingDate']}',
            ])
              pw.Expanded(
                  child: pw.Text(text,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          context: context,
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.55),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headerStyle:
              pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 7),
          cellAlignment: pw.Alignment.center,
          headerCount: 2,
          data: tableRows,
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 42,
          width: double.infinity,
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.55)),
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'REMARKS: ${report['remarks']}${registerId == null ? '' : '  |  REGISTER: $registerId'}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL CARTONS: ${report['totalCartons']}',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('TOTAL DEFECTS: ${report['totalDefects']}',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('Supervisor: $supervisor',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ]),
        ),
      ],
    ),
  );
  return pdf.save();
}

Future<Uint8List> _buildDigitalRegisterPdfBytesV2(
  Map<String, Object?> report,
  Uint8List? logoBytes,
  String supervisor,
) async {
  final trucks = _reportMaps(report['trucks']);
  final items = _reportMaps(report['items']);
  final corrections = _reportMaps(report['corrections']);
  final pdf = pw.Document();
  final rowCount = report['rowCount'] as int? ?? 0;
  final totalLayers = trucks.fold<int>(
    0,
    (total, truck) => total + _reportMaps(truck['layers']).length,
  );
  final legacyRows = <List<String>>[
    [
      'S.NO.',
      for (final truck in trucks) ...[
        'VEHICLE: ${truck['vehicleNumber']}',
        '',
      ],
    ],
    [
      '',
      for (var index = 0; index < trucks.length; index++) ...[
        'CARTONS',
        'ITEM'
      ],
    ],
    for (var row = 0; row < rowCount; row++)
      [
        '${row + 1}',
        for (final truck in trucks) ..._digitalRegisterCells(truck, row),
      ],
  ];
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    margin: const pw.EdgeInsets.fromLTRB(24, 22, 24, 22),
    header: (context) => ReportTemplateServiceImpl.buildHeader(
      title: 'Digital Wagon Register',
      logo: logoBytes == null ? null : pw.MemoryImage(logoBytes),
      reference: report['wagonNumber'].toString(),
      date: report['loadingDate'].toString(),
    ),
    footer: (context) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey500)),
      ),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('PAGE ${context.pageNumber} OF ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7)),
      ),
    ),
    build: (context) => [
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.7)),
        child: pw.Row(children: [
          for (final value in [
            'FROM: ${_reportValue(report['origin'])}',
            'TO: ${_reportValue(report['destination'])}',
            'WAGON: ${report['wagonNumber']}',
            'CARTONS: ${report['totalCartons']}',
            'DATE: ${report['loadingDate']}',
          ])
            pw.Expanded(
                child: pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold))),
        ]),
      ),
      pw.SizedBox(height: 7),
      pw.TableHelper.fromTextArray(
        context: context,
        border: pw.TableBorder.all(color: PdfColors.black, width: 0.45),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        headerStyle: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 6),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        cellAlignment: pw.Alignment.center,
        headerCount: 2,
        data: legacyRows,
      ),
      pw.SizedBox(height: 8),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.7),
            ),
            child: pw.Row(
              children: [
                for (final value in [
                  'VEHICLES: ${trucks.length}',
                  'LAYERS: $totalLayers',
                  'CARTONS: ${report['totalCartons']}',
                  'DEFECTS: ${report['totalDefects']}',
                ])
                  pw.Expanded(
                    child: pw.Text(
                      value,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            'SUPERVISOR: $supervisor',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('REMARKS: ${_reportValue(report['remarks'])}',
              style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    header: (context) => ReportTemplateServiceImpl.buildHeader(
      title: 'Digital Wagon Register',
      logo: logoBytes == null ? null : pw.MemoryImage(logoBytes),
      reference: report['wagonNumber'].toString(),
      date: report['loadingDate'].toString(),
    ),
    footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
    build: (context) => [
      _registerSectionTitle('Executive Summary'),
      pw.TableHelper.fromTextArray(
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        headers: const ['From', 'To', 'Trucks', 'Cartons', 'Defects'],
        data: [
          [
            _reportValue(report['origin']),
            _reportValue(report['destination']),
            trucks.length,
            report['totalCartons'],
            report['totalDefects'],
          ]
        ],
      ),
      pw.SizedBox(height: 16),
      _registerSectionTitle('Item Reconciliation'),
      if (items.isEmpty)
        pw.Text('No item manifest recorded.')
      else
        pw.TableHelper.fromTextArray(
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headers: const ['Item', 'Manifest', 'Loaded', 'Remaining', 'Status'],
          data: items
              .map((item) => [
                    item['name'],
                    item['manifest'],
                    item['loaded'],
                    item['remaining'],
                    (item['remaining'] as int) == 0
                        ? 'Complete'
                        : 'In progress',
                  ])
              .toList(),
        ),
      pw.SizedBox(height: 16),
      _registerSectionTitle('Truck Summary'),
      pw.TableHelper.fromTextArray(
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 7),
        headers: const [
          'Vehicle',
          'Driver',
          'Status',
          'Layers',
          'Cartons',
          'Def.'
        ],
        data: trucks
            .map((truck) => [
                  truck['vehicleNumber'],
                  truck['driverName'],
                  truck['status'],
                  truck['totalLayers'],
                  truck['totalCartons'],
                  truck['totalDefects'],
                ])
            .toList(),
      ),
      pw.SizedBox(height: 16),
      ...trucks.expand((truck) {
        final layers = _reportMaps(truck['layers']);
        return <pw.Widget>[
          pw.Text('${truck['vehicleNumber']} - Layer Details',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.TableHelper.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle:
                pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 6),
            headers: const [
              'Layer',
              'Cartons',
              'Items',
              'Def.',
              'Operator',
              'Added',
              'Notes'
            ],
            data: layers
                .map((layer) => [
                      layer['number'],
                      layer['cartons'],
                      layer['items'],
                      layer['defects'],
                      layer['operator'],
                      layer['added'],
                      layer['notes'],
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ];
      }),
      if (corrections.isNotEmpty) ...[
        _registerSectionTitle('Correction Audit'),
        pw.TableHelper.fromTextArray(
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headerStyle:
              pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 6),
          headers: const [
            'Layer',
            'Changed At',
            'Operator',
            'Changes',
            'Reason'
          ],
          data: corrections
              .map((item) => [
                    item['layer'],
                    item['when'],
                    item['operator'],
                    item['changes'],
                    item['reason'],
                  ])
              .toList(),
        ),
      ],
      pw.SizedBox(height: 14),
      pw.Text('Remarks: ${_reportValue(report['remarks'])}'),
      pw.SizedBox(height: 20),
      ReportTemplateServiceImpl.buildSignatures(supervisorName: supervisor),
    ],
  ));
  return pdf.save();
}

pw.Widget _registerSectionTitle(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
    );

Future<Uint8List> _buildAnalyticsPdfBytes(
  Map<String, Object?> report,
  Uint8List? logoBytes,
  String supervisor,
) async {
  final trucks = _reportMaps(report['trucks']);
  final averageConfidence = report['averageConfidence']! as double;
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => ReportTemplateServiceImpl.buildHeader(
        title: 'Enterprise Analytics & Operations',
        logo: logoBytes == null ? null : pw.MemoryImage(logoBytes),
        subtitle: 'Global KPI Report | Generated: ${report['generatedAt']}',
      ),
      footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
      build: (context) => [
        pw.Text('Executive Summary',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900)),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildKpiCard('Total Wagons', '${report['totalWagons']}'),
                _buildKpiCard('Total Trucks', '${report['totalTrucks']}'),
                _buildKpiCard('Total Layers', '${report['totalLayers']}'),
                _buildKpiCard('Total Cartons', '${report['totalCartons']}'),
                _buildKpiCard('Avg Confidence',
                    '${(averageConfidence * 100).toStringAsFixed(1)}%'),
              ]),
        ),
        pw.SizedBox(height: 24),
        pw.Text('Recent Truck Operations',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: context,
          headerDecoration:
              const pw.BoxDecoration(color: PdfColors.blueGrey800),
          headerStyle: pw.TextStyle(
              color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          headers: const [
            'Truck ID',
            'Vehicle No.',
            'Driver',
            'Cartons',
            'Defects',
            'Status',
            'Completed',
          ],
          data: trucks
              .map((truck) => [
                    truck['truckNumber'].toString(),
                    truck['vehicleNumber'].toString(),
                    truck['driverName'].toString(),
                    truck['totalCartons'].toString(),
                    truck['totalDefects'].toString(),
                    truck['status'].toString(),
                    truck['completedDate'].toString(),
                  ])
              .toList(growable: false),
        ),
        pw.SizedBox(height: 30),
        pw.Text('System Health & Quality',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(
            'Total defects flagged by AI across all operations: ${report['totalDefects']}',
            style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.SizedBox(height: 40),
        ReportTemplateServiceImpl.buildSignatures(supervisorName: supervisor),
      ],
    ),
  );
  return pdf.save();
}

List<Map<String, Object?>> _reportMaps(Object? value) {
  return (value! as List)
      .cast<Map<Object?, Object?>>()
      .map((entry) => entry.cast<String, Object?>())
      .toList(growable: false);
}

List<String> _digitalRegisterCells(Map<String, Object?> truck, int row) {
  final layers = _reportMaps(truck['layers']);
  final expectedLayerNumber = row + 1;
  Map<String, Object?>? layer;
  for (final candidate in layers) {
    final number = candidate['number'] ?? candidate['layerNumber'];
    if (number is num && number.toInt() == expectedLayerNumber) {
      layer = candidate;
      break;
    }
  }
  if (layer == null && row < layers.length) {
    final candidate = layers[row];
    if (!candidate.containsKey('number') &&
        !candidate.containsKey('layerNumber')) {
      layer = candidate;
    }
  }
  if (layer == null) return const ['', ''];
  return [
    layer['cartonCount']?.toString() ?? '',
    layer['item']?.toString() ?? '',
  ];
}

pw.Widget _buildKpiCard(String label, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800)),
      pw.SizedBox(height: 4),
      pw.Text(label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
    ],
  );
}
