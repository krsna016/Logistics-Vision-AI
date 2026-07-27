import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'report_template_service_impl.dart';
import 'package:drift/drift.dart' as drift;

class PdfReportServiceImpl implements PdfReportService {
  final AppDatabase _db;

  PdfReportServiceImpl(this._db);

  Future<File> _savePdf(pw.Document pdf, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${prefix}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  Future<File> generateTruckReport({required String truckId}) async {
    final truck = await (_db.select(_db.trucks)..where((t) => t.id.equals(truckId))).getSingleOrNull();
    final layers = await (_db.select(_db.layers)..where((l) => l.truckId.equals(truckId))).get();

    if (truck == null) throw Exception('Truck not found');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => ReportTemplateServiceImpl.buildHeader(
          title: 'Truck Loading Report',
          subtitle: 'Truck Number: ${truck.truckNumber} | Date: ${DateTime.now().toString().split(' ')[0]}',
        ),
        footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
        build: (context) => [
          pw.Text('Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Vehicle Number: ${truck.vehicleNumber}'),
              pw.Text('Driver: ${truck.driverName}'),
            ]
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Company: ${truck.company}'),
              pw.Text('Status: ${truck.status}'),
            ]
          ),
          pw.SizedBox(height: 20),
          pw.Text('Layers Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Layer No.', 'Cartons', 'Defects', 'Avg Confidence', 'Operator'],
            data: layers.map((l) => [
              l.layerNumber.toString(),
              l.cartonCount.toString(),
              l.defectCount.toString(),
              '${(l.averageConfidence * 100).toStringAsFixed(1)}%',
              l.operatorId ?? 'N/A'
            ]).toList(),
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
                pw.Text('Total Layers: ${truck.totalLayers}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Cartons: ${truck.totalCartons}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Total Defects: ${truck.totalDefects}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ]
            )
          ),
          ReportTemplateServiceImpl.buildSignatures(),
        ],
      ),
    );

    return _savePdf(pdf, 'TRUCK_${truck.truckNumber}');
  }

  @override
  Future<File> generateWagonReport({required String wagonId}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(child: pw.Text('Wagon Report for $wagonId')),
      ),
    );
    return _savePdf(pdf, 'WAGON_$wagonId');
  }

  @override
  Future<File> generateAnalyticsReport() async {
    final wagons = await _db.select(_db.wagons).get();
    final trucks = await (_db.select(_db.trucks)..where((t) => t.isDeleted.equals(false))).get();
    final layers = await (_db.select(_db.layers)..where((l) => l.isDeleted.equals(false))).get();

    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);
    final totalDefects = layers.fold<int>(0, (sum, l) => sum + l.defectCount);
    final avgConfidence = layers.isEmpty ? 0.0 : layers.fold<double>(0.0, (sum, l) => sum + l.averageConfidence) / layers.length;

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => ReportTemplateServiceImpl.buildHeader(
          title: 'Enterprise Analytics & Operations',
          subtitle: 'Global KPI Report | Generated: ${DateTime.now().toString().split('.')[0]}',
        ),
        footer: (context) => ReportTemplateServiceImpl.buildFooter(context),
        build: (context) => [
          pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
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
                _buildKPICard('Avg Confidence', '${(avgConfidence * 100).toStringAsFixed(1)}%'),
              ]
            ),
          ),
          
          pw.SizedBox(height: 24),
          pw.Text('Recent Truck Operations', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          
          pw.TableHelper.fromTextArray(
            context: context,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headers: ['Truck ID', 'Vehicle No.', 'Driver', 'Cartons', 'Defects', 'Status', 'Completed'],
            data: trucks.take(50).map((t) => [
              t.truckNumber,
              t.vehicleNumber,
              t.driverName,
              t.totalCartons.toString(),
              t.totalDefects.toString(),
              t.status,
              t.completedDate?.toString().split('.')[0] ?? 'N/A'
            ]).toList(),
          ),
          
          pw.SizedBox(height: 30),
          pw.Text('System Health & Quality', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Total defects flagged by AI across all operations: $totalDefects', style: const pw.TextStyle(color: PdfColors.grey700)),
          
          pw.SizedBox(height: 40),
          ReportTemplateServiceImpl.buildSignatures(),
        ],
      ),
    );
    
    return _savePdf(pdf, 'ENTERPRISE_ANALYTICS');
  }

  pw.Widget _buildKPICard(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }
}
