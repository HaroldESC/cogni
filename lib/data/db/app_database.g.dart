// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GameProgressTable extends GameProgress
    with TableInfo<$GameProgressTable, GameProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _unlockedUpToMeta = const VerificationMeta(
    'unlockedUpTo',
  );
  @override
  late final GeneratedColumn<int> unlockedUpTo = GeneratedColumn<int>(
    'unlocked_up_to',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    mode,
    unlockedUpTo,
    bestScore,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('unlocked_up_to')) {
      context.handle(
        _unlockedUpToMeta,
        unlockedUpTo.isAcceptableOrUnknown(
          data['unlocked_up_to']!,
          _unlockedUpToMeta,
        ),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      unlockedUpTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_up_to'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GameProgressTable createAlias(String alias) {
    return $GameProgressTable(attachedDatabase, alias);
  }
}

class GameProgressData extends DataClass
    implements Insertable<GameProgressData> {
  /// Surrogate local del progreso: no viaja a sync (D-015).
  final int id;

  /// Juego al que pertenece la fila de progreso (`pi_memory`, `mental_sums`).
  final String gameId;

  /// Modo de juego; `default` si no se indicó.
  final String mode;

  /// Siguiente umbral desbloqueado, en dígitos (π: 120).
  final int unlockedUpTo;

  /// Mejor puntuación registrada en el juego.
  final int bestScore;

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  final DateTime updatedAt;

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  final DateTime? deletedAt;
  const GameProgressData({
    required this.id,
    required this.gameId,
    required this.mode,
    required this.unlockedUpTo,
    required this.bestScore,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<String>(gameId);
    map['mode'] = Variable<String>(mode);
    map['unlocked_up_to'] = Variable<int>(unlockedUpTo);
    map['best_score'] = Variable<int>(bestScore);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GameProgressCompanion toCompanion(bool nullToAbsent) {
    return GameProgressCompanion(
      id: Value(id),
      gameId: Value(gameId),
      mode: Value(mode),
      unlockedUpTo: Value(unlockedUpTo),
      bestScore: Value(bestScore),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory GameProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameProgressData(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      mode: serializer.fromJson<String>(json['mode']),
      unlockedUpTo: serializer.fromJson<int>(json['unlockedUpTo']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<String>(gameId),
      'mode': serializer.toJson<String>(mode),
      'unlockedUpTo': serializer.toJson<int>(unlockedUpTo),
      'bestScore': serializer.toJson<int>(bestScore),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GameProgressData copyWith({
    int? id,
    String? gameId,
    String? mode,
    int? unlockedUpTo,
    int? bestScore,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GameProgressData(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    mode: mode ?? this.mode,
    unlockedUpTo: unlockedUpTo ?? this.unlockedUpTo,
    bestScore: bestScore ?? this.bestScore,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GameProgressData copyWithCompanion(GameProgressCompanion data) {
    return GameProgressData(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      mode: data.mode.present ? data.mode.value : this.mode,
      unlockedUpTo: data.unlockedUpTo.present
          ? data.unlockedUpTo.value
          : this.unlockedUpTo,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameProgressData(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('unlockedUpTo: $unlockedUpTo, ')
          ..write('bestScore: $bestScore, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    mode,
    unlockedUpTo,
    bestScore,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameProgressData &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.mode == this.mode &&
          other.unlockedUpTo == this.unlockedUpTo &&
          other.bestScore == this.bestScore &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GameProgressCompanion extends UpdateCompanion<GameProgressData> {
  final Value<int> id;
  final Value<String> gameId;
  final Value<String> mode;
  final Value<int> unlockedUpTo;
  final Value<int> bestScore;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const GameProgressCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.mode = const Value.absent(),
    this.unlockedUpTo = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  GameProgressCompanion.insert({
    this.id = const Value.absent(),
    required String gameId,
    this.mode = const Value.absent(),
    this.unlockedUpTo = const Value.absent(),
    this.bestScore = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : gameId = Value(gameId),
       updatedAt = Value(updatedAt);
  static Insertable<GameProgressData> custom({
    Expression<int>? id,
    Expression<String>? gameId,
    Expression<String>? mode,
    Expression<int>? unlockedUpTo,
    Expression<int>? bestScore,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (mode != null) 'mode': mode,
      if (unlockedUpTo != null) 'unlocked_up_to': unlockedUpTo,
      if (bestScore != null) 'best_score': bestScore,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  GameProgressCompanion copyWith({
    Value<int>? id,
    Value<String>? gameId,
    Value<String>? mode,
    Value<int>? unlockedUpTo,
    Value<int>? bestScore,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return GameProgressCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      unlockedUpTo: unlockedUpTo ?? this.unlockedUpTo,
      bestScore: bestScore ?? this.bestScore,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (unlockedUpTo.present) {
      map['unlocked_up_to'] = Variable<int>(unlockedUpTo.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameProgressCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('unlockedUpTo: $unlockedUpTo, ')
          ..write('bestScore: $bestScore, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkpointMeta = const VerificationMeta(
    'checkpoint',
  );
  @override
  late final GeneratedColumn<int> checkpoint = GeneratedColumn<int>(
    'checkpoint',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    gameId,
    mode,
    status,
    checkpoint,
    position,
    score,
    stateJson,
    startedAt,
    endedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checkpoint')) {
      context.handle(
        _checkpointMeta,
        checkpoint.isAcceptableOrUnknown(data['checkpoint']!, _checkpointMeta),
      );
    } else if (isInserting) {
      context.missing(_checkpointMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      checkpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checkpoint'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  /// UUID v4 generado en el cliente ANTES del insert: es la PK y la identidad
  /// global. Sin él, un autoIncrement solo sería único por dispositivo
  /// (D-015).
  final String uuid;

  /// Juego al que pertenece la sesión (`pi_memory`, `mental_sums`).
  final String gameId;

  /// Modo de juego; `default` si no se indicó.
  final String mode;

  /// Estado de la sesión: `active | completed | abandoned` (sin `paused`,
  /// D-017).
  final String status;

  /// Checkpoint alcanzado, para la retoma de la sesión.
  final int checkpoint;

  /// Posición actual dentro de la secuencia, en dígitos.
  final int position;

  /// Puntuación acumulada en la sesión.
  final int score;

  /// Estado en memoria de la sesión serializado en JSON; `NULL` si no hay.
  final String? stateJson;

  /// Momento de inicio de la sesión.
  final DateTime startedAt;

  /// Momento de fin; `NULL` mientras la sesión no haya terminado.
  final DateTime? endedAt;

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  final DateTime updatedAt;

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  final DateTime? deletedAt;
  const GameSession({
    required this.uuid,
    required this.gameId,
    required this.mode,
    required this.status,
    required this.checkpoint,
    required this.position,
    required this.score,
    this.stateJson,
    required this.startedAt,
    this.endedAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['game_id'] = Variable<String>(gameId);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    map['checkpoint'] = Variable<int>(checkpoint);
    map['position'] = Variable<int>(position);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || stateJson != null) {
      map['state_json'] = Variable<String>(stateJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      uuid: Value(uuid),
      gameId: Value(gameId),
      mode: Value(mode),
      status: Value(status),
      checkpoint: Value(checkpoint),
      position: Value(position),
      score: Value(score),
      stateJson: stateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(stateJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      uuid: serializer.fromJson<String>(json['uuid']),
      gameId: serializer.fromJson<String>(json['gameId']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      checkpoint: serializer.fromJson<int>(json['checkpoint']),
      position: serializer.fromJson<int>(json['position']),
      score: serializer.fromJson<int>(json['score']),
      stateJson: serializer.fromJson<String?>(json['stateJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'gameId': serializer.toJson<String>(gameId),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'checkpoint': serializer.toJson<int>(checkpoint),
      'position': serializer.toJson<int>(position),
      'score': serializer.toJson<int>(score),
      'stateJson': serializer.toJson<String?>(stateJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GameSession copyWith({
    String? uuid,
    String? gameId,
    String? mode,
    String? status,
    int? checkpoint,
    int? position,
    int? score,
    Value<String?> stateJson = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GameSession(
    uuid: uuid ?? this.uuid,
    gameId: gameId ?? this.gameId,
    mode: mode ?? this.mode,
    status: status ?? this.status,
    checkpoint: checkpoint ?? this.checkpoint,
    position: position ?? this.position,
    score: score ?? this.score,
    stateJson: stateJson.present ? stateJson.value : this.stateJson,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      checkpoint: data.checkpoint.present
          ? data.checkpoint.value
          : this.checkpoint,
      position: data.position.present ? data.position.value : this.position,
      score: data.score.present ? data.score.value : this.score,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('uuid: $uuid, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('checkpoint: $checkpoint, ')
          ..write('position: $position, ')
          ..write('score: $score, ')
          ..write('stateJson: $stateJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    gameId,
    mode,
    status,
    checkpoint,
    position,
    score,
    stateJson,
    startedAt,
    endedAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.uuid == this.uuid &&
          other.gameId == this.gameId &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.checkpoint == this.checkpoint &&
          other.position == this.position &&
          other.score == this.score &&
          other.stateJson == this.stateJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<String> uuid;
  final Value<String> gameId;
  final Value<String> mode;
  final Value<String> status;
  final Value<int> checkpoint;
  final Value<int> position;
  final Value<int> score;
  final Value<String?> stateJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.uuid = const Value.absent(),
    this.gameId = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.checkpoint = const Value.absent(),
    this.position = const Value.absent(),
    this.score = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String uuid,
    required String gameId,
    this.mode = const Value.absent(),
    required String status,
    required int checkpoint,
    required int position,
    this.score = const Value.absent(),
    this.stateJson = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       gameId = Value(gameId),
       status = Value(status),
       checkpoint = Value(checkpoint),
       position = Value(position),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<GameSession> custom({
    Expression<String>? uuid,
    Expression<String>? gameId,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<int>? checkpoint,
    Expression<int>? position,
    Expression<int>? score,
    Expression<String>? stateJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (gameId != null) 'game_id': gameId,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (checkpoint != null) 'checkpoint': checkpoint,
      if (position != null) 'position': position,
      if (score != null) 'score': score,
      if (stateJson != null) 'state_json': stateJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? gameId,
    Value<String>? mode,
    Value<String>? status,
    Value<int>? checkpoint,
    Value<int>? position,
    Value<int>? score,
    Value<String?>? stateJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GameSessionsCompanion(
      uuid: uuid ?? this.uuid,
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      checkpoint: checkpoint ?? this.checkpoint,
      position: position ?? this.position,
      score: score ?? this.score,
      stateJson: stateJson ?? this.stateJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checkpoint.present) {
      map['checkpoint'] = Variable<int>(checkpoint.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('gameId: $gameId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('checkpoint: $checkpoint, ')
          ..write('position: $position, ')
          ..write('score: $score, ')
          ..write('stateJson: $stateJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
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
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  /// Clave namespaciada por feature; es la PK (identidad global, D-015).
  final String key;

  /// Valor de la clave, como JSON serializado (D-036): `20`, `1000`,
  /// `"system"`.
  final String value;

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  final DateTime updatedAt;

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  final DateTime? deletedAt;
  const Setting({
    required this.key,
    required this.value,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Setting copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Setting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GameProgressTable gameProgress = $GameProgressTable(this);
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index progressGameMode = Index(
    'progress_game_mode',
    'CREATE UNIQUE INDEX progress_game_mode ON game_progress (game_id, mode)',
  );
  late final Index idxOneActiveSession = Index(
    'idx_one_active_session',
    'CREATE UNIQUE INDEX idx_one_active_session ON game_sessions (game_id, mode) WHERE status = \'active\' AND deleted_at IS NULL',
  );
  late final GameProgressDao gameProgressDao = GameProgressDao(
    this as AppDatabase,
  );
  late final GameSessionsDao gameSessionsDao = GameSessionsDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gameProgress,
    gameSessions,
    settings,
    progressGameMode,
    idxOneActiveSession,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$GameProgressTableCreateCompanionBuilder =
    GameProgressCompanion Function({
      Value<int> id,
      required String gameId,
      Value<String> mode,
      Value<int> unlockedUpTo,
      Value<int> bestScore,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$GameProgressTableUpdateCompanionBuilder =
    GameProgressCompanion Function({
      Value<int> id,
      Value<String> gameId,
      Value<String> mode,
      Value<int> unlockedUpTo,
      Value<int> bestScore,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$GameProgressTableFilterComposer
    extends Composer<_$AppDatabase, $GameProgressTable> {
  $$GameProgressTableFilterComposer({
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

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedUpTo => $composableBuilder(
    column: $table.unlockedUpTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $GameProgressTable> {
  $$GameProgressTableOrderingComposer({
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

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedUpTo => $composableBuilder(
    column: $table.unlockedUpTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameProgressTable> {
  $$GameProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get unlockedUpTo => $composableBuilder(
    column: $table.unlockedUpTo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$GameProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameProgressTable,
          GameProgressData,
          $$GameProgressTableFilterComposer,
          $$GameProgressTableOrderingComposer,
          $$GameProgressTableAnnotationComposer,
          $$GameProgressTableCreateCompanionBuilder,
          $$GameProgressTableUpdateCompanionBuilder,
          (
            GameProgressData,
            BaseReferences<_$AppDatabase, $GameProgressTable, GameProgressData>,
          ),
          GameProgressData,
          PrefetchHooks Function()
        > {
  $$GameProgressTableTableManager(_$AppDatabase db, $GameProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> unlockedUpTo = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => GameProgressCompanion(
                id: id,
                gameId: gameId,
                mode: mode,
                unlockedUpTo: unlockedUpTo,
                bestScore: bestScore,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gameId,
                Value<String> mode = const Value.absent(),
                Value<int> unlockedUpTo = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => GameProgressCompanion.insert(
                id: id,
                gameId: gameId,
                mode: mode,
                unlockedUpTo: unlockedUpTo,
                bestScore: bestScore,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameProgressTable, GameProgressData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameProgressTable,
                    GameProgressData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameProgressTable,
      GameProgressData,
      $$GameProgressTableFilterComposer,
      $$GameProgressTableOrderingComposer,
      $$GameProgressTableAnnotationComposer,
      $$GameProgressTableCreateCompanionBuilder,
      $$GameProgressTableUpdateCompanionBuilder,
      (
        GameProgressData,
        BaseReferences<_$AppDatabase, $GameProgressTable, GameProgressData>,
      ),
      GameProgressData,
      PrefetchHooks Function()
    >;
typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      required String uuid,
      required String gameId,
      Value<String> mode,
      required String status,
      required int checkpoint,
      required int position,
      Value<int> score,
      Value<String?> stateJson,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<String> uuid,
      Value<String> gameId,
      Value<String> mode,
      Value<String> status,
      Value<int> checkpoint,
      Value<int> position,
      Value<int> score,
      Value<String?> stateJson,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkpoint => $composableBuilder(
    column: $table.checkpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkpoint => $composableBuilder(
    column: $table.checkpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get checkpoint => $composableBuilder(
    column: $table.checkpoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (
            GameSession,
            BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
          ),
          GameSession,
          PrefetchHooks Function()
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> checkpoint = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> stateJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion(
                uuid: uuid,
                gameId: gameId,
                mode: mode,
                status: status,
                checkpoint: checkpoint,
                position: position,
                score: score,
                stateJson: stateJson,
                startedAt: startedAt,
                endedAt: endedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String gameId,
                Value<String> mode = const Value.absent(),
                required String status,
                required int checkpoint,
                required int position,
                Value<int> score = const Value.absent(),
                Value<String?> stateJson = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                uuid: uuid,
                gameId: gameId,
                mode: mode,
                status: status,
                checkpoint: checkpoint,
                position: position,
                score: score,
                stateJson: stateJson,
                startedAt: startedAt,
                endedAt: endedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSessionsTable, GameSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameSessionsTable,
                    GameSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (
        GameSession,
        BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
      ),
      GameSession,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
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
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GameProgressTableTableManager get gameProgress =>
      $$GameProgressTableTableManager(_db, _db.gameProgress);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
