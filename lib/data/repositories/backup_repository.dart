import 'dart:io';

import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/backup_codec.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Export e import del progreso del jugador (§5.5, D-024, D-035).
///
/// Es el único punto de escritura de las tres tablas cuando el origen de los
/// datos es un archivo: ni widgets ni notifiers tocan Drift (regla 8 de
/// `AGENTS.md`).
///
/// Dos garantías sostienen el import, y en este orden:
/// 1. Se **valida** el archivo —el sobre ([BackupCodec.decode]) y cada fila—
///    antes de escribir nada. Una fila que esta app no puede entender se
///    rechaza con [FormatException] en vez de resolverse en silencio por
///    `ON CONFLICT` (D-037).
/// 2. Se deja una **auto-copia previa** del estado actual en
///    `cogni-preimport-<fecha>.json` antes de la primera escritura, porque
///    «proteger el progreso» no puede convertirse en la forma de perderlo.
///
/// El import v1 es una *restauración*, no una fusión: sustituye el contenido
/// de `game_progress`, `game_sessions` y `settings` por el del archivo, dentro
/// de una transacción, conservando `uuid`, `updated_at` y `deleted_at` tal cual
/// venían (D-024). La confirmación explícita es de la UI (F3, Ajustes); este
/// método solo restaura.
class BackupRepository {
  /// Crea el repositorio sobre [db].
  ///
  /// [dataDir] es el directorio donde se escribe la auto-copia previa al
  /// import. Por defecto es el directorio de soporte de la aplicación, el
  /// mismo que usa `connection.dart` para `app.db`; los tests inyectan un
  /// directorio temporal.
  new(AppDatabase db, {Future<Directory> Function()? dataDir})
    : _db = db,
      _dataDir = dataDir ?? getApplicationSupportDirectory;

  final AppDatabase _db;

  /// Resuelve el directorio de la auto-copia; inyectado para poder testear.
  final Future<Directory> Function() _dataDir;

  /// Codec del formato v1; sin estado, se reutiliza.
  final BackupCodec _codec = BackupCodec();

  /// Prefijo del fichero de auto-copia previa al import (§5.5).
  static const String _preImportPrefix = 'cogni-preimport-';

  /// Estados admitidos por `game_sessions.status`: ni más ni menos (§5.2,
  /// D-017). Un backup con otro estado es de una versión que esta app no
  /// entiende y se rechaza en vez de restaurarse a medias.
  static const Set<String> _statuses = {'active', 'completed', 'abandoned'};

  /// Exporta las tres tablas a un backup JSON legible.
  ///
  /// Lectura pura: **no muta la base**. Incluye los tombstones (`deleted_at`)
  /// para que el backup pueda restaurar también los borrados lógicos (D-015).
  /// Las filas se ordenan por su clave natural para que dos exports del mismo
  /// estado den el mismo texto. `exported_at` es el instante actual en UTC
  /// (D-033).
  Future<String> exportToJson() async => _codec.encode(await _readAll());

  /// Restaura el estado de las tres tablas desde el backup [source].
  ///
  /// En orden: valida el archivo, resuelve las `active` duplicadas del propio
  /// archivo, convierte y valida cada fila, deja la auto-copia previa y, por
  /// último, sustituye el contenido dentro de una transacción. Un archivo
  /// inválido no escribe nada ni deja auto-copia: todas las comprobaciones
  /// [_sessionFromRow], [_validateProgressRows] y [_validateSettingRows]
  /// ocurren **antes** de [_writeSafetyCopy], así que un rechazo llega con la
  /// base intacta y sin red de seguridad malgastada. Si algo falla al
  /// escribir, la transacción revierte y la auto-copia sigue ahí para volver
  /// atrás.
  ///
  /// Un backup puede dejar `settings` **sin las semillas** de `onCreate`
  /// (§5.2): la restauración sustituye el contenido en vez de completarlo. En
  /// ese caso `SettingsRepository.read` devuelve `null` —ausencia, no un
  /// valor— y es el consumidor (F3+) quien aplica su default.
  Future<void> importFromJson(String source) async {
    // 1. Validar antes de tocar nada. Si el archivo no es un backup legible,
    //    aquí se para: ni escrituras ni auto-copia.
    final data = _codec.decode(source);

    // 2. Dos `active` para la misma pareja `(game_id, mode)`: el índice
    //    parcial de SQLite (D-019) rechazaría la segunda, así que la perdedora
    //    se degrada a `abandoned` ANTES de insertar (§5.4.2).
    final sessions = _degradeDuplicateActives(data.gameSessions);

    // 3. Convertir y validar fila a fila antes de escribir: una fila mal
    //    formada, con un estado desconocido, con un número negativo o
    //    duplicada en su clave natural falla aquí, sin haber tocado la base ni
    //    haber dejado la auto-copia.
    final sessionRows = sessions.map(_sessionFromRow).toList();
    final progressRows = _validateProgressRows(data.gameProgress);
    final settingRows = _validateSettingRows(data.settings);

    // 4. Auto-copia previa obligatoria del estado que se va a sustituir.
    await _writeSafetyCopy();

    // 5. Restauración. `deleteAll` + insert conserva el contenido exacto del
    //    archivo (tombstones incluidos) y evita mezclar filas del estado
    //    anterior con las del import.
    await _db.transaction(() async {
      await _db.settingsDao.deleteAll();
      await _db.gameProgressDao.deleteAll();
      await _db.gameSessionsDao.deleteAll();
      for (final row in settingRows) {
        await _db.settingsDao.upsert(row);
      }
      for (final row in progressRows) {
        await _db.gameProgressDao.upsert(row);
      }
      for (final row in sessionRows) {
        await _db.gameSessionsDao.insert(row);
      }
    });
  }

  /// Lee las tres tablas, con tombstones, y las mapea a filas del backup.
  Future<BackupData> _readAll() async {
    final sessions = await _db.gameSessionsDao.getAll();
    final progress = await _db.gameProgressDao.selectAll();
    final settings = await _db.settingsDao.selectAll();

    sessions.sort((a, b) => a.uuid.compareTo(b.uuid));
    progress.sort((a, b) {
      final byGame = a.gameId.compareTo(b.gameId);
      return byGame != 0 ? byGame : a.mode.compareTo(b.mode);
    });
    settings.sort((a, b) => a.key.compareTo(b.key));

    return BackupData(
      exportedAt: DateTime.now().toUtc(),
      gameSessions: sessions.map(_sessionToRow).toList(),
      gameProgress: progress.map(_progressToRow).toList(),
      settings: settings.map(_settingToRow).toList(),
    );
  }

  /// Escribe el estado actual en `cogni-preimport-<fecha>.json`.
  ///
  /// La fecha es `yyyyMMdd-HHmmss` en UTC (D-033). Si ya existe un fichero con
  /// esa misma marca, se añade `-2`, `-3`… para no sobrescribir una copia
  /// anterior: perder la auto-copia sería perder la red de seguridad.
  Future<void> _writeSafetyCopy() async {
    final snapshot = await exportToJson();
    final dir = await _dataDir();
    final exists = dir.existsSync();
    if (!exists) {
      await dir.create(recursive: true);
    }
    final stamp = _timestamp(DateTime.now().toUtc());
    await _freeFile(dir, stamp).writeAsString(snapshot);
  }

  /// Primer nombre libre para la auto-copia de la marca [stamp].
  File _freeFile(Directory dir, String stamp) {
    var candidate = File(p.join(dir.path, '$_preImportPrefix$stamp.json'));
    var attempt = 1;
    while (candidate.existsSync()) {
      attempt += 1;
      candidate = File(
        p.join(dir.path, '$_preImportPrefix$stamp-$attempt.json'),
      );
    }
    return candidate;
  }

  /// Devuelve las filas con las `active` duplicadas ya resueltas.
  ///
  /// Solo cuenta como duplicada una fila `active` **viva** (`deleted_at` nula):
  /// es lo que cubre el índice parcial de la tabla (D-019), y un tombstone
  /// libera el hueco sin necesidad de tocar `status`. Gana la de `updated_at`
  /// más reciente; a igualdad gana la de UUID mayor, para que el resultado sea
  /// determinista. Las perdedoras pasan a `abandoned` conservando su
  /// `updated_at`: es una restauración, no una escritura nueva.
  ///
  /// Las filas originales no se mutan; las que cambian de estado se copian.
  List<Map<String, Object?>> _degradeDuplicateActives(
    List<Map<String, Object?>> rows,
  ) {
    final winners = <String, _ActiveCandidate>{};
    final losers = <String>{};

    for (final row in rows) {
      if (row['status'] != 'active' || row['deleted_at'] != null) {
        continue;
      }
      final gameId = _readString(row, 'game_id');
      final mode = _readStringOr(row, 'mode', 'default');
      final candidate = _ActiveCandidate(
        uuid: _readString(row, 'uuid'),
        updatedAt: _readDate(row, 'updated_at'),
      );
      final key = '$gameId/$mode';
      final current = winners[key];
      if (current == null) {
        winners[key] = candidate;
      } else if (_isNewer(candidate, current)) {
        winners[key] = candidate;
        losers.add(current.uuid);
      } else {
        losers.add(candidate.uuid);
      }
    }

    if (losers.isEmpty) {
      return rows;
    }
    final restored = <Map<String, Object?>>[];
    for (final row in rows) {
      if (losers.contains(row['uuid'])) {
        final degraded = Map<String, Object?>.of(row);
        degraded['status'] = 'abandoned';
        restored.add(degraded);
      } else {
        restored.add(row);
      }
    }
    return restored;
  }

  /// Si [a] es más reciente que [b]; a igualdad de `updated_at`, la de UUID
  /// mayor, para que el degradado sea reproducible.
  bool _isNewer(_ActiveCandidate a, _ActiveCandidate b) {
    final byDate = a.updatedAt.compareTo(b.updatedAt);
    if (byDate != 0) {
      return byDate > 0;
    }
    return a.uuid.compareTo(b.uuid) > 0;
  }

  /// Marca `yyyyMMdd-HHmmss` en UTC para el nombre de la auto-copia.
  String _timestamp(DateTime utc) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}-'
        '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}';
  }

  /// Mapea una fila de `game_sessions` del backup al companion de Drift.
  GameSessionsCompanion _sessionFromRow(Map<String, Object?> row) {
    final status = _readString(row, 'status');
    if (!_statuses.contains(status)) {
      throw FormatException(
        'La sesión "${_readString(row, 'uuid')}" trae un estado desconocido: '
        '"$status" (se esperaba active, completed o abandoned).',
      );
    }
    return GameSessionsCompanion.insert(
      uuid: _readString(row, 'uuid'),
      gameId: _readString(row, 'game_id'),
      mode: Value(_readStringOr(row, 'mode', 'default')),
      status: status,
      checkpoint: _readInt(row, 'checkpoint'),
      position: _readInt(row, 'position'),
      score: Value(_readIntOr(row, 'score', 0)),
      stateJson: Value(_readStringOrNull(row, 'state_json')),
      startedAt: _readDate(row, 'started_at'),
      endedAt: Value(_readNullableDate(row, 'ended_at')),
      updatedAt: _readDate(row, 'updated_at'),
      deletedAt: Value(_readNullableDate(row, 'deleted_at')),
    );
  }

  /// Mapea una fila de `game_progress` del backup al companion de Drift.
  ///
  /// El surrogate `id` no se restaura: no viaja en el backup (D-015) y SQLite
  /// lo reasigna con su `autoIncrement`. La clave natural sigue siendo
  /// `(game_id, mode)`, así que el `DoUpdate` del DAO no puede colisionar.
  GameProgressCompanion _progressFromRow(Map<String, Object?> row) {
    return GameProgressCompanion.insert(
      gameId: _readString(row, 'game_id'),
      mode: Value(_readStringOr(row, 'mode', 'default')),
      unlockedUpTo: Value(_readNonNegativeIntOr(row, 'unlocked_up_to', 0)),
      bestScore: Value(_readNonNegativeIntOr(row, 'best_score', 0)),
      updatedAt: _readDate(row, 'updated_at'),
      deletedAt: Value(_readNullableDate(row, 'deleted_at')),
    );
  }

  /// Mapea una fila de `settings` del backup al companion de Drift.
  SettingsCompanion _settingFromRow(Map<String, Object?> row) {
    return SettingsCompanion.insert(
      key: _readString(row, 'key'),
      value: _readString(row, 'value'),
      updatedAt: _readDate(row, 'updated_at'),
      deletedAt: Value(_readNullableDate(row, 'deleted_at')),
    );
  }

  /// Convierte y valida todas las filas de `game_progress` del backup.
  ///
  /// Además de la forma de cada columna ([_progressFromRow]), rechaza dos
  /// filas con la misma clave natural `(game_id, mode)`: el
  /// `ON CONFLICT DO UPDATE` del DAO las resolvería en silencio y solo
  /// sobreviviría la última, perdiéndose el progreso de la otra sin dejar
  /// rastro. Un archivo cuya fila no se entiende se rechaza con
  /// [FormatException] en vez de restaurarse a medias (D-037).
  ///
  /// En `game_sessions` el duplicado no se comprueba aquí: la clave primaria es
  /// el `uuid`, y las `active` repetidas las resuelve
  /// [_degradeDuplicateActives] degradando a la perdedora (D-019).
  List<GameProgressCompanion> _validateProgressRows(
    List<Map<String, Object?>> rows,
  ) {
    final seen = <String>{};
    final companions = <GameProgressCompanion>[];
    for (final row in rows) {
      final companion = _progressFromRow(row);
      final key = '${companion.gameId.value}/${companion.mode.value}';
      if (!seen.add(key)) {
        throw FormatException(
          'game_progress duplicado: $key. Dos filas del backup comparten '
          'game_id y mode.',
        );
      }
      companions.add(companion);
    }
    return companions;
  }

  /// Convierte y valida todas las filas de `settings` del backup.
  ///
  /// Igual que [_validateProgressRows] para la clave natural `key`, que aquí es
  /// además la PK: un duplicado se perdería en el `insertOnConflictUpdate` del
  /// DAO (D-037).
  List<SettingsCompanion> _validateSettingRows(
    List<Map<String, Object?>> rows,
  ) {
    final seen = <String>{};
    final companions = <SettingsCompanion>[];
    for (final row in rows) {
      final companion = _settingFromRow(row);
      if (!seen.add(companion.key.value)) {
        throw FormatException(
          'settings duplicado: ${companion.key.value}. Dos filas del backup '
          'comparten key.',
        );
      }
      companions.add(companion);
    }
    return companions;
  }

  /// Mapea una sesión de la base a su fila del backup.
  Map<String, Object?> _sessionToRow(GameSession row) {
    return {
      'uuid': row.uuid,
      'game_id': row.gameId,
      'mode': row.mode,
      'status': row.status,
      'checkpoint': row.checkpoint,
      'position': row.position,
      'score': row.score,
      'state_json': row.stateJson,
      'started_at': _stamp(row.startedAt),
      'ended_at': _stampOrNull(row.endedAt),
      'updated_at': _stamp(row.updatedAt),
      'deleted_at': _stampOrNull(row.deletedAt),
    };
  }

  /// Mapea una fila de progreso de la base a su fila del backup.
  Map<String, Object?> _progressToRow(GameProgressData row) {
    return {
      'game_id': row.gameId,
      'mode': row.mode,
      'unlocked_up_to': row.unlockedUpTo,
      'best_score': row.bestScore,
      'updated_at': _stamp(row.updatedAt),
      'deleted_at': _stampOrNull(row.deletedAt),
    };
  }

  /// Mapea un ajuste de la base a su fila del backup.
  Map<String, Object?> _settingToRow(Setting row) {
    return {
      'key': row.key,
      'value': row.value,
      'updated_at': _stamp(row.updatedAt),
      'deleted_at': _stampOrNull(row.deletedAt),
    };
  }

  /// Fecha en ISO-8601 UTC para el JSON (D-033).
  String _stamp(DateTime value) => value.toUtc().toIso8601String();

  /// Fecha en ISO-8601 UTC, o `null` si la columna está vacía.
  String? _stampOrNull(DateTime? value) => value?.toUtc().toIso8601String();

  /// Lee un texto obligatorio de la fila del backup.
  String _readString(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is String) {
      return value;
    }
    throw FormatException(
      'El backup trae una fila sin la columna de texto "$column".',
    );
  }

  /// Lee un texto obligatorio o [fallback] si la columna no viene.
  String _readStringOr(
    Map<String, Object?> row,
    String column,
    String fallback,
  ) {
    final value = row[column];
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value;
    }
    throw FormatException(
      'El backup trae una fila con "$column" que no es texto.',
    );
  }

  /// Lee un texto nullable de la fila del backup.
  String? _readStringOrNull(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    throw FormatException(
      'El backup trae una fila con "$column" que no es texto.',
    );
  }

  /// Lee un entero obligatorio de la fila del backup.
  int _readInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is int) {
      return value;
    }
    throw FormatException('El backup trae una fila sin el número "$column".');
  }

  /// Lee un entero o [fallback] si la columna no viene.
  int _readIntOr(Map<String, Object?> row, String column, int fallback) {
    final value = row[column];
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    throw FormatException(
      'El backup trae una fila con "$column" que no es un número.',
    );
  }

  /// Lee un entero no negativo o [fallback] si la columna no viene.
  ///
  /// Un progreso o una puntuación negativos no son un estado que esta app
  /// pueda haber producido: se rechaza el archivo en vez de guardarlos y
  /// dejar que una futura restaura los revierta en silencio (D-037).
  int _readNonNegativeIntOr(
    Map<String, Object?> row,
    String column,
    int fallback,
  ) {
    final value = _readIntOr(row, column, fallback);
    if (value < 0) {
      throw FormatException('El backup trae "$column" negativo: $value.');
    }
    return value;
  }

  /// Lee una fecha obligatoria y la normaliza a UTC (D-033).
  DateTime _readDate(Map<String, Object?> row, String column) {
    final parsed = _tryReadDate(row, column);
    if (parsed == null) {
      throw FormatException('El backup trae una fila sin la fecha "$column".');
    }
    return parsed;
  }

  /// Lee una fecha nullable y la normaliza a UTC (D-033).
  DateTime? _readNullableDate(Map<String, Object?> row, String column) {
    if (row[column] == null) {
      return null;
    }
    final parsed = _tryReadDate(row, column);
    if (parsed == null) {
      throw FormatException(
        'El backup trae una fila con "$column" que no es una fecha ISO-8601.',
      );
    }
    return parsed;
  }

  /// Intenta leer una fecha ISO-8601; `null` si no está o no se puede leer.
  DateTime? _tryReadDate(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}

/// Candidata a sesión `active` mientras se resuelven los duplicados del import.
class _ActiveCandidate {
  /// Crea la candidata con su identidad global y su marca de actualización.
  const new({required this.uuid, required this.updatedAt});

  /// UUID v4 de la sesión (identidad global, D-015).
  final String uuid;

  /// Marca `updated_at` ya normalizada a UTC: decide quién gana.
  final DateTime updatedAt;
}
