// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WarehousesTable extends Warehouses
    with TableInfo<$WarehousesTable, Warehouse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarehousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        name,
        location
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warehouses';
  @override
  VerificationContext validateIntegrity(Insertable<Warehouse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Warehouse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Warehouse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
    );
  }

  @override
  $WarehousesTable createAlias(String alias) {
    return $WarehousesTable(attachedDatabase, alias);
  }
}

class Warehouse extends DataClass implements Insertable<Warehouse> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String name;
  final String location;
  const Warehouse(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.name,
      required this.location});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    return map;
  }

  WarehousesCompanion toCompanion(bool nullToAbsent) {
    return WarehousesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      name: Value(name),
      location: Value(location),
    );
  }

  factory Warehouse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Warehouse(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
    };
  }

  Warehouse copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? name,
          String? location}) =>
      Warehouse(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        name: name ?? this.name,
        location: location ?? this.location,
      );
  Warehouse copyWithCompanion(WarehousesCompanion data) {
    return Warehouse(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Warehouse(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, updatedAt, isDeleted, version, syncStatus, name, location);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Warehouse &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.name == this.name &&
          other.location == this.location);
}

class WarehousesCompanion extends UpdateCompanion<Warehouse> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> name;
  final Value<String> location;
  final Value<int> rowid;
  const WarehousesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarehousesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String name,
    required String location,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        location = Value(location);
  static Insertable<Warehouse> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? name,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarehousesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? name,
      Value<String>? location,
      Value<int>? rowid}) {
    return WarehousesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      location: location ?? this.location,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarehousesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WagonsTable extends Wagons with TableInfo<$WagonsTable, Wagon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WagonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _wagonNumberMeta =
      const VerificationMeta('wagonNumber');
  @override
  late final GeneratedColumn<String> wagonNumber = GeneratedColumn<String>(
      'wagon_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedTruckCountMeta =
      const VerificationMeta('expectedTruckCount');
  @override
  late final GeneratedColumn<int> expectedTruckCount = GeneratedColumn<int>(
      'expected_truck_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _destinationMeta =
      const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
      'destination', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loadingDateMeta =
      const VerificationMeta('loadingDate');
  @override
  late final GeneratedColumn<DateTime> loadingDate = GeneratedColumn<DateTime>(
      'loading_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remarksMeta =
      const VerificationMeta('remarks');
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
      'remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemManifestJsonMeta =
      const VerificationMeta('itemManifestJson');
  @override
  late final GeneratedColumn<String> itemManifestJson = GeneratedColumn<String>(
      'item_manifest_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _completedTruckCountMeta =
      const VerificationMeta('completedTruckCount');
  @override
  late final GeneratedColumn<int> completedTruckCount = GeneratedColumn<int>(
      'completed_truck_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        warehouseId,
        wagonNumber,
        status,
        expectedTruckCount,
        origin,
        destination,
        loadingDate,
        remarks,
        itemManifestJson,
        completedTruckCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wagons';
  @override
  VerificationContext validateIntegrity(Insertable<Wagon> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('wagon_number')) {
      context.handle(
          _wagonNumberMeta,
          wagonNumber.isAcceptableOrUnknown(
              data['wagon_number']!, _wagonNumberMeta));
    } else if (isInserting) {
      context.missing(_wagonNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expected_truck_count')) {
      context.handle(
          _expectedTruckCountMeta,
          expectedTruckCount.isAcceptableOrUnknown(
              data['expected_truck_count']!, _expectedTruckCountMeta));
    } else if (isInserting) {
      context.missing(_expectedTruckCountMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    }
    if (data.containsKey('destination')) {
      context.handle(
          _destinationMeta,
          destination.isAcceptableOrUnknown(
              data['destination']!, _destinationMeta));
    }
    if (data.containsKey('loading_date')) {
      context.handle(
          _loadingDateMeta,
          loadingDate.isAcceptableOrUnknown(
              data['loading_date']!, _loadingDateMeta));
    }
    if (data.containsKey('remarks')) {
      context.handle(_remarksMeta,
          remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta));
    }
    if (data.containsKey('item_manifest_json')) {
      context.handle(
          _itemManifestJsonMeta,
          itemManifestJson.isAcceptableOrUnknown(
              data['item_manifest_json']!, _itemManifestJsonMeta));
    }
    if (data.containsKey('completed_truck_count')) {
      context.handle(
          _completedTruckCountMeta,
          completedTruckCount.isAcceptableOrUnknown(
              data['completed_truck_count']!, _completedTruckCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wagon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wagon(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      wagonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wagon_number'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      expectedTruckCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}expected_truck_count'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin']),
      destination: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destination']),
      loadingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}loading_date']),
      remarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remarks']),
      itemManifestJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}item_manifest_json'])!,
      completedTruckCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_truck_count'])!,
    );
  }

  @override
  $WagonsTable createAlias(String alias) {
    return $WagonsTable(attachedDatabase, alias);
  }
}

class Wagon extends DataClass implements Insertable<Wagon> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String? warehouseId;
  final String wagonNumber;
  final String status;
  final int expectedTruckCount;
  final String? origin;
  final String? destination;
  final DateTime? loadingDate;
  final String? remarks;
  final String itemManifestJson;
  final int completedTruckCount;
  const Wagon(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      this.warehouseId,
      required this.wagonNumber,
      required this.status,
      required this.expectedTruckCount,
      this.origin,
      this.destination,
      this.loadingDate,
      this.remarks,
      required this.itemManifestJson,
      required this.completedTruckCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    map['wagon_number'] = Variable<String>(wagonNumber);
    map['status'] = Variable<String>(status);
    map['expected_truck_count'] = Variable<int>(expectedTruckCount);
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || loadingDate != null) {
      map['loading_date'] = Variable<DateTime>(loadingDate);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['item_manifest_json'] = Variable<String>(itemManifestJson);
    map['completed_truck_count'] = Variable<int>(completedTruckCount);
    return map;
  }

  WagonsCompanion toCompanion(bool nullToAbsent) {
    return WagonsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      wagonNumber: Value(wagonNumber),
      status: Value(status),
      expectedTruckCount: Value(expectedTruckCount),
      origin:
          origin == null && nullToAbsent ? const Value.absent() : Value(origin),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      loadingDate: loadingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(loadingDate),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      itemManifestJson: Value(itemManifestJson),
      completedTruckCount: Value(completedTruckCount),
    );
  }

  factory Wagon.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wagon(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      wagonNumber: serializer.fromJson<String>(json['wagonNumber']),
      status: serializer.fromJson<String>(json['status']),
      expectedTruckCount: serializer.fromJson<int>(json['expectedTruckCount']),
      origin: serializer.fromJson<String?>(json['origin']),
      destination: serializer.fromJson<String?>(json['destination']),
      loadingDate: serializer.fromJson<DateTime?>(json['loadingDate']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      itemManifestJson: serializer.fromJson<String>(json['itemManifestJson']),
      completedTruckCount:
          serializer.fromJson<int>(json['completedTruckCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'wagonNumber': serializer.toJson<String>(wagonNumber),
      'status': serializer.toJson<String>(status),
      'expectedTruckCount': serializer.toJson<int>(expectedTruckCount),
      'origin': serializer.toJson<String?>(origin),
      'destination': serializer.toJson<String?>(destination),
      'loadingDate': serializer.toJson<DateTime?>(loadingDate),
      'remarks': serializer.toJson<String?>(remarks),
      'itemManifestJson': serializer.toJson<String>(itemManifestJson),
      'completedTruckCount': serializer.toJson<int>(completedTruckCount),
    };
  }

  Wagon copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          Value<String?> warehouseId = const Value.absent(),
          String? wagonNumber,
          String? status,
          int? expectedTruckCount,
          Value<String?> origin = const Value.absent(),
          Value<String?> destination = const Value.absent(),
          Value<DateTime?> loadingDate = const Value.absent(),
          Value<String?> remarks = const Value.absent(),
          String? itemManifestJson,
          int? completedTruckCount}) =>
      Wagon(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        wagonNumber: wagonNumber ?? this.wagonNumber,
        status: status ?? this.status,
        expectedTruckCount: expectedTruckCount ?? this.expectedTruckCount,
        origin: origin.present ? origin.value : this.origin,
        destination: destination.present ? destination.value : this.destination,
        loadingDate: loadingDate.present ? loadingDate.value : this.loadingDate,
        remarks: remarks.present ? remarks.value : this.remarks,
        itemManifestJson: itemManifestJson ?? this.itemManifestJson,
        completedTruckCount: completedTruckCount ?? this.completedTruckCount,
      );
  Wagon copyWithCompanion(WagonsCompanion data) {
    return Wagon(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      wagonNumber:
          data.wagonNumber.present ? data.wagonNumber.value : this.wagonNumber,
      status: data.status.present ? data.status.value : this.status,
      expectedTruckCount: data.expectedTruckCount.present
          ? data.expectedTruckCount.value
          : this.expectedTruckCount,
      origin: data.origin.present ? data.origin.value : this.origin,
      destination:
          data.destination.present ? data.destination.value : this.destination,
      loadingDate:
          data.loadingDate.present ? data.loadingDate.value : this.loadingDate,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      itemManifestJson: data.itemManifestJson.present
          ? data.itemManifestJson.value
          : this.itemManifestJson,
      completedTruckCount: data.completedTruckCount.present
          ? data.completedTruckCount.value
          : this.completedTruckCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wagon(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('wagonNumber: $wagonNumber, ')
          ..write('status: $status, ')
          ..write('expectedTruckCount: $expectedTruckCount, ')
          ..write('origin: $origin, ')
          ..write('destination: $destination, ')
          ..write('loadingDate: $loadingDate, ')
          ..write('remarks: $remarks, ')
          ..write('itemManifestJson: $itemManifestJson, ')
          ..write('completedTruckCount: $completedTruckCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      warehouseId,
      wagonNumber,
      status,
      expectedTruckCount,
      origin,
      destination,
      loadingDate,
      remarks,
      itemManifestJson,
      completedTruckCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wagon &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.warehouseId == this.warehouseId &&
          other.wagonNumber == this.wagonNumber &&
          other.status == this.status &&
          other.expectedTruckCount == this.expectedTruckCount &&
          other.origin == this.origin &&
          other.destination == this.destination &&
          other.loadingDate == this.loadingDate &&
          other.remarks == this.remarks &&
          other.itemManifestJson == this.itemManifestJson &&
          other.completedTruckCount == this.completedTruckCount);
}

class WagonsCompanion extends UpdateCompanion<Wagon> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String?> warehouseId;
  final Value<String> wagonNumber;
  final Value<String> status;
  final Value<int> expectedTruckCount;
  final Value<String?> origin;
  final Value<String?> destination;
  final Value<DateTime?> loadingDate;
  final Value<String?> remarks;
  final Value<String> itemManifestJson;
  final Value<int> completedTruckCount;
  final Value<int> rowid;
  const WagonsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.wagonNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.expectedTruckCount = const Value.absent(),
    this.origin = const Value.absent(),
    this.destination = const Value.absent(),
    this.loadingDate = const Value.absent(),
    this.remarks = const Value.absent(),
    this.itemManifestJson = const Value.absent(),
    this.completedTruckCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WagonsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.warehouseId = const Value.absent(),
    required String wagonNumber,
    required String status,
    required int expectedTruckCount,
    this.origin = const Value.absent(),
    this.destination = const Value.absent(),
    this.loadingDate = const Value.absent(),
    this.remarks = const Value.absent(),
    this.itemManifestJson = const Value.absent(),
    this.completedTruckCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        wagonNumber = Value(wagonNumber),
        status = Value(status),
        expectedTruckCount = Value(expectedTruckCount);
  static Insertable<Wagon> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? warehouseId,
    Expression<String>? wagonNumber,
    Expression<String>? status,
    Expression<int>? expectedTruckCount,
    Expression<String>? origin,
    Expression<String>? destination,
    Expression<DateTime>? loadingDate,
    Expression<String>? remarks,
    Expression<String>? itemManifestJson,
    Expression<int>? completedTruckCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (wagonNumber != null) 'wagon_number': wagonNumber,
      if (status != null) 'status': status,
      if (expectedTruckCount != null)
        'expected_truck_count': expectedTruckCount,
      if (origin != null) 'origin': origin,
      if (destination != null) 'destination': destination,
      if (loadingDate != null) 'loading_date': loadingDate,
      if (remarks != null) 'remarks': remarks,
      if (itemManifestJson != null) 'item_manifest_json': itemManifestJson,
      if (completedTruckCount != null)
        'completed_truck_count': completedTruckCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WagonsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String?>? warehouseId,
      Value<String>? wagonNumber,
      Value<String>? status,
      Value<int>? expectedTruckCount,
      Value<String?>? origin,
      Value<String?>? destination,
      Value<DateTime?>? loadingDate,
      Value<String?>? remarks,
      Value<String>? itemManifestJson,
      Value<int>? completedTruckCount,
      Value<int>? rowid}) {
    return WagonsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      warehouseId: warehouseId ?? this.warehouseId,
      wagonNumber: wagonNumber ?? this.wagonNumber,
      status: status ?? this.status,
      expectedTruckCount: expectedTruckCount ?? this.expectedTruckCount,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      loadingDate: loadingDate ?? this.loadingDate,
      remarks: remarks ?? this.remarks,
      itemManifestJson: itemManifestJson ?? this.itemManifestJson,
      completedTruckCount: completedTruckCount ?? this.completedTruckCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (wagonNumber.present) {
      map['wagon_number'] = Variable<String>(wagonNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expectedTruckCount.present) {
      map['expected_truck_count'] = Variable<int>(expectedTruckCount.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (loadingDate.present) {
      map['loading_date'] = Variable<DateTime>(loadingDate.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (itemManifestJson.present) {
      map['item_manifest_json'] = Variable<String>(itemManifestJson.value);
    }
    if (completedTruckCount.present) {
      map['completed_truck_count'] = Variable<int>(completedTruckCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WagonsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('wagonNumber: $wagonNumber, ')
          ..write('status: $status, ')
          ..write('expectedTruckCount: $expectedTruckCount, ')
          ..write('origin: $origin, ')
          ..write('destination: $destination, ')
          ..write('loadingDate: $loadingDate, ')
          ..write('remarks: $remarks, ')
          ..write('itemManifestJson: $itemManifestJson, ')
          ..write('completedTruckCount: $completedTruckCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrucksTable extends Trucks with TableInfo<$TrucksTable, Truck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrucksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _wagonIdMeta =
      const VerificationMeta('wagonId');
  @override
  late final GeneratedColumn<String> wagonId = GeneratedColumn<String>(
      'wagon_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wagons (id)'));
  static const VerificationMeta _truckNumberMeta =
      const VerificationMeta('truckNumber');
  @override
  late final GeneratedColumn<String> truckNumber = GeneratedColumn<String>(
      'truck_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleNumberMeta =
      const VerificationMeta('vehicleNumber');
  @override
  late final GeneratedColumn<String> vehicleNumber = GeneratedColumn<String>(
      'vehicle_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverNameMeta =
      const VerificationMeta('driverName');
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
      'driver_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverMobileMeta =
      const VerificationMeta('driverMobile');
  @override
  late final GeneratedColumn<String> driverMobile = GeneratedColumn<String>(
      'driver_mobile', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _companyMeta =
      const VerificationMeta('company');
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
      'company', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseMeta =
      const VerificationMeta('warehouse');
  @override
  late final GeneratedColumn<String> warehouse = GeneratedColumn<String>(
      'warehouse', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedDateMeta =
      const VerificationMeta('completedDate');
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>('completed_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalLayersMeta =
      const VerificationMeta('totalLayers');
  @override
  late final GeneratedColumn<int> totalLayers = GeneratedColumn<int>(
      'total_layers', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalCartonsMeta =
      const VerificationMeta('totalCartons');
  @override
  late final GeneratedColumn<int> totalCartons = GeneratedColumn<int>(
      'total_cartons', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalDefectsMeta =
      const VerificationMeta('totalDefects');
  @override
  late final GeneratedColumn<int> totalDefects = GeneratedColumn<int>(
      'total_defects', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        wagonId,
        truckNumber,
        vehicleNumber,
        driverName,
        driverMobile,
        company,
        status,
        warehouse,
        completedDate,
        notes,
        totalLayers,
        totalCartons,
        totalDefects,
        isArchived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trucks';
  @override
  VerificationContext validateIntegrity(Insertable<Truck> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('wagon_id')) {
      context.handle(_wagonIdMeta,
          wagonId.isAcceptableOrUnknown(data['wagon_id']!, _wagonIdMeta));
    }
    if (data.containsKey('truck_number')) {
      context.handle(
          _truckNumberMeta,
          truckNumber.isAcceptableOrUnknown(
              data['truck_number']!, _truckNumberMeta));
    } else if (isInserting) {
      context.missing(_truckNumberMeta);
    }
    if (data.containsKey('vehicle_number')) {
      context.handle(
          _vehicleNumberMeta,
          vehicleNumber.isAcceptableOrUnknown(
              data['vehicle_number']!, _vehicleNumberMeta));
    } else if (isInserting) {
      context.missing(_vehicleNumberMeta);
    }
    if (data.containsKey('driver_name')) {
      context.handle(
          _driverNameMeta,
          driverName.isAcceptableOrUnknown(
              data['driver_name']!, _driverNameMeta));
    } else if (isInserting) {
      context.missing(_driverNameMeta);
    }
    if (data.containsKey('driver_mobile')) {
      context.handle(
          _driverMobileMeta,
          driverMobile.isAcceptableOrUnknown(
              data['driver_mobile']!, _driverMobileMeta));
    }
    if (data.containsKey('company')) {
      context.handle(_companyMeta,
          company.isAcceptableOrUnknown(data['company']!, _companyMeta));
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('warehouse')) {
      context.handle(_warehouseMeta,
          warehouse.isAcceptableOrUnknown(data['warehouse']!, _warehouseMeta));
    }
    if (data.containsKey('completed_date')) {
      context.handle(
          _completedDateMeta,
          completedDate.isAcceptableOrUnknown(
              data['completed_date']!, _completedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('total_layers')) {
      context.handle(
          _totalLayersMeta,
          totalLayers.isAcceptableOrUnknown(
              data['total_layers']!, _totalLayersMeta));
    }
    if (data.containsKey('total_cartons')) {
      context.handle(
          _totalCartonsMeta,
          totalCartons.isAcceptableOrUnknown(
              data['total_cartons']!, _totalCartonsMeta));
    }
    if (data.containsKey('total_defects')) {
      context.handle(
          _totalDefectsMeta,
          totalDefects.isAcceptableOrUnknown(
              data['total_defects']!, _totalDefectsMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Truck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Truck(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      wagonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wagon_id']),
      truckNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_number'])!,
      vehicleNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_number'])!,
      driverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_name'])!,
      driverMobile: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_mobile']),
      company: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      warehouse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse']),
      completedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}completed_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      totalLayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_layers'])!,
      totalCartons: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cartons'])!,
      totalDefects: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_defects'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $TrucksTable createAlias(String alias) {
    return $TrucksTable(attachedDatabase, alias);
  }
}

class Truck extends DataClass implements Insertable<Truck> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String? wagonId;
  final String truckNumber;
  final String vehicleNumber;
  final String driverName;
  final String? driverMobile;
  final String company;
  final String status;
  final String? warehouse;
  final DateTime? completedDate;
  final String? notes;
  final int totalLayers;
  final int totalCartons;
  final int totalDefects;
  final bool isArchived;
  const Truck(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      this.wagonId,
      required this.truckNumber,
      required this.vehicleNumber,
      required this.driverName,
      this.driverMobile,
      required this.company,
      required this.status,
      this.warehouse,
      this.completedDate,
      this.notes,
      required this.totalLayers,
      required this.totalCartons,
      required this.totalDefects,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || wagonId != null) {
      map['wagon_id'] = Variable<String>(wagonId);
    }
    map['truck_number'] = Variable<String>(truckNumber);
    map['vehicle_number'] = Variable<String>(vehicleNumber);
    map['driver_name'] = Variable<String>(driverName);
    if (!nullToAbsent || driverMobile != null) {
      map['driver_mobile'] = Variable<String>(driverMobile);
    }
    map['company'] = Variable<String>(company);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || warehouse != null) {
      map['warehouse'] = Variable<String>(warehouse);
    }
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['total_layers'] = Variable<int>(totalLayers);
    map['total_cartons'] = Variable<int>(totalCartons);
    map['total_defects'] = Variable<int>(totalDefects);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  TrucksCompanion toCompanion(bool nullToAbsent) {
    return TrucksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      wagonId: wagonId == null && nullToAbsent
          ? const Value.absent()
          : Value(wagonId),
      truckNumber: Value(truckNumber),
      vehicleNumber: Value(vehicleNumber),
      driverName: Value(driverName),
      driverMobile: driverMobile == null && nullToAbsent
          ? const Value.absent()
          : Value(driverMobile),
      company: Value(company),
      status: Value(status),
      warehouse: warehouse == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouse),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      totalLayers: Value(totalLayers),
      totalCartons: Value(totalCartons),
      totalDefects: Value(totalDefects),
      isArchived: Value(isArchived),
    );
  }

  factory Truck.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Truck(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      wagonId: serializer.fromJson<String?>(json['wagonId']),
      truckNumber: serializer.fromJson<String>(json['truckNumber']),
      vehicleNumber: serializer.fromJson<String>(json['vehicleNumber']),
      driverName: serializer.fromJson<String>(json['driverName']),
      driverMobile: serializer.fromJson<String?>(json['driverMobile']),
      company: serializer.fromJson<String>(json['company']),
      status: serializer.fromJson<String>(json['status']),
      warehouse: serializer.fromJson<String?>(json['warehouse']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      totalLayers: serializer.fromJson<int>(json['totalLayers']),
      totalCartons: serializer.fromJson<int>(json['totalCartons']),
      totalDefects: serializer.fromJson<int>(json['totalDefects']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'wagonId': serializer.toJson<String?>(wagonId),
      'truckNumber': serializer.toJson<String>(truckNumber),
      'vehicleNumber': serializer.toJson<String>(vehicleNumber),
      'driverName': serializer.toJson<String>(driverName),
      'driverMobile': serializer.toJson<String?>(driverMobile),
      'company': serializer.toJson<String>(company),
      'status': serializer.toJson<String>(status),
      'warehouse': serializer.toJson<String?>(warehouse),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'notes': serializer.toJson<String?>(notes),
      'totalLayers': serializer.toJson<int>(totalLayers),
      'totalCartons': serializer.toJson<int>(totalCartons),
      'totalDefects': serializer.toJson<int>(totalDefects),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Truck copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          Value<String?> wagonId = const Value.absent(),
          String? truckNumber,
          String? vehicleNumber,
          String? driverName,
          Value<String?> driverMobile = const Value.absent(),
          String? company,
          String? status,
          Value<String?> warehouse = const Value.absent(),
          Value<DateTime?> completedDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? totalLayers,
          int? totalCartons,
          int? totalDefects,
          bool? isArchived}) =>
      Truck(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        wagonId: wagonId.present ? wagonId.value : this.wagonId,
        truckNumber: truckNumber ?? this.truckNumber,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        driverName: driverName ?? this.driverName,
        driverMobile:
            driverMobile.present ? driverMobile.value : this.driverMobile,
        company: company ?? this.company,
        status: status ?? this.status,
        warehouse: warehouse.present ? warehouse.value : this.warehouse,
        completedDate:
            completedDate.present ? completedDate.value : this.completedDate,
        notes: notes.present ? notes.value : this.notes,
        totalLayers: totalLayers ?? this.totalLayers,
        totalCartons: totalCartons ?? this.totalCartons,
        totalDefects: totalDefects ?? this.totalDefects,
        isArchived: isArchived ?? this.isArchived,
      );
  Truck copyWithCompanion(TrucksCompanion data) {
    return Truck(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      wagonId: data.wagonId.present ? data.wagonId.value : this.wagonId,
      truckNumber:
          data.truckNumber.present ? data.truckNumber.value : this.truckNumber,
      vehicleNumber: data.vehicleNumber.present
          ? data.vehicleNumber.value
          : this.vehicleNumber,
      driverName:
          data.driverName.present ? data.driverName.value : this.driverName,
      driverMobile: data.driverMobile.present
          ? data.driverMobile.value
          : this.driverMobile,
      company: data.company.present ? data.company.value : this.company,
      status: data.status.present ? data.status.value : this.status,
      warehouse: data.warehouse.present ? data.warehouse.value : this.warehouse,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      totalLayers:
          data.totalLayers.present ? data.totalLayers.value : this.totalLayers,
      totalCartons: data.totalCartons.present
          ? data.totalCartons.value
          : this.totalCartons,
      totalDefects: data.totalDefects.present
          ? data.totalDefects.value
          : this.totalDefects,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Truck(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('wagonId: $wagonId, ')
          ..write('truckNumber: $truckNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('driverName: $driverName, ')
          ..write('driverMobile: $driverMobile, ')
          ..write('company: $company, ')
          ..write('status: $status, ')
          ..write('warehouse: $warehouse, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons, ')
          ..write('totalDefects: $totalDefects, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      wagonId,
      truckNumber,
      vehicleNumber,
      driverName,
      driverMobile,
      company,
      status,
      warehouse,
      completedDate,
      notes,
      totalLayers,
      totalCartons,
      totalDefects,
      isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Truck &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.wagonId == this.wagonId &&
          other.truckNumber == this.truckNumber &&
          other.vehicleNumber == this.vehicleNumber &&
          other.driverName == this.driverName &&
          other.driverMobile == this.driverMobile &&
          other.company == this.company &&
          other.status == this.status &&
          other.warehouse == this.warehouse &&
          other.completedDate == this.completedDate &&
          other.notes == this.notes &&
          other.totalLayers == this.totalLayers &&
          other.totalCartons == this.totalCartons &&
          other.totalDefects == this.totalDefects &&
          other.isArchived == this.isArchived);
}

class TrucksCompanion extends UpdateCompanion<Truck> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String?> wagonId;
  final Value<String> truckNumber;
  final Value<String> vehicleNumber;
  final Value<String> driverName;
  final Value<String?> driverMobile;
  final Value<String> company;
  final Value<String> status;
  final Value<String?> warehouse;
  final Value<DateTime?> completedDate;
  final Value<String?> notes;
  final Value<int> totalLayers;
  final Value<int> totalCartons;
  final Value<int> totalDefects;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const TrucksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.wagonId = const Value.absent(),
    this.truckNumber = const Value.absent(),
    this.vehicleNumber = const Value.absent(),
    this.driverName = const Value.absent(),
    this.driverMobile = const Value.absent(),
    this.company = const Value.absent(),
    this.status = const Value.absent(),
    this.warehouse = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalLayers = const Value.absent(),
    this.totalCartons = const Value.absent(),
    this.totalDefects = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrucksCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.wagonId = const Value.absent(),
    required String truckNumber,
    required String vehicleNumber,
    required String driverName,
    this.driverMobile = const Value.absent(),
    required String company,
    required String status,
    this.warehouse = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.totalLayers = const Value.absent(),
    this.totalCartons = const Value.absent(),
    this.totalDefects = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        truckNumber = Value(truckNumber),
        vehicleNumber = Value(vehicleNumber),
        driverName = Value(driverName),
        company = Value(company),
        status = Value(status);
  static Insertable<Truck> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? wagonId,
    Expression<String>? truckNumber,
    Expression<String>? vehicleNumber,
    Expression<String>? driverName,
    Expression<String>? driverMobile,
    Expression<String>? company,
    Expression<String>? status,
    Expression<String>? warehouse,
    Expression<DateTime>? completedDate,
    Expression<String>? notes,
    Expression<int>? totalLayers,
    Expression<int>? totalCartons,
    Expression<int>? totalDefects,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (wagonId != null) 'wagon_id': wagonId,
      if (truckNumber != null) 'truck_number': truckNumber,
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      if (driverName != null) 'driver_name': driverName,
      if (driverMobile != null) 'driver_mobile': driverMobile,
      if (company != null) 'company': company,
      if (status != null) 'status': status,
      if (warehouse != null) 'warehouse': warehouse,
      if (completedDate != null) 'completed_date': completedDate,
      if (notes != null) 'notes': notes,
      if (totalLayers != null) 'total_layers': totalLayers,
      if (totalCartons != null) 'total_cartons': totalCartons,
      if (totalDefects != null) 'total_defects': totalDefects,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrucksCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String?>? wagonId,
      Value<String>? truckNumber,
      Value<String>? vehicleNumber,
      Value<String>? driverName,
      Value<String?>? driverMobile,
      Value<String>? company,
      Value<String>? status,
      Value<String?>? warehouse,
      Value<DateTime?>? completedDate,
      Value<String?>? notes,
      Value<int>? totalLayers,
      Value<int>? totalCartons,
      Value<int>? totalDefects,
      Value<bool>? isArchived,
      Value<int>? rowid}) {
    return TrucksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      wagonId: wagonId ?? this.wagonId,
      truckNumber: truckNumber ?? this.truckNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      driverMobile: driverMobile ?? this.driverMobile,
      company: company ?? this.company,
      status: status ?? this.status,
      warehouse: warehouse ?? this.warehouse,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      totalDefects: totalDefects ?? this.totalDefects,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (wagonId.present) {
      map['wagon_id'] = Variable<String>(wagonId.value);
    }
    if (truckNumber.present) {
      map['truck_number'] = Variable<String>(truckNumber.value);
    }
    if (vehicleNumber.present) {
      map['vehicle_number'] = Variable<String>(vehicleNumber.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (driverMobile.present) {
      map['driver_mobile'] = Variable<String>(driverMobile.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (warehouse.present) {
      map['warehouse'] = Variable<String>(warehouse.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (totalLayers.present) {
      map['total_layers'] = Variable<int>(totalLayers.value);
    }
    if (totalCartons.present) {
      map['total_cartons'] = Variable<int>(totalCartons.value);
    }
    if (totalDefects.present) {
      map['total_defects'] = Variable<int>(totalDefects.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrucksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('wagonId: $wagonId, ')
          ..write('truckNumber: $truckNumber, ')
          ..write('vehicleNumber: $vehicleNumber, ')
          ..write('driverName: $driverName, ')
          ..write('driverMobile: $driverMobile, ')
          ..write('company: $company, ')
          ..write('status: $status, ')
          ..write('warehouse: $warehouse, ')
          ..write('completedDate: $completedDate, ')
          ..write('notes: $notes, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons, ')
          ..write('totalDefects: $totalDefects, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LayersTable extends Layers with TableInfo<$LayersTable, Layer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES trucks (id)'));
  static const VerificationMeta _layerNumberMeta =
      const VerificationMeta('layerNumber');
  @override
  late final GeneratedColumn<int> layerNumber = GeneratedColumn<int>(
      'layer_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cartonCountMeta =
      const VerificationMeta('cartonCount');
  @override
  late final GeneratedColumn<int> cartonCount = GeneratedColumn<int>(
      'carton_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _defectCountMeta =
      const VerificationMeta('defectCount');
  @override
  late final GeneratedColumn<int> defectCount = GeneratedColumn<int>(
      'defect_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemAllocationsJsonMeta =
      const VerificationMeta('itemAllocationsJson');
  @override
  late final GeneratedColumn<String> itemAllocationsJson =
      GeneratedColumn<String>('item_allocations_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _averageConfidenceMeta =
      const VerificationMeta('averageConfidence');
  @override
  late final GeneratedColumn<double> averageConfidence =
      GeneratedColumn<double>('average_confidence', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        truckId,
        layerNumber,
        cartonCount,
        defectCount,
        photoPath,
        notes,
        itemName,
        itemAllocationsJson,
        averageConfidence,
        timestamp,
        operatorId,
        modelVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'layers';
  @override
  VerificationContext validateIntegrity(Insertable<Layer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    } else if (isInserting) {
      context.missing(_truckIdMeta);
    }
    if (data.containsKey('layer_number')) {
      context.handle(
          _layerNumberMeta,
          layerNumber.isAcceptableOrUnknown(
              data['layer_number']!, _layerNumberMeta));
    } else if (isInserting) {
      context.missing(_layerNumberMeta);
    }
    if (data.containsKey('carton_count')) {
      context.handle(
          _cartonCountMeta,
          cartonCount.isAcceptableOrUnknown(
              data['carton_count']!, _cartonCountMeta));
    } else if (isInserting) {
      context.missing(_cartonCountMeta);
    }
    if (data.containsKey('defect_count')) {
      context.handle(
          _defectCountMeta,
          defectCount.isAcceptableOrUnknown(
              data['defect_count']!, _defectCountMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    }
    if (data.containsKey('item_allocations_json')) {
      context.handle(
          _itemAllocationsJsonMeta,
          itemAllocationsJson.isAcceptableOrUnknown(
              data['item_allocations_json']!, _itemAllocationsJsonMeta));
    }
    if (data.containsKey('average_confidence')) {
      context.handle(
          _averageConfidenceMeta,
          averageConfidence.isAcceptableOrUnknown(
              data['average_confidence']!, _averageConfidenceMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Layer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Layer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id'])!,
      layerNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}layer_number'])!,
      cartonCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carton_count'])!,
      defectCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}defect_count'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name']),
      itemAllocationsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}item_allocations_json'])!,
      averageConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_confidence'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp']),
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id']),
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version']),
    );
  }

  @override
  $LayersTable createAlias(String alias) {
    return $LayersTable(attachedDatabase, alias);
  }
}

class Layer extends DataClass implements Insertable<Layer> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String truckId;
  final int layerNumber;
  final int cartonCount;
  final int defectCount;
  final String? photoPath;
  final String? notes;
  final String? itemName;
  final String itemAllocationsJson;
  final double averageConfidence;
  final DateTime? timestamp;
  final String? operatorId;
  final String? modelVersion;
  const Layer(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.truckId,
      required this.layerNumber,
      required this.cartonCount,
      required this.defectCount,
      this.photoPath,
      this.notes,
      this.itemName,
      required this.itemAllocationsJson,
      required this.averageConfidence,
      this.timestamp,
      this.operatorId,
      this.modelVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['truck_id'] = Variable<String>(truckId);
    map['layer_number'] = Variable<int>(layerNumber);
    map['carton_count'] = Variable<int>(cartonCount);
    map['defect_count'] = Variable<int>(defectCount);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || itemName != null) {
      map['item_name'] = Variable<String>(itemName);
    }
    map['item_allocations_json'] = Variable<String>(itemAllocationsJson);
    map['average_confidence'] = Variable<double>(averageConfidence);
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    if (!nullToAbsent || operatorId != null) {
      map['operator_id'] = Variable<String>(operatorId);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    return map;
  }

  LayersCompanion toCompanion(bool nullToAbsent) {
    return LayersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      truckId: Value(truckId),
      layerNumber: Value(layerNumber),
      cartonCount: Value(cartonCount),
      defectCount: Value(defectCount),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      itemName: itemName == null && nullToAbsent
          ? const Value.absent()
          : Value(itemName),
      itemAllocationsJson: Value(itemAllocationsJson),
      averageConfidence: Value(averageConfidence),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      operatorId: operatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorId),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
    );
  }

  factory Layer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Layer(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      truckId: serializer.fromJson<String>(json['truckId']),
      layerNumber: serializer.fromJson<int>(json['layerNumber']),
      cartonCount: serializer.fromJson<int>(json['cartonCount']),
      defectCount: serializer.fromJson<int>(json['defectCount']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      itemName: serializer.fromJson<String?>(json['itemName']),
      itemAllocationsJson:
          serializer.fromJson<String>(json['itemAllocationsJson']),
      averageConfidence: serializer.fromJson<double>(json['averageConfidence']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      operatorId: serializer.fromJson<String?>(json['operatorId']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'truckId': serializer.toJson<String>(truckId),
      'layerNumber': serializer.toJson<int>(layerNumber),
      'cartonCount': serializer.toJson<int>(cartonCount),
      'defectCount': serializer.toJson<int>(defectCount),
      'photoPath': serializer.toJson<String?>(photoPath),
      'notes': serializer.toJson<String?>(notes),
      'itemName': serializer.toJson<String?>(itemName),
      'itemAllocationsJson': serializer.toJson<String>(itemAllocationsJson),
      'averageConfidence': serializer.toJson<double>(averageConfidence),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'operatorId': serializer.toJson<String?>(operatorId),
      'modelVersion': serializer.toJson<String?>(modelVersion),
    };
  }

  Layer copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? truckId,
          int? layerNumber,
          int? cartonCount,
          int? defectCount,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> itemName = const Value.absent(),
          String? itemAllocationsJson,
          double? averageConfidence,
          Value<DateTime?> timestamp = const Value.absent(),
          Value<String?> operatorId = const Value.absent(),
          Value<String?> modelVersion = const Value.absent()}) =>
      Layer(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        truckId: truckId ?? this.truckId,
        layerNumber: layerNumber ?? this.layerNumber,
        cartonCount: cartonCount ?? this.cartonCount,
        defectCount: defectCount ?? this.defectCount,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        notes: notes.present ? notes.value : this.notes,
        itemName: itemName.present ? itemName.value : this.itemName,
        itemAllocationsJson: itemAllocationsJson ?? this.itemAllocationsJson,
        averageConfidence: averageConfidence ?? this.averageConfidence,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        operatorId: operatorId.present ? operatorId.value : this.operatorId,
        modelVersion:
            modelVersion.present ? modelVersion.value : this.modelVersion,
      );
  Layer copyWithCompanion(LayersCompanion data) {
    return Layer(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      layerNumber:
          data.layerNumber.present ? data.layerNumber.value : this.layerNumber,
      cartonCount:
          data.cartonCount.present ? data.cartonCount.value : this.cartonCount,
      defectCount:
          data.defectCount.present ? data.defectCount.value : this.defectCount,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemAllocationsJson: data.itemAllocationsJson.present
          ? data.itemAllocationsJson.value
          : this.itemAllocationsJson,
      averageConfidence: data.averageConfidence.present
          ? data.averageConfidence.value
          : this.averageConfidence,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Layer(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('truckId: $truckId, ')
          ..write('layerNumber: $layerNumber, ')
          ..write('cartonCount: $cartonCount, ')
          ..write('defectCount: $defectCount, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('itemName: $itemName, ')
          ..write('itemAllocationsJson: $itemAllocationsJson, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('timestamp: $timestamp, ')
          ..write('operatorId: $operatorId, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      truckId,
      layerNumber,
      cartonCount,
      defectCount,
      photoPath,
      notes,
      itemName,
      itemAllocationsJson,
      averageConfidence,
      timestamp,
      operatorId,
      modelVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Layer &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.truckId == this.truckId &&
          other.layerNumber == this.layerNumber &&
          other.cartonCount == this.cartonCount &&
          other.defectCount == this.defectCount &&
          other.photoPath == this.photoPath &&
          other.notes == this.notes &&
          other.itemName == this.itemName &&
          other.itemAllocationsJson == this.itemAllocationsJson &&
          other.averageConfidence == this.averageConfidence &&
          other.timestamp == this.timestamp &&
          other.operatorId == this.operatorId &&
          other.modelVersion == this.modelVersion);
}

class LayersCompanion extends UpdateCompanion<Layer> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> truckId;
  final Value<int> layerNumber;
  final Value<int> cartonCount;
  final Value<int> defectCount;
  final Value<String?> photoPath;
  final Value<String?> notes;
  final Value<String?> itemName;
  final Value<String> itemAllocationsJson;
  final Value<double> averageConfidence;
  final Value<DateTime?> timestamp;
  final Value<String?> operatorId;
  final Value<String?> modelVersion;
  final Value<int> rowid;
  const LayersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.truckId = const Value.absent(),
    this.layerNumber = const Value.absent(),
    this.cartonCount = const Value.absent(),
    this.defectCount = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemAllocationsJson = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LayersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String truckId,
    required int layerNumber,
    required int cartonCount,
    this.defectCount = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemAllocationsJson = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        truckId = Value(truckId),
        layerNumber = Value(layerNumber),
        cartonCount = Value(cartonCount);
  static Insertable<Layer> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? truckId,
    Expression<int>? layerNumber,
    Expression<int>? cartonCount,
    Expression<int>? defectCount,
    Expression<String>? photoPath,
    Expression<String>? notes,
    Expression<String>? itemName,
    Expression<String>? itemAllocationsJson,
    Expression<double>? averageConfidence,
    Expression<DateTime>? timestamp,
    Expression<String>? operatorId,
    Expression<String>? modelVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (truckId != null) 'truck_id': truckId,
      if (layerNumber != null) 'layer_number': layerNumber,
      if (cartonCount != null) 'carton_count': cartonCount,
      if (defectCount != null) 'defect_count': defectCount,
      if (photoPath != null) 'photo_path': photoPath,
      if (notes != null) 'notes': notes,
      if (itemName != null) 'item_name': itemName,
      if (itemAllocationsJson != null)
        'item_allocations_json': itemAllocationsJson,
      if (averageConfidence != null) 'average_confidence': averageConfidence,
      if (timestamp != null) 'timestamp': timestamp,
      if (operatorId != null) 'operator_id': operatorId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LayersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? truckId,
      Value<int>? layerNumber,
      Value<int>? cartonCount,
      Value<int>? defectCount,
      Value<String?>? photoPath,
      Value<String?>? notes,
      Value<String?>? itemName,
      Value<String>? itemAllocationsJson,
      Value<double>? averageConfidence,
      Value<DateTime?>? timestamp,
      Value<String?>? operatorId,
      Value<String?>? modelVersion,
      Value<int>? rowid}) {
    return LayersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      truckId: truckId ?? this.truckId,
      layerNumber: layerNumber ?? this.layerNumber,
      cartonCount: cartonCount ?? this.cartonCount,
      defectCount: defectCount ?? this.defectCount,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      itemName: itemName ?? this.itemName,
      itemAllocationsJson: itemAllocationsJson ?? this.itemAllocationsJson,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      timestamp: timestamp ?? this.timestamp,
      operatorId: operatorId ?? this.operatorId,
      modelVersion: modelVersion ?? this.modelVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (layerNumber.present) {
      map['layer_number'] = Variable<int>(layerNumber.value);
    }
    if (cartonCount.present) {
      map['carton_count'] = Variable<int>(cartonCount.value);
    }
    if (defectCount.present) {
      map['defect_count'] = Variable<int>(defectCount.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemAllocationsJson.present) {
      map['item_allocations_json'] =
          Variable<String>(itemAllocationsJson.value);
    }
    if (averageConfidence.present) {
      map['average_confidence'] = Variable<double>(averageConfidence.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('truckId: $truckId, ')
          ..write('layerNumber: $layerNumber, ')
          ..write('cartonCount: $cartonCount, ')
          ..write('defectCount: $defectCount, ')
          ..write('photoPath: $photoPath, ')
          ..write('notes: $notes, ')
          ..write('itemName: $itemName, ')
          ..write('itemAllocationsJson: $itemAllocationsJson, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('timestamp: $timestamp, ')
          ..write('operatorId: $operatorId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectionsTable extends Detections
    with TableInfo<$DetectionsTable, Detection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _layerIdMeta =
      const VerificationMeta('layerId');
  @override
  late final GeneratedColumn<String> layerId = GeneratedColumn<String>(
      'layer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES layers (id)'));
  static const VerificationMeta _boundingBoxXMeta =
      const VerificationMeta('boundingBoxX');
  @override
  late final GeneratedColumn<double> boundingBoxX = GeneratedColumn<double>(
      'bounding_box_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxYMeta =
      const VerificationMeta('boundingBoxY');
  @override
  late final GeneratedColumn<double> boundingBoxY = GeneratedColumn<double>(
      'bounding_box_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxWMeta =
      const VerificationMeta('boundingBoxW');
  @override
  late final GeneratedColumn<double> boundingBoxW = GeneratedColumn<double>(
      'bounding_box_w', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxHMeta =
      const VerificationMeta('boundingBoxH');
  @override
  late final GeneratedColumn<double> boundingBoxH = GeneratedColumn<double>(
      'bounding_box_h', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        layerId,
        boundingBoxX,
        boundingBoxY,
        boundingBoxW,
        boundingBoxH,
        confidence,
        label
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detections';
  @override
  VerificationContext validateIntegrity(Insertable<Detection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('layer_id')) {
      context.handle(_layerIdMeta,
          layerId.isAcceptableOrUnknown(data['layer_id']!, _layerIdMeta));
    } else if (isInserting) {
      context.missing(_layerIdMeta);
    }
    if (data.containsKey('bounding_box_x')) {
      context.handle(
          _boundingBoxXMeta,
          boundingBoxX.isAcceptableOrUnknown(
              data['bounding_box_x']!, _boundingBoxXMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxXMeta);
    }
    if (data.containsKey('bounding_box_y')) {
      context.handle(
          _boundingBoxYMeta,
          boundingBoxY.isAcceptableOrUnknown(
              data['bounding_box_y']!, _boundingBoxYMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxYMeta);
    }
    if (data.containsKey('bounding_box_w')) {
      context.handle(
          _boundingBoxWMeta,
          boundingBoxW.isAcceptableOrUnknown(
              data['bounding_box_w']!, _boundingBoxWMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxWMeta);
    }
    if (data.containsKey('bounding_box_h')) {
      context.handle(
          _boundingBoxHMeta,
          boundingBoxH.isAcceptableOrUnknown(
              data['bounding_box_h']!, _boundingBoxHMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxHMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Detection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Detection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      layerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}layer_id'])!,
      boundingBoxX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_x'])!,
      boundingBoxY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_y'])!,
      boundingBoxW: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_w'])!,
      boundingBoxH: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_h'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $DetectionsTable createAlias(String alias) {
    return $DetectionsTable(attachedDatabase, alias);
  }
}

class Detection extends DataClass implements Insertable<Detection> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String layerId;
  final double boundingBoxX;
  final double boundingBoxY;
  final double boundingBoxW;
  final double boundingBoxH;
  final double confidence;
  final String label;
  const Detection(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.layerId,
      required this.boundingBoxX,
      required this.boundingBoxY,
      required this.boundingBoxW,
      required this.boundingBoxH,
      required this.confidence,
      required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['layer_id'] = Variable<String>(layerId);
    map['bounding_box_x'] = Variable<double>(boundingBoxX);
    map['bounding_box_y'] = Variable<double>(boundingBoxY);
    map['bounding_box_w'] = Variable<double>(boundingBoxW);
    map['bounding_box_h'] = Variable<double>(boundingBoxH);
    map['confidence'] = Variable<double>(confidence);
    map['label'] = Variable<String>(label);
    return map;
  }

  DetectionsCompanion toCompanion(bool nullToAbsent) {
    return DetectionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      layerId: Value(layerId),
      boundingBoxX: Value(boundingBoxX),
      boundingBoxY: Value(boundingBoxY),
      boundingBoxW: Value(boundingBoxW),
      boundingBoxH: Value(boundingBoxH),
      confidence: Value(confidence),
      label: Value(label),
    );
  }

  factory Detection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Detection(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      layerId: serializer.fromJson<String>(json['layerId']),
      boundingBoxX: serializer.fromJson<double>(json['boundingBoxX']),
      boundingBoxY: serializer.fromJson<double>(json['boundingBoxY']),
      boundingBoxW: serializer.fromJson<double>(json['boundingBoxW']),
      boundingBoxH: serializer.fromJson<double>(json['boundingBoxH']),
      confidence: serializer.fromJson<double>(json['confidence']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'layerId': serializer.toJson<String>(layerId),
      'boundingBoxX': serializer.toJson<double>(boundingBoxX),
      'boundingBoxY': serializer.toJson<double>(boundingBoxY),
      'boundingBoxW': serializer.toJson<double>(boundingBoxW),
      'boundingBoxH': serializer.toJson<double>(boundingBoxH),
      'confidence': serializer.toJson<double>(confidence),
      'label': serializer.toJson<String>(label),
    };
  }

  Detection copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? layerId,
          double? boundingBoxX,
          double? boundingBoxY,
          double? boundingBoxW,
          double? boundingBoxH,
          double? confidence,
          String? label}) =>
      Detection(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        layerId: layerId ?? this.layerId,
        boundingBoxX: boundingBoxX ?? this.boundingBoxX,
        boundingBoxY: boundingBoxY ?? this.boundingBoxY,
        boundingBoxW: boundingBoxW ?? this.boundingBoxW,
        boundingBoxH: boundingBoxH ?? this.boundingBoxH,
        confidence: confidence ?? this.confidence,
        label: label ?? this.label,
      );
  Detection copyWithCompanion(DetectionsCompanion data) {
    return Detection(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      layerId: data.layerId.present ? data.layerId.value : this.layerId,
      boundingBoxX: data.boundingBoxX.present
          ? data.boundingBoxX.value
          : this.boundingBoxX,
      boundingBoxY: data.boundingBoxY.present
          ? data.boundingBoxY.value
          : this.boundingBoxY,
      boundingBoxW: data.boundingBoxW.present
          ? data.boundingBoxW.value
          : this.boundingBoxW,
      boundingBoxH: data.boundingBoxH.present
          ? data.boundingBoxH.value
          : this.boundingBoxH,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Detection(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('layerId: $layerId, ')
          ..write('boundingBoxX: $boundingBoxX, ')
          ..write('boundingBoxY: $boundingBoxY, ')
          ..write('boundingBoxW: $boundingBoxW, ')
          ..write('boundingBoxH: $boundingBoxH, ')
          ..write('confidence: $confidence, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      layerId,
      boundingBoxX,
      boundingBoxY,
      boundingBoxW,
      boundingBoxH,
      confidence,
      label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Detection &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.layerId == this.layerId &&
          other.boundingBoxX == this.boundingBoxX &&
          other.boundingBoxY == this.boundingBoxY &&
          other.boundingBoxW == this.boundingBoxW &&
          other.boundingBoxH == this.boundingBoxH &&
          other.confidence == this.confidence &&
          other.label == this.label);
}

class DetectionsCompanion extends UpdateCompanion<Detection> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> layerId;
  final Value<double> boundingBoxX;
  final Value<double> boundingBoxY;
  final Value<double> boundingBoxW;
  final Value<double> boundingBoxH;
  final Value<double> confidence;
  final Value<String> label;
  final Value<int> rowid;
  const DetectionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.layerId = const Value.absent(),
    this.boundingBoxX = const Value.absent(),
    this.boundingBoxY = const Value.absent(),
    this.boundingBoxW = const Value.absent(),
    this.boundingBoxH = const Value.absent(),
    this.confidence = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetectionsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String layerId,
    required double boundingBoxX,
    required double boundingBoxY,
    required double boundingBoxW,
    required double boundingBoxH,
    required double confidence,
    required String label,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        layerId = Value(layerId),
        boundingBoxX = Value(boundingBoxX),
        boundingBoxY = Value(boundingBoxY),
        boundingBoxW = Value(boundingBoxW),
        boundingBoxH = Value(boundingBoxH),
        confidence = Value(confidence),
        label = Value(label);
  static Insertable<Detection> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? layerId,
    Expression<double>? boundingBoxX,
    Expression<double>? boundingBoxY,
    Expression<double>? boundingBoxW,
    Expression<double>? boundingBoxH,
    Expression<double>? confidence,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (layerId != null) 'layer_id': layerId,
      if (boundingBoxX != null) 'bounding_box_x': boundingBoxX,
      if (boundingBoxY != null) 'bounding_box_y': boundingBoxY,
      if (boundingBoxW != null) 'bounding_box_w': boundingBoxW,
      if (boundingBoxH != null) 'bounding_box_h': boundingBoxH,
      if (confidence != null) 'confidence': confidence,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetectionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? layerId,
      Value<double>? boundingBoxX,
      Value<double>? boundingBoxY,
      Value<double>? boundingBoxW,
      Value<double>? boundingBoxH,
      Value<double>? confidence,
      Value<String>? label,
      Value<int>? rowid}) {
    return DetectionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      layerId: layerId ?? this.layerId,
      boundingBoxX: boundingBoxX ?? this.boundingBoxX,
      boundingBoxY: boundingBoxY ?? this.boundingBoxY,
      boundingBoxW: boundingBoxW ?? this.boundingBoxW,
      boundingBoxH: boundingBoxH ?? this.boundingBoxH,
      confidence: confidence ?? this.confidence,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (layerId.present) {
      map['layer_id'] = Variable<String>(layerId.value);
    }
    if (boundingBoxX.present) {
      map['bounding_box_x'] = Variable<double>(boundingBoxX.value);
    }
    if (boundingBoxY.present) {
      map['bounding_box_y'] = Variable<double>(boundingBoxY.value);
    }
    if (boundingBoxW.present) {
      map['bounding_box_w'] = Variable<double>(boundingBoxW.value);
    }
    if (boundingBoxH.present) {
      map['bounding_box_h'] = Variable<double>(boundingBoxH.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('layerId: $layerId, ')
          ..write('boundingBoxX: $boundingBoxX, ')
          ..write('boundingBoxY: $boundingBoxY, ')
          ..write('boundingBoxW: $boundingBoxW, ')
          ..write('boundingBoxH: $boundingBoxH, ')
          ..write('confidence: $confidence, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DigitalRegistersTable extends DigitalRegisters
    with TableInfo<$DigitalRegistersTable, DigitalRegister> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DigitalRegistersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _wagonIdMeta =
      const VerificationMeta('wagonId');
  @override
  late final GeneratedColumn<String> wagonId = GeneratedColumn<String>(
      'wagon_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wagons (id)'));
  static const VerificationMeta _wagonNumberMeta =
      const VerificationMeta('wagonNumber');
  @override
  late final GeneratedColumn<String> wagonNumber = GeneratedColumn<String>(
      'wagon_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _generatedByMeta =
      const VerificationMeta('generatedBy');
  @override
  late final GeneratedColumn<String> generatedBy = GeneratedColumn<String>(
      'generated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shiftMeta = const VerificationMeta('shift');
  @override
  late final GeneratedColumn<String> shift = GeneratedColumn<String>(
      'shift', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verificationHashMeta =
      const VerificationMeta('verificationHash');
  @override
  late final GeneratedColumn<String> verificationHash = GeneratedColumn<String>(
      'verification_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalTrucksMeta =
      const VerificationMeta('totalTrucks');
  @override
  late final GeneratedColumn<int> totalTrucks = GeneratedColumn<int>(
      'total_trucks', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalLayersMeta =
      const VerificationMeta('totalLayers');
  @override
  late final GeneratedColumn<int> totalLayers = GeneratedColumn<int>(
      'total_layers', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalCartonsMeta =
      const VerificationMeta('totalCartons');
  @override
  late final GeneratedColumn<int> totalCartons = GeneratedColumn<int>(
      'total_cartons', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        wagonId,
        wagonNumber,
        generatedBy,
        shift,
        verificationHash,
        totalTrucks,
        totalLayers,
        totalCartons
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'digital_registers';
  @override
  VerificationContext validateIntegrity(Insertable<DigitalRegister> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('wagon_id')) {
      context.handle(_wagonIdMeta,
          wagonId.isAcceptableOrUnknown(data['wagon_id']!, _wagonIdMeta));
    } else if (isInserting) {
      context.missing(_wagonIdMeta);
    }
    if (data.containsKey('wagon_number')) {
      context.handle(
          _wagonNumberMeta,
          wagonNumber.isAcceptableOrUnknown(
              data['wagon_number']!, _wagonNumberMeta));
    } else if (isInserting) {
      context.missing(_wagonNumberMeta);
    }
    if (data.containsKey('generated_by')) {
      context.handle(
          _generatedByMeta,
          generatedBy.isAcceptableOrUnknown(
              data['generated_by']!, _generatedByMeta));
    } else if (isInserting) {
      context.missing(_generatedByMeta);
    }
    if (data.containsKey('shift')) {
      context.handle(
          _shiftMeta, shift.isAcceptableOrUnknown(data['shift']!, _shiftMeta));
    } else if (isInserting) {
      context.missing(_shiftMeta);
    }
    if (data.containsKey('verification_hash')) {
      context.handle(
          _verificationHashMeta,
          verificationHash.isAcceptableOrUnknown(
              data['verification_hash']!, _verificationHashMeta));
    } else if (isInserting) {
      context.missing(_verificationHashMeta);
    }
    if (data.containsKey('total_trucks')) {
      context.handle(
          _totalTrucksMeta,
          totalTrucks.isAcceptableOrUnknown(
              data['total_trucks']!, _totalTrucksMeta));
    } else if (isInserting) {
      context.missing(_totalTrucksMeta);
    }
    if (data.containsKey('total_layers')) {
      context.handle(
          _totalLayersMeta,
          totalLayers.isAcceptableOrUnknown(
              data['total_layers']!, _totalLayersMeta));
    } else if (isInserting) {
      context.missing(_totalLayersMeta);
    }
    if (data.containsKey('total_cartons')) {
      context.handle(
          _totalCartonsMeta,
          totalCartons.isAcceptableOrUnknown(
              data['total_cartons']!, _totalCartonsMeta));
    } else if (isInserting) {
      context.missing(_totalCartonsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DigitalRegister map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DigitalRegister(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      wagonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wagon_id'])!,
      wagonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wagon_number'])!,
      generatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}generated_by'])!,
      shift: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift'])!,
      verificationHash: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verification_hash'])!,
      totalTrucks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_trucks'])!,
      totalLayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_layers'])!,
      totalCartons: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cartons'])!,
    );
  }

  @override
  $DigitalRegistersTable createAlias(String alias) {
    return $DigitalRegistersTable(attachedDatabase, alias);
  }
}

class DigitalRegister extends DataClass implements Insertable<DigitalRegister> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String wagonId;
  final String wagonNumber;
  final String generatedBy;
  final String shift;
  final String verificationHash;
  final int totalTrucks;
  final int totalLayers;
  final int totalCartons;
  const DigitalRegister(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.wagonId,
      required this.wagonNumber,
      required this.generatedBy,
      required this.shift,
      required this.verificationHash,
      required this.totalTrucks,
      required this.totalLayers,
      required this.totalCartons});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['wagon_id'] = Variable<String>(wagonId);
    map['wagon_number'] = Variable<String>(wagonNumber);
    map['generated_by'] = Variable<String>(generatedBy);
    map['shift'] = Variable<String>(shift);
    map['verification_hash'] = Variable<String>(verificationHash);
    map['total_trucks'] = Variable<int>(totalTrucks);
    map['total_layers'] = Variable<int>(totalLayers);
    map['total_cartons'] = Variable<int>(totalCartons);
    return map;
  }

  DigitalRegistersCompanion toCompanion(bool nullToAbsent) {
    return DigitalRegistersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      wagonId: Value(wagonId),
      wagonNumber: Value(wagonNumber),
      generatedBy: Value(generatedBy),
      shift: Value(shift),
      verificationHash: Value(verificationHash),
      totalTrucks: Value(totalTrucks),
      totalLayers: Value(totalLayers),
      totalCartons: Value(totalCartons),
    );
  }

  factory DigitalRegister.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DigitalRegister(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      wagonId: serializer.fromJson<String>(json['wagonId']),
      wagonNumber: serializer.fromJson<String>(json['wagonNumber']),
      generatedBy: serializer.fromJson<String>(json['generatedBy']),
      shift: serializer.fromJson<String>(json['shift']),
      verificationHash: serializer.fromJson<String>(json['verificationHash']),
      totalTrucks: serializer.fromJson<int>(json['totalTrucks']),
      totalLayers: serializer.fromJson<int>(json['totalLayers']),
      totalCartons: serializer.fromJson<int>(json['totalCartons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'wagonId': serializer.toJson<String>(wagonId),
      'wagonNumber': serializer.toJson<String>(wagonNumber),
      'generatedBy': serializer.toJson<String>(generatedBy),
      'shift': serializer.toJson<String>(shift),
      'verificationHash': serializer.toJson<String>(verificationHash),
      'totalTrucks': serializer.toJson<int>(totalTrucks),
      'totalLayers': serializer.toJson<int>(totalLayers),
      'totalCartons': serializer.toJson<int>(totalCartons),
    };
  }

  DigitalRegister copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? wagonId,
          String? wagonNumber,
          String? generatedBy,
          String? shift,
          String? verificationHash,
          int? totalTrucks,
          int? totalLayers,
          int? totalCartons}) =>
      DigitalRegister(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        wagonId: wagonId ?? this.wagonId,
        wagonNumber: wagonNumber ?? this.wagonNumber,
        generatedBy: generatedBy ?? this.generatedBy,
        shift: shift ?? this.shift,
        verificationHash: verificationHash ?? this.verificationHash,
        totalTrucks: totalTrucks ?? this.totalTrucks,
        totalLayers: totalLayers ?? this.totalLayers,
        totalCartons: totalCartons ?? this.totalCartons,
      );
  DigitalRegister copyWithCompanion(DigitalRegistersCompanion data) {
    return DigitalRegister(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      wagonId: data.wagonId.present ? data.wagonId.value : this.wagonId,
      wagonNumber:
          data.wagonNumber.present ? data.wagonNumber.value : this.wagonNumber,
      generatedBy:
          data.generatedBy.present ? data.generatedBy.value : this.generatedBy,
      shift: data.shift.present ? data.shift.value : this.shift,
      verificationHash: data.verificationHash.present
          ? data.verificationHash.value
          : this.verificationHash,
      totalTrucks:
          data.totalTrucks.present ? data.totalTrucks.value : this.totalTrucks,
      totalLayers:
          data.totalLayers.present ? data.totalLayers.value : this.totalLayers,
      totalCartons: data.totalCartons.present
          ? data.totalCartons.value
          : this.totalCartons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DigitalRegister(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('wagonId: $wagonId, ')
          ..write('wagonNumber: $wagonNumber, ')
          ..write('generatedBy: $generatedBy, ')
          ..write('shift: $shift, ')
          ..write('verificationHash: $verificationHash, ')
          ..write('totalTrucks: $totalTrucks, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      wagonId,
      wagonNumber,
      generatedBy,
      shift,
      verificationHash,
      totalTrucks,
      totalLayers,
      totalCartons);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DigitalRegister &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.wagonId == this.wagonId &&
          other.wagonNumber == this.wagonNumber &&
          other.generatedBy == this.generatedBy &&
          other.shift == this.shift &&
          other.verificationHash == this.verificationHash &&
          other.totalTrucks == this.totalTrucks &&
          other.totalLayers == this.totalLayers &&
          other.totalCartons == this.totalCartons);
}

class DigitalRegistersCompanion extends UpdateCompanion<DigitalRegister> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> wagonId;
  final Value<String> wagonNumber;
  final Value<String> generatedBy;
  final Value<String> shift;
  final Value<String> verificationHash;
  final Value<int> totalTrucks;
  final Value<int> totalLayers;
  final Value<int> totalCartons;
  final Value<int> rowid;
  const DigitalRegistersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.wagonId = const Value.absent(),
    this.wagonNumber = const Value.absent(),
    this.generatedBy = const Value.absent(),
    this.shift = const Value.absent(),
    this.verificationHash = const Value.absent(),
    this.totalTrucks = const Value.absent(),
    this.totalLayers = const Value.absent(),
    this.totalCartons = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DigitalRegistersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String wagonId,
    required String wagonNumber,
    required String generatedBy,
    required String shift,
    required String verificationHash,
    required int totalTrucks,
    required int totalLayers,
    required int totalCartons,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        wagonId = Value(wagonId),
        wagonNumber = Value(wagonNumber),
        generatedBy = Value(generatedBy),
        shift = Value(shift),
        verificationHash = Value(verificationHash),
        totalTrucks = Value(totalTrucks),
        totalLayers = Value(totalLayers),
        totalCartons = Value(totalCartons);
  static Insertable<DigitalRegister> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? wagonId,
    Expression<String>? wagonNumber,
    Expression<String>? generatedBy,
    Expression<String>? shift,
    Expression<String>? verificationHash,
    Expression<int>? totalTrucks,
    Expression<int>? totalLayers,
    Expression<int>? totalCartons,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (wagonId != null) 'wagon_id': wagonId,
      if (wagonNumber != null) 'wagon_number': wagonNumber,
      if (generatedBy != null) 'generated_by': generatedBy,
      if (shift != null) 'shift': shift,
      if (verificationHash != null) 'verification_hash': verificationHash,
      if (totalTrucks != null) 'total_trucks': totalTrucks,
      if (totalLayers != null) 'total_layers': totalLayers,
      if (totalCartons != null) 'total_cartons': totalCartons,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DigitalRegistersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? wagonId,
      Value<String>? wagonNumber,
      Value<String>? generatedBy,
      Value<String>? shift,
      Value<String>? verificationHash,
      Value<int>? totalTrucks,
      Value<int>? totalLayers,
      Value<int>? totalCartons,
      Value<int>? rowid}) {
    return DigitalRegistersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      wagonId: wagonId ?? this.wagonId,
      wagonNumber: wagonNumber ?? this.wagonNumber,
      generatedBy: generatedBy ?? this.generatedBy,
      shift: shift ?? this.shift,
      verificationHash: verificationHash ?? this.verificationHash,
      totalTrucks: totalTrucks ?? this.totalTrucks,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (wagonId.present) {
      map['wagon_id'] = Variable<String>(wagonId.value);
    }
    if (wagonNumber.present) {
      map['wagon_number'] = Variable<String>(wagonNumber.value);
    }
    if (generatedBy.present) {
      map['generated_by'] = Variable<String>(generatedBy.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(shift.value);
    }
    if (verificationHash.present) {
      map['verification_hash'] = Variable<String>(verificationHash.value);
    }
    if (totalTrucks.present) {
      map['total_trucks'] = Variable<int>(totalTrucks.value);
    }
    if (totalLayers.present) {
      map['total_layers'] = Variable<int>(totalLayers.value);
    }
    if (totalCartons.present) {
      map['total_cartons'] = Variable<int>(totalCartons.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DigitalRegistersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('wagonId: $wagonId, ')
          ..write('wagonNumber: $wagonNumber, ')
          ..write('generatedBy: $generatedBy, ')
          ..write('shift: $shift, ')
          ..write('verificationHash: $verificationHash, ')
          ..write('totalTrucks: $totalTrucks, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoadingSessionsTable extends LoadingSessions
    with TableInfo<$LoadingSessionsTable, LoadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES trucks (id)'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES warehouses (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalLayersMeta =
      const VerificationMeta('totalLayers');
  @override
  late final GeneratedColumn<int> totalLayers = GeneratedColumn<int>(
      'total_layers', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalCartonsMeta =
      const VerificationMeta('totalCartons');
  @override
  late final GeneratedColumn<int> totalCartons = GeneratedColumn<int>(
      'total_cartons', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalDefectsMeta =
      const VerificationMeta('totalDefects');
  @override
  late final GeneratedColumn<int> totalDefects = GeneratedColumn<int>(
      'total_defects', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _averageConfidenceMeta =
      const VerificationMeta('averageConfidence');
  @override
  late final GeneratedColumn<double> averageConfidence =
      GeneratedColumn<double>('average_confidence', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        truckId,
        warehouseId,
        startTime,
        endTime,
        operatorId,
        status,
        totalLayers,
        totalCartons,
        totalDefects,
        averageConfidence,
        modelVersion,
        notes,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loading_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<LoadingSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    } else if (isInserting) {
      context.missing(_truckIdMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_layers')) {
      context.handle(
          _totalLayersMeta,
          totalLayers.isAcceptableOrUnknown(
              data['total_layers']!, _totalLayersMeta));
    }
    if (data.containsKey('total_cartons')) {
      context.handle(
          _totalCartonsMeta,
          totalCartons.isAcceptableOrUnknown(
              data['total_cartons']!, _totalCartonsMeta));
    }
    if (data.containsKey('total_defects')) {
      context.handle(
          _totalDefectsMeta,
          totalDefects.isAcceptableOrUnknown(
              data['total_defects']!, _totalDefectsMeta));
    }
    if (data.containsKey('average_confidence')) {
      context.handle(
          _averageConfidenceMeta,
          averageConfidence.isAcceptableOrUnknown(
              data['average_confidence']!, _averageConfidenceMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoadingSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalLayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_layers'])!,
      totalCartons: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cartons'])!,
      totalDefects: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_defects'])!,
      averageConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_confidence'])!,
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  $LoadingSessionsTable createAlias(String alias) {
    return $LoadingSessionsTable(attachedDatabase, alias);
  }
}

class LoadingSession extends DataClass implements Insertable<LoadingSession> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String truckId;
  final String? warehouseId;
  final DateTime startTime;
  final DateTime? endTime;
  final String operatorId;
  final String status;
  final int totalLayers;
  final int totalCartons;
  final int totalDefects;
  final double averageConfidence;
  final String? modelVersion;
  final String? notes;
  final String? metadata;
  const LoadingSession(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.truckId,
      this.warehouseId,
      required this.startTime,
      this.endTime,
      required this.operatorId,
      required this.status,
      required this.totalLayers,
      required this.totalCartons,
      required this.totalDefects,
      required this.averageConfidence,
      this.modelVersion,
      this.notes,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['truck_id'] = Variable<String>(truckId);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['operator_id'] = Variable<String>(operatorId);
    map['status'] = Variable<String>(status);
    map['total_layers'] = Variable<int>(totalLayers);
    map['total_cartons'] = Variable<int>(totalCartons);
    map['total_defects'] = Variable<int>(totalDefects);
    map['average_confidence'] = Variable<double>(averageConfidence);
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  LoadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return LoadingSessionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      truckId: Value(truckId),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      operatorId: Value(operatorId),
      status: Value(status),
      totalLayers: Value(totalLayers),
      totalCartons: Value(totalCartons),
      totalDefects: Value(totalDefects),
      averageConfidence: Value(averageConfidence),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory LoadingSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoadingSession(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      truckId: serializer.fromJson<String>(json['truckId']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      status: serializer.fromJson<String>(json['status']),
      totalLayers: serializer.fromJson<int>(json['totalLayers']),
      totalCartons: serializer.fromJson<int>(json['totalCartons']),
      totalDefects: serializer.fromJson<int>(json['totalDefects']),
      averageConfidence: serializer.fromJson<double>(json['averageConfidence']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      notes: serializer.fromJson<String?>(json['notes']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'truckId': serializer.toJson<String>(truckId),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'operatorId': serializer.toJson<String>(operatorId),
      'status': serializer.toJson<String>(status),
      'totalLayers': serializer.toJson<int>(totalLayers),
      'totalCartons': serializer.toJson<int>(totalCartons),
      'totalDefects': serializer.toJson<int>(totalDefects),
      'averageConfidence': serializer.toJson<double>(averageConfidence),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'notes': serializer.toJson<String?>(notes),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  LoadingSession copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? truckId,
          Value<String?> warehouseId = const Value.absent(),
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          String? operatorId,
          String? status,
          int? totalLayers,
          int? totalCartons,
          int? totalDefects,
          double? averageConfidence,
          Value<String?> modelVersion = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> metadata = const Value.absent()}) =>
      LoadingSession(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        truckId: truckId ?? this.truckId,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        operatorId: operatorId ?? this.operatorId,
        status: status ?? this.status,
        totalLayers: totalLayers ?? this.totalLayers,
        totalCartons: totalCartons ?? this.totalCartons,
        totalDefects: totalDefects ?? this.totalDefects,
        averageConfidence: averageConfidence ?? this.averageConfidence,
        modelVersion:
            modelVersion.present ? modelVersion.value : this.modelVersion,
        notes: notes.present ? notes.value : this.notes,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  LoadingSession copyWithCompanion(LoadingSessionsCompanion data) {
    return LoadingSession(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      status: data.status.present ? data.status.value : this.status,
      totalLayers:
          data.totalLayers.present ? data.totalLayers.value : this.totalLayers,
      totalCartons: data.totalCartons.present
          ? data.totalCartons.value
          : this.totalCartons,
      totalDefects: data.totalDefects.present
          ? data.totalDefects.value
          : this.totalDefects,
      averageConfidence: data.averageConfidence.present
          ? data.averageConfidence.value
          : this.averageConfidence,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      notes: data.notes.present ? data.notes.value : this.notes,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoadingSession(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('truckId: $truckId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('operatorId: $operatorId, ')
          ..write('status: $status, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons, ')
          ..write('totalDefects: $totalDefects, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('notes: $notes, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      truckId,
      warehouseId,
      startTime,
      endTime,
      operatorId,
      status,
      totalLayers,
      totalCartons,
      totalDefects,
      averageConfidence,
      modelVersion,
      notes,
      metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoadingSession &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.truckId == this.truckId &&
          other.warehouseId == this.warehouseId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.operatorId == this.operatorId &&
          other.status == this.status &&
          other.totalLayers == this.totalLayers &&
          other.totalCartons == this.totalCartons &&
          other.totalDefects == this.totalDefects &&
          other.averageConfidence == this.averageConfidence &&
          other.modelVersion == this.modelVersion &&
          other.notes == this.notes &&
          other.metadata == this.metadata);
}

class LoadingSessionsCompanion extends UpdateCompanion<LoadingSession> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> truckId;
  final Value<String?> warehouseId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<String> operatorId;
  final Value<String> status;
  final Value<int> totalLayers;
  final Value<int> totalCartons;
  final Value<int> totalDefects;
  final Value<double> averageConfidence;
  final Value<String?> modelVersion;
  final Value<String?> notes;
  final Value<String?> metadata;
  final Value<int> rowid;
  const LoadingSessionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.truckId = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.status = const Value.absent(),
    this.totalLayers = const Value.absent(),
    this.totalCartons = const Value.absent(),
    this.totalDefects = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.notes = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoadingSessionsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String truckId,
    this.warehouseId = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required String operatorId,
    required String status,
    this.totalLayers = const Value.absent(),
    this.totalCartons = const Value.absent(),
    this.totalDefects = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.notes = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        truckId = Value(truckId),
        startTime = Value(startTime),
        operatorId = Value(operatorId),
        status = Value(status);
  static Insertable<LoadingSession> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? truckId,
    Expression<String>? warehouseId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? operatorId,
    Expression<String>? status,
    Expression<int>? totalLayers,
    Expression<int>? totalCartons,
    Expression<int>? totalDefects,
    Expression<double>? averageConfidence,
    Expression<String>? modelVersion,
    Expression<String>? notes,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (truckId != null) 'truck_id': truckId,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (operatorId != null) 'operator_id': operatorId,
      if (status != null) 'status': status,
      if (totalLayers != null) 'total_layers': totalLayers,
      if (totalCartons != null) 'total_cartons': totalCartons,
      if (totalDefects != null) 'total_defects': totalDefects,
      if (averageConfidence != null) 'average_confidence': averageConfidence,
      if (modelVersion != null) 'model_version': modelVersion,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoadingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? truckId,
      Value<String?>? warehouseId,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<String>? operatorId,
      Value<String>? status,
      Value<int>? totalLayers,
      Value<int>? totalCartons,
      Value<int>? totalDefects,
      Value<double>? averageConfidence,
      Value<String?>? modelVersion,
      Value<String?>? notes,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return LoadingSessionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      truckId: truckId ?? this.truckId,
      warehouseId: warehouseId ?? this.warehouseId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      operatorId: operatorId ?? this.operatorId,
      status: status ?? this.status,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      totalDefects: totalDefects ?? this.totalDefects,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      modelVersion: modelVersion ?? this.modelVersion,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalLayers.present) {
      map['total_layers'] = Variable<int>(totalLayers.value);
    }
    if (totalCartons.present) {
      map['total_cartons'] = Variable<int>(totalCartons.value);
    }
    if (totalDefects.present) {
      map['total_defects'] = Variable<int>(totalDefects.value);
    }
    if (averageConfidence.present) {
      map['average_confidence'] = Variable<double>(averageConfidence.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('truckId: $truckId, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('operatorId: $operatorId, ')
          ..write('status: $status, ')
          ..write('totalLayers: $totalLayers, ')
          ..write('totalCartons: $totalCartons, ')
          ..write('totalDefects: $totalDefects, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('notes: $notes, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityId, entityType, action, userId, timestamp, details];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String entityId;
  final String entityType;
  final String action;
  final String userId;
  final DateTime timestamp;
  final String? details;
  const AuditLog(
      {required this.id,
      required this.entityId,
      required this.entityType,
      required this.action,
      required this.userId,
      required this.timestamp,
      this.details});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['action'] = Variable<String>(action);
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      entityType: Value(entityType),
      action: Value(action),
      userId: Value(userId),
      timestamp: Value(timestamp),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      action: serializer.fromJson<String>(json['action']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'action': serializer.toJson<String>(action),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'details': serializer.toJson<String?>(details),
    };
  }

  AuditLog copyWith(
          {String? id,
          String? entityId,
          String? entityType,
          String? action,
          String? userId,
          DateTime? timestamp,
          Value<String?> details = const Value.absent()}) =>
      AuditLog(
        id: id ?? this.id,
        entityId: entityId ?? this.entityId,
        entityType: entityType ?? this.entityType,
        action: action ?? this.action,
        userId: userId ?? this.userId,
        timestamp: timestamp ?? this.timestamp,
        details: details.present ? details.value : this.details,
      );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      action: data.action.present ? data.action.value : this.action,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityId, entityType, action, userId, timestamp, details);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.action == this.action &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.details == this.details);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<String> action;
  final Value<String> userId;
  final Value<DateTime> timestamp;
  final Value<String?> details;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.action = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String entityId,
    required String entityType,
    required String action,
    required String userId,
    this.timestamp = const Value.absent(),
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityId = Value(entityId),
        entityType = Value(entityType),
        action = Value(action),
        userId = Value(userId);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<String>? action,
    Expression<String>? userId,
    Expression<DateTime>? timestamp,
    Expression<String>? details,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (action != null) 'action': action,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (details != null) 'details': details,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityId,
      Value<String>? entityType,
      Value<String>? action,
      Value<String>? userId,
      Value<DateTime>? timestamp,
      Value<String?>? details,
      Value<int>? rowid}) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('details: $details, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadDataMeta =
      const VerificationMeta('payloadData');
  @override
  late final GeneratedColumn<String> payloadData = GeneratedColumn<String>(
      'payload_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _queuedAtMeta =
      const VerificationMeta('queuedAt');
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
      'queued_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityId,
        entityType,
        operation,
        payloadData,
        version,
        priority,
        createdAt,
        updatedAt,
        queuedAt,
        retryCount,
        status,
        errorMessage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_data')) {
      context.handle(
          _payloadDataMeta,
          payloadData.isAcceptableOrUnknown(
              data['payload_data']!, _payloadDataMeta));
    } else if (isInserting) {
      context.missing(_payloadDataMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('queued_at')) {
      context.handle(_queuedAtMeta,
          queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payloadData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_data'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      queuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}queued_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final String id;
  final String entityId;
  final String entityType;
  final String operation;
  final String payloadData;
  final int version;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime queuedAt;
  final int retryCount;
  final String status;
  final String? errorMessage;
  const SyncQueue(
      {required this.id,
      required this.entityId,
      required this.entityType,
      required this.operation,
      required this.payloadData,
      required this.version,
      required this.priority,
      required this.createdAt,
      required this.updatedAt,
      required this.queuedAt,
      required this.retryCount,
      required this.status,
      this.errorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['entity_type'] = Variable<String>(entityType);
    map['operation'] = Variable<String>(operation);
    map['payload_data'] = Variable<String>(payloadData);
    map['version'] = Variable<int>(version);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      entityId: Value(entityId),
      entityType: Value(entityType),
      operation: Value(operation),
      payloadData: Value(payloadData),
      version: Value(version),
      priority: Value(priority),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      queuedAt: Value(queuedAt),
      retryCount: Value(retryCount),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadData: serializer.fromJson<String>(json['payloadData']),
      version: serializer.fromJson<int>(json['version']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'operation': serializer.toJson<String>(operation),
      'payloadData': serializer.toJson<String>(payloadData),
      'version': serializer.toJson<int>(version),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueue copyWith(
          {String? id,
          String? entityId,
          String? entityType,
          String? operation,
          String? payloadData,
          int? version,
          int? priority,
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? queuedAt,
          int? retryCount,
          String? status,
          Value<String?> errorMessage = const Value.absent()}) =>
      SyncQueue(
        id: id ?? this.id,
        entityId: entityId ?? this.entityId,
        entityType: entityType ?? this.entityType,
        operation: operation ?? this.operation,
        payloadData: payloadData ?? this.payloadData,
        version: version ?? this.version,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        queuedAt: queuedAt ?? this.queuedAt,
        retryCount: retryCount ?? this.retryCount,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadData:
          data.payloadData.present ? data.payloadData.value : this.payloadData,
      version: data.version.present ? data.version.value : this.version,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payloadData: $payloadData, ')
          ..write('version: $version, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      entityId,
      entityType,
      operation,
      payloadData,
      version,
      priority,
      createdAt,
      updatedAt,
      queuedAt,
      retryCount,
      status,
      errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.payloadData == this.payloadData &&
          other.version == this.version &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.queuedAt == this.queuedAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> entityType;
  final Value<String> operation;
  final Value<String> payloadData;
  final Value<int> version;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> queuedAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadData = const Value.absent(),
    this.version = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    required String id,
    required String entityId,
    required String entityType,
    required String operation,
    required String payloadData,
    this.version = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityId = Value(entityId),
        entityType = Value(entityType),
        operation = Value(operation),
        payloadData = Value(payloadData);
  static Insertable<SyncQueue> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? entityType,
    Expression<String>? operation,
    Expression<String>? payloadData,
    Expression<int>? version,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? queuedAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (operation != null) 'operation': operation,
      if (payloadData != null) 'payload_data': payloadData,
      if (version != null) 'version': version,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueuesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityId,
      Value<String>? entityType,
      Value<String>? operation,
      Value<String>? payloadData,
      Value<int>? version,
      Value<int>? priority,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? queuedAt,
      Value<int>? retryCount,
      Value<String>? status,
      Value<String?>? errorMessage,
      Value<int>? rowid}) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      payloadData: payloadData ?? this.payloadData,
      version: version ?? this.version,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadData.present) {
      map['payload_data'] = Variable<String>(payloadData.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payloadData: $payloadData, ')
          ..write('version: $version, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatasetImagesTable extends DatasetImages
    with TableInfo<$DatasetImagesTable, DatasetImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatasetImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _truckIdMeta =
      const VerificationMeta('truckId');
  @override
  late final GeneratedColumn<String> truckId = GeneratedColumn<String>(
      'truck_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wagonIdMeta =
      const VerificationMeta('wagonId');
  @override
  late final GeneratedColumn<String> wagonId = GeneratedColumn<String>(
      'wagon_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _layerNumberMeta =
      const VerificationMeta('layerNumber');
  @override
  late final GeneratedColumn<int> layerNumber = GeneratedColumn<int>(
      'layer_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originalPathMeta =
      const VerificationMeta('originalPath');
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
      'original_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _annotatedPathMeta =
      const VerificationMeta('annotatedPath');
  @override
  late final GeneratedColumn<String> annotatedPath = GeneratedColumn<String>(
      'annotated_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _approvalStatusMeta =
      const VerificationMeta('approvalStatus');
  @override
  late final GeneratedColumn<String> approvalStatus = GeneratedColumn<String>(
      'approval_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _rejectReasonMeta =
      const VerificationMeta('rejectReason');
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
      'reject_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isExportedMeta =
      const VerificationMeta('isExported');
  @override
  late final GeneratedColumn<bool> isExported = GeneratedColumn<bool>(
      'is_exported', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_exported" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        warehouseId,
        truckId,
        wagonId,
        layerNumber,
        originalPath,
        annotatedPath,
        thumbnailPath,
        fileSize,
        approvalStatus,
        rejectReason,
        operatorId,
        timestamp,
        isExported
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dataset_images';
  @override
  VerificationContext validateIntegrity(Insertable<DatasetImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('truck_id')) {
      context.handle(_truckIdMeta,
          truckId.isAcceptableOrUnknown(data['truck_id']!, _truckIdMeta));
    }
    if (data.containsKey('wagon_id')) {
      context.handle(_wagonIdMeta,
          wagonId.isAcceptableOrUnknown(data['wagon_id']!, _wagonIdMeta));
    }
    if (data.containsKey('layer_number')) {
      context.handle(
          _layerNumberMeta,
          layerNumber.isAcceptableOrUnknown(
              data['layer_number']!, _layerNumberMeta));
    }
    if (data.containsKey('original_path')) {
      context.handle(
          _originalPathMeta,
          originalPath.isAcceptableOrUnknown(
              data['original_path']!, _originalPathMeta));
    } else if (isInserting) {
      context.missing(_originalPathMeta);
    }
    if (data.containsKey('annotated_path')) {
      context.handle(
          _annotatedPathMeta,
          annotatedPath.isAcceptableOrUnknown(
              data['annotated_path']!, _annotatedPathMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('approval_status')) {
      context.handle(
          _approvalStatusMeta,
          approvalStatus.isAcceptableOrUnknown(
              data['approval_status']!, _approvalStatusMeta));
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
          _rejectReasonMeta,
          rejectReason.isAcceptableOrUnknown(
              data['reject_reason']!, _rejectReasonMeta));
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('is_exported')) {
      context.handle(
          _isExportedMeta,
          isExported.isAcceptableOrUnknown(
              data['is_exported']!, _isExportedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatasetImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatasetImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      truckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}truck_id']),
      wagonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wagon_id']),
      layerNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}layer_number']),
      originalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_path'])!,
      annotatedPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}annotated_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      approvalStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}approval_status'])!,
      rejectReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reject_reason']),
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp']),
      isExported: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_exported'])!,
    );
  }

  @override
  $DatasetImagesTable createAlias(String alias) {
    return $DatasetImagesTable(attachedDatabase, alias);
  }
}

class DatasetImage extends DataClass implements Insertable<DatasetImage> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String? warehouseId;
  final String? truckId;
  final String? wagonId;
  final int? layerNumber;
  final String originalPath;
  final String? annotatedPath;
  final String? thumbnailPath;
  final int fileSize;
  final String approvalStatus;
  final String? rejectReason;
  final String? operatorId;
  final DateTime? timestamp;
  final bool isExported;
  const DatasetImage(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      this.warehouseId,
      this.truckId,
      this.wagonId,
      this.layerNumber,
      required this.originalPath,
      this.annotatedPath,
      this.thumbnailPath,
      required this.fileSize,
      required this.approvalStatus,
      this.rejectReason,
      this.operatorId,
      this.timestamp,
      required this.isExported});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    if (!nullToAbsent || truckId != null) {
      map['truck_id'] = Variable<String>(truckId);
    }
    if (!nullToAbsent || wagonId != null) {
      map['wagon_id'] = Variable<String>(wagonId);
    }
    if (!nullToAbsent || layerNumber != null) {
      map['layer_number'] = Variable<int>(layerNumber);
    }
    map['original_path'] = Variable<String>(originalPath);
    if (!nullToAbsent || annotatedPath != null) {
      map['annotated_path'] = Variable<String>(annotatedPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['file_size'] = Variable<int>(fileSize);
    map['approval_status'] = Variable<String>(approvalStatus);
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    if (!nullToAbsent || operatorId != null) {
      map['operator_id'] = Variable<String>(operatorId);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    map['is_exported'] = Variable<bool>(isExported);
    return map;
  }

  DatasetImagesCompanion toCompanion(bool nullToAbsent) {
    return DatasetImagesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      truckId: truckId == null && nullToAbsent
          ? const Value.absent()
          : Value(truckId),
      wagonId: wagonId == null && nullToAbsent
          ? const Value.absent()
          : Value(wagonId),
      layerNumber: layerNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(layerNumber),
      originalPath: Value(originalPath),
      annotatedPath: annotatedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(annotatedPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      fileSize: Value(fileSize),
      approvalStatus: Value(approvalStatus),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
      operatorId: operatorId == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorId),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      isExported: Value(isExported),
    );
  }

  factory DatasetImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatasetImage(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      truckId: serializer.fromJson<String?>(json['truckId']),
      wagonId: serializer.fromJson<String?>(json['wagonId']),
      layerNumber: serializer.fromJson<int?>(json['layerNumber']),
      originalPath: serializer.fromJson<String>(json['originalPath']),
      annotatedPath: serializer.fromJson<String?>(json['annotatedPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      approvalStatus: serializer.fromJson<String>(json['approvalStatus']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
      operatorId: serializer.fromJson<String?>(json['operatorId']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      isExported: serializer.fromJson<bool>(json['isExported']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'truckId': serializer.toJson<String?>(truckId),
      'wagonId': serializer.toJson<String?>(wagonId),
      'layerNumber': serializer.toJson<int?>(layerNumber),
      'originalPath': serializer.toJson<String>(originalPath),
      'annotatedPath': serializer.toJson<String?>(annotatedPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'fileSize': serializer.toJson<int>(fileSize),
      'approvalStatus': serializer.toJson<String>(approvalStatus),
      'rejectReason': serializer.toJson<String?>(rejectReason),
      'operatorId': serializer.toJson<String?>(operatorId),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'isExported': serializer.toJson<bool>(isExported),
    };
  }

  DatasetImage copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          Value<String?> warehouseId = const Value.absent(),
          Value<String?> truckId = const Value.absent(),
          Value<String?> wagonId = const Value.absent(),
          Value<int?> layerNumber = const Value.absent(),
          String? originalPath,
          Value<String?> annotatedPath = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          int? fileSize,
          String? approvalStatus,
          Value<String?> rejectReason = const Value.absent(),
          Value<String?> operatorId = const Value.absent(),
          Value<DateTime?> timestamp = const Value.absent(),
          bool? isExported}) =>
      DatasetImage(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        truckId: truckId.present ? truckId.value : this.truckId,
        wagonId: wagonId.present ? wagonId.value : this.wagonId,
        layerNumber: layerNumber.present ? layerNumber.value : this.layerNumber,
        originalPath: originalPath ?? this.originalPath,
        annotatedPath:
            annotatedPath.present ? annotatedPath.value : this.annotatedPath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        fileSize: fileSize ?? this.fileSize,
        approvalStatus: approvalStatus ?? this.approvalStatus,
        rejectReason:
            rejectReason.present ? rejectReason.value : this.rejectReason,
        operatorId: operatorId.present ? operatorId.value : this.operatorId,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        isExported: isExported ?? this.isExported,
      );
  DatasetImage copyWithCompanion(DatasetImagesCompanion data) {
    return DatasetImage(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      truckId: data.truckId.present ? data.truckId.value : this.truckId,
      wagonId: data.wagonId.present ? data.wagonId.value : this.wagonId,
      layerNumber:
          data.layerNumber.present ? data.layerNumber.value : this.layerNumber,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      annotatedPath: data.annotatedPath.present
          ? data.annotatedPath.value
          : this.annotatedPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      approvalStatus: data.approvalStatus.present
          ? data.approvalStatus.value
          : this.approvalStatus,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isExported:
          data.isExported.present ? data.isExported.value : this.isExported,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatasetImage(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('truckId: $truckId, ')
          ..write('wagonId: $wagonId, ')
          ..write('layerNumber: $layerNumber, ')
          ..write('originalPath: $originalPath, ')
          ..write('annotatedPath: $annotatedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('operatorId: $operatorId, ')
          ..write('timestamp: $timestamp, ')
          ..write('isExported: $isExported')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      warehouseId,
      truckId,
      wagonId,
      layerNumber,
      originalPath,
      annotatedPath,
      thumbnailPath,
      fileSize,
      approvalStatus,
      rejectReason,
      operatorId,
      timestamp,
      isExported);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatasetImage &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.warehouseId == this.warehouseId &&
          other.truckId == this.truckId &&
          other.wagonId == this.wagonId &&
          other.layerNumber == this.layerNumber &&
          other.originalPath == this.originalPath &&
          other.annotatedPath == this.annotatedPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.fileSize == this.fileSize &&
          other.approvalStatus == this.approvalStatus &&
          other.rejectReason == this.rejectReason &&
          other.operatorId == this.operatorId &&
          other.timestamp == this.timestamp &&
          other.isExported == this.isExported);
}

class DatasetImagesCompanion extends UpdateCompanion<DatasetImage> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String?> warehouseId;
  final Value<String?> truckId;
  final Value<String?> wagonId;
  final Value<int?> layerNumber;
  final Value<String> originalPath;
  final Value<String?> annotatedPath;
  final Value<String?> thumbnailPath;
  final Value<int> fileSize;
  final Value<String> approvalStatus;
  final Value<String?> rejectReason;
  final Value<String?> operatorId;
  final Value<DateTime?> timestamp;
  final Value<bool> isExported;
  final Value<int> rowid;
  const DatasetImagesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.truckId = const Value.absent(),
    this.wagonId = const Value.absent(),
    this.layerNumber = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.annotatedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.approvalStatus = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isExported = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatasetImagesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.truckId = const Value.absent(),
    this.wagonId = const Value.absent(),
    this.layerNumber = const Value.absent(),
    required String originalPath,
    this.annotatedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    required int fileSize,
    this.approvalStatus = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isExported = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalPath = Value(originalPath),
        fileSize = Value(fileSize);
  static Insertable<DatasetImage> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? warehouseId,
    Expression<String>? truckId,
    Expression<String>? wagonId,
    Expression<int>? layerNumber,
    Expression<String>? originalPath,
    Expression<String>? annotatedPath,
    Expression<String>? thumbnailPath,
    Expression<int>? fileSize,
    Expression<String>? approvalStatus,
    Expression<String>? rejectReason,
    Expression<String>? operatorId,
    Expression<DateTime>? timestamp,
    Expression<bool>? isExported,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (truckId != null) 'truck_id': truckId,
      if (wagonId != null) 'wagon_id': wagonId,
      if (layerNumber != null) 'layer_number': layerNumber,
      if (originalPath != null) 'original_path': originalPath,
      if (annotatedPath != null) 'annotated_path': annotatedPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (fileSize != null) 'file_size': fileSize,
      if (approvalStatus != null) 'approval_status': approvalStatus,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (operatorId != null) 'operator_id': operatorId,
      if (timestamp != null) 'timestamp': timestamp,
      if (isExported != null) 'is_exported': isExported,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatasetImagesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String?>? warehouseId,
      Value<String?>? truckId,
      Value<String?>? wagonId,
      Value<int?>? layerNumber,
      Value<String>? originalPath,
      Value<String?>? annotatedPath,
      Value<String?>? thumbnailPath,
      Value<int>? fileSize,
      Value<String>? approvalStatus,
      Value<String?>? rejectReason,
      Value<String?>? operatorId,
      Value<DateTime?>? timestamp,
      Value<bool>? isExported,
      Value<int>? rowid}) {
    return DatasetImagesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      warehouseId: warehouseId ?? this.warehouseId,
      truckId: truckId ?? this.truckId,
      wagonId: wagonId ?? this.wagonId,
      layerNumber: layerNumber ?? this.layerNumber,
      originalPath: originalPath ?? this.originalPath,
      annotatedPath: annotatedPath ?? this.annotatedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      fileSize: fileSize ?? this.fileSize,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectReason: rejectReason ?? this.rejectReason,
      operatorId: operatorId ?? this.operatorId,
      timestamp: timestamp ?? this.timestamp,
      isExported: isExported ?? this.isExported,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (truckId.present) {
      map['truck_id'] = Variable<String>(truckId.value);
    }
    if (wagonId.present) {
      map['wagon_id'] = Variable<String>(wagonId.value);
    }
    if (layerNumber.present) {
      map['layer_number'] = Variable<int>(layerNumber.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (annotatedPath.present) {
      map['annotated_path'] = Variable<String>(annotatedPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (approvalStatus.present) {
      map['approval_status'] = Variable<String>(approvalStatus.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isExported.present) {
      map['is_exported'] = Variable<bool>(isExported.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatasetImagesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('truckId: $truckId, ')
          ..write('wagonId: $wagonId, ')
          ..write('layerNumber: $layerNumber, ')
          ..write('originalPath: $originalPath, ')
          ..write('annotatedPath: $annotatedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('fileSize: $fileSize, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('operatorId: $operatorId, ')
          ..write('timestamp: $timestamp, ')
          ..write('isExported: $isExported, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageMetadataTable extends ImageMetadata
    with TableInfo<$ImageMetadataTable, ImageMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES dataset_images (id) ON DELETE CASCADE'));
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _captureTimeMeta =
      const VerificationMeta('captureTime');
  @override
  late final GeneratedColumn<DateTime> captureTime = GeneratedColumn<DateTime>(
      'capture_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cameraResolutionMeta =
      const VerificationMeta('cameraResolution');
  @override
  late final GeneratedColumn<String> cameraResolution = GeneratedColumn<String>(
      'camera_resolution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inferenceTimeMsMeta =
      const VerificationMeta('inferenceTimeMs');
  @override
  late final GeneratedColumn<double> inferenceTimeMs = GeneratedColumn<double>(
      'inference_time_ms', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _averageConfidenceMeta =
      const VerificationMeta('averageConfidence');
  @override
  late final GeneratedColumn<double> averageConfidence =
      GeneratedColumn<double>('average_confidence', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _detectedCountMeta =
      const VerificationMeta('detectedCount');
  @override
  late final GeneratedColumn<int> detectedCount = GeneratedColumn<int>(
      'detected_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manualCountMeta =
      const VerificationMeta('manualCount');
  @override
  late final GeneratedColumn<int> manualCount = GeneratedColumn<int>(
      'manual_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _finalCountMeta =
      const VerificationMeta('finalCount');
  @override
  late final GeneratedColumn<int> finalCount = GeneratedColumn<int>(
      'final_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        imageId,
        filename,
        captureTime,
        deviceModel,
        cameraResolution,
        modelVersion,
        inferenceTimeMs,
        averageConfidence,
        detectedCount,
        manualCount,
        finalCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<ImageMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('capture_time')) {
      context.handle(
          _captureTimeMeta,
          captureTime.isAcceptableOrUnknown(
              data['capture_time']!, _captureTimeMeta));
    } else if (isInserting) {
      context.missing(_captureTimeMeta);
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    }
    if (data.containsKey('camera_resolution')) {
      context.handle(
          _cameraResolutionMeta,
          cameraResolution.isAcceptableOrUnknown(
              data['camera_resolution']!, _cameraResolutionMeta));
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    }
    if (data.containsKey('inference_time_ms')) {
      context.handle(
          _inferenceTimeMsMeta,
          inferenceTimeMs.isAcceptableOrUnknown(
              data['inference_time_ms']!, _inferenceTimeMsMeta));
    }
    if (data.containsKey('average_confidence')) {
      context.handle(
          _averageConfidenceMeta,
          averageConfidence.isAcceptableOrUnknown(
              data['average_confidence']!, _averageConfidenceMeta));
    }
    if (data.containsKey('detected_count')) {
      context.handle(
          _detectedCountMeta,
          detectedCount.isAcceptableOrUnknown(
              data['detected_count']!, _detectedCountMeta));
    }
    if (data.containsKey('manual_count')) {
      context.handle(
          _manualCountMeta,
          manualCount.isAcceptableOrUnknown(
              data['manual_count']!, _manualCountMeta));
    }
    if (data.containsKey('final_count')) {
      context.handle(
          _finalCountMeta,
          finalCount.isAcceptableOrUnknown(
              data['final_count']!, _finalCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {imageId};
  @override
  ImageMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageMetadataData(
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id'])!,
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      captureTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}capture_time'])!,
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model']),
      cameraResolution: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}camera_resolution']),
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version']),
      inferenceTimeMs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}inference_time_ms'])!,
      averageConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_confidence'])!,
      detectedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}detected_count'])!,
      manualCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}manual_count']),
      finalCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}final_count']),
    );
  }

  @override
  $ImageMetadataTable createAlias(String alias) {
    return $ImageMetadataTable(attachedDatabase, alias);
  }
}

class ImageMetadataData extends DataClass
    implements Insertable<ImageMetadataData> {
  final String imageId;
  final String filename;
  final DateTime captureTime;
  final String? deviceModel;
  final String? cameraResolution;
  final String? modelVersion;
  final double inferenceTimeMs;
  final double averageConfidence;
  final int detectedCount;
  final int? manualCount;
  final int? finalCount;
  const ImageMetadataData(
      {required this.imageId,
      required this.filename,
      required this.captureTime,
      this.deviceModel,
      this.cameraResolution,
      this.modelVersion,
      required this.inferenceTimeMs,
      required this.averageConfidence,
      required this.detectedCount,
      this.manualCount,
      this.finalCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['image_id'] = Variable<String>(imageId);
    map['filename'] = Variable<String>(filename);
    map['capture_time'] = Variable<DateTime>(captureTime);
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || cameraResolution != null) {
      map['camera_resolution'] = Variable<String>(cameraResolution);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    map['inference_time_ms'] = Variable<double>(inferenceTimeMs);
    map['average_confidence'] = Variable<double>(averageConfidence);
    map['detected_count'] = Variable<int>(detectedCount);
    if (!nullToAbsent || manualCount != null) {
      map['manual_count'] = Variable<int>(manualCount);
    }
    if (!nullToAbsent || finalCount != null) {
      map['final_count'] = Variable<int>(finalCount);
    }
    return map;
  }

  ImageMetadataCompanion toCompanion(bool nullToAbsent) {
    return ImageMetadataCompanion(
      imageId: Value(imageId),
      filename: Value(filename),
      captureTime: Value(captureTime),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      cameraResolution: cameraResolution == null && nullToAbsent
          ? const Value.absent()
          : Value(cameraResolution),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      inferenceTimeMs: Value(inferenceTimeMs),
      averageConfidence: Value(averageConfidence),
      detectedCount: Value(detectedCount),
      manualCount: manualCount == null && nullToAbsent
          ? const Value.absent()
          : Value(manualCount),
      finalCount: finalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(finalCount),
    );
  }

  factory ImageMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageMetadataData(
      imageId: serializer.fromJson<String>(json['imageId']),
      filename: serializer.fromJson<String>(json['filename']),
      captureTime: serializer.fromJson<DateTime>(json['captureTime']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      cameraResolution: serializer.fromJson<String?>(json['cameraResolution']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      inferenceTimeMs: serializer.fromJson<double>(json['inferenceTimeMs']),
      averageConfidence: serializer.fromJson<double>(json['averageConfidence']),
      detectedCount: serializer.fromJson<int>(json['detectedCount']),
      manualCount: serializer.fromJson<int?>(json['manualCount']),
      finalCount: serializer.fromJson<int?>(json['finalCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'imageId': serializer.toJson<String>(imageId),
      'filename': serializer.toJson<String>(filename),
      'captureTime': serializer.toJson<DateTime>(captureTime),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'cameraResolution': serializer.toJson<String?>(cameraResolution),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'inferenceTimeMs': serializer.toJson<double>(inferenceTimeMs),
      'averageConfidence': serializer.toJson<double>(averageConfidence),
      'detectedCount': serializer.toJson<int>(detectedCount),
      'manualCount': serializer.toJson<int?>(manualCount),
      'finalCount': serializer.toJson<int?>(finalCount),
    };
  }

  ImageMetadataData copyWith(
          {String? imageId,
          String? filename,
          DateTime? captureTime,
          Value<String?> deviceModel = const Value.absent(),
          Value<String?> cameraResolution = const Value.absent(),
          Value<String?> modelVersion = const Value.absent(),
          double? inferenceTimeMs,
          double? averageConfidence,
          int? detectedCount,
          Value<int?> manualCount = const Value.absent(),
          Value<int?> finalCount = const Value.absent()}) =>
      ImageMetadataData(
        imageId: imageId ?? this.imageId,
        filename: filename ?? this.filename,
        captureTime: captureTime ?? this.captureTime,
        deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
        cameraResolution: cameraResolution.present
            ? cameraResolution.value
            : this.cameraResolution,
        modelVersion:
            modelVersion.present ? modelVersion.value : this.modelVersion,
        inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
        averageConfidence: averageConfidence ?? this.averageConfidence,
        detectedCount: detectedCount ?? this.detectedCount,
        manualCount: manualCount.present ? manualCount.value : this.manualCount,
        finalCount: finalCount.present ? finalCount.value : this.finalCount,
      );
  ImageMetadataData copyWithCompanion(ImageMetadataCompanion data) {
    return ImageMetadataData(
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      filename: data.filename.present ? data.filename.value : this.filename,
      captureTime:
          data.captureTime.present ? data.captureTime.value : this.captureTime,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      cameraResolution: data.cameraResolution.present
          ? data.cameraResolution.value
          : this.cameraResolution,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      inferenceTimeMs: data.inferenceTimeMs.present
          ? data.inferenceTimeMs.value
          : this.inferenceTimeMs,
      averageConfidence: data.averageConfidence.present
          ? data.averageConfidence.value
          : this.averageConfidence,
      detectedCount: data.detectedCount.present
          ? data.detectedCount.value
          : this.detectedCount,
      manualCount:
          data.manualCount.present ? data.manualCount.value : this.manualCount,
      finalCount:
          data.finalCount.present ? data.finalCount.value : this.finalCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageMetadataData(')
          ..write('imageId: $imageId, ')
          ..write('filename: $filename, ')
          ..write('captureTime: $captureTime, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('cameraResolution: $cameraResolution, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('inferenceTimeMs: $inferenceTimeMs, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('detectedCount: $detectedCount, ')
          ..write('manualCount: $manualCount, ')
          ..write('finalCount: $finalCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      imageId,
      filename,
      captureTime,
      deviceModel,
      cameraResolution,
      modelVersion,
      inferenceTimeMs,
      averageConfidence,
      detectedCount,
      manualCount,
      finalCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageMetadataData &&
          other.imageId == this.imageId &&
          other.filename == this.filename &&
          other.captureTime == this.captureTime &&
          other.deviceModel == this.deviceModel &&
          other.cameraResolution == this.cameraResolution &&
          other.modelVersion == this.modelVersion &&
          other.inferenceTimeMs == this.inferenceTimeMs &&
          other.averageConfidence == this.averageConfidence &&
          other.detectedCount == this.detectedCount &&
          other.manualCount == this.manualCount &&
          other.finalCount == this.finalCount);
}

class ImageMetadataCompanion extends UpdateCompanion<ImageMetadataData> {
  final Value<String> imageId;
  final Value<String> filename;
  final Value<DateTime> captureTime;
  final Value<String?> deviceModel;
  final Value<String?> cameraResolution;
  final Value<String?> modelVersion;
  final Value<double> inferenceTimeMs;
  final Value<double> averageConfidence;
  final Value<int> detectedCount;
  final Value<int?> manualCount;
  final Value<int?> finalCount;
  final Value<int> rowid;
  const ImageMetadataCompanion({
    this.imageId = const Value.absent(),
    this.filename = const Value.absent(),
    this.captureTime = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.cameraResolution = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.inferenceTimeMs = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.detectedCount = const Value.absent(),
    this.manualCount = const Value.absent(),
    this.finalCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageMetadataCompanion.insert({
    required String imageId,
    required String filename,
    required DateTime captureTime,
    this.deviceModel = const Value.absent(),
    this.cameraResolution = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.inferenceTimeMs = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.detectedCount = const Value.absent(),
    this.manualCount = const Value.absent(),
    this.finalCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : imageId = Value(imageId),
        filename = Value(filename),
        captureTime = Value(captureTime);
  static Insertable<ImageMetadataData> custom({
    Expression<String>? imageId,
    Expression<String>? filename,
    Expression<DateTime>? captureTime,
    Expression<String>? deviceModel,
    Expression<String>? cameraResolution,
    Expression<String>? modelVersion,
    Expression<double>? inferenceTimeMs,
    Expression<double>? averageConfidence,
    Expression<int>? detectedCount,
    Expression<int>? manualCount,
    Expression<int>? finalCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (imageId != null) 'image_id': imageId,
      if (filename != null) 'filename': filename,
      if (captureTime != null) 'capture_time': captureTime,
      if (deviceModel != null) 'device_model': deviceModel,
      if (cameraResolution != null) 'camera_resolution': cameraResolution,
      if (modelVersion != null) 'model_version': modelVersion,
      if (inferenceTimeMs != null) 'inference_time_ms': inferenceTimeMs,
      if (averageConfidence != null) 'average_confidence': averageConfidence,
      if (detectedCount != null) 'detected_count': detectedCount,
      if (manualCount != null) 'manual_count': manualCount,
      if (finalCount != null) 'final_count': finalCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageMetadataCompanion copyWith(
      {Value<String>? imageId,
      Value<String>? filename,
      Value<DateTime>? captureTime,
      Value<String?>? deviceModel,
      Value<String?>? cameraResolution,
      Value<String?>? modelVersion,
      Value<double>? inferenceTimeMs,
      Value<double>? averageConfidence,
      Value<int>? detectedCount,
      Value<int?>? manualCount,
      Value<int?>? finalCount,
      Value<int>? rowid}) {
    return ImageMetadataCompanion(
      imageId: imageId ?? this.imageId,
      filename: filename ?? this.filename,
      captureTime: captureTime ?? this.captureTime,
      deviceModel: deviceModel ?? this.deviceModel,
      cameraResolution: cameraResolution ?? this.cameraResolution,
      modelVersion: modelVersion ?? this.modelVersion,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      detectedCount: detectedCount ?? this.detectedCount,
      manualCount: manualCount ?? this.manualCount,
      finalCount: finalCount ?? this.finalCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (captureTime.present) {
      map['capture_time'] = Variable<DateTime>(captureTime.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (cameraResolution.present) {
      map['camera_resolution'] = Variable<String>(cameraResolution.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (inferenceTimeMs.present) {
      map['inference_time_ms'] = Variable<double>(inferenceTimeMs.value);
    }
    if (averageConfidence.present) {
      map['average_confidence'] = Variable<double>(averageConfidence.value);
    }
    if (detectedCount.present) {
      map['detected_count'] = Variable<int>(detectedCount.value);
    }
    if (manualCount.present) {
      map['manual_count'] = Variable<int>(manualCount.value);
    }
    if (finalCount.present) {
      map['final_count'] = Variable<int>(finalCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageMetadataCompanion(')
          ..write('imageId: $imageId, ')
          ..write('filename: $filename, ')
          ..write('captureTime: $captureTime, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('cameraResolution: $cameraResolution, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('inferenceTimeMs: $inferenceTimeMs, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('detectedCount: $detectedCount, ')
          ..write('manualCount: $manualCount, ')
          ..write('finalCount: $finalCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageQualityTable extends ImageQuality
    with TableInfo<$ImageQualityTable, ImageQualityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageQualityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES dataset_images (id) ON DELETE CASCADE'));
  static const VerificationMeta _blurScoreMeta =
      const VerificationMeta('blurScore');
  @override
  late final GeneratedColumn<double> blurScore = GeneratedColumn<double>(
      'blur_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _brightnessMeta =
      const VerificationMeta('brightness');
  @override
  late final GeneratedColumn<double> brightness = GeneratedColumn<double>(
      'brightness', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(128.0));
  static const VerificationMeta _contrastMeta =
      const VerificationMeta('contrast');
  @override
  late final GeneratedColumn<double> contrast = GeneratedColumn<double>(
      'contrast', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _rotationMeta =
      const VerificationMeta('rotation');
  @override
  late final GeneratedColumn<double> rotation = GeneratedColumn<double>(
      'rotation', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _perspectiveMeta =
      const VerificationMeta('perspective');
  @override
  late final GeneratedColumn<double> perspective = GeneratedColumn<double>(
      'perspective', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _occlusionMeta =
      const VerificationMeta('occlusion');
  @override
  late final GeneratedColumn<double> occlusion = GeneratedColumn<double>(
      'occlusion', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        imageId,
        blurScore,
        brightness,
        contrast,
        rotation,
        perspective,
        occlusion,
        distance
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_quality';
  @override
  VerificationContext validateIntegrity(Insertable<ImageQualityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('blur_score')) {
      context.handle(_blurScoreMeta,
          blurScore.isAcceptableOrUnknown(data['blur_score']!, _blurScoreMeta));
    }
    if (data.containsKey('brightness')) {
      context.handle(
          _brightnessMeta,
          brightness.isAcceptableOrUnknown(
              data['brightness']!, _brightnessMeta));
    }
    if (data.containsKey('contrast')) {
      context.handle(_contrastMeta,
          contrast.isAcceptableOrUnknown(data['contrast']!, _contrastMeta));
    }
    if (data.containsKey('rotation')) {
      context.handle(_rotationMeta,
          rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta));
    }
    if (data.containsKey('perspective')) {
      context.handle(
          _perspectiveMeta,
          perspective.isAcceptableOrUnknown(
              data['perspective']!, _perspectiveMeta));
    }
    if (data.containsKey('occlusion')) {
      context.handle(_occlusionMeta,
          occlusion.isAcceptableOrUnknown(data['occlusion']!, _occlusionMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {imageId};
  @override
  ImageQualityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageQualityData(
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id'])!,
      blurScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}blur_score'])!,
      brightness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}brightness'])!,
      contrast: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}contrast'])!,
      rotation: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation'])!,
      perspective: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}perspective'])!,
      occlusion: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}occlusion'])!,
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance'])!,
    );
  }

  @override
  $ImageQualityTable createAlias(String alias) {
    return $ImageQualityTable(attachedDatabase, alias);
  }
}

class ImageQualityData extends DataClass
    implements Insertable<ImageQualityData> {
  final String imageId;
  final double blurScore;
  final double brightness;
  final double contrast;
  final double rotation;
  final double perspective;
  final double occlusion;
  final double distance;
  const ImageQualityData(
      {required this.imageId,
      required this.blurScore,
      required this.brightness,
      required this.contrast,
      required this.rotation,
      required this.perspective,
      required this.occlusion,
      required this.distance});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['image_id'] = Variable<String>(imageId);
    map['blur_score'] = Variable<double>(blurScore);
    map['brightness'] = Variable<double>(brightness);
    map['contrast'] = Variable<double>(contrast);
    map['rotation'] = Variable<double>(rotation);
    map['perspective'] = Variable<double>(perspective);
    map['occlusion'] = Variable<double>(occlusion);
    map['distance'] = Variable<double>(distance);
    return map;
  }

  ImageQualityCompanion toCompanion(bool nullToAbsent) {
    return ImageQualityCompanion(
      imageId: Value(imageId),
      blurScore: Value(blurScore),
      brightness: Value(brightness),
      contrast: Value(contrast),
      rotation: Value(rotation),
      perspective: Value(perspective),
      occlusion: Value(occlusion),
      distance: Value(distance),
    );
  }

  factory ImageQualityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageQualityData(
      imageId: serializer.fromJson<String>(json['imageId']),
      blurScore: serializer.fromJson<double>(json['blurScore']),
      brightness: serializer.fromJson<double>(json['brightness']),
      contrast: serializer.fromJson<double>(json['contrast']),
      rotation: serializer.fromJson<double>(json['rotation']),
      perspective: serializer.fromJson<double>(json['perspective']),
      occlusion: serializer.fromJson<double>(json['occlusion']),
      distance: serializer.fromJson<double>(json['distance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'imageId': serializer.toJson<String>(imageId),
      'blurScore': serializer.toJson<double>(blurScore),
      'brightness': serializer.toJson<double>(brightness),
      'contrast': serializer.toJson<double>(contrast),
      'rotation': serializer.toJson<double>(rotation),
      'perspective': serializer.toJson<double>(perspective),
      'occlusion': serializer.toJson<double>(occlusion),
      'distance': serializer.toJson<double>(distance),
    };
  }

  ImageQualityData copyWith(
          {String? imageId,
          double? blurScore,
          double? brightness,
          double? contrast,
          double? rotation,
          double? perspective,
          double? occlusion,
          double? distance}) =>
      ImageQualityData(
        imageId: imageId ?? this.imageId,
        blurScore: blurScore ?? this.blurScore,
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        rotation: rotation ?? this.rotation,
        perspective: perspective ?? this.perspective,
        occlusion: occlusion ?? this.occlusion,
        distance: distance ?? this.distance,
      );
  ImageQualityData copyWithCompanion(ImageQualityCompanion data) {
    return ImageQualityData(
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      blurScore: data.blurScore.present ? data.blurScore.value : this.blurScore,
      brightness:
          data.brightness.present ? data.brightness.value : this.brightness,
      contrast: data.contrast.present ? data.contrast.value : this.contrast,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      perspective:
          data.perspective.present ? data.perspective.value : this.perspective,
      occlusion: data.occlusion.present ? data.occlusion.value : this.occlusion,
      distance: data.distance.present ? data.distance.value : this.distance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageQualityData(')
          ..write('imageId: $imageId, ')
          ..write('blurScore: $blurScore, ')
          ..write('brightness: $brightness, ')
          ..write('contrast: $contrast, ')
          ..write('rotation: $rotation, ')
          ..write('perspective: $perspective, ')
          ..write('occlusion: $occlusion, ')
          ..write('distance: $distance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(imageId, blurScore, brightness, contrast,
      rotation, perspective, occlusion, distance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageQualityData &&
          other.imageId == this.imageId &&
          other.blurScore == this.blurScore &&
          other.brightness == this.brightness &&
          other.contrast == this.contrast &&
          other.rotation == this.rotation &&
          other.perspective == this.perspective &&
          other.occlusion == this.occlusion &&
          other.distance == this.distance);
}

class ImageQualityCompanion extends UpdateCompanion<ImageQualityData> {
  final Value<String> imageId;
  final Value<double> blurScore;
  final Value<double> brightness;
  final Value<double> contrast;
  final Value<double> rotation;
  final Value<double> perspective;
  final Value<double> occlusion;
  final Value<double> distance;
  final Value<int> rowid;
  const ImageQualityCompanion({
    this.imageId = const Value.absent(),
    this.blurScore = const Value.absent(),
    this.brightness = const Value.absent(),
    this.contrast = const Value.absent(),
    this.rotation = const Value.absent(),
    this.perspective = const Value.absent(),
    this.occlusion = const Value.absent(),
    this.distance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageQualityCompanion.insert({
    required String imageId,
    this.blurScore = const Value.absent(),
    this.brightness = const Value.absent(),
    this.contrast = const Value.absent(),
    this.rotation = const Value.absent(),
    this.perspective = const Value.absent(),
    this.occlusion = const Value.absent(),
    this.distance = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : imageId = Value(imageId);
  static Insertable<ImageQualityData> custom({
    Expression<String>? imageId,
    Expression<double>? blurScore,
    Expression<double>? brightness,
    Expression<double>? contrast,
    Expression<double>? rotation,
    Expression<double>? perspective,
    Expression<double>? occlusion,
    Expression<double>? distance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (imageId != null) 'image_id': imageId,
      if (blurScore != null) 'blur_score': blurScore,
      if (brightness != null) 'brightness': brightness,
      if (contrast != null) 'contrast': contrast,
      if (rotation != null) 'rotation': rotation,
      if (perspective != null) 'perspective': perspective,
      if (occlusion != null) 'occlusion': occlusion,
      if (distance != null) 'distance': distance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageQualityCompanion copyWith(
      {Value<String>? imageId,
      Value<double>? blurScore,
      Value<double>? brightness,
      Value<double>? contrast,
      Value<double>? rotation,
      Value<double>? perspective,
      Value<double>? occlusion,
      Value<double>? distance,
      Value<int>? rowid}) {
    return ImageQualityCompanion(
      imageId: imageId ?? this.imageId,
      blurScore: blurScore ?? this.blurScore,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      rotation: rotation ?? this.rotation,
      perspective: perspective ?? this.perspective,
      occlusion: occlusion ?? this.occlusion,
      distance: distance ?? this.distance,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (blurScore.present) {
      map['blur_score'] = Variable<double>(blurScore.value);
    }
    if (brightness.present) {
      map['brightness'] = Variable<double>(brightness.value);
    }
    if (contrast.present) {
      map['contrast'] = Variable<double>(contrast.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<double>(rotation.value);
    }
    if (perspective.present) {
      map['perspective'] = Variable<double>(perspective.value);
    }
    if (occlusion.present) {
      map['occlusion'] = Variable<double>(occlusion.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageQualityCompanion(')
          ..write('imageId: $imageId, ')
          ..write('blurScore: $blurScore, ')
          ..write('brightness: $brightness, ')
          ..write('contrast: $contrast, ')
          ..write('rotation: $rotation, ')
          ..write('perspective: $perspective, ')
          ..write('occlusion: $occlusion, ')
          ..write('distance: $distance, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnotationsTable extends Annotations
    with TableInfo<$AnnotationsTable, Annotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES dataset_images (id) ON DELETE CASCADE'));
  static const VerificationMeta _boundingBoxXMeta =
      const VerificationMeta('boundingBoxX');
  @override
  late final GeneratedColumn<double> boundingBoxX = GeneratedColumn<double>(
      'bounding_box_x', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxYMeta =
      const VerificationMeta('boundingBoxY');
  @override
  late final GeneratedColumn<double> boundingBoxY = GeneratedColumn<double>(
      'bounding_box_y', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxWMeta =
      const VerificationMeta('boundingBoxW');
  @override
  late final GeneratedColumn<double> boundingBoxW = GeneratedColumn<double>(
      'bounding_box_w', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _boundingBoxHMeta =
      const VerificationMeta('boundingBoxH');
  @override
  late final GeneratedColumn<double> boundingBoxH = GeneratedColumn<double>(
      'bounding_box_h', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isManualCorrectionMeta =
      const VerificationMeta('isManualCorrection');
  @override
  late final GeneratedColumn<bool> isManualCorrection = GeneratedColumn<bool>(
      'is_manual_correction', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_manual_correction" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _correctionReasonMeta =
      const VerificationMeta('correctionReason');
  @override
  late final GeneratedColumn<String> correctionReason = GeneratedColumn<String>(
      'correction_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        imageId,
        boundingBoxX,
        boundingBoxY,
        boundingBoxW,
        boundingBoxH,
        label,
        confidence,
        isManualCorrection,
        correctionReason
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotations';
  @override
  VerificationContext validateIntegrity(Insertable<Annotation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    } else if (isInserting) {
      context.missing(_imageIdMeta);
    }
    if (data.containsKey('bounding_box_x')) {
      context.handle(
          _boundingBoxXMeta,
          boundingBoxX.isAcceptableOrUnknown(
              data['bounding_box_x']!, _boundingBoxXMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxXMeta);
    }
    if (data.containsKey('bounding_box_y')) {
      context.handle(
          _boundingBoxYMeta,
          boundingBoxY.isAcceptableOrUnknown(
              data['bounding_box_y']!, _boundingBoxYMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxYMeta);
    }
    if (data.containsKey('bounding_box_w')) {
      context.handle(
          _boundingBoxWMeta,
          boundingBoxW.isAcceptableOrUnknown(
              data['bounding_box_w']!, _boundingBoxWMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxWMeta);
    }
    if (data.containsKey('bounding_box_h')) {
      context.handle(
          _boundingBoxHMeta,
          boundingBoxH.isAcceptableOrUnknown(
              data['bounding_box_h']!, _boundingBoxHMeta));
    } else if (isInserting) {
      context.missing(_boundingBoxHMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('is_manual_correction')) {
      context.handle(
          _isManualCorrectionMeta,
          isManualCorrection.isAcceptableOrUnknown(
              data['is_manual_correction']!, _isManualCorrectionMeta));
    }
    if (data.containsKey('correction_reason')) {
      context.handle(
          _correctionReasonMeta,
          correctionReason.isAcceptableOrUnknown(
              data['correction_reason']!, _correctionReasonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Annotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Annotation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id'])!,
      boundingBoxX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_x'])!,
      boundingBoxY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_y'])!,
      boundingBoxW: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_w'])!,
      boundingBoxH: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bounding_box_h'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      isManualCorrection: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_manual_correction'])!,
      correctionReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}correction_reason']),
    );
  }

  @override
  $AnnotationsTable createAlias(String alias) {
    return $AnnotationsTable(attachedDatabase, alias);
  }
}

class Annotation extends DataClass implements Insertable<Annotation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String imageId;
  final double boundingBoxX;
  final double boundingBoxY;
  final double boundingBoxW;
  final double boundingBoxH;
  final String label;
  final double confidence;
  final bool isManualCorrection;
  final String? correctionReason;
  const Annotation(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.imageId,
      required this.boundingBoxX,
      required this.boundingBoxY,
      required this.boundingBoxW,
      required this.boundingBoxH,
      required this.label,
      required this.confidence,
      required this.isManualCorrection,
      this.correctionReason});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['image_id'] = Variable<String>(imageId);
    map['bounding_box_x'] = Variable<double>(boundingBoxX);
    map['bounding_box_y'] = Variable<double>(boundingBoxY);
    map['bounding_box_w'] = Variable<double>(boundingBoxW);
    map['bounding_box_h'] = Variable<double>(boundingBoxH);
    map['label'] = Variable<String>(label);
    map['confidence'] = Variable<double>(confidence);
    map['is_manual_correction'] = Variable<bool>(isManualCorrection);
    if (!nullToAbsent || correctionReason != null) {
      map['correction_reason'] = Variable<String>(correctionReason);
    }
    return map;
  }

  AnnotationsCompanion toCompanion(bool nullToAbsent) {
    return AnnotationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      imageId: Value(imageId),
      boundingBoxX: Value(boundingBoxX),
      boundingBoxY: Value(boundingBoxY),
      boundingBoxW: Value(boundingBoxW),
      boundingBoxH: Value(boundingBoxH),
      label: Value(label),
      confidence: Value(confidence),
      isManualCorrection: Value(isManualCorrection),
      correctionReason: correctionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionReason),
    );
  }

  factory Annotation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Annotation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      imageId: serializer.fromJson<String>(json['imageId']),
      boundingBoxX: serializer.fromJson<double>(json['boundingBoxX']),
      boundingBoxY: serializer.fromJson<double>(json['boundingBoxY']),
      boundingBoxW: serializer.fromJson<double>(json['boundingBoxW']),
      boundingBoxH: serializer.fromJson<double>(json['boundingBoxH']),
      label: serializer.fromJson<String>(json['label']),
      confidence: serializer.fromJson<double>(json['confidence']),
      isManualCorrection: serializer.fromJson<bool>(json['isManualCorrection']),
      correctionReason: serializer.fromJson<String?>(json['correctionReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'imageId': serializer.toJson<String>(imageId),
      'boundingBoxX': serializer.toJson<double>(boundingBoxX),
      'boundingBoxY': serializer.toJson<double>(boundingBoxY),
      'boundingBoxW': serializer.toJson<double>(boundingBoxW),
      'boundingBoxH': serializer.toJson<double>(boundingBoxH),
      'label': serializer.toJson<String>(label),
      'confidence': serializer.toJson<double>(confidence),
      'isManualCorrection': serializer.toJson<bool>(isManualCorrection),
      'correctionReason': serializer.toJson<String?>(correctionReason),
    };
  }

  Annotation copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? imageId,
          double? boundingBoxX,
          double? boundingBoxY,
          double? boundingBoxW,
          double? boundingBoxH,
          String? label,
          double? confidence,
          bool? isManualCorrection,
          Value<String?> correctionReason = const Value.absent()}) =>
      Annotation(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        imageId: imageId ?? this.imageId,
        boundingBoxX: boundingBoxX ?? this.boundingBoxX,
        boundingBoxY: boundingBoxY ?? this.boundingBoxY,
        boundingBoxW: boundingBoxW ?? this.boundingBoxW,
        boundingBoxH: boundingBoxH ?? this.boundingBoxH,
        label: label ?? this.label,
        confidence: confidence ?? this.confidence,
        isManualCorrection: isManualCorrection ?? this.isManualCorrection,
        correctionReason: correctionReason.present
            ? correctionReason.value
            : this.correctionReason,
      );
  Annotation copyWithCompanion(AnnotationsCompanion data) {
    return Annotation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      boundingBoxX: data.boundingBoxX.present
          ? data.boundingBoxX.value
          : this.boundingBoxX,
      boundingBoxY: data.boundingBoxY.present
          ? data.boundingBoxY.value
          : this.boundingBoxY,
      boundingBoxW: data.boundingBoxW.present
          ? data.boundingBoxW.value
          : this.boundingBoxW,
      boundingBoxH: data.boundingBoxH.present
          ? data.boundingBoxH.value
          : this.boundingBoxH,
      label: data.label.present ? data.label.value : this.label,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      isManualCorrection: data.isManualCorrection.present
          ? data.isManualCorrection.value
          : this.isManualCorrection,
      correctionReason: data.correctionReason.present
          ? data.correctionReason.value
          : this.correctionReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Annotation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('imageId: $imageId, ')
          ..write('boundingBoxX: $boundingBoxX, ')
          ..write('boundingBoxY: $boundingBoxY, ')
          ..write('boundingBoxW: $boundingBoxW, ')
          ..write('boundingBoxH: $boundingBoxH, ')
          ..write('label: $label, ')
          ..write('confidence: $confidence, ')
          ..write('isManualCorrection: $isManualCorrection, ')
          ..write('correctionReason: $correctionReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      imageId,
      boundingBoxX,
      boundingBoxY,
      boundingBoxW,
      boundingBoxH,
      label,
      confidence,
      isManualCorrection,
      correctionReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Annotation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.imageId == this.imageId &&
          other.boundingBoxX == this.boundingBoxX &&
          other.boundingBoxY == this.boundingBoxY &&
          other.boundingBoxW == this.boundingBoxW &&
          other.boundingBoxH == this.boundingBoxH &&
          other.label == this.label &&
          other.confidence == this.confidence &&
          other.isManualCorrection == this.isManualCorrection &&
          other.correctionReason == this.correctionReason);
}

class AnnotationsCompanion extends UpdateCompanion<Annotation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> imageId;
  final Value<double> boundingBoxX;
  final Value<double> boundingBoxY;
  final Value<double> boundingBoxW;
  final Value<double> boundingBoxH;
  final Value<String> label;
  final Value<double> confidence;
  final Value<bool> isManualCorrection;
  final Value<String?> correctionReason;
  final Value<int> rowid;
  const AnnotationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.imageId = const Value.absent(),
    this.boundingBoxX = const Value.absent(),
    this.boundingBoxY = const Value.absent(),
    this.boundingBoxW = const Value.absent(),
    this.boundingBoxH = const Value.absent(),
    this.label = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isManualCorrection = const Value.absent(),
    this.correctionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnotationsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String imageId,
    required double boundingBoxX,
    required double boundingBoxY,
    required double boundingBoxW,
    required double boundingBoxH,
    required String label,
    required double confidence,
    this.isManualCorrection = const Value.absent(),
    this.correctionReason = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        imageId = Value(imageId),
        boundingBoxX = Value(boundingBoxX),
        boundingBoxY = Value(boundingBoxY),
        boundingBoxW = Value(boundingBoxW),
        boundingBoxH = Value(boundingBoxH),
        label = Value(label),
        confidence = Value(confidence);
  static Insertable<Annotation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? imageId,
    Expression<double>? boundingBoxX,
    Expression<double>? boundingBoxY,
    Expression<double>? boundingBoxW,
    Expression<double>? boundingBoxH,
    Expression<String>? label,
    Expression<double>? confidence,
    Expression<bool>? isManualCorrection,
    Expression<String>? correctionReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (imageId != null) 'image_id': imageId,
      if (boundingBoxX != null) 'bounding_box_x': boundingBoxX,
      if (boundingBoxY != null) 'bounding_box_y': boundingBoxY,
      if (boundingBoxW != null) 'bounding_box_w': boundingBoxW,
      if (boundingBoxH != null) 'bounding_box_h': boundingBoxH,
      if (label != null) 'label': label,
      if (confidence != null) 'confidence': confidence,
      if (isManualCorrection != null)
        'is_manual_correction': isManualCorrection,
      if (correctionReason != null) 'correction_reason': correctionReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnotationsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? imageId,
      Value<double>? boundingBoxX,
      Value<double>? boundingBoxY,
      Value<double>? boundingBoxW,
      Value<double>? boundingBoxH,
      Value<String>? label,
      Value<double>? confidence,
      Value<bool>? isManualCorrection,
      Value<String?>? correctionReason,
      Value<int>? rowid}) {
    return AnnotationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      imageId: imageId ?? this.imageId,
      boundingBoxX: boundingBoxX ?? this.boundingBoxX,
      boundingBoxY: boundingBoxY ?? this.boundingBoxY,
      boundingBoxW: boundingBoxW ?? this.boundingBoxW,
      boundingBoxH: boundingBoxH ?? this.boundingBoxH,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      isManualCorrection: isManualCorrection ?? this.isManualCorrection,
      correctionReason: correctionReason ?? this.correctionReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
    }
    if (boundingBoxX.present) {
      map['bounding_box_x'] = Variable<double>(boundingBoxX.value);
    }
    if (boundingBoxY.present) {
      map['bounding_box_y'] = Variable<double>(boundingBoxY.value);
    }
    if (boundingBoxW.present) {
      map['bounding_box_w'] = Variable<double>(boundingBoxW.value);
    }
    if (boundingBoxH.present) {
      map['bounding_box_h'] = Variable<double>(boundingBoxH.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (isManualCorrection.present) {
      map['is_manual_correction'] = Variable<bool>(isManualCorrection.value);
    }
    if (correctionReason.present) {
      map['correction_reason'] = Variable<String>(correctionReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('imageId: $imageId, ')
          ..write('boundingBoxX: $boundingBoxX, ')
          ..write('boundingBoxY: $boundingBoxY, ')
          ..write('boundingBoxW: $boundingBoxW, ')
          ..write('boundingBoxH: $boundingBoxH, ')
          ..write('label: $label, ')
          ..write('confidence: $confidence, ')
          ..write('isManualCorrection: $isManualCorrection, ')
          ..write('correctionReason: $correctionReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatasetExportsTable extends DatasetExports
    with TableInfo<$DatasetExportsTable, DatasetExport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatasetExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exportPathMeta =
      const VerificationMeta('exportPath');
  @override
  late final GeneratedColumn<String> exportPath = GeneratedColumn<String>(
      'export_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _totalImagesMeta =
      const VerificationMeta('totalImages');
  @override
  late final GeneratedColumn<int> totalImages = GeneratedColumn<int>(
      'total_images', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manifestJsonMeta =
      const VerificationMeta('manifestJson');
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
      'manifest_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, exportPath, format, timestamp, status, totalImages, manifestJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dataset_exports';
  @override
  VerificationContext validateIntegrity(Insertable<DatasetExport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('export_path')) {
      context.handle(
          _exportPathMeta,
          exportPath.isAcceptableOrUnknown(
              data['export_path']!, _exportPathMeta));
    } else if (isInserting) {
      context.missing(_exportPathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('total_images')) {
      context.handle(
          _totalImagesMeta,
          totalImages.isAcceptableOrUnknown(
              data['total_images']!, _totalImagesMeta));
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
          _manifestJsonMeta,
          manifestJson.isAcceptableOrUnknown(
              data['manifest_json']!, _manifestJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatasetExport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatasetExport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      exportPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}export_path'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalImages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_images'])!,
      manifestJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manifest_json']),
    );
  }

  @override
  $DatasetExportsTable createAlias(String alias) {
    return $DatasetExportsTable(attachedDatabase, alias);
  }
}

class DatasetExport extends DataClass implements Insertable<DatasetExport> {
  final String id;
  final String exportPath;
  final String format;
  final DateTime timestamp;
  final String status;
  final int totalImages;
  final String? manifestJson;
  const DatasetExport(
      {required this.id,
      required this.exportPath,
      required this.format,
      required this.timestamp,
      required this.status,
      required this.totalImages,
      this.manifestJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['export_path'] = Variable<String>(exportPath);
    map['format'] = Variable<String>(format);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['status'] = Variable<String>(status);
    map['total_images'] = Variable<int>(totalImages);
    if (!nullToAbsent || manifestJson != null) {
      map['manifest_json'] = Variable<String>(manifestJson);
    }
    return map;
  }

  DatasetExportsCompanion toCompanion(bool nullToAbsent) {
    return DatasetExportsCompanion(
      id: Value(id),
      exportPath: Value(exportPath),
      format: Value(format),
      timestamp: Value(timestamp),
      status: Value(status),
      totalImages: Value(totalImages),
      manifestJson: manifestJson == null && nullToAbsent
          ? const Value.absent()
          : Value(manifestJson),
    );
  }

  factory DatasetExport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatasetExport(
      id: serializer.fromJson<String>(json['id']),
      exportPath: serializer.fromJson<String>(json['exportPath']),
      format: serializer.fromJson<String>(json['format']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      totalImages: serializer.fromJson<int>(json['totalImages']),
      manifestJson: serializer.fromJson<String?>(json['manifestJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exportPath': serializer.toJson<String>(exportPath),
      'format': serializer.toJson<String>(format),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'status': serializer.toJson<String>(status),
      'totalImages': serializer.toJson<int>(totalImages),
      'manifestJson': serializer.toJson<String?>(manifestJson),
    };
  }

  DatasetExport copyWith(
          {String? id,
          String? exportPath,
          String? format,
          DateTime? timestamp,
          String? status,
          int? totalImages,
          Value<String?> manifestJson = const Value.absent()}) =>
      DatasetExport(
        id: id ?? this.id,
        exportPath: exportPath ?? this.exportPath,
        format: format ?? this.format,
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
        totalImages: totalImages ?? this.totalImages,
        manifestJson:
            manifestJson.present ? manifestJson.value : this.manifestJson,
      );
  DatasetExport copyWithCompanion(DatasetExportsCompanion data) {
    return DatasetExport(
      id: data.id.present ? data.id.value : this.id,
      exportPath:
          data.exportPath.present ? data.exportPath.value : this.exportPath,
      format: data.format.present ? data.format.value : this.format,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
      totalImages:
          data.totalImages.present ? data.totalImages.value : this.totalImages,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatasetExport(')
          ..write('id: $id, ')
          ..write('exportPath: $exportPath, ')
          ..write('format: $format, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('totalImages: $totalImages, ')
          ..write('manifestJson: $manifestJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, exportPath, format, timestamp, status, totalImages, manifestJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatasetExport &&
          other.id == this.id &&
          other.exportPath == this.exportPath &&
          other.format == this.format &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.totalImages == this.totalImages &&
          other.manifestJson == this.manifestJson);
}

class DatasetExportsCompanion extends UpdateCompanion<DatasetExport> {
  final Value<String> id;
  final Value<String> exportPath;
  final Value<String> format;
  final Value<DateTime> timestamp;
  final Value<String> status;
  final Value<int> totalImages;
  final Value<String?> manifestJson;
  final Value<int> rowid;
  const DatasetExportsCompanion({
    this.id = const Value.absent(),
    this.exportPath = const Value.absent(),
    this.format = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.totalImages = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatasetExportsCompanion.insert({
    required String id,
    required String exportPath,
    required String format,
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.totalImages = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        exportPath = Value(exportPath),
        format = Value(format);
  static Insertable<DatasetExport> custom({
    Expression<String>? id,
    Expression<String>? exportPath,
    Expression<String>? format,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
    Expression<int>? totalImages,
    Expression<String>? manifestJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exportPath != null) 'export_path': exportPath,
      if (format != null) 'format': format,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (totalImages != null) 'total_images': totalImages,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatasetExportsCompanion copyWith(
      {Value<String>? id,
      Value<String>? exportPath,
      Value<String>? format,
      Value<DateTime>? timestamp,
      Value<String>? status,
      Value<int>? totalImages,
      Value<String?>? manifestJson,
      Value<int>? rowid}) {
    return DatasetExportsCompanion(
      id: id ?? this.id,
      exportPath: exportPath ?? this.exportPath,
      format: format ?? this.format,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      totalImages: totalImages ?? this.totalImages,
      manifestJson: manifestJson ?? this.manifestJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exportPath.present) {
      map['export_path'] = Variable<String>(exportPath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalImages.present) {
      map['total_images'] = Variable<int>(totalImages.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatasetExportsCompanion(')
          ..write('id: $id, ')
          ..write('exportPath: $exportPath, ')
          ..write('format: $format, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('totalImages: $totalImages, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelHistoryTable extends ModelHistory
    with TableInfo<$ModelHistoryTable, ModelHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trainingDateMeta =
      const VerificationMeta('trainingDate');
  @override
  late final GeneratedColumn<DateTime> trainingDate = GeneratedColumn<DateTime>(
      'training_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _imagesUsedMeta =
      const VerificationMeta('imagesUsed');
  @override
  late final GeneratedColumn<int> imagesUsed = GeneratedColumn<int>(
      'images_used', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _precisionMeta =
      const VerificationMeta('precision');
  @override
  late final GeneratedColumn<double> precision = GeneratedColumn<double>(
      'precision', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _recallMeta = const VerificationMeta('recall');
  @override
  late final GeneratedColumn<double> recall = GeneratedColumn<double>(
      'recall', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _mAPMeta = const VerificationMeta('mAP');
  @override
  late final GeneratedColumn<double> mAP = GeneratedColumn<double>(
      'm_a_p', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deploymentDateMeta =
      const VerificationMeta('deploymentDate');
  @override
  late final GeneratedColumn<DateTime> deploymentDate =
      GeneratedColumn<DateTime>('deployment_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        modelName,
        version,
        trainingDate,
        imagesUsed,
        precision,
        recall,
        mAP,
        deploymentDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_history';
  @override
  VerificationContext validateIntegrity(Insertable<ModelHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('training_date')) {
      context.handle(
          _trainingDateMeta,
          trainingDate.isAcceptableOrUnknown(
              data['training_date']!, _trainingDateMeta));
    } else if (isInserting) {
      context.missing(_trainingDateMeta);
    }
    if (data.containsKey('images_used')) {
      context.handle(
          _imagesUsedMeta,
          imagesUsed.isAcceptableOrUnknown(
              data['images_used']!, _imagesUsedMeta));
    } else if (isInserting) {
      context.missing(_imagesUsedMeta);
    }
    if (data.containsKey('precision')) {
      context.handle(_precisionMeta,
          precision.isAcceptableOrUnknown(data['precision']!, _precisionMeta));
    }
    if (data.containsKey('recall')) {
      context.handle(_recallMeta,
          recall.isAcceptableOrUnknown(data['recall']!, _recallMeta));
    }
    if (data.containsKey('m_a_p')) {
      context.handle(
          _mAPMeta, mAP.isAcceptableOrUnknown(data['m_a_p']!, _mAPMeta));
    }
    if (data.containsKey('deployment_date')) {
      context.handle(
          _deploymentDateMeta,
          deploymentDate.isAcceptableOrUnknown(
              data['deployment_date']!, _deploymentDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      trainingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}training_date'])!,
      imagesUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}images_used'])!,
      precision: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precision']),
      recall: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}recall']),
      mAP: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}m_a_p']),
      deploymentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}deployment_date']),
    );
  }

  @override
  $ModelHistoryTable createAlias(String alias) {
    return $ModelHistoryTable(attachedDatabase, alias);
  }
}

class ModelHistoryData extends DataClass
    implements Insertable<ModelHistoryData> {
  final String id;
  final String modelName;
  final String version;
  final DateTime trainingDate;
  final int imagesUsed;
  final double? precision;
  final double? recall;
  final double? mAP;
  final DateTime? deploymentDate;
  const ModelHistoryData(
      {required this.id,
      required this.modelName,
      required this.version,
      required this.trainingDate,
      required this.imagesUsed,
      this.precision,
      this.recall,
      this.mAP,
      this.deploymentDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['model_name'] = Variable<String>(modelName);
    map['version'] = Variable<String>(version);
    map['training_date'] = Variable<DateTime>(trainingDate);
    map['images_used'] = Variable<int>(imagesUsed);
    if (!nullToAbsent || precision != null) {
      map['precision'] = Variable<double>(precision);
    }
    if (!nullToAbsent || recall != null) {
      map['recall'] = Variable<double>(recall);
    }
    if (!nullToAbsent || mAP != null) {
      map['m_a_p'] = Variable<double>(mAP);
    }
    if (!nullToAbsent || deploymentDate != null) {
      map['deployment_date'] = Variable<DateTime>(deploymentDate);
    }
    return map;
  }

  ModelHistoryCompanion toCompanion(bool nullToAbsent) {
    return ModelHistoryCompanion(
      id: Value(id),
      modelName: Value(modelName),
      version: Value(version),
      trainingDate: Value(trainingDate),
      imagesUsed: Value(imagesUsed),
      precision: precision == null && nullToAbsent
          ? const Value.absent()
          : Value(precision),
      recall:
          recall == null && nullToAbsent ? const Value.absent() : Value(recall),
      mAP: mAP == null && nullToAbsent ? const Value.absent() : Value(mAP),
      deploymentDate: deploymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deploymentDate),
    );
  }

  factory ModelHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelHistoryData(
      id: serializer.fromJson<String>(json['id']),
      modelName: serializer.fromJson<String>(json['modelName']),
      version: serializer.fromJson<String>(json['version']),
      trainingDate: serializer.fromJson<DateTime>(json['trainingDate']),
      imagesUsed: serializer.fromJson<int>(json['imagesUsed']),
      precision: serializer.fromJson<double?>(json['precision']),
      recall: serializer.fromJson<double?>(json['recall']),
      mAP: serializer.fromJson<double?>(json['mAP']),
      deploymentDate: serializer.fromJson<DateTime?>(json['deploymentDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modelName': serializer.toJson<String>(modelName),
      'version': serializer.toJson<String>(version),
      'trainingDate': serializer.toJson<DateTime>(trainingDate),
      'imagesUsed': serializer.toJson<int>(imagesUsed),
      'precision': serializer.toJson<double?>(precision),
      'recall': serializer.toJson<double?>(recall),
      'mAP': serializer.toJson<double?>(mAP),
      'deploymentDate': serializer.toJson<DateTime?>(deploymentDate),
    };
  }

  ModelHistoryData copyWith(
          {String? id,
          String? modelName,
          String? version,
          DateTime? trainingDate,
          int? imagesUsed,
          Value<double?> precision = const Value.absent(),
          Value<double?> recall = const Value.absent(),
          Value<double?> mAP = const Value.absent(),
          Value<DateTime?> deploymentDate = const Value.absent()}) =>
      ModelHistoryData(
        id: id ?? this.id,
        modelName: modelName ?? this.modelName,
        version: version ?? this.version,
        trainingDate: trainingDate ?? this.trainingDate,
        imagesUsed: imagesUsed ?? this.imagesUsed,
        precision: precision.present ? precision.value : this.precision,
        recall: recall.present ? recall.value : this.recall,
        mAP: mAP.present ? mAP.value : this.mAP,
        deploymentDate:
            deploymentDate.present ? deploymentDate.value : this.deploymentDate,
      );
  ModelHistoryData copyWithCompanion(ModelHistoryCompanion data) {
    return ModelHistoryData(
      id: data.id.present ? data.id.value : this.id,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      version: data.version.present ? data.version.value : this.version,
      trainingDate: data.trainingDate.present
          ? data.trainingDate.value
          : this.trainingDate,
      imagesUsed:
          data.imagesUsed.present ? data.imagesUsed.value : this.imagesUsed,
      precision: data.precision.present ? data.precision.value : this.precision,
      recall: data.recall.present ? data.recall.value : this.recall,
      mAP: data.mAP.present ? data.mAP.value : this.mAP,
      deploymentDate: data.deploymentDate.present
          ? data.deploymentDate.value
          : this.deploymentDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelHistoryData(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('version: $version, ')
          ..write('trainingDate: $trainingDate, ')
          ..write('imagesUsed: $imagesUsed, ')
          ..write('precision: $precision, ')
          ..write('recall: $recall, ')
          ..write('mAP: $mAP, ')
          ..write('deploymentDate: $deploymentDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, modelName, version, trainingDate,
      imagesUsed, precision, recall, mAP, deploymentDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelHistoryData &&
          other.id == this.id &&
          other.modelName == this.modelName &&
          other.version == this.version &&
          other.trainingDate == this.trainingDate &&
          other.imagesUsed == this.imagesUsed &&
          other.precision == this.precision &&
          other.recall == this.recall &&
          other.mAP == this.mAP &&
          other.deploymentDate == this.deploymentDate);
}

class ModelHistoryCompanion extends UpdateCompanion<ModelHistoryData> {
  final Value<String> id;
  final Value<String> modelName;
  final Value<String> version;
  final Value<DateTime> trainingDate;
  final Value<int> imagesUsed;
  final Value<double?> precision;
  final Value<double?> recall;
  final Value<double?> mAP;
  final Value<DateTime?> deploymentDate;
  final Value<int> rowid;
  const ModelHistoryCompanion({
    this.id = const Value.absent(),
    this.modelName = const Value.absent(),
    this.version = const Value.absent(),
    this.trainingDate = const Value.absent(),
    this.imagesUsed = const Value.absent(),
    this.precision = const Value.absent(),
    this.recall = const Value.absent(),
    this.mAP = const Value.absent(),
    this.deploymentDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelHistoryCompanion.insert({
    required String id,
    required String modelName,
    required String version,
    required DateTime trainingDate,
    required int imagesUsed,
    this.precision = const Value.absent(),
    this.recall = const Value.absent(),
    this.mAP = const Value.absent(),
    this.deploymentDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        modelName = Value(modelName),
        version = Value(version),
        trainingDate = Value(trainingDate),
        imagesUsed = Value(imagesUsed);
  static Insertable<ModelHistoryData> custom({
    Expression<String>? id,
    Expression<String>? modelName,
    Expression<String>? version,
    Expression<DateTime>? trainingDate,
    Expression<int>? imagesUsed,
    Expression<double>? precision,
    Expression<double>? recall,
    Expression<double>? mAP,
    Expression<DateTime>? deploymentDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelName != null) 'model_name': modelName,
      if (version != null) 'version': version,
      if (trainingDate != null) 'training_date': trainingDate,
      if (imagesUsed != null) 'images_used': imagesUsed,
      if (precision != null) 'precision': precision,
      if (recall != null) 'recall': recall,
      if (mAP != null) 'm_a_p': mAP,
      if (deploymentDate != null) 'deployment_date': deploymentDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelHistoryCompanion copyWith(
      {Value<String>? id,
      Value<String>? modelName,
      Value<String>? version,
      Value<DateTime>? trainingDate,
      Value<int>? imagesUsed,
      Value<double?>? precision,
      Value<double?>? recall,
      Value<double?>? mAP,
      Value<DateTime?>? deploymentDate,
      Value<int>? rowid}) {
    return ModelHistoryCompanion(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      version: version ?? this.version,
      trainingDate: trainingDate ?? this.trainingDate,
      imagesUsed: imagesUsed ?? this.imagesUsed,
      precision: precision ?? this.precision,
      recall: recall ?? this.recall,
      mAP: mAP ?? this.mAP,
      deploymentDate: deploymentDate ?? this.deploymentDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (trainingDate.present) {
      map['training_date'] = Variable<DateTime>(trainingDate.value);
    }
    if (imagesUsed.present) {
      map['images_used'] = Variable<int>(imagesUsed.value);
    }
    if (precision.present) {
      map['precision'] = Variable<double>(precision.value);
    }
    if (recall.present) {
      map['recall'] = Variable<double>(recall.value);
    }
    if (mAP.present) {
      map['m_a_p'] = Variable<double>(mAP.value);
    }
    if (deploymentDate.present) {
      map['deployment_date'] = Variable<DateTime>(deploymentDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelHistoryCompanion(')
          ..write('id: $id, ')
          ..write('modelName: $modelName, ')
          ..write('version: $version, ')
          ..write('trainingDate: $trainingDate, ')
          ..write('imagesUsed: $imagesUsed, ')
          ..write('precision: $precision, ')
          ..write('recall: $recall, ')
          ..write('mAP: $mAP, ')
          ..write('deploymentDate: $deploymentDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceSessionsTable extends DeviceSessions
    with TableInfo<$DeviceSessionsTable, DeviceSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceNameMeta =
      const VerificationMeta('deviceName');
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
      'device_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _osVersionMeta =
      const VerificationMeta('osVersion');
  @override
  late final GeneratedColumn<String> osVersion = GeneratedColumn<String>(
      'os_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncMeta =
      const VerificationMeta('lastSync');
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
      'last_sync', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        deviceName,
        deviceModel,
        osVersion,
        lastSync,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_name')) {
      context.handle(
          _deviceNameMeta,
          deviceName.isAcceptableOrUnknown(
              data['device_name']!, _deviceNameMeta));
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    } else if (isInserting) {
      context.missing(_deviceModelMeta);
    }
    if (data.containsKey('os_version')) {
      context.handle(_osVersionMeta,
          osVersion.isAcceptableOrUnknown(data['os_version']!, _osVersionMeta));
    } else if (isInserting) {
      context.missing(_osVersionMeta);
    }
    if (data.containsKey('last_sync')) {
      context.handle(_lastSyncMeta,
          lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_name'])!,
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model'])!,
      osVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}os_version'])!,
      lastSync: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $DeviceSessionsTable createAlias(String alias) {
    return $DeviceSessionsTable(attachedDatabase, alias);
  }
}

class DeviceSession extends DataClass implements Insertable<DeviceSession> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String deviceName;
  final String deviceModel;
  final String osVersion;
  final DateTime lastSync;
  final bool isActive;
  const DeviceSession(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.deviceName,
      required this.deviceModel,
      required this.osVersion,
      required this.lastSync,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_name'] = Variable<String>(deviceName);
    map['device_model'] = Variable<String>(deviceModel);
    map['os_version'] = Variable<String>(osVersion);
    map['last_sync'] = Variable<DateTime>(lastSync);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DeviceSessionsCompanion toCompanion(bool nullToAbsent) {
    return DeviceSessionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deviceName: Value(deviceName),
      deviceModel: Value(deviceModel),
      osVersion: Value(osVersion),
      lastSync: Value(lastSync),
      isActive: Value(isActive),
    );
  }

  factory DeviceSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceSession(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      deviceModel: serializer.fromJson<String>(json['deviceModel']),
      osVersion: serializer.fromJson<String>(json['osVersion']),
      lastSync: serializer.fromJson<DateTime>(json['lastSync']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceName': serializer.toJson<String>(deviceName),
      'deviceModel': serializer.toJson<String>(deviceModel),
      'osVersion': serializer.toJson<String>(osVersion),
      'lastSync': serializer.toJson<DateTime>(lastSync),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DeviceSession copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? deviceName,
          String? deviceModel,
          String? osVersion,
          DateTime? lastSync,
          bool? isActive}) =>
      DeviceSession(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceName: deviceName ?? this.deviceName,
        deviceModel: deviceModel ?? this.deviceModel,
        osVersion: osVersion ?? this.osVersion,
        lastSync: lastSync ?? this.lastSync,
        isActive: isActive ?? this.isActive,
      );
  DeviceSession copyWithCompanion(DeviceSessionsCompanion data) {
    return DeviceSession(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceName:
          data.deviceName.present ? data.deviceName.value : this.deviceName,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      osVersion: data.osVersion.present ? data.osVersion.value : this.osVersion,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSession(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('osVersion: $osVersion, ')
          ..write('lastSync: $lastSync, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, isDeleted, version,
      syncStatus, deviceName, deviceModel, osVersion, lastSync, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceSession &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deviceName == this.deviceName &&
          other.deviceModel == this.deviceModel &&
          other.osVersion == this.osVersion &&
          other.lastSync == this.lastSync &&
          other.isActive == this.isActive);
}

class DeviceSessionsCompanion extends UpdateCompanion<DeviceSession> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> deviceName;
  final Value<String> deviceModel;
  final Value<String> osVersion;
  final Value<DateTime> lastSync;
  final Value<bool> isActive;
  final Value<int> rowid;
  const DeviceSessionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.osVersion = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceSessionsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceName,
    required String deviceModel,
    required String osVersion,
    this.lastSync = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceName = Value(deviceName),
        deviceModel = Value(deviceModel),
        osVersion = Value(osVersion);
  static Insertable<DeviceSession> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? deviceName,
    Expression<String>? deviceModel,
    Expression<String>? osVersion,
    Expression<DateTime>? lastSync,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceName != null) 'device_name': deviceName,
      if (deviceModel != null) 'device_model': deviceModel,
      if (osVersion != null) 'os_version': osVersion,
      if (lastSync != null) 'last_sync': lastSync,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceSessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? deviceName,
      Value<String>? deviceModel,
      Value<String>? osVersion,
      Value<DateTime>? lastSync,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return DeviceSessionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceName: deviceName ?? this.deviceName,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      lastSync: lastSync ?? this.lastSync,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (osVersion.present) {
      map['os_version'] = Variable<String>(osVersion.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSessionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceName: $deviceName, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('osVersion: $osVersion, ')
          ..write('lastSync: $lastSync, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportExportsTable extends ReportExports
    with TableInfo<$ReportExportsTable, ReportExport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _reportTypeMeta =
      const VerificationMeta('reportType');
  @override
  late final GeneratedColumn<String> reportType = GeneratedColumn<String>(
      'report_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exportTypeMeta =
      const VerificationMeta('exportType');
  @override
  late final GeneratedColumn<String> exportType = GeneratedColumn<String>(
      'export_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exportedAtMeta =
      const VerificationMeta('exportedAt');
  @override
  late final GeneratedColumn<DateTime> exportedAt = GeneratedColumn<DateTime>(
      'exported_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        reportType,
        exportType,
        userId,
        exportedAt,
        status,
        filePath,
        details
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_exports';
  @override
  VerificationContext validateIntegrity(Insertable<ReportExport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('report_type')) {
      context.handle(
          _reportTypeMeta,
          reportType.isAcceptableOrUnknown(
              data['report_type']!, _reportTypeMeta));
    } else if (isInserting) {
      context.missing(_reportTypeMeta);
    }
    if (data.containsKey('export_type')) {
      context.handle(
          _exportTypeMeta,
          exportType.isAcceptableOrUnknown(
              data['export_type']!, _exportTypeMeta));
    } else if (isInserting) {
      context.missing(_exportTypeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exported_at')) {
      context.handle(
          _exportedAtMeta,
          exportedAt.isAcceptableOrUnknown(
              data['exported_at']!, _exportedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportExport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportExport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      reportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_type'])!,
      exportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}export_type'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      exportedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}exported_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path']),
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
    );
  }

  @override
  $ReportExportsTable createAlias(String alias) {
    return $ReportExportsTable(attachedDatabase, alias);
  }
}

class ReportExport extends DataClass implements Insertable<ReportExport> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String reportType;
  final String exportType;
  final String userId;
  final DateTime exportedAt;
  final String status;
  final String? filePath;
  final String? details;
  const ReportExport(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.reportType,
      required this.exportType,
      required this.userId,
      required this.exportedAt,
      required this.status,
      this.filePath,
      this.details});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['report_type'] = Variable<String>(reportType);
    map['export_type'] = Variable<String>(exportType);
    map['user_id'] = Variable<String>(userId);
    map['exported_at'] = Variable<DateTime>(exportedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  ReportExportsCompanion toCompanion(bool nullToAbsent) {
    return ReportExportsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      reportType: Value(reportType),
      exportType: Value(exportType),
      userId: Value(userId),
      exportedAt: Value(exportedAt),
      status: Value(status),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory ReportExport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportExport(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      reportType: serializer.fromJson<String>(json['reportType']),
      exportType: serializer.fromJson<String>(json['exportType']),
      userId: serializer.fromJson<String>(json['userId']),
      exportedAt: serializer.fromJson<DateTime>(json['exportedAt']),
      status: serializer.fromJson<String>(json['status']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'reportType': serializer.toJson<String>(reportType),
      'exportType': serializer.toJson<String>(exportType),
      'userId': serializer.toJson<String>(userId),
      'exportedAt': serializer.toJson<DateTime>(exportedAt),
      'status': serializer.toJson<String>(status),
      'filePath': serializer.toJson<String?>(filePath),
      'details': serializer.toJson<String?>(details),
    };
  }

  ReportExport copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? reportType,
          String? exportType,
          String? userId,
          DateTime? exportedAt,
          String? status,
          Value<String?> filePath = const Value.absent(),
          Value<String?> details = const Value.absent()}) =>
      ReportExport(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        reportType: reportType ?? this.reportType,
        exportType: exportType ?? this.exportType,
        userId: userId ?? this.userId,
        exportedAt: exportedAt ?? this.exportedAt,
        status: status ?? this.status,
        filePath: filePath.present ? filePath.value : this.filePath,
        details: details.present ? details.value : this.details,
      );
  ReportExport copyWithCompanion(ReportExportsCompanion data) {
    return ReportExport(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      reportType:
          data.reportType.present ? data.reportType.value : this.reportType,
      exportType:
          data.exportType.present ? data.exportType.value : this.exportType,
      userId: data.userId.present ? data.userId.value : this.userId,
      exportedAt:
          data.exportedAt.present ? data.exportedAt.value : this.exportedAt,
      status: data.status.present ? data.status.value : this.status,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportExport(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('reportType: $reportType, ')
          ..write('exportType: $exportType, ')
          ..write('userId: $userId, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      reportType,
      exportType,
      userId,
      exportedAt,
      status,
      filePath,
      details);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportExport &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.reportType == this.reportType &&
          other.exportType == this.exportType &&
          other.userId == this.userId &&
          other.exportedAt == this.exportedAt &&
          other.status == this.status &&
          other.filePath == this.filePath &&
          other.details == this.details);
}

class ReportExportsCompanion extends UpdateCompanion<ReportExport> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> reportType;
  final Value<String> exportType;
  final Value<String> userId;
  final Value<DateTime> exportedAt;
  final Value<String> status;
  final Value<String?> filePath;
  final Value<String?> details;
  final Value<int> rowid;
  const ReportExportsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.reportType = const Value.absent(),
    this.exportType = const Value.absent(),
    this.userId = const Value.absent(),
    this.exportedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportExportsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String reportType,
    required String exportType,
    required String userId,
    this.exportedAt = const Value.absent(),
    required String status,
    this.filePath = const Value.absent(),
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        reportType = Value(reportType),
        exportType = Value(exportType),
        userId = Value(userId),
        status = Value(status);
  static Insertable<ReportExport> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? reportType,
    Expression<String>? exportType,
    Expression<String>? userId,
    Expression<DateTime>? exportedAt,
    Expression<String>? status,
    Expression<String>? filePath,
    Expression<String>? details,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (reportType != null) 'report_type': reportType,
      if (exportType != null) 'export_type': exportType,
      if (userId != null) 'user_id': userId,
      if (exportedAt != null) 'exported_at': exportedAt,
      if (status != null) 'status': status,
      if (filePath != null) 'file_path': filePath,
      if (details != null) 'details': details,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportExportsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? reportType,
      Value<String>? exportType,
      Value<String>? userId,
      Value<DateTime>? exportedAt,
      Value<String>? status,
      Value<String?>? filePath,
      Value<String?>? details,
      Value<int>? rowid}) {
    return ReportExportsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      reportType: reportType ?? this.reportType,
      exportType: exportType ?? this.exportType,
      userId: userId ?? this.userId,
      exportedAt: exportedAt ?? this.exportedAt,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      details: details ?? this.details,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (reportType.present) {
      map['report_type'] = Variable<String>(reportType.value);
    }
    if (exportType.present) {
      map['export_type'] = Variable<String>(exportType.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<DateTime>(exportedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportExportsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('reportType: $reportType, ')
          ..write('exportType: $exportType, ')
          ..write('userId: $userId, ')
          ..write('exportedAt: $exportedAt, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('details: $details, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
      'employee_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _warehouseIdMeta =
      const VerificationMeta('warehouseId');
  @override
  late final GeneratedColumn<String> warehouseId = GeneratedColumn<String>(
      'warehouse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _failedLoginAttemptsMeta =
      const VerificationMeta('failedLoginAttempts');
  @override
  late final GeneratedColumn<int> failedLoginAttempts = GeneratedColumn<int>(
      'failed_login_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lockedUntilMeta =
      const VerificationMeta('lockedUntil');
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
      'locked_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        employeeId,
        name,
        role,
        warehouseId,
        token,
        isActive,
        failedLoginAttempts,
        lockedUntil
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('warehouse_id')) {
      context.handle(
          _warehouseIdMeta,
          warehouseId.isAcceptableOrUnknown(
              data['warehouse_id']!, _warehouseIdMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('failed_login_attempts')) {
      context.handle(
          _failedLoginAttemptsMeta,
          failedLoginAttempts.isAcceptableOrUnknown(
              data['failed_login_attempts']!, _failedLoginAttemptsMeta));
    }
    if (data.containsKey('locked_until')) {
      context.handle(
          _lockedUntilMeta,
          lockedUntil.isAcceptableOrUnknown(
              data['locked_until']!, _lockedUntilMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}employee_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      failedLoginAttempts: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}failed_login_attempts'])!,
      lockedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}locked_until']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String employeeId;
  final String name;
  final String role;
  final String? warehouseId;
  final String? token;
  final bool isActive;
  final int failedLoginAttempts;
  final DateTime? lockedUntil;
  const User(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.employeeId,
      required this.name,
      required this.role,
      this.warehouseId,
      this.token,
      required this.isActive,
      required this.failedLoginAttempts,
      this.lockedUntil});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    map['employee_id'] = Variable<String>(employeeId);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['failed_login_attempts'] = Variable<int>(failedLoginAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      employeeId: Value(employeeId),
      name: Value(name),
      role: Value(role),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      token:
          token == null && nullToAbsent ? const Value.absent() : Value(token),
      isActive: Value(isActive),
      failedLoginAttempts: Value(failedLoginAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      token: serializer.fromJson<String?>(json['token']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      failedLoginAttempts:
          serializer.fromJson<int>(json['failedLoginAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'employeeId': serializer.toJson<String>(employeeId),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'token': serializer.toJson<String?>(token),
      'isActive': serializer.toJson<bool>(isActive),
      'failedLoginAttempts': serializer.toJson<int>(failedLoginAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
    };
  }

  User copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? employeeId,
          String? name,
          String? role,
          Value<String?> warehouseId = const Value.absent(),
          Value<String?> token = const Value.absent(),
          bool? isActive,
          int? failedLoginAttempts,
          Value<DateTime?> lockedUntil = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        employeeId: employeeId ?? this.employeeId,
        name: name ?? this.name,
        role: role ?? this.role,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        token: token.present ? token.value : this.token,
        isActive: isActive ?? this.isActive,
        failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
        lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      token: data.token.present ? data.token.value : this.token,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      failedLoginAttempts: data.failedLoginAttempts.present
          ? data.failedLoginAttempts.value
          : this.failedLoginAttempts,
      lockedUntil:
          data.lockedUntil.present ? data.lockedUntil.value : this.lockedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('employeeId: $employeeId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('token: $token, ')
          ..write('isActive: $isActive, ')
          ..write('failedLoginAttempts: $failedLoginAttempts, ')
          ..write('lockedUntil: $lockedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      version,
      syncStatus,
      employeeId,
      name,
      role,
      warehouseId,
      token,
      isActive,
      failedLoginAttempts,
      lockedUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.employeeId == this.employeeId &&
          other.name == this.name &&
          other.role == this.role &&
          other.warehouseId == this.warehouseId &&
          other.token == this.token &&
          other.isActive == this.isActive &&
          other.failedLoginAttempts == this.failedLoginAttempts &&
          other.lockedUntil == this.lockedUntil);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> employeeId;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> warehouseId;
  final Value<String?> token;
  final Value<bool> isActive;
  final Value<int> failedLoginAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.token = const Value.absent(),
    this.isActive = const Value.absent(),
    this.failedLoginAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String employeeId,
    required String name,
    required String role,
    this.warehouseId = const Value.absent(),
    this.token = const Value.absent(),
    this.isActive = const Value.absent(),
    this.failedLoginAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        employeeId = Value(employeeId),
        name = Value(name),
        role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? employeeId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? warehouseId,
    Expression<String>? token,
    Expression<bool>? isActive,
    Expression<int>? failedLoginAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (employeeId != null) 'employee_id': employeeId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (token != null) 'token': token,
      if (isActive != null) 'is_active': isActive,
      if (failedLoginAttempts != null)
        'failed_login_attempts': failedLoginAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<int>? version,
      Value<String>? syncStatus,
      Value<String>? employeeId,
      Value<String>? name,
      Value<String>? role,
      Value<String?>? warehouseId,
      Value<String?>? token,
      Value<bool>? isActive,
      Value<int>? failedLoginAttempts,
      Value<DateTime?>? lockedUntil,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      role: role ?? this.role,
      warehouseId: warehouseId ?? this.warehouseId,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (failedLoginAttempts.present) {
      map['failed_login_attempts'] = Variable<int>(failedLoginAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('employeeId: $employeeId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('token: $token, ')
          ..write('isActive: $isActive, ')
          ..write('failedLoginAttempts: $failedLoginAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WarehousesTable warehouses = $WarehousesTable(this);
  late final $WagonsTable wagons = $WagonsTable(this);
  late final $TrucksTable trucks = $TrucksTable(this);
  late final $LayersTable layers = $LayersTable(this);
  late final $DetectionsTable detections = $DetectionsTable(this);
  late final $DigitalRegistersTable digitalRegisters =
      $DigitalRegistersTable(this);
  late final $LoadingSessionsTable loadingSessions =
      $LoadingSessionsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  late final $DatasetImagesTable datasetImages = $DatasetImagesTable(this);
  late final $ImageMetadataTable imageMetadata = $ImageMetadataTable(this);
  late final $ImageQualityTable imageQuality = $ImageQualityTable(this);
  late final $AnnotationsTable annotations = $AnnotationsTable(this);
  late final $DatasetExportsTable datasetExports = $DatasetExportsTable(this);
  late final $ModelHistoryTable modelHistory = $ModelHistoryTable(this);
  late final $DeviceSessionsTable deviceSessions = $DeviceSessionsTable(this);
  late final $ReportExportsTable reportExports = $ReportExportsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        warehouses,
        wagons,
        trucks,
        layers,
        detections,
        digitalRegisters,
        loadingSessions,
        auditLogs,
        syncQueues,
        datasetImages,
        imageMetadata,
        imageQuality,
        annotations,
        datasetExports,
        modelHistory,
        deviceSessions,
        reportExports,
        users,
        settings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('dataset_images',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('image_metadata', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('dataset_images',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('image_quality', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('dataset_images',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('annotations', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$WarehousesTableCreateCompanionBuilder = WarehousesCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String name,
  required String location,
  Value<int> rowid,
});
typedef $$WarehousesTableUpdateCompanionBuilder = WarehousesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> name,
  Value<String> location,
  Value<int> rowid,
});

final class $$WarehousesTableReferences
    extends BaseReferences<_$AppDatabase, $WarehousesTable, Warehouse> {
  $$WarehousesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WagonsTable, List<Wagon>> _wagonsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.wagons,
          aliasName:
              $_aliasNameGenerator(db.warehouses.id, db.wagons.warehouseId));

  $$WagonsTableProcessedTableManager get wagonsRefs {
    final manager = $$WagonsTableTableManager($_db, $_db.wagons)
        .filter((f) => f.warehouseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wagonsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoadingSessionsTable, List<LoadingSession>>
      _loadingSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.loadingSessions,
              aliasName: $_aliasNameGenerator(
                  db.warehouses.id, db.loadingSessions.warehouseId));

  $$LoadingSessionsTableProcessedTableManager get loadingSessionsRefs {
    final manager = $$LoadingSessionsTableTableManager(
            $_db, $_db.loadingSessions)
        .filter((f) => f.warehouseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loadingSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WarehousesTableFilterComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  Expression<bool> wagonsRefs(
      Expression<bool> Function($$WagonsTableFilterComposer f) f) {
    final $$WagonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableFilterComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loadingSessionsRefs(
      Expression<bool> Function($$LoadingSessionsTableFilterComposer f) f) {
    final $$LoadingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loadingSessions,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoadingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.loadingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WarehousesTableOrderingComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));
}

class $$WarehousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarehousesTable> {
  $$WarehousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  Expression<T> wagonsRefs<T extends Object>(
      Expression<T> Function($$WagonsTableAnnotationComposer a) f) {
    final $$WagonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableAnnotationComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loadingSessionsRefs<T extends Object>(
      Expression<T> Function($$LoadingSessionsTableAnnotationComposer a) f) {
    final $$LoadingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loadingSessions,
        getReferencedColumn: (t) => t.warehouseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoadingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.loadingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WarehousesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WarehousesTable,
    Warehouse,
    $$WarehousesTableFilterComposer,
    $$WarehousesTableOrderingComposer,
    $$WarehousesTableAnnotationComposer,
    $$WarehousesTableCreateCompanionBuilder,
    $$WarehousesTableUpdateCompanionBuilder,
    (Warehouse, $$WarehousesTableReferences),
    Warehouse,
    PrefetchHooks Function({bool wagonsRefs, bool loadingSessionsRefs})> {
  $$WarehousesTableTableManager(_$AppDatabase db, $WarehousesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarehousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarehousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarehousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehousesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            name: name,
            location: location,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String name,
            required String location,
            Value<int> rowid = const Value.absent(),
          }) =>
              WarehousesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            name: name,
            location: location,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WarehousesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {wagonsRefs = false, loadingSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (wagonsRefs) db.wagons,
                if (loadingSessionsRefs) db.loadingSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wagonsRefs)
                    await $_getPrefetchedData<Warehouse, $WarehousesTable,
                            Wagon>(
                        currentTable: table,
                        referencedTable:
                            $$WarehousesTableReferences._wagonsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WarehousesTableReferences(db, table, p0)
                                .wagonsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.warehouseId == item.id),
                        typedResults: items),
                  if (loadingSessionsRefs)
                    await $_getPrefetchedData<Warehouse, $WarehousesTable,
                            LoadingSession>(
                        currentTable: table,
                        referencedTable: $$WarehousesTableReferences
                            ._loadingSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WarehousesTableReferences(db, table, p0)
                                .loadingSessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.warehouseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WarehousesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WarehousesTable,
    Warehouse,
    $$WarehousesTableFilterComposer,
    $$WarehousesTableOrderingComposer,
    $$WarehousesTableAnnotationComposer,
    $$WarehousesTableCreateCompanionBuilder,
    $$WarehousesTableUpdateCompanionBuilder,
    (Warehouse, $$WarehousesTableReferences),
    Warehouse,
    PrefetchHooks Function({bool wagonsRefs, bool loadingSessionsRefs})>;
typedef $$WagonsTableCreateCompanionBuilder = WagonsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> warehouseId,
  required String wagonNumber,
  required String status,
  required int expectedTruckCount,
  Value<String?> origin,
  Value<String?> destination,
  Value<DateTime?> loadingDate,
  Value<String?> remarks,
  Value<String> itemManifestJson,
  Value<int> completedTruckCount,
  Value<int> rowid,
});
typedef $$WagonsTableUpdateCompanionBuilder = WagonsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> warehouseId,
  Value<String> wagonNumber,
  Value<String> status,
  Value<int> expectedTruckCount,
  Value<String?> origin,
  Value<String?> destination,
  Value<DateTime?> loadingDate,
  Value<String?> remarks,
  Value<String> itemManifestJson,
  Value<int> completedTruckCount,
  Value<int> rowid,
});

final class $$WagonsTableReferences
    extends BaseReferences<_$AppDatabase, $WagonsTable, Wagon> {
  $$WagonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WarehousesTable _warehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias(
          $_aliasNameGenerator(db.wagons.warehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get warehouseId {
    final $_column = $_itemColumn<String>('warehouse_id');
    if ($_column == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_warehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TrucksTable, List<Truck>> _trucksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trucks,
          aliasName: $_aliasNameGenerator(db.wagons.id, db.trucks.wagonId));

  $$TrucksTableProcessedTableManager get trucksRefs {
    final manager = $$TrucksTableTableManager($_db, $_db.trucks)
        .filter((f) => f.wagonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trucksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DigitalRegistersTable, List<DigitalRegister>>
      _digitalRegistersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.digitalRegisters,
              aliasName: $_aliasNameGenerator(
                  db.wagons.id, db.digitalRegisters.wagonId));

  $$DigitalRegistersTableProcessedTableManager get digitalRegistersRefs {
    final manager =
        $$DigitalRegistersTableTableManager($_db, $_db.digitalRegisters)
            .filter((f) => f.wagonId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_digitalRegistersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WagonsTableFilterComposer
    extends Composer<_$AppDatabase, $WagonsTable> {
  $$WagonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedTruckCount => $composableBuilder(
      column: $table.expectedTruckCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loadingDate => $composableBuilder(
      column: $table.loadingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemManifestJson => $composableBuilder(
      column: $table.itemManifestJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedTruckCount => $composableBuilder(
      column: $table.completedTruckCount,
      builder: (column) => ColumnFilters(column));

  $$WarehousesTableFilterComposer get warehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> trucksRefs(
      Expression<bool> Function($$TrucksTableFilterComposer f) f) {
    final $$TrucksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.wagonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableFilterComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> digitalRegistersRefs(
      Expression<bool> Function($$DigitalRegistersTableFilterComposer f) f) {
    final $$DigitalRegistersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.digitalRegisters,
        getReferencedColumn: (t) => t.wagonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DigitalRegistersTableFilterComposer(
              $db: $db,
              $table: $db.digitalRegisters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WagonsTableOrderingComposer
    extends Composer<_$AppDatabase, $WagonsTable> {
  $$WagonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedTruckCount => $composableBuilder(
      column: $table.expectedTruckCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loadingDate => $composableBuilder(
      column: $table.loadingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remarks => $composableBuilder(
      column: $table.remarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemManifestJson => $composableBuilder(
      column: $table.itemManifestJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedTruckCount => $composableBuilder(
      column: $table.completedTruckCount,
      builder: (column) => ColumnOrderings(column));

  $$WarehousesTableOrderingComposer get warehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WagonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WagonsTable> {
  $$WagonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get expectedTruckCount => $composableBuilder(
      column: $table.expectedTruckCount, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
      column: $table.destination, builder: (column) => column);

  GeneratedColumn<DateTime> get loadingDate => $composableBuilder(
      column: $table.loadingDate, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get itemManifestJson => $composableBuilder(
      column: $table.itemManifestJson, builder: (column) => column);

  GeneratedColumn<int> get completedTruckCount => $composableBuilder(
      column: $table.completedTruckCount, builder: (column) => column);

  $$WarehousesTableAnnotationComposer get warehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> trucksRefs<T extends Object>(
      Expression<T> Function($$TrucksTableAnnotationComposer a) f) {
    final $$TrucksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.wagonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableAnnotationComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> digitalRegistersRefs<T extends Object>(
      Expression<T> Function($$DigitalRegistersTableAnnotationComposer a) f) {
    final $$DigitalRegistersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.digitalRegisters,
        getReferencedColumn: (t) => t.wagonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DigitalRegistersTableAnnotationComposer(
              $db: $db,
              $table: $db.digitalRegisters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WagonsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WagonsTable,
    Wagon,
    $$WagonsTableFilterComposer,
    $$WagonsTableOrderingComposer,
    $$WagonsTableAnnotationComposer,
    $$WagonsTableCreateCompanionBuilder,
    $$WagonsTableUpdateCompanionBuilder,
    (Wagon, $$WagonsTableReferences),
    Wagon,
    PrefetchHooks Function(
        {bool warehouseId, bool trucksRefs, bool digitalRegistersRefs})> {
  $$WagonsTableTableManager(_$AppDatabase db, $WagonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WagonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WagonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WagonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String> wagonNumber = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> expectedTruckCount = const Value.absent(),
            Value<String?> origin = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<DateTime?> loadingDate = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String> itemManifestJson = const Value.absent(),
            Value<int> completedTruckCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WagonsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            warehouseId: warehouseId,
            wagonNumber: wagonNumber,
            status: status,
            expectedTruckCount: expectedTruckCount,
            origin: origin,
            destination: destination,
            loadingDate: loadingDate,
            remarks: remarks,
            itemManifestJson: itemManifestJson,
            completedTruckCount: completedTruckCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            required String wagonNumber,
            required String status,
            required int expectedTruckCount,
            Value<String?> origin = const Value.absent(),
            Value<String?> destination = const Value.absent(),
            Value<DateTime?> loadingDate = const Value.absent(),
            Value<String?> remarks = const Value.absent(),
            Value<String> itemManifestJson = const Value.absent(),
            Value<int> completedTruckCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WagonsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            warehouseId: warehouseId,
            wagonNumber: wagonNumber,
            status: status,
            expectedTruckCount: expectedTruckCount,
            origin: origin,
            destination: destination,
            loadingDate: loadingDate,
            remarks: remarks,
            itemManifestJson: itemManifestJson,
            completedTruckCount: completedTruckCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WagonsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {warehouseId = false,
              trucksRefs = false,
              digitalRegistersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trucksRefs) db.trucks,
                if (digitalRegistersRefs) db.digitalRegisters
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (warehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.warehouseId,
                    referencedTable:
                        $$WagonsTableReferences._warehouseIdTable(db),
                    referencedColumn:
                        $$WagonsTableReferences._warehouseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trucksRefs)
                    await $_getPrefetchedData<Wagon, $WagonsTable, Truck>(
                        currentTable: table,
                        referencedTable:
                            $$WagonsTableReferences._trucksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WagonsTableReferences(db, table, p0).trucksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wagonId == item.id),
                        typedResults: items),
                  if (digitalRegistersRefs)
                    await $_getPrefetchedData<Wagon, $WagonsTable,
                            DigitalRegister>(
                        currentTable: table,
                        referencedTable: $$WagonsTableReferences
                            ._digitalRegistersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WagonsTableReferences(db, table, p0)
                                .digitalRegistersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wagonId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WagonsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WagonsTable,
    Wagon,
    $$WagonsTableFilterComposer,
    $$WagonsTableOrderingComposer,
    $$WagonsTableAnnotationComposer,
    $$WagonsTableCreateCompanionBuilder,
    $$WagonsTableUpdateCompanionBuilder,
    (Wagon, $$WagonsTableReferences),
    Wagon,
    PrefetchHooks Function(
        {bool warehouseId, bool trucksRefs, bool digitalRegistersRefs})>;
typedef $$TrucksTableCreateCompanionBuilder = TrucksCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> wagonId,
  required String truckNumber,
  required String vehicleNumber,
  required String driverName,
  Value<String?> driverMobile,
  required String company,
  required String status,
  Value<String?> warehouse,
  Value<DateTime?> completedDate,
  Value<String?> notes,
  Value<int> totalLayers,
  Value<int> totalCartons,
  Value<int> totalDefects,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$TrucksTableUpdateCompanionBuilder = TrucksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> wagonId,
  Value<String> truckNumber,
  Value<String> vehicleNumber,
  Value<String> driverName,
  Value<String?> driverMobile,
  Value<String> company,
  Value<String> status,
  Value<String?> warehouse,
  Value<DateTime?> completedDate,
  Value<String?> notes,
  Value<int> totalLayers,
  Value<int> totalCartons,
  Value<int> totalDefects,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$TrucksTableReferences
    extends BaseReferences<_$AppDatabase, $TrucksTable, Truck> {
  $$TrucksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WagonsTable _wagonIdTable(_$AppDatabase db) => db.wagons
      .createAlias($_aliasNameGenerator(db.trucks.wagonId, db.wagons.id));

  $$WagonsTableProcessedTableManager? get wagonId {
    final $_column = $_itemColumn<String>('wagon_id');
    if ($_column == null) return null;
    final manager = $$WagonsTableTableManager($_db, $_db.wagons)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wagonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LayersTable, List<Layer>> _layersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.layers,
          aliasName: $_aliasNameGenerator(db.trucks.id, db.layers.truckId));

  $$LayersTableProcessedTableManager get layersRefs {
    final manager = $$LayersTableTableManager($_db, $_db.layers)
        .filter((f) => f.truckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_layersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LoadingSessionsTable, List<LoadingSession>>
      _loadingSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.loadingSessions,
              aliasName: $_aliasNameGenerator(
                  db.trucks.id, db.loadingSessions.truckId));

  $$LoadingSessionsTableProcessedTableManager get loadingSessionsRefs {
    final manager =
        $$LoadingSessionsTableTableManager($_db, $_db.loadingSessions)
            .filter((f) => f.truckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_loadingSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TrucksTableFilterComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckNumber => $composableBuilder(
      column: $table.truckNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverMobile => $composableBuilder(
      column: $table.driverMobile, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouse => $composableBuilder(
      column: $table.warehouse, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  $$WagonsTableFilterComposer get wagonId {
    final $$WagonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableFilterComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> layersRefs(
      Expression<bool> Function($$LayersTableFilterComposer f) f) {
    final $$LayersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.layers,
        getReferencedColumn: (t) => t.truckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LayersTableFilterComposer(
              $db: $db,
              $table: $db.layers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> loadingSessionsRefs(
      Expression<bool> Function($$LoadingSessionsTableFilterComposer f) f) {
    final $$LoadingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loadingSessions,
        getReferencedColumn: (t) => t.truckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoadingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.loadingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TrucksTableOrderingComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckNumber => $composableBuilder(
      column: $table.truckNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverMobile => $composableBuilder(
      column: $table.driverMobile,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get company => $composableBuilder(
      column: $table.company, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouse => $composableBuilder(
      column: $table.warehouse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  $$WagonsTableOrderingComposer get wagonId {
    final $$WagonsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableOrderingComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrucksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrucksTable> {
  $$TrucksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get truckNumber => $composableBuilder(
      column: $table.truckNumber, builder: (column) => column);

  GeneratedColumn<String> get vehicleNumber => $composableBuilder(
      column: $table.vehicleNumber, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => column);

  GeneratedColumn<String> get driverMobile => $composableBuilder(
      column: $table.driverMobile, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get warehouse =>
      $composableBuilder(column: $table.warehouse, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
      column: $table.completedDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => column);

  GeneratedColumn<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => column);

  GeneratedColumn<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  $$WagonsTableAnnotationComposer get wagonId {
    final $$WagonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableAnnotationComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> layersRefs<T extends Object>(
      Expression<T> Function($$LayersTableAnnotationComposer a) f) {
    final $$LayersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.layers,
        getReferencedColumn: (t) => t.truckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LayersTableAnnotationComposer(
              $db: $db,
              $table: $db.layers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> loadingSessionsRefs<T extends Object>(
      Expression<T> Function($$LoadingSessionsTableAnnotationComposer a) f) {
    final $$LoadingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loadingSessions,
        getReferencedColumn: (t) => t.truckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoadingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.loadingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TrucksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrucksTable,
    Truck,
    $$TrucksTableFilterComposer,
    $$TrucksTableOrderingComposer,
    $$TrucksTableAnnotationComposer,
    $$TrucksTableCreateCompanionBuilder,
    $$TrucksTableUpdateCompanionBuilder,
    (Truck, $$TrucksTableReferences),
    Truck,
    PrefetchHooks Function(
        {bool wagonId, bool layersRefs, bool loadingSessionsRefs})> {
  $$TrucksTableTableManager(_$AppDatabase db, $TrucksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrucksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrucksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrucksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> wagonId = const Value.absent(),
            Value<String> truckNumber = const Value.absent(),
            Value<String> vehicleNumber = const Value.absent(),
            Value<String> driverName = const Value.absent(),
            Value<String?> driverMobile = const Value.absent(),
            Value<String> company = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> warehouse = const Value.absent(),
            Value<DateTime?> completedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> totalLayers = const Value.absent(),
            Value<int> totalCartons = const Value.absent(),
            Value<int> totalDefects = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrucksCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            wagonId: wagonId,
            truckNumber: truckNumber,
            vehicleNumber: vehicleNumber,
            driverName: driverName,
            driverMobile: driverMobile,
            company: company,
            status: status,
            warehouse: warehouse,
            completedDate: completedDate,
            notes: notes,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            totalDefects: totalDefects,
            isArchived: isArchived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> wagonId = const Value.absent(),
            required String truckNumber,
            required String vehicleNumber,
            required String driverName,
            Value<String?> driverMobile = const Value.absent(),
            required String company,
            required String status,
            Value<String?> warehouse = const Value.absent(),
            Value<DateTime?> completedDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> totalLayers = const Value.absent(),
            Value<int> totalCartons = const Value.absent(),
            Value<int> totalDefects = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrucksCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            wagonId: wagonId,
            truckNumber: truckNumber,
            vehicleNumber: vehicleNumber,
            driverName: driverName,
            driverMobile: driverMobile,
            company: company,
            status: status,
            warehouse: warehouse,
            completedDate: completedDate,
            notes: notes,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            totalDefects: totalDefects,
            isArchived: isArchived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TrucksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {wagonId = false,
              layersRefs = false,
              loadingSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (layersRefs) db.layers,
                if (loadingSessionsRefs) db.loadingSessions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (wagonId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wagonId,
                    referencedTable: $$TrucksTableReferences._wagonIdTable(db),
                    referencedColumn:
                        $$TrucksTableReferences._wagonIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (layersRefs)
                    await $_getPrefetchedData<Truck, $TrucksTable, Layer>(
                        currentTable: table,
                        referencedTable:
                            $$TrucksTableReferences._layersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TrucksTableReferences(db, table, p0).layersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.truckId == item.id),
                        typedResults: items),
                  if (loadingSessionsRefs)
                    await $_getPrefetchedData<Truck, $TrucksTable,
                            LoadingSession>(
                        currentTable: table,
                        referencedTable: $$TrucksTableReferences
                            ._loadingSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TrucksTableReferences(db, table, p0)
                                .loadingSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.truckId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TrucksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrucksTable,
    Truck,
    $$TrucksTableFilterComposer,
    $$TrucksTableOrderingComposer,
    $$TrucksTableAnnotationComposer,
    $$TrucksTableCreateCompanionBuilder,
    $$TrucksTableUpdateCompanionBuilder,
    (Truck, $$TrucksTableReferences),
    Truck,
    PrefetchHooks Function(
        {bool wagonId, bool layersRefs, bool loadingSessionsRefs})>;
typedef $$LayersTableCreateCompanionBuilder = LayersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String truckId,
  required int layerNumber,
  required int cartonCount,
  Value<int> defectCount,
  Value<String?> photoPath,
  Value<String?> notes,
  Value<String?> itemName,
  Value<String> itemAllocationsJson,
  Value<double> averageConfidence,
  Value<DateTime?> timestamp,
  Value<String?> operatorId,
  Value<String?> modelVersion,
  Value<int> rowid,
});
typedef $$LayersTableUpdateCompanionBuilder = LayersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> truckId,
  Value<int> layerNumber,
  Value<int> cartonCount,
  Value<int> defectCount,
  Value<String?> photoPath,
  Value<String?> notes,
  Value<String?> itemName,
  Value<String> itemAllocationsJson,
  Value<double> averageConfidence,
  Value<DateTime?> timestamp,
  Value<String?> operatorId,
  Value<String?> modelVersion,
  Value<int> rowid,
});

final class $$LayersTableReferences
    extends BaseReferences<_$AppDatabase, $LayersTable, Layer> {
  $$LayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrucksTable _truckIdTable(_$AppDatabase db) => db.trucks
      .createAlias($_aliasNameGenerator(db.layers.truckId, db.trucks.id));

  $$TrucksTableProcessedTableManager get truckId {
    final $_column = $_itemColumn<String>('truck_id')!;

    final manager = $$TrucksTableTableManager($_db, $_db.trucks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_truckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DetectionsTable, List<Detection>>
      _detectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.detections,
          aliasName: $_aliasNameGenerator(db.layers.id, db.detections.layerId));

  $$DetectionsTableProcessedTableManager get detectionsRefs {
    final manager = $$DetectionsTableTableManager($_db, $_db.detections)
        .filter((f) => f.layerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_detectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LayersTableFilterComposer
    extends Composer<_$AppDatabase, $LayersTable> {
  $$LayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cartonCount => $composableBuilder(
      column: $table.cartonCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defectCount => $composableBuilder(
      column: $table.defectCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemAllocationsJson => $composableBuilder(
      column: $table.itemAllocationsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  $$TrucksTableFilterComposer get truckId {
    final $$TrucksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableFilterComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> detectionsRefs(
      Expression<bool> Function($$DetectionsTableFilterComposer f) f) {
    final $$DetectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detections,
        getReferencedColumn: (t) => t.layerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetectionsTableFilterComposer(
              $db: $db,
              $table: $db.detections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LayersTableOrderingComposer
    extends Composer<_$AppDatabase, $LayersTable> {
  $$LayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cartonCount => $composableBuilder(
      column: $table.cartonCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defectCount => $composableBuilder(
      column: $table.defectCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemAllocationsJson => $composableBuilder(
      column: $table.itemAllocationsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  $$TrucksTableOrderingComposer get truckId {
    final $$TrucksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableOrderingComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayersTable> {
  $$LayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => column);

  GeneratedColumn<int> get cartonCount => $composableBuilder(
      column: $table.cartonCount, builder: (column) => column);

  GeneratedColumn<int> get defectCount => $composableBuilder(
      column: $table.defectCount, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemAllocationsJson => $composableBuilder(
      column: $table.itemAllocationsJson, builder: (column) => column);

  GeneratedColumn<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  $$TrucksTableAnnotationComposer get truckId {
    final $$TrucksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableAnnotationComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> detectionsRefs<T extends Object>(
      Expression<T> Function($$DetectionsTableAnnotationComposer a) f) {
    final $$DetectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detections,
        getReferencedColumn: (t) => t.layerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.detections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LayersTable,
    Layer,
    $$LayersTableFilterComposer,
    $$LayersTableOrderingComposer,
    $$LayersTableAnnotationComposer,
    $$LayersTableCreateCompanionBuilder,
    $$LayersTableUpdateCompanionBuilder,
    (Layer, $$LayersTableReferences),
    Layer,
    PrefetchHooks Function({bool truckId, bool detectionsRefs})> {
  $$LayersTableTableManager(_$AppDatabase db, $LayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> truckId = const Value.absent(),
            Value<int> layerNumber = const Value.absent(),
            Value<int> cartonCount = const Value.absent(),
            Value<int> defectCount = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> itemName = const Value.absent(),
            Value<String> itemAllocationsJson = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            Value<String?> operatorId = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            truckId: truckId,
            layerNumber: layerNumber,
            cartonCount: cartonCount,
            defectCount: defectCount,
            photoPath: photoPath,
            notes: notes,
            itemName: itemName,
            itemAllocationsJson: itemAllocationsJson,
            averageConfidence: averageConfidence,
            timestamp: timestamp,
            operatorId: operatorId,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String truckId,
            required int layerNumber,
            required int cartonCount,
            Value<int> defectCount = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> itemName = const Value.absent(),
            Value<String> itemAllocationsJson = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            Value<String?> operatorId = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LayersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            truckId: truckId,
            layerNumber: layerNumber,
            cartonCount: cartonCount,
            defectCount: defectCount,
            photoPath: photoPath,
            notes: notes,
            itemName: itemName,
            itemAllocationsJson: itemAllocationsJson,
            averageConfidence: averageConfidence,
            timestamp: timestamp,
            operatorId: operatorId,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LayersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({truckId = false, detectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (detectionsRefs) db.detections],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (truckId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.truckId,
                    referencedTable: $$LayersTableReferences._truckIdTable(db),
                    referencedColumn:
                        $$LayersTableReferences._truckIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detectionsRefs)
                    await $_getPrefetchedData<Layer, $LayersTable, Detection>(
                        currentTable: table,
                        referencedTable:
                            $$LayersTableReferences._detectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LayersTableReferences(db, table, p0)
                                .detectionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.layerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LayersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LayersTable,
    Layer,
    $$LayersTableFilterComposer,
    $$LayersTableOrderingComposer,
    $$LayersTableAnnotationComposer,
    $$LayersTableCreateCompanionBuilder,
    $$LayersTableUpdateCompanionBuilder,
    (Layer, $$LayersTableReferences),
    Layer,
    PrefetchHooks Function({bool truckId, bool detectionsRefs})>;
typedef $$DetectionsTableCreateCompanionBuilder = DetectionsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String layerId,
  required double boundingBoxX,
  required double boundingBoxY,
  required double boundingBoxW,
  required double boundingBoxH,
  required double confidence,
  required String label,
  Value<int> rowid,
});
typedef $$DetectionsTableUpdateCompanionBuilder = DetectionsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> layerId,
  Value<double> boundingBoxX,
  Value<double> boundingBoxY,
  Value<double> boundingBoxW,
  Value<double> boundingBoxH,
  Value<double> confidence,
  Value<String> label,
  Value<int> rowid,
});

final class $$DetectionsTableReferences
    extends BaseReferences<_$AppDatabase, $DetectionsTable, Detection> {
  $$DetectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LayersTable _layerIdTable(_$AppDatabase db) => db.layers
      .createAlias($_aliasNameGenerator(db.detections.layerId, db.layers.id));

  $$LayersTableProcessedTableManager get layerId {
    final $_column = $_itemColumn<String>('layer_id')!;

    final manager = $$LayersTableTableManager($_db, $_db.layers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DetectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  $$LayersTableFilterComposer get layerId {
    final $$LayersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.layerId,
        referencedTable: $db.layers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LayersTableFilterComposer(
              $db: $db,
              $table: $db.layers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  $$LayersTableOrderingComposer get layerId {
    final $$LayersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.layerId,
        referencedTable: $db.layers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LayersTableOrderingComposer(
              $db: $db,
              $table: $db.layers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$LayersTableAnnotationComposer get layerId {
    final $$LayersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.layerId,
        referencedTable: $db.layers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LayersTableAnnotationComposer(
              $db: $db,
              $table: $db.layers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetectionsTable,
    Detection,
    $$DetectionsTableFilterComposer,
    $$DetectionsTableOrderingComposer,
    $$DetectionsTableAnnotationComposer,
    $$DetectionsTableCreateCompanionBuilder,
    $$DetectionsTableUpdateCompanionBuilder,
    (Detection, $$DetectionsTableReferences),
    Detection,
    PrefetchHooks Function({bool layerId})> {
  $$DetectionsTableTableManager(_$AppDatabase db, $DetectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> layerId = const Value.absent(),
            Value<double> boundingBoxX = const Value.absent(),
            Value<double> boundingBoxY = const Value.absent(),
            Value<double> boundingBoxW = const Value.absent(),
            Value<double> boundingBoxH = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DetectionsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            layerId: layerId,
            boundingBoxX: boundingBoxX,
            boundingBoxY: boundingBoxY,
            boundingBoxW: boundingBoxW,
            boundingBoxH: boundingBoxH,
            confidence: confidence,
            label: label,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String layerId,
            required double boundingBoxX,
            required double boundingBoxY,
            required double boundingBoxW,
            required double boundingBoxH,
            required double confidence,
            required String label,
            Value<int> rowid = const Value.absent(),
          }) =>
              DetectionsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            layerId: layerId,
            boundingBoxX: boundingBoxX,
            boundingBoxY: boundingBoxY,
            boundingBoxW: boundingBoxW,
            boundingBoxH: boundingBoxH,
            confidence: confidence,
            label: label,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DetectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({layerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (layerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.layerId,
                    referencedTable:
                        $$DetectionsTableReferences._layerIdTable(db),
                    referencedColumn:
                        $$DetectionsTableReferences._layerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DetectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetectionsTable,
    Detection,
    $$DetectionsTableFilterComposer,
    $$DetectionsTableOrderingComposer,
    $$DetectionsTableAnnotationComposer,
    $$DetectionsTableCreateCompanionBuilder,
    $$DetectionsTableUpdateCompanionBuilder,
    (Detection, $$DetectionsTableReferences),
    Detection,
    PrefetchHooks Function({bool layerId})>;
typedef $$DigitalRegistersTableCreateCompanionBuilder
    = DigitalRegistersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String wagonId,
  required String wagonNumber,
  required String generatedBy,
  required String shift,
  required String verificationHash,
  required int totalTrucks,
  required int totalLayers,
  required int totalCartons,
  Value<int> rowid,
});
typedef $$DigitalRegistersTableUpdateCompanionBuilder
    = DigitalRegistersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> wagonId,
  Value<String> wagonNumber,
  Value<String> generatedBy,
  Value<String> shift,
  Value<String> verificationHash,
  Value<int> totalTrucks,
  Value<int> totalLayers,
  Value<int> totalCartons,
  Value<int> rowid,
});

final class $$DigitalRegistersTableReferences extends BaseReferences<
    _$AppDatabase, $DigitalRegistersTable, DigitalRegister> {
  $$DigitalRegistersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WagonsTable _wagonIdTable(_$AppDatabase db) => db.wagons.createAlias(
      $_aliasNameGenerator(db.digitalRegisters.wagonId, db.wagons.id));

  $$WagonsTableProcessedTableManager get wagonId {
    final $_column = $_itemColumn<String>('wagon_id')!;

    final manager = $$WagonsTableTableManager($_db, $_db.wagons)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wagonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DigitalRegistersTableFilterComposer
    extends Composer<_$AppDatabase, $DigitalRegistersTable> {
  $$DigitalRegistersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shift => $composableBuilder(
      column: $table.shift, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationHash => $composableBuilder(
      column: $table.verificationHash,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTrucks => $composableBuilder(
      column: $table.totalTrucks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => ColumnFilters(column));

  $$WagonsTableFilterComposer get wagonId {
    final $$WagonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableFilterComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DigitalRegistersTableOrderingComposer
    extends Composer<_$AppDatabase, $DigitalRegistersTable> {
  $$DigitalRegistersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shift => $composableBuilder(
      column: $table.shift, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationHash => $composableBuilder(
      column: $table.verificationHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTrucks => $composableBuilder(
      column: $table.totalTrucks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons,
      builder: (column) => ColumnOrderings(column));

  $$WagonsTableOrderingComposer get wagonId {
    final $$WagonsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableOrderingComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DigitalRegistersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DigitalRegistersTable> {
  $$DigitalRegistersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get wagonNumber => $composableBuilder(
      column: $table.wagonNumber, builder: (column) => column);

  GeneratedColumn<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => column);

  GeneratedColumn<String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<String> get verificationHash => $composableBuilder(
      column: $table.verificationHash, builder: (column) => column);

  GeneratedColumn<int> get totalTrucks => $composableBuilder(
      column: $table.totalTrucks, builder: (column) => column);

  GeneratedColumn<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => column);

  GeneratedColumn<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => column);

  $$WagonsTableAnnotationComposer get wagonId {
    final $$WagonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wagonId,
        referencedTable: $db.wagons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WagonsTableAnnotationComposer(
              $db: $db,
              $table: $db.wagons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DigitalRegistersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DigitalRegistersTable,
    DigitalRegister,
    $$DigitalRegistersTableFilterComposer,
    $$DigitalRegistersTableOrderingComposer,
    $$DigitalRegistersTableAnnotationComposer,
    $$DigitalRegistersTableCreateCompanionBuilder,
    $$DigitalRegistersTableUpdateCompanionBuilder,
    (DigitalRegister, $$DigitalRegistersTableReferences),
    DigitalRegister,
    PrefetchHooks Function({bool wagonId})> {
  $$DigitalRegistersTableTableManager(
      _$AppDatabase db, $DigitalRegistersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DigitalRegistersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DigitalRegistersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DigitalRegistersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> wagonId = const Value.absent(),
            Value<String> wagonNumber = const Value.absent(),
            Value<String> generatedBy = const Value.absent(),
            Value<String> shift = const Value.absent(),
            Value<String> verificationHash = const Value.absent(),
            Value<int> totalTrucks = const Value.absent(),
            Value<int> totalLayers = const Value.absent(),
            Value<int> totalCartons = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DigitalRegistersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            wagonId: wagonId,
            wagonNumber: wagonNumber,
            generatedBy: generatedBy,
            shift: shift,
            verificationHash: verificationHash,
            totalTrucks: totalTrucks,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String wagonId,
            required String wagonNumber,
            required String generatedBy,
            required String shift,
            required String verificationHash,
            required int totalTrucks,
            required int totalLayers,
            required int totalCartons,
            Value<int> rowid = const Value.absent(),
          }) =>
              DigitalRegistersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            wagonId: wagonId,
            wagonNumber: wagonNumber,
            generatedBy: generatedBy,
            shift: shift,
            verificationHash: verificationHash,
            totalTrucks: totalTrucks,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DigitalRegistersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({wagonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (wagonId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wagonId,
                    referencedTable:
                        $$DigitalRegistersTableReferences._wagonIdTable(db),
                    referencedColumn:
                        $$DigitalRegistersTableReferences._wagonIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DigitalRegistersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DigitalRegistersTable,
    DigitalRegister,
    $$DigitalRegistersTableFilterComposer,
    $$DigitalRegistersTableOrderingComposer,
    $$DigitalRegistersTableAnnotationComposer,
    $$DigitalRegistersTableCreateCompanionBuilder,
    $$DigitalRegistersTableUpdateCompanionBuilder,
    (DigitalRegister, $$DigitalRegistersTableReferences),
    DigitalRegister,
    PrefetchHooks Function({bool wagonId})>;
typedef $$LoadingSessionsTableCreateCompanionBuilder = LoadingSessionsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String truckId,
  Value<String?> warehouseId,
  required DateTime startTime,
  Value<DateTime?> endTime,
  required String operatorId,
  required String status,
  Value<int> totalLayers,
  Value<int> totalCartons,
  Value<int> totalDefects,
  Value<double> averageConfidence,
  Value<String?> modelVersion,
  Value<String?> notes,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $$LoadingSessionsTableUpdateCompanionBuilder = LoadingSessionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> truckId,
  Value<String?> warehouseId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<String> operatorId,
  Value<String> status,
  Value<int> totalLayers,
  Value<int> totalCartons,
  Value<int> totalDefects,
  Value<double> averageConfidence,
  Value<String?> modelVersion,
  Value<String?> notes,
  Value<String?> metadata,
  Value<int> rowid,
});

final class $$LoadingSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $LoadingSessionsTable, LoadingSession> {
  $$LoadingSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TrucksTable _truckIdTable(_$AppDatabase db) => db.trucks.createAlias(
      $_aliasNameGenerator(db.loadingSessions.truckId, db.trucks.id));

  $$TrucksTableProcessedTableManager get truckId {
    final $_column = $_itemColumn<String>('truck_id')!;

    final manager = $$TrucksTableTableManager($_db, $_db.trucks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_truckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WarehousesTable _warehouseIdTable(_$AppDatabase db) =>
      db.warehouses.createAlias($_aliasNameGenerator(
          db.loadingSessions.warehouseId, db.warehouses.id));

  $$WarehousesTableProcessedTableManager? get warehouseId {
    final $_column = $_itemColumn<String>('warehouse_id');
    if ($_column == null) return null;
    final manager = $$WarehousesTableTableManager($_db, $_db.warehouses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_warehouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LoadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LoadingSessionsTable> {
  $$LoadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$TrucksTableFilterComposer get truckId {
    final $$TrucksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableFilterComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableFilterComposer get warehouseId {
    final $$WarehousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableFilterComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoadingSessionsTable> {
  $$LoadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$TrucksTableOrderingComposer get truckId {
    final $$TrucksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableOrderingComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableOrderingComposer get warehouseId {
    final $$WarehousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableOrderingComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoadingSessionsTable> {
  $$LoadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalLayers => $composableBuilder(
      column: $table.totalLayers, builder: (column) => column);

  GeneratedColumn<int> get totalCartons => $composableBuilder(
      column: $table.totalCartons, builder: (column) => column);

  GeneratedColumn<int> get totalDefects => $composableBuilder(
      column: $table.totalDefects, builder: (column) => column);

  GeneratedColumn<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$TrucksTableAnnotationComposer get truckId {
    final $$TrucksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.truckId,
        referencedTable: $db.trucks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrucksTableAnnotationComposer(
              $db: $db,
              $table: $db.trucks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WarehousesTableAnnotationComposer get warehouseId {
    final $$WarehousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.warehouseId,
        referencedTable: $db.warehouses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WarehousesTableAnnotationComposer(
              $db: $db,
              $table: $db.warehouses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoadingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoadingSessionsTable,
    LoadingSession,
    $$LoadingSessionsTableFilterComposer,
    $$LoadingSessionsTableOrderingComposer,
    $$LoadingSessionsTableAnnotationComposer,
    $$LoadingSessionsTableCreateCompanionBuilder,
    $$LoadingSessionsTableUpdateCompanionBuilder,
    (LoadingSession, $$LoadingSessionsTableReferences),
    LoadingSession,
    PrefetchHooks Function({bool truckId, bool warehouseId})> {
  $$LoadingSessionsTableTableManager(
      _$AppDatabase db, $LoadingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> truckId = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalLayers = const Value.absent(),
            Value<int> totalCartons = const Value.absent(),
            Value<int> totalDefects = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoadingSessionsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            truckId: truckId,
            warehouseId: warehouseId,
            startTime: startTime,
            endTime: endTime,
            operatorId: operatorId,
            status: status,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            totalDefects: totalDefects,
            averageConfidence: averageConfidence,
            modelVersion: modelVersion,
            notes: notes,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String truckId,
            Value<String?> warehouseId = const Value.absent(),
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            required String operatorId,
            required String status,
            Value<int> totalLayers = const Value.absent(),
            Value<int> totalCartons = const Value.absent(),
            Value<int> totalDefects = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoadingSessionsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            truckId: truckId,
            warehouseId: warehouseId,
            startTime: startTime,
            endTime: endTime,
            operatorId: operatorId,
            status: status,
            totalLayers: totalLayers,
            totalCartons: totalCartons,
            totalDefects: totalDefects,
            averageConfidence: averageConfidence,
            modelVersion: modelVersion,
            notes: notes,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LoadingSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({truckId = false, warehouseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (truckId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.truckId,
                    referencedTable:
                        $$LoadingSessionsTableReferences._truckIdTable(db),
                    referencedColumn:
                        $$LoadingSessionsTableReferences._truckIdTable(db).id,
                  ) as T;
                }
                if (warehouseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.warehouseId,
                    referencedTable:
                        $$LoadingSessionsTableReferences._warehouseIdTable(db),
                    referencedColumn: $$LoadingSessionsTableReferences
                        ._warehouseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LoadingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoadingSessionsTable,
    LoadingSession,
    $$LoadingSessionsTableFilterComposer,
    $$LoadingSessionsTableOrderingComposer,
    $$LoadingSessionsTableAnnotationComposer,
    $$LoadingSessionsTableCreateCompanionBuilder,
    $$LoadingSessionsTableUpdateCompanionBuilder,
    (LoadingSession, $$LoadingSessionsTableReferences),
    LoadingSession,
    PrefetchHooks Function({bool truckId, bool warehouseId})>;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required String entityId,
  required String entityType,
  required String action,
  required String userId,
  Value<DateTime> timestamp,
  Value<String?> details,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> entityId,
  Value<String> entityType,
  Value<String> action,
  Value<String> userId,
  Value<DateTime> timestamp,
  Value<String?> details,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);
}

class $$AuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()> {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion(
            id: id,
            entityId: entityId,
            entityType: entityType,
            action: action,
            userId: userId,
            timestamp: timestamp,
            details: details,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityId,
            required String entityType,
            required String action,
            required String userId,
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion.insert(
            id: id,
            entityId: entityId,
            entityType: entityType,
            action: action,
            userId: userId,
            timestamp: timestamp,
            details: details,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()>;
typedef $$SyncQueuesTableCreateCompanionBuilder = SyncQueuesCompanion Function({
  required String id,
  required String entityId,
  required String entityType,
  required String operation,
  required String payloadData,
  Value<int> version,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> queuedAt,
  Value<int> retryCount,
  Value<String> status,
  Value<String?> errorMessage,
  Value<int> rowid,
});
typedef $$SyncQueuesTableUpdateCompanionBuilder = SyncQueuesCompanion Function({
  Value<String> id,
  Value<String> entityId,
  Value<String> entityType,
  Value<String> operation,
  Value<String> payloadData,
  Value<int> version,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> queuedAt,
  Value<int> retryCount,
  Value<String> status,
  Value<String?> errorMessage,
  Value<int> rowid,
});

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadData => $composableBuilder(
      column: $table.payloadData, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadData => $composableBuilder(
      column: $table.payloadData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadData => $composableBuilder(
      column: $table.payloadData, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);
}

class $$SyncQueuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()> {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payloadData = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> queuedAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueuesCompanion(
            id: id,
            entityId: entityId,
            entityType: entityType,
            operation: operation,
            payloadData: payloadData,
            version: version,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            queuedAt: queuedAt,
            retryCount: retryCount,
            status: status,
            errorMessage: errorMessage,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityId,
            required String entityType,
            required String operation,
            required String payloadData,
            Value<int> version = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> queuedAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueuesCompanion.insert(
            id: id,
            entityId: entityId,
            entityType: entityType,
            operation: operation,
            payloadData: payloadData,
            version: version,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            queuedAt: queuedAt,
            retryCount: retryCount,
            status: status,
            errorMessage: errorMessage,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()>;
typedef $$DatasetImagesTableCreateCompanionBuilder = DatasetImagesCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> warehouseId,
  Value<String?> truckId,
  Value<String?> wagonId,
  Value<int?> layerNumber,
  required String originalPath,
  Value<String?> annotatedPath,
  Value<String?> thumbnailPath,
  required int fileSize,
  Value<String> approvalStatus,
  Value<String?> rejectReason,
  Value<String?> operatorId,
  Value<DateTime?> timestamp,
  Value<bool> isExported,
  Value<int> rowid,
});
typedef $$DatasetImagesTableUpdateCompanionBuilder = DatasetImagesCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String?> warehouseId,
  Value<String?> truckId,
  Value<String?> wagonId,
  Value<int?> layerNumber,
  Value<String> originalPath,
  Value<String?> annotatedPath,
  Value<String?> thumbnailPath,
  Value<int> fileSize,
  Value<String> approvalStatus,
  Value<String?> rejectReason,
  Value<String?> operatorId,
  Value<DateTime?> timestamp,
  Value<bool> isExported,
  Value<int> rowid,
});

final class $$DatasetImagesTableReferences
    extends BaseReferences<_$AppDatabase, $DatasetImagesTable, DatasetImage> {
  $$DatasetImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ImageMetadataTable, List<ImageMetadataData>>
      _imageMetadataRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.imageMetadata,
              aliasName: $_aliasNameGenerator(
                  db.datasetImages.id, db.imageMetadata.imageId));

  $$ImageMetadataTableProcessedTableManager get imageMetadataRefs {
    final manager = $$ImageMetadataTableTableManager($_db, $_db.imageMetadata)
        .filter((f) => f.imageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageMetadataRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ImageQualityTable, List<ImageQualityData>>
      _imageQualityRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.imageQuality,
              aliasName: $_aliasNameGenerator(
                  db.datasetImages.id, db.imageQuality.imageId));

  $$ImageQualityTableProcessedTableManager get imageQualityRefs {
    final manager = $$ImageQualityTableTableManager($_db, $_db.imageQuality)
        .filter((f) => f.imageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imageQualityRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AnnotationsTable, List<Annotation>>
      _annotationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.annotations,
              aliasName: $_aliasNameGenerator(
                  db.datasetImages.id, db.annotations.imageId));

  $$AnnotationsTableProcessedTableManager get annotationsRefs {
    final manager = $$AnnotationsTableTableManager($_db, $_db.annotations)
        .filter((f) => f.imageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_annotationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DatasetImagesTableFilterComposer
    extends Composer<_$AppDatabase, $DatasetImagesTable> {
  $$DatasetImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wagonId => $composableBuilder(
      column: $table.wagonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExported => $composableBuilder(
      column: $table.isExported, builder: (column) => ColumnFilters(column));

  Expression<bool> imageMetadataRefs(
      Expression<bool> Function($$ImageMetadataTableFilterComposer f) f) {
    final $$ImageMetadataTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.imageMetadata,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageMetadataTableFilterComposer(
              $db: $db,
              $table: $db.imageMetadata,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> imageQualityRefs(
      Expression<bool> Function($$ImageQualityTableFilterComposer f) f) {
    final $$ImageQualityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.imageQuality,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageQualityTableFilterComposer(
              $db: $db,
              $table: $db.imageQuality,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> annotationsRefs(
      Expression<bool> Function($$AnnotationsTableFilterComposer f) f) {
    final $$AnnotationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.annotations,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnnotationsTableFilterComposer(
              $db: $db,
              $table: $db.annotations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DatasetImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DatasetImagesTable> {
  $$DatasetImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckId => $composableBuilder(
      column: $table.truckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wagonId => $composableBuilder(
      column: $table.wagonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalPath => $composableBuilder(
      column: $table.originalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExported => $composableBuilder(
      column: $table.isExported, builder: (column) => ColumnOrderings(column));
}

class $$DatasetImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatasetImagesTable> {
  $$DatasetImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get truckId =>
      $composableBuilder(column: $table.truckId, builder: (column) => column);

  GeneratedColumn<String> get wagonId =>
      $composableBuilder(column: $table.wagonId, builder: (column) => column);

  GeneratedColumn<int> get layerNumber => $composableBuilder(
      column: $table.layerNumber, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => column);

  GeneratedColumn<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isExported => $composableBuilder(
      column: $table.isExported, builder: (column) => column);

  Expression<T> imageMetadataRefs<T extends Object>(
      Expression<T> Function($$ImageMetadataTableAnnotationComposer a) f) {
    final $$ImageMetadataTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.imageMetadata,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageMetadataTableAnnotationComposer(
              $db: $db,
              $table: $db.imageMetadata,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> imageQualityRefs<T extends Object>(
      Expression<T> Function($$ImageQualityTableAnnotationComposer a) f) {
    final $$ImageQualityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.imageQuality,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ImageQualityTableAnnotationComposer(
              $db: $db,
              $table: $db.imageQuality,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> annotationsRefs<T extends Object>(
      Expression<T> Function($$AnnotationsTableAnnotationComposer a) f) {
    final $$AnnotationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.annotations,
        getReferencedColumn: (t) => t.imageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnnotationsTableAnnotationComposer(
              $db: $db,
              $table: $db.annotations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DatasetImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DatasetImagesTable,
    DatasetImage,
    $$DatasetImagesTableFilterComposer,
    $$DatasetImagesTableOrderingComposer,
    $$DatasetImagesTableAnnotationComposer,
    $$DatasetImagesTableCreateCompanionBuilder,
    $$DatasetImagesTableUpdateCompanionBuilder,
    (DatasetImage, $$DatasetImagesTableReferences),
    DatasetImage,
    PrefetchHooks Function(
        {bool imageMetadataRefs,
        bool imageQualityRefs,
        bool annotationsRefs})> {
  $$DatasetImagesTableTableManager(_$AppDatabase db, $DatasetImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatasetImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatasetImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatasetImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> truckId = const Value.absent(),
            Value<String?> wagonId = const Value.absent(),
            Value<int?> layerNumber = const Value.absent(),
            Value<String> originalPath = const Value.absent(),
            Value<String?> annotatedPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String> approvalStatus = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<String?> operatorId = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            Value<bool> isExported = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DatasetImagesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            warehouseId: warehouseId,
            truckId: truckId,
            wagonId: wagonId,
            layerNumber: layerNumber,
            originalPath: originalPath,
            annotatedPath: annotatedPath,
            thumbnailPath: thumbnailPath,
            fileSize: fileSize,
            approvalStatus: approvalStatus,
            rejectReason: rejectReason,
            operatorId: operatorId,
            timestamp: timestamp,
            isExported: isExported,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> truckId = const Value.absent(),
            Value<String?> wagonId = const Value.absent(),
            Value<int?> layerNumber = const Value.absent(),
            required String originalPath,
            Value<String?> annotatedPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            required int fileSize,
            Value<String> approvalStatus = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<String?> operatorId = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            Value<bool> isExported = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DatasetImagesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            warehouseId: warehouseId,
            truckId: truckId,
            wagonId: wagonId,
            layerNumber: layerNumber,
            originalPath: originalPath,
            annotatedPath: annotatedPath,
            thumbnailPath: thumbnailPath,
            fileSize: fileSize,
            approvalStatus: approvalStatus,
            rejectReason: rejectReason,
            operatorId: operatorId,
            timestamp: timestamp,
            isExported: isExported,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DatasetImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {imageMetadataRefs = false,
              imageQualityRefs = false,
              annotationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (imageMetadataRefs) db.imageMetadata,
                if (imageQualityRefs) db.imageQuality,
                if (annotationsRefs) db.annotations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (imageMetadataRefs)
                    await $_getPrefetchedData<DatasetImage, $DatasetImagesTable,
                            ImageMetadataData>(
                        currentTable: table,
                        referencedTable: $$DatasetImagesTableReferences
                            ._imageMetadataRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DatasetImagesTableReferences(db, table, p0)
                                .imageMetadataRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.imageId == item.id),
                        typedResults: items),
                  if (imageQualityRefs)
                    await $_getPrefetchedData<DatasetImage, $DatasetImagesTable,
                            ImageQualityData>(
                        currentTable: table,
                        referencedTable: $$DatasetImagesTableReferences
                            ._imageQualityRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DatasetImagesTableReferences(db, table, p0)
                                .imageQualityRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.imageId == item.id),
                        typedResults: items),
                  if (annotationsRefs)
                    await $_getPrefetchedData<DatasetImage, $DatasetImagesTable,
                            Annotation>(
                        currentTable: table,
                        referencedTable: $$DatasetImagesTableReferences
                            ._annotationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DatasetImagesTableReferences(db, table, p0)
                                .annotationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.imageId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DatasetImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DatasetImagesTable,
    DatasetImage,
    $$DatasetImagesTableFilterComposer,
    $$DatasetImagesTableOrderingComposer,
    $$DatasetImagesTableAnnotationComposer,
    $$DatasetImagesTableCreateCompanionBuilder,
    $$DatasetImagesTableUpdateCompanionBuilder,
    (DatasetImage, $$DatasetImagesTableReferences),
    DatasetImage,
    PrefetchHooks Function(
        {bool imageMetadataRefs, bool imageQualityRefs, bool annotationsRefs})>;
typedef $$ImageMetadataTableCreateCompanionBuilder = ImageMetadataCompanion
    Function({
  required String imageId,
  required String filename,
  required DateTime captureTime,
  Value<String?> deviceModel,
  Value<String?> cameraResolution,
  Value<String?> modelVersion,
  Value<double> inferenceTimeMs,
  Value<double> averageConfidence,
  Value<int> detectedCount,
  Value<int?> manualCount,
  Value<int?> finalCount,
  Value<int> rowid,
});
typedef $$ImageMetadataTableUpdateCompanionBuilder = ImageMetadataCompanion
    Function({
  Value<String> imageId,
  Value<String> filename,
  Value<DateTime> captureTime,
  Value<String?> deviceModel,
  Value<String?> cameraResolution,
  Value<String?> modelVersion,
  Value<double> inferenceTimeMs,
  Value<double> averageConfidence,
  Value<int> detectedCount,
  Value<int?> manualCount,
  Value<int?> finalCount,
  Value<int> rowid,
});

final class $$ImageMetadataTableReferences extends BaseReferences<_$AppDatabase,
    $ImageMetadataTable, ImageMetadataData> {
  $$ImageMetadataTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DatasetImagesTable _imageIdTable(_$AppDatabase db) =>
      db.datasetImages.createAlias(
          $_aliasNameGenerator(db.imageMetadata.imageId, db.datasetImages.id));

  $$DatasetImagesTableProcessedTableManager get imageId {
    final $_column = $_itemColumn<String>('image_id')!;

    final manager = $$DatasetImagesTableTableManager($_db, $_db.datasetImages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ImageMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $ImageMetadataTable> {
  $$ImageMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cameraResolution => $composableBuilder(
      column: $table.cameraResolution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get detectedCount => $composableBuilder(
      column: $table.detectedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get manualCount => $composableBuilder(
      column: $table.manualCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get finalCount => $composableBuilder(
      column: $table.finalCount, builder: (column) => ColumnFilters(column));

  $$DatasetImagesTableFilterComposer get imageId {
    final $$DatasetImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableFilterComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageMetadataTable> {
  $$ImageMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cameraResolution => $composableBuilder(
      column: $table.cameraResolution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get detectedCount => $composableBuilder(
      column: $table.detectedCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get manualCount => $composableBuilder(
      column: $table.manualCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get finalCount => $composableBuilder(
      column: $table.finalCount, builder: (column) => ColumnOrderings(column));

  $$DatasetImagesTableOrderingComposer get imageId {
    final $$DatasetImagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableOrderingComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageMetadataTable> {
  $$ImageMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<DateTime> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => column);

  GeneratedColumn<String> get cameraResolution => $composableBuilder(
      column: $table.cameraResolution, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);

  GeneratedColumn<double> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs, builder: (column) => column);

  GeneratedColumn<double> get averageConfidence => $composableBuilder(
      column: $table.averageConfidence, builder: (column) => column);

  GeneratedColumn<int> get detectedCount => $composableBuilder(
      column: $table.detectedCount, builder: (column) => column);

  GeneratedColumn<int> get manualCount => $composableBuilder(
      column: $table.manualCount, builder: (column) => column);

  GeneratedColumn<int> get finalCount => $composableBuilder(
      column: $table.finalCount, builder: (column) => column);

  $$DatasetImagesTableAnnotationComposer get imageId {
    final $$DatasetImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageMetadataTable,
    ImageMetadataData,
    $$ImageMetadataTableFilterComposer,
    $$ImageMetadataTableOrderingComposer,
    $$ImageMetadataTableAnnotationComposer,
    $$ImageMetadataTableCreateCompanionBuilder,
    $$ImageMetadataTableUpdateCompanionBuilder,
    (ImageMetadataData, $$ImageMetadataTableReferences),
    ImageMetadataData,
    PrefetchHooks Function({bool imageId})> {
  $$ImageMetadataTableTableManager(_$AppDatabase db, $ImageMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> imageId = const Value.absent(),
            Value<String> filename = const Value.absent(),
            Value<DateTime> captureTime = const Value.absent(),
            Value<String?> deviceModel = const Value.absent(),
            Value<String?> cameraResolution = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<double> inferenceTimeMs = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<int> detectedCount = const Value.absent(),
            Value<int?> manualCount = const Value.absent(),
            Value<int?> finalCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageMetadataCompanion(
            imageId: imageId,
            filename: filename,
            captureTime: captureTime,
            deviceModel: deviceModel,
            cameraResolution: cameraResolution,
            modelVersion: modelVersion,
            inferenceTimeMs: inferenceTimeMs,
            averageConfidence: averageConfidence,
            detectedCount: detectedCount,
            manualCount: manualCount,
            finalCount: finalCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String imageId,
            required String filename,
            required DateTime captureTime,
            Value<String?> deviceModel = const Value.absent(),
            Value<String?> cameraResolution = const Value.absent(),
            Value<String?> modelVersion = const Value.absent(),
            Value<double> inferenceTimeMs = const Value.absent(),
            Value<double> averageConfidence = const Value.absent(),
            Value<int> detectedCount = const Value.absent(),
            Value<int?> manualCount = const Value.absent(),
            Value<int?> finalCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageMetadataCompanion.insert(
            imageId: imageId,
            filename: filename,
            captureTime: captureTime,
            deviceModel: deviceModel,
            cameraResolution: cameraResolution,
            modelVersion: modelVersion,
            inferenceTimeMs: inferenceTimeMs,
            averageConfidence: averageConfidence,
            detectedCount: detectedCount,
            manualCount: manualCount,
            finalCount: finalCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ImageMetadataTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({imageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (imageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.imageId,
                    referencedTable:
                        $$ImageMetadataTableReferences._imageIdTable(db),
                    referencedColumn:
                        $$ImageMetadataTableReferences._imageIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ImageMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageMetadataTable,
    ImageMetadataData,
    $$ImageMetadataTableFilterComposer,
    $$ImageMetadataTableOrderingComposer,
    $$ImageMetadataTableAnnotationComposer,
    $$ImageMetadataTableCreateCompanionBuilder,
    $$ImageMetadataTableUpdateCompanionBuilder,
    (ImageMetadataData, $$ImageMetadataTableReferences),
    ImageMetadataData,
    PrefetchHooks Function({bool imageId})>;
typedef $$ImageQualityTableCreateCompanionBuilder = ImageQualityCompanion
    Function({
  required String imageId,
  Value<double> blurScore,
  Value<double> brightness,
  Value<double> contrast,
  Value<double> rotation,
  Value<double> perspective,
  Value<double> occlusion,
  Value<double> distance,
  Value<int> rowid,
});
typedef $$ImageQualityTableUpdateCompanionBuilder = ImageQualityCompanion
    Function({
  Value<String> imageId,
  Value<double> blurScore,
  Value<double> brightness,
  Value<double> contrast,
  Value<double> rotation,
  Value<double> perspective,
  Value<double> occlusion,
  Value<double> distance,
  Value<int> rowid,
});

final class $$ImageQualityTableReferences extends BaseReferences<_$AppDatabase,
    $ImageQualityTable, ImageQualityData> {
  $$ImageQualityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DatasetImagesTable _imageIdTable(_$AppDatabase db) =>
      db.datasetImages.createAlias(
          $_aliasNameGenerator(db.imageQuality.imageId, db.datasetImages.id));

  $$DatasetImagesTableProcessedTableManager get imageId {
    final $_column = $_itemColumn<String>('image_id')!;

    final manager = $$DatasetImagesTableTableManager($_db, $_db.datasetImages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ImageQualityTableFilterComposer
    extends Composer<_$AppDatabase, $ImageQualityTable> {
  $$ImageQualityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get blurScore => $composableBuilder(
      column: $table.blurScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get perspective => $composableBuilder(
      column: $table.perspective, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get occlusion => $composableBuilder(
      column: $table.occlusion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  $$DatasetImagesTableFilterComposer get imageId {
    final $$DatasetImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableFilterComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageQualityTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageQualityTable> {
  $$ImageQualityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get blurScore => $composableBuilder(
      column: $table.blurScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get contrast => $composableBuilder(
      column: $table.contrast, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get perspective => $composableBuilder(
      column: $table.perspective, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get occlusion => $composableBuilder(
      column: $table.occlusion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  $$DatasetImagesTableOrderingComposer get imageId {
    final $$DatasetImagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableOrderingComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageQualityTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageQualityTable> {
  $$ImageQualityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get blurScore =>
      $composableBuilder(column: $table.blurScore, builder: (column) => column);

  GeneratedColumn<double> get brightness => $composableBuilder(
      column: $table.brightness, builder: (column) => column);

  GeneratedColumn<double> get contrast =>
      $composableBuilder(column: $table.contrast, builder: (column) => column);

  GeneratedColumn<double> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<double> get perspective => $composableBuilder(
      column: $table.perspective, builder: (column) => column);

  GeneratedColumn<double> get occlusion =>
      $composableBuilder(column: $table.occlusion, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  $$DatasetImagesTableAnnotationComposer get imageId {
    final $$DatasetImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ImageQualityTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageQualityTable,
    ImageQualityData,
    $$ImageQualityTableFilterComposer,
    $$ImageQualityTableOrderingComposer,
    $$ImageQualityTableAnnotationComposer,
    $$ImageQualityTableCreateCompanionBuilder,
    $$ImageQualityTableUpdateCompanionBuilder,
    (ImageQualityData, $$ImageQualityTableReferences),
    ImageQualityData,
    PrefetchHooks Function({bool imageId})> {
  $$ImageQualityTableTableManager(_$AppDatabase db, $ImageQualityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageQualityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageQualityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageQualityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> imageId = const Value.absent(),
            Value<double> blurScore = const Value.absent(),
            Value<double> brightness = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> rotation = const Value.absent(),
            Value<double> perspective = const Value.absent(),
            Value<double> occlusion = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageQualityCompanion(
            imageId: imageId,
            blurScore: blurScore,
            brightness: brightness,
            contrast: contrast,
            rotation: rotation,
            perspective: perspective,
            occlusion: occlusion,
            distance: distance,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String imageId,
            Value<double> blurScore = const Value.absent(),
            Value<double> brightness = const Value.absent(),
            Value<double> contrast = const Value.absent(),
            Value<double> rotation = const Value.absent(),
            Value<double> perspective = const Value.absent(),
            Value<double> occlusion = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageQualityCompanion.insert(
            imageId: imageId,
            blurScore: blurScore,
            brightness: brightness,
            contrast: contrast,
            rotation: rotation,
            perspective: perspective,
            occlusion: occlusion,
            distance: distance,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ImageQualityTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({imageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (imageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.imageId,
                    referencedTable:
                        $$ImageQualityTableReferences._imageIdTable(db),
                    referencedColumn:
                        $$ImageQualityTableReferences._imageIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ImageQualityTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageQualityTable,
    ImageQualityData,
    $$ImageQualityTableFilterComposer,
    $$ImageQualityTableOrderingComposer,
    $$ImageQualityTableAnnotationComposer,
    $$ImageQualityTableCreateCompanionBuilder,
    $$ImageQualityTableUpdateCompanionBuilder,
    (ImageQualityData, $$ImageQualityTableReferences),
    ImageQualityData,
    PrefetchHooks Function({bool imageId})>;
typedef $$AnnotationsTableCreateCompanionBuilder = AnnotationsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String imageId,
  required double boundingBoxX,
  required double boundingBoxY,
  required double boundingBoxW,
  required double boundingBoxH,
  required String label,
  required double confidence,
  Value<bool> isManualCorrection,
  Value<String?> correctionReason,
  Value<int> rowid,
});
typedef $$AnnotationsTableUpdateCompanionBuilder = AnnotationsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> imageId,
  Value<double> boundingBoxX,
  Value<double> boundingBoxY,
  Value<double> boundingBoxW,
  Value<double> boundingBoxH,
  Value<String> label,
  Value<double> confidence,
  Value<bool> isManualCorrection,
  Value<String?> correctionReason,
  Value<int> rowid,
});

final class $$AnnotationsTableReferences
    extends BaseReferences<_$AppDatabase, $AnnotationsTable, Annotation> {
  $$AnnotationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DatasetImagesTable _imageIdTable(_$AppDatabase db) =>
      db.datasetImages.createAlias(
          $_aliasNameGenerator(db.annotations.imageId, db.datasetImages.id));

  $$DatasetImagesTableProcessedTableManager get imageId {
    final $_column = $_itemColumn<String>('image_id')!;

    final manager = $$DatasetImagesTableTableManager($_db, $_db.datasetImages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManualCorrection => $composableBuilder(
      column: $table.isManualCorrection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctionReason => $composableBuilder(
      column: $table.correctionReason,
      builder: (column) => ColumnFilters(column));

  $$DatasetImagesTableFilterComposer get imageId {
    final $$DatasetImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableFilterComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManualCorrection => $composableBuilder(
      column: $table.isManualCorrection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctionReason => $composableBuilder(
      column: $table.correctionReason,
      builder: (column) => ColumnOrderings(column));

  $$DatasetImagesTableOrderingComposer get imageId {
    final $$DatasetImagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableOrderingComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxX => $composableBuilder(
      column: $table.boundingBoxX, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxY => $composableBuilder(
      column: $table.boundingBoxY, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxW => $composableBuilder(
      column: $table.boundingBoxW, builder: (column) => column);

  GeneratedColumn<double> get boundingBoxH => $composableBuilder(
      column: $table.boundingBoxH, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<bool> get isManualCorrection => $composableBuilder(
      column: $table.isManualCorrection, builder: (column) => column);

  GeneratedColumn<String> get correctionReason => $composableBuilder(
      column: $table.correctionReason, builder: (column) => column);

  $$DatasetImagesTableAnnotationComposer get imageId {
    final $$DatasetImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.imageId,
        referencedTable: $db.datasetImages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DatasetImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.datasetImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnotationsTable,
    Annotation,
    $$AnnotationsTableFilterComposer,
    $$AnnotationsTableOrderingComposer,
    $$AnnotationsTableAnnotationComposer,
    $$AnnotationsTableCreateCompanionBuilder,
    $$AnnotationsTableUpdateCompanionBuilder,
    (Annotation, $$AnnotationsTableReferences),
    Annotation,
    PrefetchHooks Function({bool imageId})> {
  $$AnnotationsTableTableManager(_$AppDatabase db, $AnnotationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> imageId = const Value.absent(),
            Value<double> boundingBoxX = const Value.absent(),
            Value<double> boundingBoxY = const Value.absent(),
            Value<double> boundingBoxW = const Value.absent(),
            Value<double> boundingBoxH = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<bool> isManualCorrection = const Value.absent(),
            Value<String?> correctionReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnotationsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            imageId: imageId,
            boundingBoxX: boundingBoxX,
            boundingBoxY: boundingBoxY,
            boundingBoxW: boundingBoxW,
            boundingBoxH: boundingBoxH,
            label: label,
            confidence: confidence,
            isManualCorrection: isManualCorrection,
            correctionReason: correctionReason,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String imageId,
            required double boundingBoxX,
            required double boundingBoxY,
            required double boundingBoxW,
            required double boundingBoxH,
            required String label,
            required double confidence,
            Value<bool> isManualCorrection = const Value.absent(),
            Value<String?> correctionReason = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnotationsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            imageId: imageId,
            boundingBoxX: boundingBoxX,
            boundingBoxY: boundingBoxY,
            boundingBoxW: boundingBoxW,
            boundingBoxH: boundingBoxH,
            label: label,
            confidence: confidence,
            isManualCorrection: isManualCorrection,
            correctionReason: correctionReason,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnnotationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({imageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (imageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.imageId,
                    referencedTable:
                        $$AnnotationsTableReferences._imageIdTable(db),
                    referencedColumn:
                        $$AnnotationsTableReferences._imageIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AnnotationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnnotationsTable,
    Annotation,
    $$AnnotationsTableFilterComposer,
    $$AnnotationsTableOrderingComposer,
    $$AnnotationsTableAnnotationComposer,
    $$AnnotationsTableCreateCompanionBuilder,
    $$AnnotationsTableUpdateCompanionBuilder,
    (Annotation, $$AnnotationsTableReferences),
    Annotation,
    PrefetchHooks Function({bool imageId})>;
typedef $$DatasetExportsTableCreateCompanionBuilder = DatasetExportsCompanion
    Function({
  required String id,
  required String exportPath,
  required String format,
  Value<DateTime> timestamp,
  Value<String> status,
  Value<int> totalImages,
  Value<String?> manifestJson,
  Value<int> rowid,
});
typedef $$DatasetExportsTableUpdateCompanionBuilder = DatasetExportsCompanion
    Function({
  Value<String> id,
  Value<String> exportPath,
  Value<String> format,
  Value<DateTime> timestamp,
  Value<String> status,
  Value<int> totalImages,
  Value<String?> manifestJson,
  Value<int> rowid,
});

class $$DatasetExportsTableFilterComposer
    extends Composer<_$AppDatabase, $DatasetExportsTable> {
  $$DatasetExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exportPath => $composableBuilder(
      column: $table.exportPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalImages => $composableBuilder(
      column: $table.totalImages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson, builder: (column) => ColumnFilters(column));
}

class $$DatasetExportsTableOrderingComposer
    extends Composer<_$AppDatabase, $DatasetExportsTable> {
  $$DatasetExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exportPath => $composableBuilder(
      column: $table.exportPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalImages => $composableBuilder(
      column: $table.totalImages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson,
      builder: (column) => ColumnOrderings(column));
}

class $$DatasetExportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatasetExportsTable> {
  $$DatasetExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exportPath => $composableBuilder(
      column: $table.exportPath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalImages => $composableBuilder(
      column: $table.totalImages, builder: (column) => column);

  GeneratedColumn<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson, builder: (column) => column);
}

class $$DatasetExportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DatasetExportsTable,
    DatasetExport,
    $$DatasetExportsTableFilterComposer,
    $$DatasetExportsTableOrderingComposer,
    $$DatasetExportsTableAnnotationComposer,
    $$DatasetExportsTableCreateCompanionBuilder,
    $$DatasetExportsTableUpdateCompanionBuilder,
    (
      DatasetExport,
      BaseReferences<_$AppDatabase, $DatasetExportsTable, DatasetExport>
    ),
    DatasetExport,
    PrefetchHooks Function()> {
  $$DatasetExportsTableTableManager(
      _$AppDatabase db, $DatasetExportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatasetExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DatasetExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DatasetExportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> exportPath = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalImages = const Value.absent(),
            Value<String?> manifestJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DatasetExportsCompanion(
            id: id,
            exportPath: exportPath,
            format: format,
            timestamp: timestamp,
            status: status,
            totalImages: totalImages,
            manifestJson: manifestJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String exportPath,
            required String format,
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalImages = const Value.absent(),
            Value<String?> manifestJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DatasetExportsCompanion.insert(
            id: id,
            exportPath: exportPath,
            format: format,
            timestamp: timestamp,
            status: status,
            totalImages: totalImages,
            manifestJson: manifestJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DatasetExportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DatasetExportsTable,
    DatasetExport,
    $$DatasetExportsTableFilterComposer,
    $$DatasetExportsTableOrderingComposer,
    $$DatasetExportsTableAnnotationComposer,
    $$DatasetExportsTableCreateCompanionBuilder,
    $$DatasetExportsTableUpdateCompanionBuilder,
    (
      DatasetExport,
      BaseReferences<_$AppDatabase, $DatasetExportsTable, DatasetExport>
    ),
    DatasetExport,
    PrefetchHooks Function()>;
typedef $$ModelHistoryTableCreateCompanionBuilder = ModelHistoryCompanion
    Function({
  required String id,
  required String modelName,
  required String version,
  required DateTime trainingDate,
  required int imagesUsed,
  Value<double?> precision,
  Value<double?> recall,
  Value<double?> mAP,
  Value<DateTime?> deploymentDate,
  Value<int> rowid,
});
typedef $$ModelHistoryTableUpdateCompanionBuilder = ModelHistoryCompanion
    Function({
  Value<String> id,
  Value<String> modelName,
  Value<String> version,
  Value<DateTime> trainingDate,
  Value<int> imagesUsed,
  Value<double?> precision,
  Value<double?> recall,
  Value<double?> mAP,
  Value<DateTime?> deploymentDate,
  Value<int> rowid,
});

class $$ModelHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ModelHistoryTable> {
  $$ModelHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get trainingDate => $composableBuilder(
      column: $table.trainingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get imagesUsed => $composableBuilder(
      column: $table.imagesUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precision => $composableBuilder(
      column: $table.precision, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get recall => $composableBuilder(
      column: $table.recall, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get mAP => $composableBuilder(
      column: $table.mAP, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deploymentDate => $composableBuilder(
      column: $table.deploymentDate,
      builder: (column) => ColumnFilters(column));
}

class $$ModelHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelHistoryTable> {
  $$ModelHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get trainingDate => $composableBuilder(
      column: $table.trainingDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get imagesUsed => $composableBuilder(
      column: $table.imagesUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precision => $composableBuilder(
      column: $table.precision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get recall => $composableBuilder(
      column: $table.recall, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get mAP => $composableBuilder(
      column: $table.mAP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deploymentDate => $composableBuilder(
      column: $table.deploymentDate,
      builder: (column) => ColumnOrderings(column));
}

class $$ModelHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelHistoryTable> {
  $$ModelHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get trainingDate => $composableBuilder(
      column: $table.trainingDate, builder: (column) => column);

  GeneratedColumn<int> get imagesUsed => $composableBuilder(
      column: $table.imagesUsed, builder: (column) => column);

  GeneratedColumn<double> get precision =>
      $composableBuilder(column: $table.precision, builder: (column) => column);

  GeneratedColumn<double> get recall =>
      $composableBuilder(column: $table.recall, builder: (column) => column);

  GeneratedColumn<double> get mAP =>
      $composableBuilder(column: $table.mAP, builder: (column) => column);

  GeneratedColumn<DateTime> get deploymentDate => $composableBuilder(
      column: $table.deploymentDate, builder: (column) => column);
}

class $$ModelHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModelHistoryTable,
    ModelHistoryData,
    $$ModelHistoryTableFilterComposer,
    $$ModelHistoryTableOrderingComposer,
    $$ModelHistoryTableAnnotationComposer,
    $$ModelHistoryTableCreateCompanionBuilder,
    $$ModelHistoryTableUpdateCompanionBuilder,
    (
      ModelHistoryData,
      BaseReferences<_$AppDatabase, $ModelHistoryTable, ModelHistoryData>
    ),
    ModelHistoryData,
    PrefetchHooks Function()> {
  $$ModelHistoryTableTableManager(_$AppDatabase db, $ModelHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<DateTime> trainingDate = const Value.absent(),
            Value<int> imagesUsed = const Value.absent(),
            Value<double?> precision = const Value.absent(),
            Value<double?> recall = const Value.absent(),
            Value<double?> mAP = const Value.absent(),
            Value<DateTime?> deploymentDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelHistoryCompanion(
            id: id,
            modelName: modelName,
            version: version,
            trainingDate: trainingDate,
            imagesUsed: imagesUsed,
            precision: precision,
            recall: recall,
            mAP: mAP,
            deploymentDate: deploymentDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String modelName,
            required String version,
            required DateTime trainingDate,
            required int imagesUsed,
            Value<double?> precision = const Value.absent(),
            Value<double?> recall = const Value.absent(),
            Value<double?> mAP = const Value.absent(),
            Value<DateTime?> deploymentDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelHistoryCompanion.insert(
            id: id,
            modelName: modelName,
            version: version,
            trainingDate: trainingDate,
            imagesUsed: imagesUsed,
            precision: precision,
            recall: recall,
            mAP: mAP,
            deploymentDate: deploymentDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModelHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ModelHistoryTable,
    ModelHistoryData,
    $$ModelHistoryTableFilterComposer,
    $$ModelHistoryTableOrderingComposer,
    $$ModelHistoryTableAnnotationComposer,
    $$ModelHistoryTableCreateCompanionBuilder,
    $$ModelHistoryTableUpdateCompanionBuilder,
    (
      ModelHistoryData,
      BaseReferences<_$AppDatabase, $ModelHistoryTable, ModelHistoryData>
    ),
    ModelHistoryData,
    PrefetchHooks Function()>;
typedef $$DeviceSessionsTableCreateCompanionBuilder = DeviceSessionsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String deviceName,
  required String deviceModel,
  required String osVersion,
  Value<DateTime> lastSync,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$DeviceSessionsTableUpdateCompanionBuilder = DeviceSessionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> deviceName,
  Value<String> deviceModel,
  Value<String> osVersion,
  Value<DateTime> lastSync,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$DeviceSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceSessionsTable> {
  $$DeviceSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get osVersion => $composableBuilder(
      column: $table.osVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
      column: $table.lastSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$DeviceSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceSessionsTable> {
  $$DeviceSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get osVersion => $composableBuilder(
      column: $table.osVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
      column: $table.lastSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$DeviceSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceSessionsTable> {
  $$DeviceSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
      column: $table.deviceName, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
      column: $table.deviceModel, builder: (column) => column);

  GeneratedColumn<String> get osVersion =>
      $composableBuilder(column: $table.osVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$DeviceSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceSessionsTable,
    DeviceSession,
    $$DeviceSessionsTableFilterComposer,
    $$DeviceSessionsTableOrderingComposer,
    $$DeviceSessionsTableAnnotationComposer,
    $$DeviceSessionsTableCreateCompanionBuilder,
    $$DeviceSessionsTableUpdateCompanionBuilder,
    (
      DeviceSession,
      BaseReferences<_$AppDatabase, $DeviceSessionsTable, DeviceSession>
    ),
    DeviceSession,
    PrefetchHooks Function()> {
  $$DeviceSessionsTableTableManager(
      _$AppDatabase db, $DeviceSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceName = const Value.absent(),
            Value<String> deviceModel = const Value.absent(),
            Value<String> osVersion = const Value.absent(),
            Value<DateTime> lastSync = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSessionsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            deviceName: deviceName,
            deviceModel: deviceModel,
            osVersion: osVersion,
            lastSync: lastSync,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceName,
            required String deviceModel,
            required String osVersion,
            Value<DateTime> lastSync = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSessionsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            deviceName: deviceName,
            deviceModel: deviceModel,
            osVersion: osVersion,
            lastSync: lastSync,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeviceSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceSessionsTable,
    DeviceSession,
    $$DeviceSessionsTableFilterComposer,
    $$DeviceSessionsTableOrderingComposer,
    $$DeviceSessionsTableAnnotationComposer,
    $$DeviceSessionsTableCreateCompanionBuilder,
    $$DeviceSessionsTableUpdateCompanionBuilder,
    (
      DeviceSession,
      BaseReferences<_$AppDatabase, $DeviceSessionsTable, DeviceSession>
    ),
    DeviceSession,
    PrefetchHooks Function()>;
typedef $$ReportExportsTableCreateCompanionBuilder = ReportExportsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String reportType,
  required String exportType,
  required String userId,
  Value<DateTime> exportedAt,
  required String status,
  Value<String?> filePath,
  Value<String?> details,
  Value<int> rowid,
});
typedef $$ReportExportsTableUpdateCompanionBuilder = ReportExportsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> reportType,
  Value<String> exportType,
  Value<String> userId,
  Value<DateTime> exportedAt,
  Value<String> status,
  Value<String?> filePath,
  Value<String?> details,
  Value<int> rowid,
});

class $$ReportExportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportExportsTable> {
  $$ReportExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exportType => $composableBuilder(
      column: $table.exportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exportedAt => $composableBuilder(
      column: $table.exportedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));
}

class $$ReportExportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportExportsTable> {
  $$ReportExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exportType => $composableBuilder(
      column: $table.exportType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exportedAt => $composableBuilder(
      column: $table.exportedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));
}

class $$ReportExportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportExportsTable> {
  $$ReportExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => column);

  GeneratedColumn<String> get exportType => $composableBuilder(
      column: $table.exportType, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get exportedAt => $composableBuilder(
      column: $table.exportedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);
}

class $$ReportExportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReportExportsTable,
    ReportExport,
    $$ReportExportsTableFilterComposer,
    $$ReportExportsTableOrderingComposer,
    $$ReportExportsTableAnnotationComposer,
    $$ReportExportsTableCreateCompanionBuilder,
    $$ReportExportsTableUpdateCompanionBuilder,
    (
      ReportExport,
      BaseReferences<_$AppDatabase, $ReportExportsTable, ReportExport>
    ),
    ReportExport,
    PrefetchHooks Function()> {
  $$ReportExportsTableTableManager(_$AppDatabase db, $ReportExportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportExportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> reportType = const Value.absent(),
            Value<String> exportType = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> exportedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> filePath = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportExportsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            reportType: reportType,
            exportType: exportType,
            userId: userId,
            exportedAt: exportedAt,
            status: status,
            filePath: filePath,
            details: details,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String reportType,
            required String exportType,
            required String userId,
            Value<DateTime> exportedAt = const Value.absent(),
            required String status,
            Value<String?> filePath = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportExportsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            reportType: reportType,
            exportType: exportType,
            userId: userId,
            exportedAt: exportedAt,
            status: status,
            filePath: filePath,
            details: details,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportExportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReportExportsTable,
    ReportExport,
    $$ReportExportsTableFilterComposer,
    $$ReportExportsTableOrderingComposer,
    $$ReportExportsTableAnnotationComposer,
    $$ReportExportsTableCreateCompanionBuilder,
    $$ReportExportsTableUpdateCompanionBuilder,
    (
      ReportExport,
      BaseReferences<_$AppDatabase, $ReportExportsTable, ReportExport>
    ),
    ReportExport,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String employeeId,
  required String name,
  required String role,
  Value<String?> warehouseId,
  Value<String?> token,
  Value<bool> isActive,
  Value<int> failedLoginAttempts,
  Value<DateTime?> lockedUntil,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> employeeId,
  Value<String> name,
  Value<String> role,
  Value<String?> warehouseId,
  Value<String?> token,
  Value<bool> isActive,
  Value<int> failedLoginAttempts,
  Value<DateTime?> lockedUntil,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
      column: $table.employeeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> employeeId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> failedLoginAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            employeeId: employeeId,
            name: name,
            role: role,
            warehouseId: warehouseId,
            token: token,
            isActive: isActive,
            failedLoginAttempts: failedLoginAttempts,
            lockedUntil: lockedUntil,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String employeeId,
            required String name,
            required String role,
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> failedLoginAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            employeeId: employeeId,
            name: name,
            role: role,
            warehouseId: warehouseId,
            token: token,
            isActive: isActive,
            failedLoginAttempts: failedLoginAttempts,
            lockedUntil: lockedUntil,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WarehousesTableTableManager get warehouses =>
      $$WarehousesTableTableManager(_db, _db.warehouses);
  $$WagonsTableTableManager get wagons =>
      $$WagonsTableTableManager(_db, _db.wagons);
  $$TrucksTableTableManager get trucks =>
      $$TrucksTableTableManager(_db, _db.trucks);
  $$LayersTableTableManager get layers =>
      $$LayersTableTableManager(_db, _db.layers);
  $$DetectionsTableTableManager get detections =>
      $$DetectionsTableTableManager(_db, _db.detections);
  $$DigitalRegistersTableTableManager get digitalRegisters =>
      $$DigitalRegistersTableTableManager(_db, _db.digitalRegisters);
  $$LoadingSessionsTableTableManager get loadingSessions =>
      $$LoadingSessionsTableTableManager(_db, _db.loadingSessions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
  $$DatasetImagesTableTableManager get datasetImages =>
      $$DatasetImagesTableTableManager(_db, _db.datasetImages);
  $$ImageMetadataTableTableManager get imageMetadata =>
      $$ImageMetadataTableTableManager(_db, _db.imageMetadata);
  $$ImageQualityTableTableManager get imageQuality =>
      $$ImageQualityTableTableManager(_db, _db.imageQuality);
  $$AnnotationsTableTableManager get annotations =>
      $$AnnotationsTableTableManager(_db, _db.annotations);
  $$DatasetExportsTableTableManager get datasetExports =>
      $$DatasetExportsTableTableManager(_db, _db.datasetExports);
  $$ModelHistoryTableTableManager get modelHistory =>
      $$ModelHistoryTableTableManager(_db, _db.modelHistory);
  $$DeviceSessionsTableTableManager get deviceSessions =>
      $$DeviceSessionsTableTableManager(_db, _db.deviceSessions);
  $$ReportExportsTableTableManager get reportExports =>
      $$ReportExportsTableTableManager(_db, _db.reportExports);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
