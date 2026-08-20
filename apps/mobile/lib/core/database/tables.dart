import 'package:drift/drift.dart';

// Common local record metadata.
mixin SyncMetadata on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

class Warehouses extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get name => text()();
  TextColumn get location => text()();
}

class Wagons extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get warehouseId => text().references(Warehouses, #id).nullable()();
  TextColumn get wagonNumber => text()();
  TextColumn get status =>
      text()(); // e.g. planning, loading, completed, archived
  IntColumn get expectedTruckCount => integer()();

  // Fields for existing domain entity mapping
  TextColumn get origin => text().nullable()();
  TextColumn get destination => text().nullable()();
  DateTimeColumn get loadingDate => dateTime().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get itemManifestJson => text().withDefault(const Constant('[]'))();
  IntColumn get completedTruckCount =>
      integer().withDefault(const Constant(0))();
}

class Trucks extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get wagonId => text().references(Wagons, #id).nullable()();
  TextColumn get truckNumber => text()();
  TextColumn get vehicleNumber => text()();
  TextColumn get driverName => text()();
  TextColumn get driverMobile => text().nullable()();
  TextColumn get company => text()();
  TextColumn get status => text()();
  TextColumn get warehouse => text().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get totalLayers => integer().withDefault(const Constant(0))();
  IntColumn get totalCartons => integer().withDefault(const Constant(0))();
  IntColumn get totalDefects => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Layers extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get truckId => text().references(Trucks, #id)();
  IntColumn get layerNumber => integer()();
  IntColumn get cartonCount => integer()();
  IntColumn get defectCount => integer().withDefault(const Constant(0))();
  TextColumn get photoPath => text().nullable()(); // local path
  TextColumn get croppedPhotoPath => text().nullable()();

  /// JSON normalized rectangle used to produce [croppedPhotoPath].
  TextColumn get countingRegionJson => text().nullable()();
  TextColumn get detectionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  TextColumn get itemName => text().nullable()();
  TextColumn get itemAllocationsJson =>
      text().withDefault(const Constant('[]'))();
  RealColumn get averageConfidence => real().withDefault(const Constant(0.0))();
  DateTimeColumn get timestamp => dateTime().nullable()();
  TextColumn get operatorId => text().nullable()();
  TextColumn get modelVersion => text().nullable()();
}

class Detections extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get layerId => text().references(Layers, #id)();
  RealColumn get boundingBoxX => real()();
  RealColumn get boundingBoxY => real()();
  RealColumn get boundingBoxW => real()();
  RealColumn get boundingBoxH => real()();
  RealColumn get confidence => real()();
  TextColumn get label => text()(); // e.g. carton, defect
}

class DigitalRegisters extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get wagonId => text().references(Wagons, #id)();
  TextColumn get wagonNumber => text()();
  TextColumn get generatedBy => text()();
  TextColumn get shift => text()();
  TextColumn get verificationHash => text()();
  IntColumn get totalTrucks => integer()();
  IntColumn get totalLayers => integer()();
  IntColumn get totalCartons => integer()();
}

class LoadingSessions extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get truckId => text().references(Trucks, #id)();
  TextColumn get warehouseId => text().references(Warehouses, #id).nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get operatorId => text()();
  TextColumn get status => text()(); // active, paused, completed
  IntColumn get totalLayers => integer().withDefault(const Constant(0))();
  IntColumn get totalCartons => integer().withDefault(const Constant(0))();
  IntColumn get totalDefects => integer().withDefault(const Constant(0))();
  RealColumn get averageConfidence => real().withDefault(const Constant(0.0))();
  TextColumn get modelVersion => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get metadata => text().nullable()();
}

class AuditLogs extends Table {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get id => text()();
  TextColumn get entityId => text()();
  TextColumn get entityType => text()();
  TextColumn get action => text()(); // create, update, delete, sync
  TextColumn get userId => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get details => text().nullable()();
}

// Retained only so existing local databases open without a destructive schema
// migration. No repository writes to or reads from this legacy table.
class DatasetImages extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get warehouseId => text().nullable()();
  TextColumn get truckId => text().nullable()();
  TextColumn get wagonId => text().nullable()();
  IntColumn get layerNumber => integer().nullable()();

  TextColumn get originalPath => text()(); // internal sandbox relative path
  TextColumn get annotatedPath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get fileSize => integer()();

  // Review Status
  TextColumn get approvalStatus => text().withDefault(const Constant(
      'pending'))(); // pending, approved, rejected, manual_correction
  TextColumn get rejectReason => text().nullable()();

  // Tracking
  TextColumn get operatorId => text().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  BoolColumn get isExported => boolean().withDefault(const Constant(false))();
}

class ImageMetadata extends Table {
  @override
  Set<Column> get primaryKey => {imageId};
  TextColumn get imageId =>
      text().references(DatasetImages, #id, onDelete: KeyAction.cascade)();
  TextColumn get filename => text()();
  DateTimeColumn get captureTime => dateTime()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get cameraResolution => text().nullable()();

  // Telemetry
  TextColumn get modelVersion => text().nullable()();
  RealColumn get inferenceTimeMs => real().withDefault(const Constant(0.0))();
  RealColumn get averageConfidence => real().withDefault(const Constant(0.0))();
  IntColumn get detectedCount => integer().withDefault(const Constant(0))();
  IntColumn get manualCount => integer().nullable()();
  IntColumn get finalCount => integer().nullable()();
}

class Annotations extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get imageId =>
      text().references(DatasetImages, #id, onDelete: KeyAction.cascade)();
  RealColumn get boundingBoxX => real()();
  RealColumn get boundingBoxY => real()();
  RealColumn get boundingBoxW => real()();
  RealColumn get boundingBoxH => real()();
  TextColumn get label => text()(); // e.g., 'carton', 'defect'
  RealColumn get confidence => real()();
  BoolColumn get isManualCorrection =>
      boolean().withDefault(const Constant(false))();
  TextColumn get correctionReason => text().nullable()();
}

class DatasetExports extends Table {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get id => text()();
  TextColumn get exportPath => text()(); // zip file path
  TextColumn get format => text()(); // 'yolo', 'zip'
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(
      const Constant('pending'))(); // pending, processing, completed, failed
  IntColumn get totalImages => integer().withDefault(const Constant(0))();
  TextColumn get manifestJson =>
      text().nullable()(); // stores configurations used
}

class ImageQuality extends Table {
  @override
  Set<Column> get primaryKey => {imageId};
  TextColumn get imageId =>
      text().references(DatasetImages, #id, onDelete: KeyAction.cascade)();
  RealColumn get blurScore => real().withDefault(const Constant(1.0))();
  RealColumn get brightness => real().withDefault(const Constant(128.0))();
  RealColumn get contrast => real().withDefault(const Constant(1.0))();
  RealColumn get rotation => real().withDefault(const Constant(0.0))();
  RealColumn get perspective => real().withDefault(const Constant(0.0))();
  RealColumn get occlusion => real().withDefault(const Constant(0.0))();
  RealColumn get distance => real().withDefault(const Constant(0.0))();
}

class ModelHistory extends Table {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get id => text()();
  TextColumn get modelName => text()();
  TextColumn get version => text()();
  DateTimeColumn get trainingDate => dateTime()();
  IntColumn get imagesUsed => integer()();
  RealColumn get precision => real().nullable()();
  RealColumn get recall => real().nullable()();
  RealColumn get mAP => real().nullable()();
  DateTimeColumn get deploymentDate => dateTime().nullable()();
}

class DeviceSessions extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get deviceName => text()();
  TextColumn get deviceModel => text()();
  TextColumn get osVersion => text()();
  DateTimeColumn get lastSync => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Users extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get employeeId => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get warehouseId => text().nullable()();
  TextColumn get token => text().nullable()(); // Future auth
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get failedLoginAttempts =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
}

class Settings extends Table {
  @override
  Set<Column> get primaryKey => {key};
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON or String
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ReportExports extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get reportType =>
      text()(); // e.g. 'Wagon Report', 'Daily Loading Report'
  TextColumn get exportType => text()(); // e.g. 'PDF', 'EXCEL', 'CSV'
  TextColumn get userId => text()();
  DateTimeColumn get exportedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text()(); // e.g. 'Success', 'Failed'
  TextColumn get filePath => text().nullable()();
  TextColumn get details => text().nullable()();
}
