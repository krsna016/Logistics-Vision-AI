import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class ExcelReportServiceImpl implements ExcelReportService {
  final AppDatabase _db;
  final String? supervisorName;

  ExcelReportServiceImpl(this._db, {this.supervisorName});

  String get _supervisor => supervisorName?.trim().isNotEmpty == true
      ? supervisorName!.trim()
      : 'Operations Supervisor';

  Future<File> _saveExcel(Excel excel, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/${prefix}_$timestamp.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }

  @override
  Future<File> generateTruckReport({required String truckId}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Truck_$truckId'];
    excel.setDefaultSheet(sheet.sheetName);

    // Fetch data
    final truck = await (_db.select(_db.trucks)
          ..where((t) => t.id.equals(truckId)))
        .getSingleOrNull();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.truckId.equals(truckId)))
        .get();

    if (truck == null) throw Exception('Truck not found');

    // Header styling
    CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Merge Cells for Title
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("G1"));
    var titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value =
        TextCellValue('Truck Loading Report - ${truck.truckNumber}');
    titleCell.cellStyle =
        CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);

    // Metadata
    sheet.cell(CellIndex.indexByString("A3")).value =
        TextCellValue('Driver: ${truck.driverName}');
    sheet.cell(CellIndex.indexByString("A4")).value =
        TextCellValue('Company: ${truck.company}');
    sheet.cell(CellIndex.indexByString("D3")).value = TextCellValue(
        'Date: ${truck.completedDate?.toIso8601String() ?? 'N/A'}');
    sheet.cell(CellIndex.indexByString("D4")).value =
        TextCellValue(_supervisor);

    // Data Table Headers
    final headers = [
      'Layer No',
      'Carton Count',
      'Defects',
      'Layer Added',
      'Operator',
      'Model Version'
    ];
    for (int i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Rows
    int currentRow = 6;
    for (var layer in layers) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = IntCellValue(layer.layerNumber);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = IntCellValue(layer.cartonCount);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .value = IntCellValue(layer.defectCount);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue(layer.timestamp.toString().split('.')[0]);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = TextCellValue(layer.operatorId ?? 'N/A');
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = TextCellValue(layer.modelVersion ?? 'N/A');
      currentRow++;
    }

    // Totals
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: currentRow + 1))
        .value = TextCellValue('TOTAL');
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 1, rowIndex: currentRow + 1))
        .value = IntCellValue(truck.totalCartons);
    sheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: 2, rowIndex: currentRow + 1))
        .value = IntCellValue(truck.totalDefects);

    return _saveExcel(excel, 'TRUCK_${truck.truckNumber}');
  }

  @override
  Future<File> generateWagonReport({required String wagonId}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Wagon_$wagonId'];
    excel.setDefaultSheet(sheet.sheetName);

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
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );
    final valueStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('H1'));
    sheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('Wagon Loading Report - ${wagon.wagonNumber}');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('A3')).value =
        TextCellValue('From: ${wagon.origin}');
    sheet.cell(CellIndex.indexByString('A4')).value =
        TextCellValue('To: ${wagon.destination}');
    sheet.cell(CellIndex.indexByString('D3')).value = TextCellValue(
        'Loading Date: ${wagon.loadingDate.toString().split(' ')[0]}');
    sheet.cell(CellIndex.indexByString('D4')).value =
        TextCellValue(_supervisor);
    sheet.cell(CellIndex.indexByString('G3')).value =
        TextCellValue('Status: ${wagon.status}');

    const headers = [
      'Truck No.',
      'Vehicle No.',
      'Driver',
      'Phone',
      'Layers',
      'Cartons',
      'Defects',
      'Status',
    ];
    for (var column = 0; column < headers.length; column++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 5));
      cell.value = TextCellValue(headers[column]);
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(5, 28);
    var currentRow = 6;
    for (final truck in trucks) {
      final values = [
        truck.truckNumber,
        truck.vehicleNumber,
        truck.driverName,
        truck.driverMobile ?? 'N/A',
        truck.totalLayers.toString(),
        truck.totalCartons.toString(),
        truck.totalDefects.toString(),
        truck.status,
      ];
      for (var column = 0; column < values.length; column++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: column, rowIndex: currentRow));
        cell.value = TextCellValue(values[column]);
        cell.cellStyle = valueStyle;
      }
      currentRow++;
    }
    currentRow++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('TOTAL TRUCKS: ${trucks.length}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue('TOTAL LAYERS: $totalLayers');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
        .value = TextCellValue('TOTAL CARTONS: $totalCartons');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
        .value = TextCellValue('TOTAL DEFECTS: $totalDefects');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
        .value = TextCellValue(_supervisor);
    currentRow += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('REMARKS: ${wagon.remarks ?? ''}');
    return _saveExcel(excel, 'WAGON_${wagon.wagonNumber}');
  }

  @override
  Future<File> generateDigitalRegisterReport({required String wagonId}) async {
    final excel = Excel.createExcel();
    final sheet = excel['Wagon_$wagonId'];
    excel.setDefaultSheet(sheet.sheetName);

    final wagon = await (_db.select(_db.wagons)
          ..where((w) => w.id.equals(wagonId) & w.isDeleted.equals(false)))
        .getSingleOrNull();
    if (wagon == null) throw Exception('Wagon not found');
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
    final register = await (_db.select(_db.digitalRegisters)
          ..where((r) => r.wagonId.equals(wagonId) & r.isDeleted.equals(false)))
        .getSingleOrNull();
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );
    final valueStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
    var currentRow = 0;
    final topFields = [
      'FROM: ${wagon.origin}',
      'TO: ${wagon.destination}',
      'WAGON NO: ${wagon.wagonNumber}',
      'WAGON QTY: $totalCartons',
      'UNLOADING DATE: ${wagon.loadingDate.toString().split(' ')[0]}',
    ];
    for (var column = 0; column < topFields.length; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: column, rowIndex: currentRow))
          .value = TextCellValue(topFields[column]);
    }
    currentRow += 2;
    final truckHeader = <String>['S.NO.'];
    final quantityHeader = <String>[''];
    for (final truck in trucks) {
      truckHeader.addAll(['TRUCK NO: ${truck.truckNumber}', '']);
      quantityHeader.addAll(['QTY', 'ITEM']);
    }
    for (var column = 0; column < truckHeader.length; column++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: column, rowIndex: currentRow));
      cell.value = TextCellValue(truckHeader[column]);
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(currentRow, 32);
    currentRow++;
    for (var column = 0; column < quantityHeader.length; column++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: column, rowIndex: currentRow));
      cell.value = TextCellValue(quantityHeader[column]);
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(currentRow, 24);
    currentRow++;
    var rowCount = 20;
    for (final layer in layers) {
      if (layer.layerNumber > rowCount) rowCount = layer.layerNumber;
    }
    for (var layerNumber = 1; layerNumber <= rowCount; layerNumber++) {
      var column = 0;
      final serialCell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: column++, rowIndex: currentRow));
      serialCell.value = IntCellValue(layerNumber);
      serialCell.cellStyle = valueStyle;
      for (final truck in trucks) {
        final matches = layers.where((item) =>
            item.truckId == truck.id && item.layerNumber == layerNumber);
        final layer = matches.isEmpty ? null : matches.first;
        final qtyCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: column++, rowIndex: currentRow));
        qtyCell.value =
            layer == null ? TextCellValue('') : IntCellValue(layer.cartonCount);
        qtyCell.cellStyle = valueStyle;
        final itemCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: column++, rowIndex: currentRow));
        final item = layer?.notes?.split('|').first.trim();
        itemCell.value =
            TextCellValue(item == null || item.isEmpty ? '' : item);
        itemCell.cellStyle = valueStyle;
      }
      currentRow++;
    }
    currentRow++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('REMARKS: ${wagon.remarks ?? ''}');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .value = TextCellValue('TOTAL CARTONS: $totalCartons');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
        .value = TextCellValue('TOTAL DEFECTS: $totalDefects');
    if (register != null) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue(_supervisor);
    } else {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue(_supervisor);
    }
    return _saveExcel(excel, 'WAGON_$wagonId');
  }

  @override
  Future<File> generateAnalyticsReport() async {
    final excel = Excel.createExcel();
    final sheet = excel['Analytics'];
    excel.setDefaultSheet(sheet.sheetName);

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

    CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );

    // Title
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("G1"));
    var titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value = TextCellValue('Enterprise Analytics & Operations');
    titleCell.cellStyle = titleStyle;

    sheet.cell(CellIndex.indexByString("A2")).value =
        TextCellValue('Generated: ${DateTime.now().toString()}');

    // KPI Summary
    sheet.cell(CellIndex.indexByString("A4")).value =
        TextCellValue('Global KPI Summary');
    sheet.cell(CellIndex.indexByString("A4")).cellStyle =
        CellStyle(bold: true, fontSize: 14);

    sheet.cell(CellIndex.indexByString("A5")).value =
        TextCellValue('Total Wagons');
    sheet.cell(CellIndex.indexByString("B5")).value =
        IntCellValue(wagons.length);

    sheet.cell(CellIndex.indexByString("A6")).value =
        TextCellValue('Total Trucks');
    sheet.cell(CellIndex.indexByString("B6")).value =
        IntCellValue(trucks.length);

    sheet.cell(CellIndex.indexByString("A7")).value =
        TextCellValue('Total Layers');
    sheet.cell(CellIndex.indexByString("B7")).value =
        IntCellValue(layers.length);

    sheet.cell(CellIndex.indexByString("A8")).value =
        TextCellValue('Total Cartons');
    sheet.cell(CellIndex.indexByString("B8")).value =
        IntCellValue(totalCartons);

    sheet.cell(CellIndex.indexByString("A9")).value =
        TextCellValue('Total Defects');
    sheet.cell(CellIndex.indexByString("B9")).value =
        IntCellValue(totalDefects);

    sheet.cell(CellIndex.indexByString("A10")).value =
        TextCellValue('Average Confidence');
    sheet.cell(CellIndex.indexByString("B10")).value =
        DoubleCellValue(avgConfidence);

    // Trucks Table Header
    sheet.cell(CellIndex.indexByString("A12")).value =
        TextCellValue('Detailed Truck Operations');
    sheet.cell(CellIndex.indexByString("A12")).cellStyle =
        CellStyle(bold: true, fontSize: 14);

    final headers = [
      'Truck ID',
      'Vehicle No.',
      'Driver',
      'Cartons',
      'Defects',
      'Status',
      'Completed Date'
    ];
    for (int i = 0; i < headers.length; i++) {
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 13));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Rows
    int currentRow = 14;
    for (var truck in trucks) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue(truck.truckNumber);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
          .value = TextCellValue(truck.vehicleNumber);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .value = TextCellValue(truck.driverName);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = IntCellValue(truck.totalCartons);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = IntCellValue(truck.totalDefects);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = TextCellValue(truck.status);
      sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 6, rowIndex: currentRow))
              .value =
          TextCellValue(truck.completedDate?.toIso8601String() ?? 'N/A');
      currentRow++;
    }

    return _saveExcel(excel, 'ENTERPRISE_ANALYTICS');
  }
}
