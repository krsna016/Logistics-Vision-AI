import 'package:drift/drift.dart';

// Base Sync Fields Mixin/Interface
mixin SyncMetadata on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
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
  TextColumn get status => text()(); // e.g. planning, loading, completed, archived
  IntColumn get expectedTruckCount => integer()();
  
  // Fields for existing domain entity mapping
  TextColumn get origin => text().nullable()();
  TextColumn get destination => text().nullable()();
  DateTimeColumn get loadingDate => dateTime().nullable()();
  TextColumn get remarks => text().nullable()();
  IntColumn get completedTruckCount => integer().withDefault(const Constant(0))();
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
  TextColumn get notes => text().nullable()();
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

class SyncQueues extends Table {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get id => text()();
  TextColumn get entityId => text()();
  TextColumn get entityType => text()(); // Wagon, Truck, Layer, etc.
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payloadData => text()(); // JSON string
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, processing, failed
  TextColumn get errorMessage => text().nullable()();
}

class DatasetImages extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get warehouseId => text().nullable()();
  TextColumn get truckId => text().nullable()();
  TextColumn get originalPath => text()();
  TextColumn get annotatedPath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get metadataJson => text()(); // Environment info, lighting, etc.
  IntColumn get fileSize => integer()();
}

class Users extends Table with SyncMetadata {
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get warehouseId => text().nullable()();
  TextColumn get token => text().nullable()(); // Future auth
}

class Settings extends Table {
  @override
  Set<Column> get primaryKey => {key};
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON or String
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
