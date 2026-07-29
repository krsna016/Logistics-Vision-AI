import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'report_template_service_impl.dart';
import 'package:drift/drift.dart' as drift;

class PdfReportServiceImpl implements PdfReportService {
  final AppDatabase _db;
  final String? supervisorName;

  PdfReportServiceImpl(this._db, {this.supervisorName});

  String get _supervisor => supervisorName?.trim().isNotEmpty == true
      ? supervisorName!.trim()
      : 'Operations Supervisor';

  Future<pw.ImageProvider?> _loadReportLogo() async {
    try {
      final data = await rootBundle.load('assets/images/report_logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  Future<File> _savePdf(pw.Document pdf, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${prefix}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  Future<File> generateTruckReport({required String truckId}) async {
    final truck = await (_db.select(_db.trucks)
          ..where((t) => t.id.equals(truckId)))
        .getSingleOrNull();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.truckId.equals(truckId)))
        .get();

    if (truck == null) throw Exception('Truck not found');

    final logo = await _loadReportLogo();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => ReportTemplateServiceImpl.buildHeader(
          title: 'Truck Loading Report',
          logo: logo,
          subtitle:
              'Truck Number: ${truck.truckNumber} | Date: ${DateTime.now().toString().split(' ')[0]}',
        ),
        footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
        build: (context) => [
          pw.Text('Details',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Vehicle Number: ${truck.vehicleNumber}'),
                pw.Text('Driver: ${truck.driverName}'),
              ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Driver Phone: ${truck.driverMobile ?? 'N/A'}'),
                pw.Text('Company: ${truck.company}'),
              ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Warehouse: ${truck.warehouse}'),
                pw.Text('Status: ${truck.status}'),
              ]),
          pw.SizedBox(height: 8),
          pw.SizedBox(height: 20),
          pw.Text('Layers Summary',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: [
              'Layer No.',
              'Cartons',
              'Defects',
              'Layer Added',
              'Operator'
            ],
            data: layers
                .map((l) => [
                      l.layerNumber.toString(),
                      l.cartonCount.toString(),
                      l.defectCount.toString(),
                      l.timestamp.toString().split('.')[0],
                      l.operatorId ?? 'N/A'
                    ])
                .toList(),
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
                    pw.Text('Total Layers: ${truck.totalLayers}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Cartons: ${truck.totalCartons}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Defects: ${truck.totalDefects}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ])),
          ReportTemplateServiceImpl.buildSignatures(
              supervisorName: _supervisor),
        ],
      ),
    );

    return _savePdf(pdf, 'TRUCK_${truck.truckNumber}');
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
    final totalCartons =
        trucks.fold<int>(0, (sum, truck) => sum + truck.totalCartons);
    final totalDefects =
        trucks.fold<int>(0, (sum, truck) => sum + truck.totalDefects);
    final totalLayers =
        trucks.fold<int>(0, (sum, truck) => sum + truck.totalLayers);

    final logo = await _loadReportLogo();
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => ReportTemplateServiceImpl.buildHeader(
          title: 'Wagon Loading Report',
          logo: logo,
          subtitle:
              'Wagon Number: ${wagon.wagonNumber} | Date: ${wagon.loadingDate.toString().split(' ')[0]}',
        ),
        footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
        build: (context) => [
          pw.Text('Wagon Details',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Wagon Number: ${wagon.wagonNumber}'),
                pw.Text('Status: ${wagon.status}'),
              ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('From: ${wagon.origin}'),
                pw.Text('To: ${wagon.destination}'),
              ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'Loading Date: ${wagon.loadingDate.toString().split(' ')[0]}'),
                pw.Text(_supervisor),
              ]),
          pw.SizedBox(height: 20),
          pw.Text('Truck Summary',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle:
                pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: [
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
                .map((truck) => [
                      truck.truckNumber,
                      truck.vehicleNumber,
                      truck.driverName,
                      truck.driverMobile ?? 'N/A',
                      truck.totalLayers.toString(),
                      truck.totalCartons.toString(),
                      truck.totalDefects.toString(),
                      truck.status,
                    ])
                .toList(),
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
                    pw.Text('Total Trucks: ${trucks.length}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Layers: $totalLayers',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Cartons: $totalCartons',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Total Defects: $totalDefects',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ])),
          pw.SizedBox(height: 16),
          pw.Text('Remarks: ${wagon.remarks ?? ''}'),
          pw.SizedBox(height: 28),
          ReportTemplateServiceImpl.buildSignatures(
              supervisorName: _supervisor),
        ],
      ),
    );
    return _savePdf(pdf, 'WAGON_${wagon.wagonNumber}');
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
        trucks.fold<int>(0, (sum, truck) => sum + truck.totalCartons);
    final totalDefects =
        trucks.fold<int>(0, (sum, truck) => sum + truck.totalDefects);

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

    final logo = await _loadReportLogo();
    final pdf = pw.Document();
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
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Text('SmartLoad System',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ]),
          ]),
          pw.SizedBox(height: 5),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.8),
            ),
            padding: const pw.EdgeInsets.all(6),
            child: pw.Row(
              children: [
                pw.Expanded(
                    child: pw.Text('FROM: ${wagon.origin}',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    child: pw.Text('TO: ${wagon.destination}',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    child: pw.Text('WAGON NO: ${wagon.wagonNumber}',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    child: pw.Text('WAGON QTY: $totalCartons',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    child: pw.Text(
                        'UNLOADING DATE: ${wagon.loadingDate.toString().split(' ')[0]}',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
              ],
            ),
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
            data: [
              [
                'S.NO.',
                for (final truck in reportTrucks) ...[
                  'TRUCK NO: ${truck.truckNumber}',
                  '',
                ],
              ],
              [
                '',
                for (var i = 0; i < reportTrucks.length; i++) ...[
                  'QTY',
                  'ITEM',
                ],
              ],
              for (var row = 1; row <= rowCount; row++)
                [
                  row.toString(),
                  for (final truck in reportTrucks) ...[
                    (layerByTruck[truck.id]?[row]?.cartonCount.toString() ??
                        ''),
                    (layerByTruck[truck.id]?[row]
                                ?.notes
                                ?.split('|')
                                .first
                                .trim()
                                .isNotEmpty ==
                            true
                        ? layerByTruck[truck.id]![row]!
                            .notes!
                            .split('|')
                            .first
                            .trim()
                        : ''),
                  ],
                ],
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 42,
            width: double.infinity,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.55)),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
                'REMARKS: ${wagon.remarks ?? ''}${register == null ? '' : '  |  REGISTER: ${register.id}'}',
                style: const pw.TextStyle(fontSize: 8)),
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL CARTONS: $totalCartons',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TOTAL DEFECTS: $totalDefects',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_supervisor,
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold)),
                ]),
          ),
        ],
      ),
    );
    return _savePdf(pdf, 'WAGON_$wagonId');
  }

  @override
  Future<File> generateAnalyticsReport() async {
    final wagons = await _db.select(_db.wagons).get();
    final trucks = await (_db.select(_db.trucks)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.isDeleted.equals(false)))
        .get();

    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);
    final totalDefects = layers.fold<int>(0, (sum, l) => sum + l.defectCount);
    final avgConfidence = layers.isEmpty
        ? 0.0
        : layers.fold<double>(0.0, (sum, l) => sum + l.averageConfidence) /
            layers.length;

    final logo = await _loadReportLogo();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => ReportTemplateServiceImpl.buildHeader(
          title: 'Enterprise Analytics & Operations',
          logo: logo,
          subtitle:
              'Global KPI Report | Generated: ${DateTime.now().toString().split('.')[0]}',
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
                  _buildKPICard('Total Wagons', wagons.length.toString()),
                  _buildKPICard('Total Trucks', trucks.length.toString()),
                  _buildKPICard('Total Layers', layers.length.toString()),
                  _buildKPICard('Total Cartons', totalCartons.toString()),
                  _buildKPICard('Avg Confidence',
                      '${(avgConfidence * 100).toStringAsFixed(1)}%'),
                ]),
          ),
          pw.SizedBox(height: 24),
          pw.Text('Recent Truck Operations',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blueGrey800),
            headerStyle: pw.TextStyle(
                color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headers: [
              'Truck ID',
              'Vehicle No.',
              'Driver',
              'Cartons',
              'Defects',
              'Status',
              'Completed'
            ],
            data: trucks
                .take(50)
                .map((t) => [
                      t.truckNumber,
                      t.vehicleNumber,
                      t.driverName,
                      t.totalCartons.toString(),
                      t.totalDefects.toString(),
                      t.status,
                      t.completedDate?.toString().split('.')[0] ?? 'N/A'
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text('System Health & Quality',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(
              'Total defects flagged by AI across all operations: $totalDefects',
              style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.SizedBox(height: 40),
          ReportTemplateServiceImpl.buildSignatures(
              supervisorName: _supervisor),
        ],
      ),
    );

    return _savePdf(pdf, 'ENTERPRISE_ANALYTICS');
  }

  pw.Widget _buildKPICard(String label, String value) {
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
}
