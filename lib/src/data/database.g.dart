// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [uid, alias, serverId, number];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      ),
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String uid;
  final String? alias;
  final String serverId;

  /// 1-based order in which the account was added; names it "Account N" while
  /// it has no alias. 0 only for rows inserted without one.
  final int number;
  const AccountRow({
    required this.uid,
    this.alias,
    required this.serverId,
    required this.number,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || alias != null) {
      map['alias'] = Variable<String>(alias);
    }
    map['server_id'] = Variable<String>(serverId);
    map['number'] = Variable<int>(number);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uid: Value(uid),
      alias: alias == null && nullToAbsent
          ? const Value.absent()
          : Value(alias),
      serverId: Value(serverId),
      number: Value(number),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      uid: serializer.fromJson<String>(json['uid']),
      alias: serializer.fromJson<String?>(json['alias']),
      serverId: serializer.fromJson<String>(json['serverId']),
      number: serializer.fromJson<int>(json['number']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'alias': serializer.toJson<String?>(alias),
      'serverId': serializer.toJson<String>(serverId),
      'number': serializer.toJson<int>(number),
    };
  }

  AccountRow copyWith({
    String? uid,
    Value<String?> alias = const Value.absent(),
    String? serverId,
    int? number,
  }) => AccountRow(
    uid: uid ?? this.uid,
    alias: alias.present ? alias.value : this.alias,
    serverId: serverId ?? this.serverId,
    number: number ?? this.number,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      alias: data.alias.present ? data.alias.value : this.alias,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      number: data.number.present ? data.number.value : this.number,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('uid: $uid, ')
          ..write('alias: $alias, ')
          ..write('serverId: $serverId, ')
          ..write('number: $number')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, alias, serverId, number);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.uid == this.uid &&
          other.alias == this.alias &&
          other.serverId == this.serverId &&
          other.number == this.number);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> uid;
  final Value<String?> alias;
  final Value<String> serverId;
  final Value<int> number;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uid = const Value.absent(),
    this.alias = const Value.absent(),
    this.serverId = const Value.absent(),
    this.number = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uid,
    this.alias = const Value.absent(),
    required String serverId,
    this.number = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       serverId = Value(serverId);
  static Insertable<AccountRow> custom({
    Expression<String>? uid,
    Expression<String>? alias,
    Expression<String>? serverId,
    Expression<int>? number,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (alias != null) 'alias': alias,
      if (serverId != null) 'server_id': serverId,
      if (number != null) 'number': number,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? uid,
    Value<String?>? alias,
    Value<String>? serverId,
    Value<int>? number,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      uid: uid ?? this.uid,
      alias: alias ?? this.alias,
      serverId: serverId ?? this.serverId,
      number: number ?? this.number,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('uid: $uid, ')
          ..write('alias: $alias, ')
          ..write('serverId: $serverId, ')
          ..write('number: $number, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConveneRecordsTable extends ConveneRecords
    with TableInfo<$ConveneRecordsTable, ConveneRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConveneRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (uid)',
    ),
  );
  static const VerificationMeta _poolTypeMeta = const VerificationMeta(
    'poolType',
  );
  @override
  late final GeneratedColumn<int> poolType = GeneratedColumn<int>(
    'pool_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceTypeMeta = const VerificationMeta(
    'resourceType',
  );
  @override
  late final GeneratedColumn<String> resourceType = GeneratedColumn<String>(
    'resource_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<int> rarity = GeneratedColumn<int>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIndexMeta = const VerificationMeta(
    'recordIndex',
  );
  @override
  late final GeneratedColumn<int> recordIndex = GeneratedColumn<int>(
    'record_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    poolType,
    time,
    name,
    resourceType,
    rarity,
    count,
    recordIndex,
    resourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'convene_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConveneRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('pool_type')) {
      context.handle(
        _poolTypeMeta,
        poolType.isAcceptableOrUnknown(data['pool_type']!, _poolTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_poolTypeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('resource_type')) {
      context.handle(
        _resourceTypeMeta,
        resourceType.isAcceptableOrUnknown(
          data['resource_type']!,
          _resourceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceTypeMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('record_index')) {
      context.handle(
        _recordIndexMeta,
        recordIndex.isAcceptableOrUnknown(
          data['record_index']!,
          _recordIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordIndexMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uid, poolType, time, name, recordIndex},
  ];
  @override
  ConveneRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConveneRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      poolType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_type'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      resourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_type'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rarity'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      recordIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_index'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
    );
  }

  @override
  $ConveneRecordsTable createAlias(String alias) {
    return $ConveneRecordsTable(attachedDatabase, alias);
  }
}

class ConveneRecordRow extends DataClass
    implements Insertable<ConveneRecordRow> {
  final int id;
  final String uid;
  final int poolType;
  final String time;
  final String name;
  final String resourceType;
  final int rarity;
  final int count;

  /// Chronological position among records sharing the same `time` (a 10-pull
  /// shares one timestamp). Makes the unique key below stable across imports.
  final int recordIndex;

  /// Game resource id (used to look up icons). 0 for rows imported before
  /// schema v2; a later import backfills it.
  final int resourceId;
  const ConveneRecordRow({
    required this.id,
    required this.uid,
    required this.poolType,
    required this.time,
    required this.name,
    required this.resourceType,
    required this.rarity,
    required this.count,
    required this.recordIndex,
    required this.resourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['pool_type'] = Variable<int>(poolType);
    map['time'] = Variable<String>(time);
    map['name'] = Variable<String>(name);
    map['resource_type'] = Variable<String>(resourceType);
    map['rarity'] = Variable<int>(rarity);
    map['count'] = Variable<int>(count);
    map['record_index'] = Variable<int>(recordIndex);
    map['resource_id'] = Variable<int>(resourceId);
    return map;
  }

  ConveneRecordsCompanion toCompanion(bool nullToAbsent) {
    return ConveneRecordsCompanion(
      id: Value(id),
      uid: Value(uid),
      poolType: Value(poolType),
      time: Value(time),
      name: Value(name),
      resourceType: Value(resourceType),
      rarity: Value(rarity),
      count: Value(count),
      recordIndex: Value(recordIndex),
      resourceId: Value(resourceId),
    );
  }

  factory ConveneRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConveneRecordRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      poolType: serializer.fromJson<int>(json['poolType']),
      time: serializer.fromJson<String>(json['time']),
      name: serializer.fromJson<String>(json['name']),
      resourceType: serializer.fromJson<String>(json['resourceType']),
      rarity: serializer.fromJson<int>(json['rarity']),
      count: serializer.fromJson<int>(json['count']),
      recordIndex: serializer.fromJson<int>(json['recordIndex']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'poolType': serializer.toJson<int>(poolType),
      'time': serializer.toJson<String>(time),
      'name': serializer.toJson<String>(name),
      'resourceType': serializer.toJson<String>(resourceType),
      'rarity': serializer.toJson<int>(rarity),
      'count': serializer.toJson<int>(count),
      'recordIndex': serializer.toJson<int>(recordIndex),
      'resourceId': serializer.toJson<int>(resourceId),
    };
  }

  ConveneRecordRow copyWith({
    int? id,
    String? uid,
    int? poolType,
    String? time,
    String? name,
    String? resourceType,
    int? rarity,
    int? count,
    int? recordIndex,
    int? resourceId,
  }) => ConveneRecordRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    poolType: poolType ?? this.poolType,
    time: time ?? this.time,
    name: name ?? this.name,
    resourceType: resourceType ?? this.resourceType,
    rarity: rarity ?? this.rarity,
    count: count ?? this.count,
    recordIndex: recordIndex ?? this.recordIndex,
    resourceId: resourceId ?? this.resourceId,
  );
  ConveneRecordRow copyWithCompanion(ConveneRecordsCompanion data) {
    return ConveneRecordRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      poolType: data.poolType.present ? data.poolType.value : this.poolType,
      time: data.time.present ? data.time.value : this.time,
      name: data.name.present ? data.name.value : this.name,
      resourceType: data.resourceType.present
          ? data.resourceType.value
          : this.resourceType,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      count: data.count.present ? data.count.value : this.count,
      recordIndex: data.recordIndex.present
          ? data.recordIndex.value
          : this.recordIndex,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConveneRecordRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('poolType: $poolType, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('resourceType: $resourceType, ')
          ..write('rarity: $rarity, ')
          ..write('count: $count, ')
          ..write('recordIndex: $recordIndex, ')
          ..write('resourceId: $resourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    poolType,
    time,
    name,
    resourceType,
    rarity,
    count,
    recordIndex,
    resourceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConveneRecordRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.poolType == this.poolType &&
          other.time == this.time &&
          other.name == this.name &&
          other.resourceType == this.resourceType &&
          other.rarity == this.rarity &&
          other.count == this.count &&
          other.recordIndex == this.recordIndex &&
          other.resourceId == this.resourceId);
}

class ConveneRecordsCompanion extends UpdateCompanion<ConveneRecordRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<int> poolType;
  final Value<String> time;
  final Value<String> name;
  final Value<String> resourceType;
  final Value<int> rarity;
  final Value<int> count;
  final Value<int> recordIndex;
  final Value<int> resourceId;
  const ConveneRecordsCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.poolType = const Value.absent(),
    this.time = const Value.absent(),
    this.name = const Value.absent(),
    this.resourceType = const Value.absent(),
    this.rarity = const Value.absent(),
    this.count = const Value.absent(),
    this.recordIndex = const Value.absent(),
    this.resourceId = const Value.absent(),
  });
  ConveneRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required int poolType,
    required String time,
    required String name,
    required String resourceType,
    required int rarity,
    required int count,
    required int recordIndex,
    this.resourceId = const Value.absent(),
  }) : uid = Value(uid),
       poolType = Value(poolType),
       time = Value(time),
       name = Value(name),
       resourceType = Value(resourceType),
       rarity = Value(rarity),
       count = Value(count),
       recordIndex = Value(recordIndex);
  static Insertable<ConveneRecordRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<int>? poolType,
    Expression<String>? time,
    Expression<String>? name,
    Expression<String>? resourceType,
    Expression<int>? rarity,
    Expression<int>? count,
    Expression<int>? recordIndex,
    Expression<int>? resourceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (poolType != null) 'pool_type': poolType,
      if (time != null) 'time': time,
      if (name != null) 'name': name,
      if (resourceType != null) 'resource_type': resourceType,
      if (rarity != null) 'rarity': rarity,
      if (count != null) 'count': count,
      if (recordIndex != null) 'record_index': recordIndex,
      if (resourceId != null) 'resource_id': resourceId,
    });
  }

  ConveneRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<int>? poolType,
    Value<String>? time,
    Value<String>? name,
    Value<String>? resourceType,
    Value<int>? rarity,
    Value<int>? count,
    Value<int>? recordIndex,
    Value<int>? resourceId,
  }) {
    return ConveneRecordsCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      poolType: poolType ?? this.poolType,
      time: time ?? this.time,
      name: name ?? this.name,
      resourceType: resourceType ?? this.resourceType,
      rarity: rarity ?? this.rarity,
      count: count ?? this.count,
      recordIndex: recordIndex ?? this.recordIndex,
      resourceId: resourceId ?? this.resourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (poolType.present) {
      map['pool_type'] = Variable<int>(poolType.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (resourceType.present) {
      map['resource_type'] = Variable<String>(resourceType.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<int>(rarity.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (recordIndex.present) {
      map['record_index'] = Variable<int>(recordIndex.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConveneRecordsCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('poolType: $poolType, ')
          ..write('time: $time, ')
          ..write('name: $name, ')
          ..write('resourceType: $resourceType, ')
          ..write('rarity: $rarity, ')
          ..write('count: $count, ')
          ..write('recordIndex: $recordIndex, ')
          ..write('resourceId: $resourceId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ConveneRecordsTable conveneRecords = $ConveneRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    conveneRecords,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String uid,
  Value<String?> alias,
  required String serverId,
  Value<int> number,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> uid,
  Value<String?> alias,
  Value<String> serverId,
  Value<int> number,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConveneRecordsTable, List<ConveneRecordRow>>
  _conveneRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conveneRecords,
    aliasName: 'accounts__uid__convene_records__uid',
  );

  $$ConveneRecordsTableProcessedTableManager get conveneRecordsRefs {
    final manager = $$ConveneRecordsTableTableManager(
      $_db,
      $_db.conveneRecords,
    ).filter((f) => f.uid.uid.sqlEquals($_itemColumn<String>('uid')!));

    final cache = $_typedResult.readTableOrNull(_conveneRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> conveneRecordsRefs(
    Expression<bool> Function($$ConveneRecordsTableFilterComposer f) f,
  ) {
    final $$ConveneRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uid,
      referencedTable: $db.conveneRecords,
      getReferencedColumn: (t) => t.uid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConveneRecordsTableFilterComposer(
            $db: $db,
            $table: $db.conveneRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  Expression<T> conveneRecordsRefs<T extends Object>(
    Expression<T> Function($$ConveneRecordsTableAnnotationComposer a) f,
  ) {
    final $$ConveneRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uid,
      referencedTable: $db.conveneRecords,
      getReferencedColumn: (t) => t.uid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConveneRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.conveneRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({bool conveneRecordsRefs})
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String?> alias = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                uid: uid,
                alias: alias,
                serverId: serverId,
                number: number,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                Value<String?> alias = const Value.absent(),
                required String serverId,
                Value<int> number = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                uid: uid,
                alias: alias,
                serverId: serverId,
                number: number,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conveneRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (conveneRecordsRefs) db.conveneRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (conveneRecordsRefs)
                    await $_getPrefetchedData<
                      AccountRow,
                      $AccountsTable,
                      ConveneRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._conveneRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AccountsTableReferences(
                        db,
                        table,
                        p0,
                      ).conveneRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.uid == item.uid),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({bool conveneRecordsRefs})
    >;
typedef $$ConveneRecordsTableCreateCompanionBuilder =
    ConveneRecordsCompanion Function({
      Value<int> id,
      required String uid,
      required int poolType,
      required String time,
      required String name,
      required String resourceType,
      required int rarity,
      required int count,
      required int recordIndex,
      Value<int> resourceId,
    });
typedef $$ConveneRecordsTableUpdateCompanionBuilder =
    ConveneRecordsCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<int> poolType,
      Value<String> time,
      Value<String> name,
      Value<String> resourceType,
      Value<int> rarity,
      Value<int> count,
      Value<int> recordIndex,
      Value<int> resourceId,
    });

final class $$ConveneRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ConveneRecordsTable, ConveneRecordRow> {
  $$ConveneRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _uidTable(_$AppDatabase db) =>
      db.accounts.createAlias('convene_records__uid__accounts__uid');

  $$AccountsTableProcessedTableManager get uid {
    final $_column = $_itemColumn<String>('uid')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.uid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConveneRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ConveneRecordsTable> {
  $$ConveneRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get poolType => $composableBuilder(
    column: $table.poolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordIndex => $composableBuilder(
    column: $table.recordIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get uid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConveneRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConveneRecordsTable> {
  $$ConveneRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolType => $composableBuilder(
    column: $table.poolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordIndex => $composableBuilder(
    column: $table.recordIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get uid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConveneRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConveneRecordsTable> {
  $$ConveneRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get poolType =>
      $composableBuilder(column: $table.poolType, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get resourceType => $composableBuilder(
    column: $table.resourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get recordIndex => $composableBuilder(
    column: $table.recordIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get uid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConveneRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConveneRecordsTable,
          ConveneRecordRow,
          $$ConveneRecordsTableFilterComposer,
          $$ConveneRecordsTableOrderingComposer,
          $$ConveneRecordsTableAnnotationComposer,
          $$ConveneRecordsTableCreateCompanionBuilder,
          $$ConveneRecordsTableUpdateCompanionBuilder,
          (ConveneRecordRow, $$ConveneRecordsTableReferences),
          ConveneRecordRow,
          PrefetchHooks Function({bool uid})
        > {
  $$ConveneRecordsTableTableManager(
    _$AppDatabase db,
    $ConveneRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConveneRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConveneRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConveneRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<int> poolType = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> resourceType = const Value.absent(),
                Value<int> rarity = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> recordIndex = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
              }) => ConveneRecordsCompanion(
                id: id,
                uid: uid,
                poolType: poolType,
                time: time,
                name: name,
                resourceType: resourceType,
                rarity: rarity,
                count: count,
                recordIndex: recordIndex,
                resourceId: resourceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required int poolType,
                required String time,
                required String name,
                required String resourceType,
                required int rarity,
                required int count,
                required int recordIndex,
                Value<int> resourceId = const Value.absent(),
              }) => ConveneRecordsCompanion.insert(
                id: id,
                uid: uid,
                poolType: poolType,
                time: time,
                name: name,
                resourceType: resourceType,
                rarity: rarity,
                count: count,
                recordIndex: recordIndex,
                resourceId: resourceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConveneRecordsTable, ConveneRecordRow>(table),
                  $$ConveneRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({uid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (uid) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.uid,
                        referencedTable: $$ConveneRecordsTableReferences
                            ._uidTable(db),
                        referencedColumn: $$ConveneRecordsTableReferences
                            ._uidTable(db)
                            .uid,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConveneRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConveneRecordsTable,
      ConveneRecordRow,
      $$ConveneRecordsTableFilterComposer,
      $$ConveneRecordsTableOrderingComposer,
      $$ConveneRecordsTableAnnotationComposer,
      $$ConveneRecordsTableCreateCompanionBuilder,
      $$ConveneRecordsTableUpdateCompanionBuilder,
      (ConveneRecordRow, $$ConveneRecordsTableReferences),
      ConveneRecordRow,
      PrefetchHooks Function({bool uid})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ConveneRecordsTableTableManager get conveneRecords =>
      $$ConveneRecordsTableTableManager(_db, _db.conveneRecords);
}
