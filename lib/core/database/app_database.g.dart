// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WardrobeItemsTable extends WardrobeItems
    with TableInfo<$WardrobeItemsTable, WardrobeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WardrobeItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOwnedMeta = const VerificationMeta(
    'quantityOwned',
  );
  @override
  late final GeneratedColumn<int> quantityOwned = GeneratedColumn<int>(
    'quantity_owned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    quantityOwned,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wardrobe_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WardrobeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('quantity_owned')) {
      context.handle(
        _quantityOwnedMeta,
        quantityOwned.isAcceptableOrUnknown(
          data['quantity_owned']!,
          _quantityOwnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOwnedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WardrobeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WardrobeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      quantityOwned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_owned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WardrobeItemsTable createAlias(String alias) {
    return $WardrobeItemsTable(attachedDatabase, alias);
  }
}

class WardrobeItem extends DataClass implements Insertable<WardrobeItem> {
  final int id;
  final String name;
  final String iconName;
  final int quantityOwned;
  final DateTime createdAt;
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.iconName,
    required this.quantityOwned,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['quantity_owned'] = Variable<int>(quantityOwned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WardrobeItemsCompanion toCompanion(bool nullToAbsent) {
    return WardrobeItemsCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      quantityOwned: Value(quantityOwned),
      createdAt: Value(createdAt),
    );
  }

  factory WardrobeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WardrobeItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      quantityOwned: serializer.fromJson<int>(json['quantityOwned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'quantityOwned': serializer.toJson<int>(quantityOwned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WardrobeItem copyWith({
    int? id,
    String? name,
    String? iconName,
    int? quantityOwned,
    DateTime? createdAt,
  }) => WardrobeItem(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    quantityOwned: quantityOwned ?? this.quantityOwned,
    createdAt: createdAt ?? this.createdAt,
  );
  WardrobeItem copyWithCompanion(WardrobeItemsCompanion data) {
    return WardrobeItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      quantityOwned: data.quantityOwned.present
          ? data.quantityOwned.value
          : this.quantityOwned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('quantityOwned: $quantityOwned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, quantityOwned, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WardrobeItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.quantityOwned == this.quantityOwned &&
          other.createdAt == this.createdAt);
}

class WardrobeItemsCompanion extends UpdateCompanion<WardrobeItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> quantityOwned;
  final Value<DateTime> createdAt;
  const WardrobeItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.quantityOwned = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WardrobeItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String iconName,
    required int quantityOwned,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       iconName = Value(iconName),
       quantityOwned = Value(quantityOwned);
  static Insertable<WardrobeItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? quantityOwned,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (quantityOwned != null) 'quantity_owned': quantityOwned,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WardrobeItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<int>? quantityOwned,
    Value<DateTime>? createdAt,
  }) {
    return WardrobeItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      quantityOwned: quantityOwned ?? this.quantityOwned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (quantityOwned.present) {
      map['quantity_owned'] = Variable<int>(quantityOwned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('quantityOwned: $quantityOwned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LaundrySessionsTable extends LaundrySessions
    with TableInfo<$LaundrySessionsTable, LaundrySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaundrySessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionDateMeta = const VerificationMeta(
    'sessionDate',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
    'session_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SessionStatus.berjalan.name),
      ).withConverter<SessionStatus>($LaundrySessionsTable.$converterstatus);
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionDate, status, verifiedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laundry_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LaundrySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_date')) {
      context.handle(
        _sessionDateMeta,
        sessionDate.isAcceptableOrUnknown(
          data['session_date']!,
          _sessionDateMeta,
        ),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LaundrySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LaundrySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_date'],
      )!,
      status: $LaundrySessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
    );
  }

  @override
  $LaundrySessionsTable createAlias(String alias) {
    return $LaundrySessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class LaundrySession extends DataClass implements Insertable<LaundrySession> {
  final int id;
  final DateTime sessionDate;
  final SessionStatus status;
  final DateTime? verifiedAt;
  const LaundrySession({
    required this.id,
    required this.sessionDate,
    required this.status,
    this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_date'] = Variable<DateTime>(sessionDate);
    {
      map['status'] = Variable<String>(
        $LaundrySessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    return map;
  }

  LaundrySessionsCompanion toCompanion(bool nullToAbsent) {
    return LaundrySessionsCompanion(
      id: Value(id),
      sessionDate: Value(sessionDate),
      status: Value(status),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
    );
  }

  factory LaundrySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LaundrySession(
      id: serializer.fromJson<int>(json['id']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      status: $LaundrySessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'status': serializer.toJson<String>(
        $LaundrySessionsTable.$converterstatus.toJson(status),
      ),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
    };
  }

  LaundrySession copyWith({
    int? id,
    DateTime? sessionDate,
    SessionStatus? status,
    Value<DateTime?> verifiedAt = const Value.absent(),
  }) => LaundrySession(
    id: id ?? this.id,
    sessionDate: sessionDate ?? this.sessionDate,
    status: status ?? this.status,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
  );
  LaundrySession copyWithCompanion(LaundrySessionsCompanion data) {
    return LaundrySession(
      id: data.id.present ? data.id.value : this.id,
      sessionDate: data.sessionDate.present
          ? data.sessionDate.value
          : this.sessionDate,
      status: data.status.present ? data.status.value : this.status,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LaundrySession(')
          ..write('id: $id, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionDate, status, verifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LaundrySession &&
          other.id == this.id &&
          other.sessionDate == this.sessionDate &&
          other.status == this.status &&
          other.verifiedAt == this.verifiedAt);
}

class LaundrySessionsCompanion extends UpdateCompanion<LaundrySession> {
  final Value<int> id;
  final Value<DateTime> sessionDate;
  final Value<SessionStatus> status;
  final Value<DateTime?> verifiedAt;
  const LaundrySessionsCompanion({
    this.id = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  });
  LaundrySessionsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.verifiedAt = const Value.absent(),
  });
  static Insertable<LaundrySession> custom({
    Expression<int>? id,
    Expression<DateTime>? sessionDate,
    Expression<String>? status,
    Expression<DateTime>? verifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionDate != null) 'session_date': sessionDate,
      if (status != null) 'status': status,
      if (verifiedAt != null) 'verified_at': verifiedAt,
    });
  }

  LaundrySessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? sessionDate,
    Value<SessionStatus>? status,
    Value<DateTime?>? verifiedAt,
  }) {
    return LaundrySessionsCompanion(
      id: id ?? this.id,
      sessionDate: sessionDate ?? this.sessionDate,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionDate.present) {
      map['session_date'] = Variable<DateTime>(sessionDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $LaundrySessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaundrySessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }
}

class $SessionItemsTable extends SessionItems
    with TableInfo<$SessionItemsTable, SessionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES laundry_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wardrobe_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quantityWashedMeta = const VerificationMeta(
    'quantityWashed',
  );
  @override
  late final GeneratedColumn<int> quantityWashed = GeneratedColumn<int>(
    'quantity_washed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityFoundMeta = const VerificationMeta(
    'quantityFound',
  );
  @override
  late final GeneratedColumn<int> quantityFound = GeneratedColumn<int>(
    'quantity_found',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    itemId,
    quantityWashed,
    quantityFound,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity_washed')) {
      context.handle(
        _quantityWashedMeta,
        quantityWashed.isAcceptableOrUnknown(
          data['quantity_washed']!,
          _quantityWashedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityWashedMeta);
    }
    if (data.containsKey('quantity_found')) {
      context.handle(
        _quantityFoundMeta,
        quantityFound.isAcceptableOrUnknown(
          data['quantity_found']!,
          _quantityFoundMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      quantityWashed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_washed'],
      )!,
      quantityFound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_found'],
      ),
    );
  }

  @override
  $SessionItemsTable createAlias(String alias) {
    return $SessionItemsTable(attachedDatabase, alias);
  }
}

class SessionItem extends DataClass implements Insertable<SessionItem> {
  final int id;
  final int sessionId;
  final int itemId;
  final int quantityWashed;
  final int? quantityFound;
  const SessionItem({
    required this.id,
    required this.sessionId,
    required this.itemId,
    required this.quantityWashed,
    this.quantityFound,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['item_id'] = Variable<int>(itemId);
    map['quantity_washed'] = Variable<int>(quantityWashed);
    if (!nullToAbsent || quantityFound != null) {
      map['quantity_found'] = Variable<int>(quantityFound);
    }
    return map;
  }

  SessionItemsCompanion toCompanion(bool nullToAbsent) {
    return SessionItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      quantityWashed: Value(quantityWashed),
      quantityFound: quantityFound == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityFound),
    );
  }

  factory SessionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionItem(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      quantityWashed: serializer.fromJson<int>(json['quantityWashed']),
      quantityFound: serializer.fromJson<int?>(json['quantityFound']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'itemId': serializer.toJson<int>(itemId),
      'quantityWashed': serializer.toJson<int>(quantityWashed),
      'quantityFound': serializer.toJson<int?>(quantityFound),
    };
  }

  SessionItem copyWith({
    int? id,
    int? sessionId,
    int? itemId,
    int? quantityWashed,
    Value<int?> quantityFound = const Value.absent(),
  }) => SessionItem(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    itemId: itemId ?? this.itemId,
    quantityWashed: quantityWashed ?? this.quantityWashed,
    quantityFound: quantityFound.present
        ? quantityFound.value
        : this.quantityFound,
  );
  SessionItem copyWithCompanion(SessionItemsCompanion data) {
    return SessionItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantityWashed: data.quantityWashed.present
          ? data.quantityWashed.value
          : this.quantityWashed,
      quantityFound: data.quantityFound.present
          ? data.quantityFound.value
          : this.quantityFound,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityWashed: $quantityWashed, ')
          ..write('quantityFound: $quantityFound')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, itemId, quantityWashed, quantityFound);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.itemId == this.itemId &&
          other.quantityWashed == this.quantityWashed &&
          other.quantityFound == this.quantityFound);
}

class SessionItemsCompanion extends UpdateCompanion<SessionItem> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> itemId;
  final Value<int> quantityWashed;
  final Value<int?> quantityFound;
  const SessionItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantityWashed = const Value.absent(),
    this.quantityFound = const Value.absent(),
  });
  SessionItemsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int itemId,
    required int quantityWashed,
    this.quantityFound = const Value.absent(),
  }) : sessionId = Value(sessionId),
       itemId = Value(itemId),
       quantityWashed = Value(quantityWashed);
  static Insertable<SessionItem> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? itemId,
    Expression<int>? quantityWashed,
    Expression<int>? quantityFound,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (itemId != null) 'item_id': itemId,
      if (quantityWashed != null) 'quantity_washed': quantityWashed,
      if (quantityFound != null) 'quantity_found': quantityFound,
    });
  }

  SessionItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? itemId,
    Value<int>? quantityWashed,
    Value<int?>? quantityFound,
  }) {
    return SessionItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      quantityWashed: quantityWashed ?? this.quantityWashed,
      quantityFound: quantityFound ?? this.quantityFound,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (quantityWashed.present) {
      map['quantity_washed'] = Variable<int>(quantityWashed.value);
    }
    if (quantityFound.present) {
      map['quantity_found'] = Variable<int>(quantityFound.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('quantityWashed: $quantityWashed, ')
          ..write('quantityFound: $quantityFound')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WardrobeItemsTable wardrobeItems = $WardrobeItemsTable(this);
  late final $LaundrySessionsTable laundrySessions = $LaundrySessionsTable(
    this,
  );
  late final $SessionItemsTable sessionItems = $SessionItemsTable(this);
  late final WardrobeDao wardrobeDao = WardrobeDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wardrobeItems,
    laundrySessions,
    sessionItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'laundry_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wardrobe_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WardrobeItemsTableCreateCompanionBuilder =
    WardrobeItemsCompanion Function({
      Value<int> id,
      required String name,
      required String iconName,
      required int quantityOwned,
      Value<DateTime> createdAt,
    });
typedef $$WardrobeItemsTableUpdateCompanionBuilder =
    WardrobeItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> iconName,
      Value<int> quantityOwned,
      Value<DateTime> createdAt,
    });

final class $$WardrobeItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WardrobeItemsTable, WardrobeItem> {
  $$WardrobeItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionItemsTable, List<SessionItem>>
  _sessionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionItems,
    aliasName: 'wardrobe_items__id__session_items__item_id',
  );

  $$SessionItemsTableProcessedTableManager get sessionItemsRefs {
    final manager = $$SessionItemsTableTableManager(
      $_db,
      $_db.sessionItems,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WardrobeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WardrobeItemsTable> {
  $$WardrobeItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionItemsRefs(
    Expression<bool> Function($$SessionItemsTableFilterComposer f) f,
  ) {
    final $$SessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WardrobeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WardrobeItemsTable> {
  $$WardrobeItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WardrobeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WardrobeItemsTable> {
  $$WardrobeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sessionItemsRefs<T extends Object>(
    Expression<T> Function($$SessionItemsTableAnnotationComposer a) f,
  ) {
    final $$SessionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WardrobeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WardrobeItemsTable,
          WardrobeItem,
          $$WardrobeItemsTableFilterComposer,
          $$WardrobeItemsTableOrderingComposer,
          $$WardrobeItemsTableAnnotationComposer,
          $$WardrobeItemsTableCreateCompanionBuilder,
          $$WardrobeItemsTableUpdateCompanionBuilder,
          (WardrobeItem, $$WardrobeItemsTableReferences),
          WardrobeItem,
          PrefetchHooks Function({bool sessionItemsRefs})
        > {
  $$WardrobeItemsTableTableManager(_$AppDatabase db, $WardrobeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WardrobeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WardrobeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WardrobeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> quantityOwned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WardrobeItemsCompanion(
                id: id,
                name: name,
                iconName: iconName,
                quantityOwned: quantityOwned,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String iconName,
                required int quantityOwned,
                Value<DateTime> createdAt = const Value.absent(),
              }) => WardrobeItemsCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                quantityOwned: quantityOwned,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WardrobeItemsTable, WardrobeItem>(table),
                  $$WardrobeItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionItemsRefs) db.sessionItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionItemsRefs)
                    await $_getPrefetchedData<
                      WardrobeItem,
                      $WardrobeItemsTable,
                      SessionItem
                    >(
                      currentTable: table,
                      referencedTable: $$WardrobeItemsTableReferences
                          ._sessionItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WardrobeItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WardrobeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WardrobeItemsTable,
      WardrobeItem,
      $$WardrobeItemsTableFilterComposer,
      $$WardrobeItemsTableOrderingComposer,
      $$WardrobeItemsTableAnnotationComposer,
      $$WardrobeItemsTableCreateCompanionBuilder,
      $$WardrobeItemsTableUpdateCompanionBuilder,
      (WardrobeItem, $$WardrobeItemsTableReferences),
      WardrobeItem,
      PrefetchHooks Function({bool sessionItemsRefs})
    >;
typedef $$LaundrySessionsTableCreateCompanionBuilder =
    LaundrySessionsCompanion Function({
      Value<int> id,
      Value<DateTime> sessionDate,
      Value<SessionStatus> status,
      Value<DateTime?> verifiedAt,
    });
typedef $$LaundrySessionsTableUpdateCompanionBuilder =
    LaundrySessionsCompanion Function({
      Value<int> id,
      Value<DateTime> sessionDate,
      Value<SessionStatus> status,
      Value<DateTime?> verifiedAt,
    });

final class $$LaundrySessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $LaundrySessionsTable, LaundrySession> {
  $$LaundrySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionItemsTable, List<SessionItem>>
  _sessionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionItems,
    aliasName: 'laundry_sessions__id__session_items__session_id',
  );

  $$SessionItemsTableProcessedTableManager get sessionItemsRefs {
    final manager = $$SessionItemsTableTableManager(
      $_db,
      $_db.sessionItems,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LaundrySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LaundrySessionsTable> {
  $$LaundrySessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionItemsRefs(
    Expression<bool> Function($$SessionItemsTableFilterComposer f) f,
  ) {
    final $$SessionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableFilterComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LaundrySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LaundrySessionsTable> {
  $$LaundrySessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LaundrySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaundrySessionsTable> {
  $$LaundrySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  Expression<T> sessionItemsRefs<T extends Object>(
    Expression<T> Function($$SessionItemsTableAnnotationComposer a) f,
  ) {
    final $$SessionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionItems,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LaundrySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LaundrySessionsTable,
          LaundrySession,
          $$LaundrySessionsTableFilterComposer,
          $$LaundrySessionsTableOrderingComposer,
          $$LaundrySessionsTableAnnotationComposer,
          $$LaundrySessionsTableCreateCompanionBuilder,
          $$LaundrySessionsTableUpdateCompanionBuilder,
          (LaundrySession, $$LaundrySessionsTableReferences),
          LaundrySession,
          PrefetchHooks Function({bool sessionItemsRefs})
        > {
  $$LaundrySessionsTableTableManager(
    _$AppDatabase db,
    $LaundrySessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaundrySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaundrySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaundrySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => LaundrySessionsCompanion(
                id: id,
                sessionDate: sessionDate,
                status: status,
                verifiedAt: verifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
              }) => LaundrySessionsCompanion.insert(
                id: id,
                sessionDate: sessionDate,
                status: status,
                verifiedAt: verifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LaundrySessionsTable, LaundrySession>(table),
                  $$LaundrySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionItemsRefs) db.sessionItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionItemsRefs)
                    await $_getPrefetchedData<
                      LaundrySession,
                      $LaundrySessionsTable,
                      SessionItem
                    >(
                      currentTable: table,
                      referencedTable: $$LaundrySessionsTableReferences
                          ._sessionItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LaundrySessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LaundrySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LaundrySessionsTable,
      LaundrySession,
      $$LaundrySessionsTableFilterComposer,
      $$LaundrySessionsTableOrderingComposer,
      $$LaundrySessionsTableAnnotationComposer,
      $$LaundrySessionsTableCreateCompanionBuilder,
      $$LaundrySessionsTableUpdateCompanionBuilder,
      (LaundrySession, $$LaundrySessionsTableReferences),
      LaundrySession,
      PrefetchHooks Function({bool sessionItemsRefs})
    >;
typedef $$SessionItemsTableCreateCompanionBuilder =
    SessionItemsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int itemId,
      required int quantityWashed,
      Value<int?> quantityFound,
    });
typedef $$SessionItemsTableUpdateCompanionBuilder =
    SessionItemsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> itemId,
      Value<int> quantityWashed,
      Value<int?> quantityFound,
    });

final class $$SessionItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionItemsTable, SessionItem> {
  $$SessionItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LaundrySessionsTable _sessionIdTable(_$AppDatabase db) => db
      .laundrySessions
      .createAlias('session_items__session_id__laundry_sessions__id');

  $$LaundrySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$LaundrySessionsTableTableManager(
      $_db,
      $_db.laundrySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WardrobeItemsTable _itemIdTable(_$AppDatabase db) => db.wardrobeItems
      .createAlias('session_items__item_id__wardrobe_items__id');

  $$WardrobeItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$WardrobeItemsTableTableManager(
      $_db,
      $_db.wardrobeItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableFilterComposer({
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

  ColumnFilters<int> get quantityWashed => $composableBuilder(
    column: $table.quantityWashed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityFound => $composableBuilder(
    column: $table.quantityFound,
    builder: (column) => ColumnFilters(column),
  );

  $$LaundrySessionsTableFilterComposer get sessionId {
    final $$LaundrySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.laundrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundrySessionsTableFilterComposer(
            $db: $db,
            $table: $db.laundrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WardrobeItemsTableFilterComposer get itemId {
    final $$WardrobeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.wardrobeItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardrobeItemsTableFilterComposer(
            $db: $db,
            $table: $db.wardrobeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableOrderingComposer({
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

  ColumnOrderings<int> get quantityWashed => $composableBuilder(
    column: $table.quantityWashed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityFound => $composableBuilder(
    column: $table.quantityFound,
    builder: (column) => ColumnOrderings(column),
  );

  $$LaundrySessionsTableOrderingComposer get sessionId {
    final $$LaundrySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.laundrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundrySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.laundrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WardrobeItemsTableOrderingComposer get itemId {
    final $$WardrobeItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.wardrobeItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardrobeItemsTableOrderingComposer(
            $db: $db,
            $table: $db.wardrobeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionItemsTable> {
  $$SessionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityWashed => $composableBuilder(
    column: $table.quantityWashed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityFound => $composableBuilder(
    column: $table.quantityFound,
    builder: (column) => column,
  );

  $$LaundrySessionsTableAnnotationComposer get sessionId {
    final $$LaundrySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.laundrySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundrySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.laundrySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WardrobeItemsTableAnnotationComposer get itemId {
    final $$WardrobeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.wardrobeItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WardrobeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wardrobeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionItemsTable,
          SessionItem,
          $$SessionItemsTableFilterComposer,
          $$SessionItemsTableOrderingComposer,
          $$SessionItemsTableAnnotationComposer,
          $$SessionItemsTableCreateCompanionBuilder,
          $$SessionItemsTableUpdateCompanionBuilder,
          (SessionItem, $$SessionItemsTableReferences),
          SessionItem,
          PrefetchHooks Function({bool sessionId, bool itemId})
        > {
  $$SessionItemsTableTableManager(_$AppDatabase db, $SessionItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> quantityWashed = const Value.absent(),
                Value<int?> quantityFound = const Value.absent(),
              }) => SessionItemsCompanion(
                id: id,
                sessionId: sessionId,
                itemId: itemId,
                quantityWashed: quantityWashed,
                quantityFound: quantityFound,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int itemId,
                required int quantityWashed,
                Value<int?> quantityFound = const Value.absent(),
              }) => SessionItemsCompanion.insert(
                id: id,
                sessionId: sessionId,
                itemId: itemId,
                quantityWashed: quantityWashed,
                quantityFound: quantityFound,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionItemsTable, SessionItem>(table),
                  $$SessionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, itemId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionItemsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionItemsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$SessionItemsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$SessionItemsTableReferences
                            ._itemIdTable(db)
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
        ),
      );
}

typedef $$SessionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionItemsTable,
      SessionItem,
      $$SessionItemsTableFilterComposer,
      $$SessionItemsTableOrderingComposer,
      $$SessionItemsTableAnnotationComposer,
      $$SessionItemsTableCreateCompanionBuilder,
      $$SessionItemsTableUpdateCompanionBuilder,
      (SessionItem, $$SessionItemsTableReferences),
      SessionItem,
      PrefetchHooks Function({bool sessionId, bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WardrobeItemsTableTableManager get wardrobeItems =>
      $$WardrobeItemsTableTableManager(_db, _db.wardrobeItems);
  $$LaundrySessionsTableTableManager get laundrySessions =>
      $$LaundrySessionsTableTableManager(_db, _db.laundrySessions);
  $$SessionItemsTableTableManager get sessionItems =>
      $$SessionItemsTableTableManager(_db, _db.sessionItems);
}
