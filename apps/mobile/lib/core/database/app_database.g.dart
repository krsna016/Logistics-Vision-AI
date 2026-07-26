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
      defaultValue: const Constant('pending'));
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
          ..write('queuedAt: $queuedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityId, entityType, operation,
      payloadData, queuedAt, retryCount, status, errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.payloadData == this.payloadData &&
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
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
        originalPath,
        annotatedPath,
        thumbnailPath,
        metadataJson,
        fileSize
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
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    } else if (isInserting) {
      context.missing(_metadataJsonMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
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
      originalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_path'])!,
      annotatedPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}annotated_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
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
  final String originalPath;
  final String? annotatedPath;
  final String? thumbnailPath;
  final String metadataJson;
  final int fileSize;
  const DatasetImage(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      this.warehouseId,
      this.truckId,
      required this.originalPath,
      this.annotatedPath,
      this.thumbnailPath,
      required this.metadataJson,
      required this.fileSize});
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
    map['original_path'] = Variable<String>(originalPath);
    if (!nullToAbsent || annotatedPath != null) {
      map['annotated_path'] = Variable<String>(annotatedPath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['file_size'] = Variable<int>(fileSize);
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
      originalPath: Value(originalPath),
      annotatedPath: annotatedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(annotatedPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      metadataJson: Value(metadataJson),
      fileSize: Value(fileSize),
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
      originalPath: serializer.fromJson<String>(json['originalPath']),
      annotatedPath: serializer.fromJson<String?>(json['annotatedPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
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
      'originalPath': serializer.toJson<String>(originalPath),
      'annotatedPath': serializer.toJson<String?>(annotatedPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'fileSize': serializer.toJson<int>(fileSize),
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
          String? originalPath,
          Value<String?> annotatedPath = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          String? metadataJson,
          int? fileSize}) =>
      DatasetImage(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        truckId: truckId.present ? truckId.value : this.truckId,
        originalPath: originalPath ?? this.originalPath,
        annotatedPath:
            annotatedPath.present ? annotatedPath.value : this.annotatedPath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        metadataJson: metadataJson ?? this.metadataJson,
        fileSize: fileSize ?? this.fileSize,
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
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      annotatedPath: data.annotatedPath.present
          ? data.annotatedPath.value
          : this.annotatedPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
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
          ..write('originalPath: $originalPath, ')
          ..write('annotatedPath: $annotatedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('fileSize: $fileSize')
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
      originalPath,
      annotatedPath,
      thumbnailPath,
      metadataJson,
      fileSize);
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
          other.originalPath == this.originalPath &&
          other.annotatedPath == this.annotatedPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.metadataJson == this.metadataJson &&
          other.fileSize == this.fileSize);
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
  final Value<String> originalPath;
  final Value<String?> annotatedPath;
  final Value<String?> thumbnailPath;
  final Value<String> metadataJson;
  final Value<int> fileSize;
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
    this.originalPath = const Value.absent(),
    this.annotatedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.fileSize = const Value.absent(),
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
    required String originalPath,
    this.annotatedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    required String metadataJson,
    required int fileSize,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalPath = Value(originalPath),
        metadataJson = Value(metadataJson),
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
    Expression<String>? originalPath,
    Expression<String>? annotatedPath,
    Expression<String>? thumbnailPath,
    Expression<String>? metadataJson,
    Expression<int>? fileSize,
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
      if (originalPath != null) 'original_path': originalPath,
      if (annotatedPath != null) 'annotated_path': annotatedPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (fileSize != null) 'file_size': fileSize,
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
      Value<String>? originalPath,
      Value<String?>? annotatedPath,
      Value<String?>? thumbnailPath,
      Value<String>? metadataJson,
      Value<int>? fileSize,
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
      originalPath: originalPath ?? this.originalPath,
      annotatedPath: annotatedPath ?? this.annotatedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      metadataJson: metadataJson ?? this.metadataJson,
      fileSize: fileSize ?? this.fileSize,
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
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (annotatedPath.present) {
      map['annotated_path'] = Variable<String>(annotatedPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
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
          ..write('originalPath: $originalPath, ')
          ..write('annotatedPath: $annotatedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('fileSize: $fileSize, ')
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        version,
        syncStatus,
        name,
        role,
        warehouseId,
        token
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      warehouseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warehouse_id']),
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token']),
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
  final String name;
  final String role;
  final String? warehouseId;
  final String? token;
  const User(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      required this.version,
      required this.syncStatus,
      required this.name,
      required this.role,
      this.warehouseId,
      this.token});
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
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || warehouseId != null) {
      map['warehouse_id'] = Variable<String>(warehouseId);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
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
      name: Value(name),
      role: Value(role),
      warehouseId: warehouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(warehouseId),
      token:
          token == null && nullToAbsent ? const Value.absent() : Value(token),
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
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      warehouseId: serializer.fromJson<String?>(json['warehouseId']),
      token: serializer.fromJson<String?>(json['token']),
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
      'role': serializer.toJson<String>(role),
      'warehouseId': serializer.toJson<String?>(warehouseId),
      'token': serializer.toJson<String?>(token),
    };
  }

  User copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          int? version,
          String? syncStatus,
          String? name,
          String? role,
          Value<String?> warehouseId = const Value.absent(),
          Value<String?> token = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
        name: name ?? this.name,
        role: role ?? this.role,
        warehouseId: warehouseId.present ? warehouseId.value : this.warehouseId,
        token: token.present ? token.value : this.token,
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
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      warehouseId:
          data.warehouseId.present ? data.warehouseId.value : this.warehouseId,
      token: data.token.present ? data.token.value : this.token,
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
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('token: $token')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, isDeleted, version,
      syncStatus, name, role, warehouseId, token);
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
          other.name == this.name &&
          other.role == this.role &&
          other.warehouseId == this.warehouseId &&
          other.token == this.token);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> warehouseId;
  final Value<String?> token;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.warehouseId = const Value.absent(),
    this.token = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String name,
    required String role,
    this.warehouseId = const Value.absent(),
    this.token = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? warehouseId,
    Expression<String>? token,
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
      if (role != null) 'role': role,
      if (warehouseId != null) 'warehouse_id': warehouseId,
      if (token != null) 'token': token,
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
      Value<String>? name,
      Value<String>? role,
      Value<String?>? warehouseId,
      Value<String?>? token,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      role: role ?? this.role,
      warehouseId: warehouseId ?? this.warehouseId,
      token: token ?? this.token,
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
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (warehouseId.present) {
      map['warehouse_id'] = Variable<String>(warehouseId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
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
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('warehouseId: $warehouseId, ')
          ..write('token: $token, ')
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
        users,
        settings
      ];
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
  required String originalPath,
  Value<String?> annotatedPath,
  Value<String?> thumbnailPath,
  required String metadataJson,
  required int fileSize,
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
  Value<String> originalPath,
  Value<String?> annotatedPath,
  Value<String?> thumbnailPath,
  Value<String> metadataJson,
  Value<int> fileSize,
  Value<int> rowid,
});

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

  ColumnFilters<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get originalPath => $composableBuilder(
      column: $table.originalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => column);

  GeneratedColumn<String> get annotatedPath => $composableBuilder(
      column: $table.annotatedPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);
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
    (
      DatasetImage,
      BaseReferences<_$AppDatabase, $DatasetImagesTable, DatasetImage>
    ),
    DatasetImage,
    PrefetchHooks Function()> {
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
            Value<String> originalPath = const Value.absent(),
            Value<String?> annotatedPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String> metadataJson = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
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
            originalPath: originalPath,
            annotatedPath: annotatedPath,
            thumbnailPath: thumbnailPath,
            metadataJson: metadataJson,
            fileSize: fileSize,
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
            required String originalPath,
            Value<String?> annotatedPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            required String metadataJson,
            required int fileSize,
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
            originalPath: originalPath,
            annotatedPath: annotatedPath,
            thumbnailPath: thumbnailPath,
            metadataJson: metadataJson,
            fileSize: fileSize,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      DatasetImage,
      BaseReferences<_$AppDatabase, $DatasetImagesTable, DatasetImage>
    ),
    DatasetImage,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  required String name,
  required String role,
  Value<String?> warehouseId,
  Value<String?> token,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<int> version,
  Value<String> syncStatus,
  Value<String> name,
  Value<String> role,
  Value<String?> warehouseId,
  Value<String?> token,
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get warehouseId => $composableBuilder(
      column: $table.warehouseId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);
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
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            name: name,
            role: role,
            warehouseId: warehouseId,
            token: token,
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
            required String role,
            Value<String?> warehouseId = const Value.absent(),
            Value<String?> token = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            version: version,
            syncStatus: syncStatus,
            name: name,
            role: role,
            warehouseId: warehouseId,
            token: token,
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
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
