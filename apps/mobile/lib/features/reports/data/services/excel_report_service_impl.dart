import 'report_date_formatter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'pdf_report_service_impl.dart'
    show buildLayerCorrectionHistoryRows, parseLayerCorrectionDetails;

class ExcelReportServiceImpl implements ExcelReportService {
  final AppDatabase _db;
  final String? supervisorName;

  ExcelReportServiceImpl(this._db, {this.supervisorName});

  /// Strips internal [SPLIT_DATA] metadata from layer notes.
  String _cleanNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return 'No notes';
    final splitIdx = notes.indexOf('[SPLIT_DATA]:');
    if (splitIdx < 0) return notes.trim();
    var cleaned = notes.substring(0, splitIdx).trim();
    if (cleaned.endsWith('|')) cleaned = cleaned.substring(0, cleaned.length - 1).trim();
    return cleaned.isEmpty ? 'No notes' : cleaned;
  }

  String get _supervisor => supervisorName?.trim().isNotEmpty == true
      ? supervisorName!.trim()
      : 'Not provided';

  String get _supervisorLabel => 'Supervisor: $_supervisor';

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
      // Use the single-item compatibility value below.
    }
    if (result.isEmpty && layer.itemName?.trim().isNotEmpty == true) {
      result[layer.itemName!.trim()] = layer.cartonCount;
    }
    return result;
  }

  String _layerItemLabel(Layer layer) => _layerAllocations(layer)
      .entries
      .map((entry) => '${entry.key}: ${entry.value}')
      .join(' + ');

  String _correctionPart(String? details, String key) =>
      parseLayerCorrectionDetails(details)[key] ?? 'Not provided';

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
          ..where((t) => t.id.equals(truckId) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    final layers = await (_db.select(_db.layers)
          ..where((l) => l.truckId.equals(truckId) & l.isDeleted.equals(false))
          ..orderBy([(l) => drift.OrderingTerm.asc(l.layerNumber)]))
        .get();

    if (truck == null) throw Exception('Truck not found');

    final wagon = truck.wagonId == null
        ? null
        : await (_db.select(_db.wagons)
              ..where((w) =>
                  w.id.equals(truck.wagonId!) & w.isDeleted.equals(false)))
            .getSingleOrNull();

    // Header styling
    CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Merge Cells for Title
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("G1"));
    var titleCell = sheet.cell(CellIndex.indexByString("A1"));
    titleCell.value =
        TextCellValue('Truck Loading Report - ${truck.vehicleNumber}');
    titleCell.cellStyle =
        CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);

    // Metadata
    sheet.cell(CellIndex.indexByString("A3")).value =
        TextCellValue('Wagon No.: ${wagon?.wagonNumber ?? 'N/A'}');
    sheet.cell(CellIndex.indexByString("A4")).value =
        TextCellValue('Vehicle: ${truck.vehicleNumber}');
    sheet.cell(CellIndex.indexByString("C3")).value =
        TextCellValue('Driver: ${truck.driverName}');
    sheet.cell(CellIndex.indexByString("C4")).value =
        TextCellValue('Phone: ${truck.driverMobile ?? 'Not provided'}');
    sheet.cell(CellIndex.indexByString("E3")).value =
        TextCellValue('Company: ${truck.company}');
    sheet.cell(CellIndex.indexByString("E4")).value =
        TextCellValue('Warehouse: ${truck.warehouse}');
    sheet.cell(CellIndex.indexByString("G3")).value =
        TextCellValue('Status: ${truck.status}');
    sheet.cell(CellIndex.indexByString("G4")).value =
        TextCellValue(_supervisorLabel);

    // Data Table Headers
    final headers = [
      'Layer',
      'Cartons',
      'Items',
      'Def.',
      'Notes',
      'Added',
      'Operator',
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
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: 2, rowIndex: currentRow))
              .value =
          TextCellValue(
              _layerItemLabel(layer).isEmpty ? 'N/A' : _layerItemLabel(layer));
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = IntCellValue(layer.defectCount);
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow))
          .value = TextCellValue(_cleanNotes(layer.notes));
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow))
          .value = TextCellValue(ReportDateFormatter.formatDateTime(layer.timestamp));
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow))
          .value = TextCellValue(layer.operatorId ?? 'N/A');
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
            .value =
        IntCellValue(
            layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount));
    sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: currentRow + 1))
            .value =
        IntCellValue(
            layers.fold<int>(0, (sum, layer) => sum + layer.defectCount));

    final layerIds = layers.map((layer) => layer.id).toList(growable: false);
    final corrections = layerIds.isEmpty
        ? <AuditLog>[]
        : await (_db.select(_db.auditLogs)
              ..where((log) =>
                  log.entityId.isIn(layerIds) &
                  log.entityType.equals('Layer') &
                  log.action.equals('correct'))
              ..orderBy([(log) => drift.OrderingTerm.asc(log.timestamp)]))
            .get();
    if (corrections.isNotEmpty) {
      final correctionSheet = excel['Layer Correction History'];
      const correctionHeaders = [
        'Layer',
        'Changed At',
        'Operator',
        'Before',
        'After',
        'Reason',
      ];
      for (var column = 0; column < correctionHeaders.length; column++) {
        final cell = correctionSheet.cell(CellIndex.indexByColumnRow(
          columnIndex: column,
          rowIndex: 0,
        ));
        cell.value = TextCellValue(correctionHeaders[column]);
        cell.cellStyle = headerStyle;
      }
      for (var row = 0; row < corrections.length; row++) {
        final audit = corrections[row];
        final parsed = parseLayerCorrectionDetails(audit.details);
        final values = [
          layers
              .firstWhere((layer) => layer.id == audit.entityId)
              .layerNumber
              .toString(),
          ReportDateFormatter.formatDateTime(audit.timestamp),
          audit.userId,
          parsed['before'] ?? 'Not recorded',
          parsed['after'] ?? 'Not recorded',
          parsed['reason'] ?? 'Not provided',
        ];
        for (var column = 0; column < values.length; column++) {
          correctionSheet
              .cell(CellIndex.indexByColumnRow(
                columnIndex: column,
                rowIndex: row + 1,
              ))
              .value = TextCellValue(values[column]);
        }
      }
    }

    return _saveExcel(excel, 'TRUCK_${truck.vehicleNumber}');
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
    final truckIds = trucks.map((truck) => truck.id).toList(growable: false);
    final layers = truckIds.isEmpty
        ? <Layer>[]
        : await (_db.select(_db.layers)
              ..where(
                  (l) => l.truckId.isIn(truckIds) & l.isDeleted.equals(false)))
            .get();
    final layerIds = layers.map((layer) => layer.id).toList(growable: false);
    final correctionAudits = layerIds.isEmpty
        ? <AuditLog>[]
        : await (_db.select(_db.auditLogs)
              ..where((log) =>
                  log.entityId.isIn(layerIds) &
                  log.entityType.equals('Layer') &
                  log.action.equals('correct'))
              ..orderBy([(log) => drift.OrderingTerm.asc(log.timestamp)]))
            .get();
    final corrections = buildLayerCorrectionHistoryRows(
      audits: correctionAudits,
      layers: layers,
      trucks: trucks,
    );
    final totalCartons =
        layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
    final totalDefects =
        layers.fold<int>(0, (sum, layer) => sum + layer.defectCount);
    final totalLayers = layers.length;
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
        .toList(growable: false);
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
        'Loading Date: ${ReportDateFormatter.formatDate(wagon.loadingDate)}');
    sheet.cell(CellIndex.indexByString('D4')).value =
        TextCellValue(_supervisorLabel);
    sheet.cell(CellIndex.indexByString('G3')).value =
        TextCellValue('Status: ${wagon.status}');

    const headers = [
      'Vehicle Number',
      'Driver',
      'Phone',
      'Layers',
      'Cartons',
      'Defects',
      'Item Breakdown',
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
      final truckLayers = layersByTruck[truck.id]!;
      final breakdownMap = <String, int>{};
      for (final layer in truckLayers) {
        for (final allocation in _layerAllocations(layer).entries) {
          breakdownMap[allocation.key] = (breakdownMap[allocation.key] ?? 0) + allocation.value;
        }
      }
      final itemBreakdown = breakdownMap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      
      final values = [
        truck.vehicleNumber,
        truck.driverName,
        truck.driverMobile ?? 'N/A',
        truckLayers.length.toString(),
        truckLayers.fold<int>(0, (sum, layer) => sum + layer.cartonCount).toString(),
        truckLayers.fold<int>(0, (sum, layer) => sum + layer.defectCount).toString(),
        itemBreakdown,
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
        .value = TextCellValue(_supervisorLabel);
    currentRow += 2;
    if (manifest.isNotEmpty) {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = TextCellValue('ITEM INVENTORY');
      currentRow++;
      const inventoryHeaders = ['Item', 'Total', 'Loaded', 'Remaining'];
      for (var column = 0; column < inventoryHeaders.length; column++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: column, rowIndex: currentRow));
        cell.value = TextCellValue(inventoryHeaders[column]);
        cell.cellStyle = headerStyle;
      }
      currentRow++;
      for (final item in manifest) {
        final name = item['name'] as String? ?? '';
        final total = (item['quantity'] as num? ?? 0).toInt();
        final loaded = loadedByItem[name] ?? 0;
        final values = [name, '$total', '$loaded', '${total - loaded}'];
        for (var column = 0; column < values.length; column++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: column, rowIndex: currentRow))
              .value = TextCellValue(values[column]);
        }
        currentRow++;
      }
      currentRow++;
    }
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
        .value = TextCellValue('REMARKS: ${wagon.remarks ?? ''}');
    final correctionSheet = excel['Layer Correction History'];
    const correctionHeaders = [
      'Vehicle',
      'Layer',
      'Changed At',
      'Operator',
      'Before',
      'After',
      'Reason',
    ];
    for (var column = 0; column < correctionHeaders.length; column++) {
      final cell = correctionSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0));
      cell.value = TextCellValue(correctionHeaders[column]);
      cell.cellStyle = headerStyle;
    }
    if (corrections.isEmpty) {
      correctionSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = TextCellValue('No layer corrections recorded.');
    } else {
      for (var row = 0; row < corrections.length; row++) {
        final correction = corrections[row];
        final values = [
          correction['vehicleNumber'].toString(),
          correction['layerNumber'].toString(),
          correction['timestamp'].toString(),
          correction['operator'].toString(),
          correction['before'].toString(),
          correction['after'].toString(),
          correction['reason'].toString(),
        ];
        for (var column = 0; column < values.length; column++) {
          correctionSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: column, rowIndex: row + 1))
              .value = TextCellValue(values[column]);
        }
      }
    }
    return _saveExcel(excel, 'WAGON_${wagon.wagonNumber}');
  }

  @override
  Future<File> generateDigitalRegisterReport({required String wagonId}) async {
    final wagon = await (_db.select(_db.wagons)
          ..where((w) => w.id.equals(wagonId) & w.isDeleted.equals(false)))
        .getSingleOrNull();
    if (wagon == null) throw Exception('Wagon not found');

    final excel = Excel.createExcel();
    final sheet = excel['Wagon_${wagon.wagonNumber}'];
    excel.setDefaultSheet(sheet.sheetName);
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
    final register = await (_db.select(_db.digitalRegisters)
          ..where((r) => r.wagonId.equals(wagonId) & r.isDeleted.equals(false)))
        .getSingleOrNull();
    void writeRow(Sheet target, int row, List<CellValue> values) {
      for (var column = 0; column < values.length; column++) {
        target
            .cell(
                CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
            .value = values[column];
      }
    }

    final summarySheet = excel['Register Summary'];
    final itemSheet = excel['Item Inventory'];
    final truckSheet = excel['Truck Summary'];
    final layerSheet = excel['Layer Details'];
    final correctionSheet = excel['Layer Correction History'];
    writeRow(summarySheet, 0, [
      TextCellValue('DIGITAL WAGON REGISTER'),
    ]);
    final summaryRows = <List<CellValue>>[
      [TextCellValue('Wagon'), TextCellValue(wagon.wagonNumber)],
      [TextCellValue('From'), TextCellValue(wagon.origin ?? 'Not provided')],
      [TextCellValue('To'), TextCellValue(wagon.destination ?? 'Not provided')],
      [TextCellValue('Supervisor'), TextCellValue(_supervisor)],
      [TextCellValue('Trucks'), IntCellValue(trucks.length)],
      [TextCellValue('Layers'), IntCellValue(layers.length)],
      [TextCellValue('Loaded Cartons'), IntCellValue(totalCartons)],
      [TextCellValue('Defects'), IntCellValue(totalDefects)],
    ];
    for (var row = 0; row < summaryRows.length; row++) {
      writeRow(summarySheet, row + 2, summaryRows[row]);
    }

    writeRow(itemSheet, 0, [
      TextCellValue('Item'),
      TextCellValue('Total'),
      TextCellValue('Loaded'),
      TextCellValue('Remaining'),
      TextCellValue('Status'),
    ]);
    final loadedByItem = <String, int>{};
    for (final layer in layers) {
      for (final allocation in _layerAllocations(layer).entries) {
        loadedByItem[allocation.key] =
            (loadedByItem[allocation.key] ?? 0) + allocation.value;
      }
    }
    final manifest = (jsonDecode(wagon.itemManifestJson) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();
    for (var row = 0; row < manifest.length; row++) {
      final name = manifest[row]['name'] as String;
      final total = (manifest[row]['quantity'] as num).toInt();
      final loaded = loadedByItem[name] ?? 0;
      final remaining = total - loaded;
      writeRow(itemSheet, row + 1, [
        TextCellValue(name),
        IntCellValue(total),
        IntCellValue(loaded),
        IntCellValue(remaining),
        TextCellValue(remaining == 0 ? 'Complete' : 'In progress'),
      ]);
    }

    writeRow(truckSheet, 0, [
      TextCellValue('Vehicle Number'),
      TextCellValue('Driver'),
      TextCellValue('Phone'),
      TextCellValue('Layers'),
      TextCellValue('Cartons'),
      TextCellValue('Defects'),
      TextCellValue('Item Breakdown'),
      TextCellValue('Status'),
    ]);
    for (var row = 0; row < trucks.length; row++) {
      final truck = trucks[row];
      final truckLayers = layers.where((layer) => layer.truckId == truck.id).toList();
      final totalTruckCartons = truckLayers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
      final totalTruckDefects = truckLayers.fold<int>(0, (sum, layer) => sum + layer.defectCount);
      
      final breakdownMap = <String, int>{};
      for (final layer in truckLayers) {
        for (final allocation in _layerAllocations(layer).entries) {
          breakdownMap[allocation.key] = (breakdownMap[allocation.key] ?? 0) + allocation.value;
        }
      }
      final itemBreakdown = breakdownMap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      
      writeRow(truckSheet, row + 1, [
        TextCellValue(truck.vehicleNumber),
        TextCellValue(truck.driverName),
        TextCellValue(truck.driverMobile ?? 'Not provided'),
        IntCellValue(truckLayers.length),
        IntCellValue(totalTruckCartons),
        IntCellValue(totalTruckDefects),
        TextCellValue(itemBreakdown),
        TextCellValue(truck.status),
      ]);
    }

    writeRow(layerSheet, 0, [
      TextCellValue('Truck'),
      TextCellValue('Layer'),
      TextCellValue('Cartons'),
      TextCellValue('Items'),
      TextCellValue('Def.'),
      TextCellValue('Notes'),
      TextCellValue('Added'),
      TextCellValue('Operator'),
    ]);
    for (var row = 0; row < layers.length; row++) {
      final layer = layers[row];
      final truck = trucks.firstWhere((item) => item.id == layer.truckId);
      writeRow(layerSheet, row + 1, [
        TextCellValue(truck.vehicleNumber),
        IntCellValue(layer.layerNumber),
        IntCellValue(layer.cartonCount),
        TextCellValue(_layerItemLabel(layer)),
        IntCellValue(layer.defectCount),
        TextCellValue(_cleanNotes(layer.notes)),
        TextCellValue(ReportDateFormatter.formatDateTime(layer.timestamp)),
        TextCellValue(layer.operatorId ?? 'Not provided'),
      ]);
    }
    final layerIds = layers.map((layer) => layer.id).toList();
    final audits = layerIds.isEmpty
        ? <AuditLog>[]
        : await (_db.select(_db.auditLogs)
              ..where((log) =>
                  log.entityId.isIn(layerIds) &
                  log.entityType.equals('Layer') &
                  log.action.equals('correct'))
              ..orderBy([(log) => drift.OrderingTerm.asc(log.timestamp)]))
            .get();
    writeRow(correctionSheet, 0, [
      TextCellValue('Vehicle'),
      TextCellValue('Layer'),
      TextCellValue('Changed At'),
      TextCellValue('Operator'),
      TextCellValue('Before'),
      TextCellValue('After'),
      TextCellValue('Reason'),
    ]);
    for (var row = 0; row < audits.length; row++) {
      final audit = audits[row];
      final layer = layers.firstWhere((item) => item.id == audit.entityId);
      final truck = trucks.firstWhere((item) => item.id == layer.truckId);
      writeRow(correctionSheet, row + 1, [
        TextCellValue(truck.vehicleNumber),
        IntCellValue(layer.layerNumber),
        TextCellValue(ReportDateFormatter.formatDateTime(audit.timestamp)),
        TextCellValue(audit.userId),
        TextCellValue(_correctionPart(audit.details, 'before')),
        TextCellValue(_correctionPart(audit.details, 'after')),
        TextCellValue(_correctionPart(audit.details, 'reason')),
      ]);
    }
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
      'LOADED CARTONS: $totalCartons',
      'LOADING DATE: ${ReportDateFormatter.formatDate(wagon.loadingDate)}',
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
      truckHeader.addAll(['VEHICLE: ${truck.vehicleNumber}', '']);
      quantityHeader.addAll(['CARTONS', 'ITEM']);
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
        final item = layer == null ? '' : _layerItemLabel(layer);
        itemCell.value = TextCellValue(item);
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
          .value = TextCellValue(_supervisorLabel);
    } else {
      sheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow))
          .value = TextCellValue(_supervisorLabel);
    }
    return _saveExcel(excel, 'WAGON_${wagon.wagonNumber}_REGISTER');
  }

  @override
  Future<File> generateAnalyticsReport() async {
    final excel = Excel.createExcel();
    final sheet = excel['Analytics'];
    excel.setDefaultSheet(sheet.sheetName);

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
        TextCellValue('Generated: ${ReportDateFormatter.formatDateTime(DateTime.now())}');

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
          TextCellValue(ReportDateFormatter.formatDateTime(truck.completedDate));
      currentRow++;
    }

    return _saveExcel(excel, 'ENTERPRISE_ANALYTICS');
  }
}
