import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'report_template_service_impl.dart';
import 'package:drift/drift.dart' as drift;

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
    final item = layer?.notes?.split('|').first.trim() ?? '';
    return item;
  }

  @override
  Future<File> generateTruckReport({required String truckId}) async {
    final truck = await (_db.select(_db.trucks)
          ..where((t) => t.id.equals(truckId) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.truckId.equals(truckId) & l.isDeleted.equals(false)))
        .get();

    if (truck == null) throw Exception('Truck not found');

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
              'timestamp': layer.timestamp.toString().split('.')[0],
              'operator': layer.operatorId ?? 'N/A',
            },
          )
          .toList(growable: false),
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
          ..where((t) => t.wagonId.equals(wagonId) & t.isDeleted.equals(false)))
        .get();
    final truckIds = trucks.map((truck) => truck.id).toList(growable: false);
    final layers = truckIds.isEmpty
        ? <Layer>[]
        : await (_db.select(_db.layers)
              ..where(
                  (l) => l.truckId.isIn(truckIds) & l.isDeleted.equals(false)))
            .get();
    final layersByTruck = <String, List<Layer>>{
      for (final truck in trucks)
        truck.id: layers.where((layer) => layer.truckId == truck.id).toList(),
    };
    final reportData = <String, Object?>{
      'wagonNumber': wagon.wagonNumber,
      'loadingDate': wagon.loadingDate.toString().split(' ')[0],
      'status': wagon.status,
      'origin': wagon.origin,
      'destination': wagon.destination,
      'remarks': wagon.remarks ?? '',
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
          ..where((t) => t.wagonId.equals(wagonId) & t.isDeleted.equals(false)))
        .get();
    final truckIds = trucks.map((truck) => truck.id).toList();
    final layers = truckIds.isEmpty
        ? <Layer>[]
        : await (_db.select(_db.layers)
              ..where(
                  (l) => l.truckId.isIn(truckIds) & l.isDeleted.equals(false)))
            .get();
    final totalCartons =
        layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
    final totalDefects =
        layers.fold<int>(0, (sum, layer) => sum + layer.defectCount);

    final reportTrucks = trucks;
    final layerByTruck = <String, Map<int, Layer>>{
      for (final truck in reportTrucks)
        truck.id: {
          for (final layer in layers.where((l) => l.truckId == truck.id))
            layer.layerNumber: layer,
        },
    };
    var rowCount = 20;
    for (final layer in layers) {
      if (layer.layerNumber > rowCount) rowCount = layer.layerNumber;
    }

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
      'trucks': reportTrucks
          .map<Map<String, Object?>>(
            (truck) => {
              'id': truck.id,
              'truckNumber': truck.truckNumber,
              'layers': [
                for (var row = 1; row <= rowCount; row++)
                  {
                    'cartonCount': layerByTruck[truck.id]?[row]?.cartonCount,
                    'item': _layerItem(layerByTruck[truck.id]?[row]),
                  },
              ],
            },
          )
          .toList(growable: false),
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
        subtitle: 'Wagon Number: $wagonNumber | Date: $loadingDate',
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
            pw.Text('From: ${report['origin']}'),
            pw.Text('To: ${report['destination']}'),
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
            'Truck No.',
            'Vehicle No.',
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
                  truck['truckNumber'].toString(),
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
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => ReportTemplateServiceImpl.buildHeader(
        title: 'Truck Loading Report',
        logo: logoBytes == null ? null : pw.MemoryImage(logoBytes),
        subtitle:
            'Truck Number: ${report['truckNumber']} | Date: ${report['generatedDate']}',
      ),
      footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
      build: (context) => [
        pw.Text('Details',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Vehicle Number: ${report['vehicleNumber']}'),
          pw.Text('Driver: ${report['driverName']}'),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Driver Phone: ${report['driverMobile']}'),
          pw.Text('Company: ${report['company']}'),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Warehouse: ${report['warehouse']}'),
          pw.Text('Status: ${report['status']}'),
        ]),
        pw.SizedBox(height: 28),
        pw.Text('Layers Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: context,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          headers: const [
            'Layer No.',
            'Cartons',
            'Defects',
            'Layer Added',
            'Operator',
          ],
          data: layers
              .map((layer) => [
                    layer['layerNumber'].toString(),
                    layer['cartonCount'].toString(),
                    layer['defectCount'].toString(),
                    layer['timestamp'].toString(),
                    layer['operator'].toString(),
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
  final trucks = _reportMaps(report['trucks']);
  final rowCount = report['rowCount']! as int;
  final tableRows = <List<String>>[
    [
      'S.NO.',
      for (final truck in trucks) ...[
        'TRUCK NO: ${truck['truckNumber']}',
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
  final layer = layers[row];
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
