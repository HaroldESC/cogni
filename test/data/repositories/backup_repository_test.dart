import 'dart:convert';
import 'dart:io';

import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/backup_codec.dart';
import 'package:cogni/data/repositories/backup_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// Instante UTC fijo: determinismo en los archivos comparados.
final _instant = DateTime.utc(2026, 10, 3, 10);

/// Nombre de la auto-copia previa al import (§5.5): `cogni-preimport-`
/// seguido de la marca UTC `yyyyMMdd-HHmmss` y, si el fichero ya existe, un
/// sufijo `-2`, `-3`… para no pisar una copia anterior.
final _autoCopyName = RegExp(r'^cogni-preimport-\d{8}-\d{6}(-\d+)?\.json$');

/// Fila de sesión tal y como viaja en el archivo de backup.
Map<String, Object?> _sessionRow({
  required String uuid,
  String gameId = 'pi_memory',
  String mode = 'default',
  String status = 'active',
  int checkpoint = 20,
  String startedAt = '2026-10-03T10:00:00.000Z',
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'uuid': uuid,
    'game_id': gameId,
    'mode': mode,
    'status': status,
    'checkpoint': checkpoint,
    'position': checkpoint,
    'score': 0,
    'state_json': null,
    'started_at': startedAt,
    'ended_at': null,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Fila de progreso del archivo: clave natural, sin `id` surrogate (D-015).
Map<String, Object?> _progressRow({
  String gameId = 'pi_memory',
  String mode = 'default',
  int unlockedUpTo = 120,
  int bestScore = 40,
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'game_id': gameId,
    'mode': mode,
    'unlocked_up_to': unlockedUpTo,
    'best_score': bestScore,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Fila de settings del archivo, con el `value` en JSON serializado (D-036).
Map<String, Object?> _settingRow({
  String key = 'pi.checkpoint_every',
  String value = '20',
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'key': key,
    'value': value,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Construye un archivo de backup completo y válido a partir de filas Dart.
String _backupJson({
  List<Map<String, Object?>> sessions = const [],
  List<Map<String, Object?>> progress = const [],
  List<Map<String, Object?>> settings = const [],
  Object? format = kBackupFormat,
  int formatVersion = kBackupFormatVersion,
}) {
  return jsonEncode(<String, Object?>{
    'format': format,
    'format_version': formatVersion,
    'app_version': kBackupAppVersion,
    'exported_at': '2026-10-03T09:00:00.000Z',
    'data': <String, Object?>{
      'game_progress': progress,
      'game_sessions': sessions,
      'settings': settings,
    },
  });
}

/// Inserta una sesión viva directamente por DAO (repository bypass: aquí se
/// prueba el repositorio de backup, no el de sesiones).
Future<void> _insertSession(
  AppDatabase db, {
  required String uuid,
  String status = 'active',
  int checkpoint = 0,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) async {
  await db.gameSessionsDao.insert(
    GameSessionsCompanion.insert(
      uuid: uuid,
      gameId: 'pi_memory',
      status: status,
      checkpoint: checkpoint,
      position: checkpoint,
      startedAt: _instant,
      updatedAt: updatedAt ?? _instant,
      deletedAt: Value(deletedAt),
    ),
  );
}

/// Recuento de filas de las tres tablas: la firma de "no he tocado nada".
Future<List<int>> _rowCounts(AppDatabase db) async {
  return <int>[
    (await db.gameProgressDao.selectAll()).length,
    (await db.gameSessionsDao.getAll()).length,
    (await db.settingsDao.selectAll()).length,
  ];
}

/// `data` del backup exportado, ya decodificado.
Future<Map<String, Object?>> _exportData(BackupRepository repo) async {
  final root = jsonDecode(await repo.exportToJson()) as Map<String, Object?>;
  return root['data']! as Map<String, Object?>;
}

/// Estado de las tres tablas del archivo exportado, como `uuid: status`.
Future<Map<String, String>> _statusesByUuid(BackupRepository repo) async {
  final sessions = (await _exportData(repo))['game_sessions']! as List<Object?>;
  return <String, String>{
    for (final row in sessions.cast<Map<String, Object?>>())
      row['uuid']! as String: row['status']! as String,
  };
}

/// Matcher de [FormatException] cuyo mensaje contiene [text]: deja claro que
/// el import se rechaza **por esa causa concreta** y no por un `TypeError`
/// colateral al decodificar el archivo.
Matcher _formatError(String text) {
  return throwsA(
    isA<FormatException>().having((e) => e.message, 'message', contains(text)),
  );
}

/// Tests del export/import de backups (Fase B, §5.5).
///
/// El `dataDir` se inyecta con un temporal por test, así que la auto-copia se
/// puede inspeccionar sin tocar el directorio real de la app. Lo que se fija:
/// `export` es lectura pura (tombstones incluidos, fechas ISO-8601 UTC),
/// `import` sustituye el contenido conservando `uuid`/`updated_at`/`deleted_at`
/// (D-015), deja siempre una auto-copia del estado previo, no toca nada si el
/// archivo es inválido y degrada a `abandoned` la `active` perdedora cuando el
/// archivo trae dos para el mismo `(game_id, mode)` (D-019, D-017).
void main() {
  late AppDatabase db;
  late Directory dir;
  late BackupRepository repo;

  setUp(() {
    db = createTestDatabase();
    dir = Directory.systemTemp.createTempSync('cogni-bk');
    repo = BackupRepository(db, dataDir: () async => dir);
    addTearDown(() => dir.delete(recursive: true));
  });

  test('export es lectura pura: no muta la base', () async {
    await _insertSession(db, uuid: 'uuid-a');
    final before = await _rowCounts(db);

    final encoded = await repo.exportToJson();

    expect(encoded, isNotEmpty);
    expect(await _rowCounts(db), before);
  });

  test('export incluye tombstones y fechas ISO-8601 en UTC', () async {
    await _insertSession(
      db,
      uuid: 'uuid-tombstone',
      status: 'completed',
      deletedAt: DateTime.utc(2026, 10, 3, 12),
    );

    final data = await _exportData(repo);
    final sessions = (data['game_sessions']! as List<Object?>)
        .cast<Map<String, Object?>>();
    final row = sessions.singleWhere((r) => r['uuid'] == 'uuid-tombstone');

    expect(row['deleted_at'], isNotNull);
    expect(row['updated_at'], endsWith('Z'));
    expect(row['started_at'], endsWith('Z'));
    expect(
      DateTime.parse(row['deleted_at']! as String).toUtc(),
      DateTime.utc(2026, 10, 3, 12),
    );
  });

  test('import restaura: sustituye el contenido y conserva '
      'uuid/updated_at/deleted_at', () async {
    await _insertSession(db, uuid: 'uuid-a', checkpoint: 5);
    expect(await db.settingsDao.read('pi.checkpoint_every'), '20');

    await repo.importFromJson(
      _backupJson(
        sessions: <Map<String, Object?>>[
          _sessionRow(
            uuid: 'uuid-b',
            status: 'completed',
            checkpoint: 60,
            updatedAt: '2026-10-03T11:30:00.000Z',
            deletedAt: '2026-10-03T12:00:00.000Z',
          ),
        ],
        progress: <Map<String, Object?>>[
          _progressRow(
            unlockedUpTo: 200,
            updatedAt: '2026-10-03T11:30:00.000Z',
          ),
        ],
        settings: <Map<String, Object?>>[
          _settingRow(value: '50', updatedAt: '2026-10-03T11:30:00.000Z'),
        ],
      ),
    );

    final sessions = await db.gameSessionsDao.getAll();
    expect(sessions.map((s) => s.uuid), <String>['uuid-b']);
    expect(sessions.single.checkpoint, 60);
    expect(sessions.single.updatedAt, DateTime.utc(2026, 10, 3, 11, 30));
    expect(sessions.single.deletedAt, DateTime.utc(2026, 10, 3, 12));
    expect(await db.gameSessionsDao.find('uuid-a'), isNull);

    final progress = await db.gameProgressDao.find('pi_memory', 'default');
    expect(progress!.unlockedUpTo, 200);

    expect(await db.settingsDao.read('pi.checkpoint_every'), '50');
    expect(await db.settingsDao.selectAll(), hasLength(1));
  });

  test('import crea la auto-copia cogni-preimport-<fecha>.json con el estado '
      'previo', () async {
    await _insertSession(db, uuid: 'uuid-a');

    await repo.importFromJson(
      _backupJson(
        sessions: <Map<String, Object?>>[_sessionRow(uuid: 'uuid-b')],
        settings: <Map<String, Object?>>[_settingRow(value: '50')],
      ),
    );

    final files = dir.listSync().whereType<File>().toList();
    expect(files, hasLength(1));
    expect(files.single.path, endsWith('.json'));
    expect(files.single.uri.pathSegments.last, matches(_autoCopyName));

    final previous = BackupCodec().decode(await files.single.readAsString());
    final seeds = {
      for (final row in previous.settings) row['key']: row['value'],
    };
    expect(seeds['pi.checkpoint_every'], '20');
    expect(previous.gameSessions.map((r) => r['uuid']), <String>['uuid-a']);
  });

  test(
    'import con archivo inválido no escribe nada ni deja auto-copia',
    () async {
      await _insertSession(db, uuid: 'uuid-a');
      final before = await _rowCounts(db);

      await expectLater(
        repo.importFromJson(_backupJson(format: 'otra-cosa')),
        throwsFormatException,
      );

      expect(await _rowCounts(db), before);
      expect(await db.settingsDao.read('pi.checkpoint_every'), '20');
      expect(dir.listSync(), isEmpty);
    },
  );

  test('import respeta los tombstones del archivo', () async {
    await repo.importFromJson(
      _backupJson(
        sessions: <Map<String, Object?>>[
          _sessionRow(
            uuid: 'uuid-tombstone',
            status: 'completed',
            updatedAt: '2026-10-03T11:00:00.000Z',
            deletedAt: '2026-10-03T11:30:00.000Z',
          ),
        ],
      ),
    );

    final row = await db.gameSessionsDao.find('uuid-tombstone');
    expect(row, isNotNull);
    expect(row!.deletedAt, DateTime.utc(2026, 10, 3, 11, 30));
  });

  test('import degrada a abandoned la active perdedora si el archivo trae dos '
      'activas iguales', () async {
    await repo.importFromJson(
      _backupJson(
        sessions: <Map<String, Object?>>[
          _sessionRow(uuid: 'uuid-vieja'),
          _sessionRow(
            uuid: 'uuid-nueva',
            checkpoint: 40,
            updatedAt: '2026-10-03T11:00:00.000Z',
          ),
        ],
      ),
    );

    final winner = await db.gameSessionsDao.find('uuid-nueva');
    expect(winner!.status, 'active');
    expect(winner.updatedAt, DateTime.utc(2026, 10, 3, 11));

    final loser = await db.gameSessionsDao.find('uuid-vieja');
    expect(loser!.status, 'abandoned');
    expect(loser.updatedAt, DateTime.utc(2026, 10, 3, 10));
  });

  test('las fechas del import se leen en UTC (D-033)', () async {
    await repo.importFromJson(
      _backupJson(
        sessions: <Map<String, Object?>>[
          _sessionRow(
            uuid: 'uuid-utc',
            status: 'completed',
            updatedAt: '2026-10-03T11:00:00.000Z',
            deletedAt: '2026-10-03T11:30:00.000Z',
          ),
        ],
      ),
    );

    final row = (await db.gameSessionsDao.find('uuid-utc'))!;
    expect(row.startedAt.isUtc, isTrue);
    expect(row.updatedAt.isUtc, isTrue);
    expect(row.startedAt, DateTime.utc(2026, 10, 3, 10));
    expect(row.updatedAt, DateTime.utc(2026, 10, 3, 11));
    expect(row.deletedAt!.isUtc, isTrue);
  });

  test(
    'import desempata por uuid si dos activas comparten updated_at',
    () async {
      await repo.importFromJson(
        _backupJson(
          sessions: <Map<String, Object?>>[
            _sessionRow(uuid: 'aaa-uuid'),
            _sessionRow(uuid: 'zzz-uuid'),
          ],
        ),
      );

      expect(await _statusesByUuid(repo), <String, String>{
        'aaa-uuid': 'abandoned',
        'zzz-uuid': 'active',
      });
    },
  );

  test('import deja exactamente una activa si el archivo trae tres', () async {
    final sessions = <Map<String, Object?>>[
      _sessionRow(uuid: 'uuid-1', updatedAt: '2026-10-03T09:00:00.000Z'),
      _sessionRow(uuid: 'uuid-2'),
      _sessionRow(uuid: 'uuid-3', updatedAt: '2026-10-03T11:00:00.000Z'),
    ];

    await repo.importFromJson(_backupJson(sessions: sessions));

    final statuses = await _statusesByUuid(repo);
    expect(statuses.values.where((s) => s == 'active'), hasLength(1));
    expect(statuses['uuid-3'], 'active');
    expect(statuses['uuid-1'], 'abandoned');
    expect(statuses['uuid-2'], 'abandoned');
  });

  test('una fila corrupta no escribe ni deja auto-copia: status pausado '
      'no existe (D-017)', () async {
    await _insertSession(db, uuid: 'uuid-a');
    final before = await _rowCounts(db);

    await expectLater(
      repo.importFromJson(
        _backupJson(
          sessions: <Map<String, Object?>>[
            _sessionRow(uuid: 'uuid-x', status: 'paused'),
          ],
        ),
      ),
      _formatError('estado desconocido'),
    );

    expect(await _rowCounts(db), before);
    expect(dir.listSync(), isEmpty);
  });

  test(
    'import rechaza game_progress duplicado sin escribir nada (D-037)',
    () async {
      await _insertSession(db, uuid: 'uuid-a');
      final before = await _rowCounts(db);

      await expectLater(
        repo.importFromJson(
          _backupJson(
            progress: <Map<String, Object?>>[_progressRow(), _progressRow()],
          ),
        ),
        _formatError('game_progress duplicado'),
      );

      expect(await _rowCounts(db), before);
      expect(dir.listSync(), isEmpty);
    },
  );

  test('import rechaza settings duplicado sin escribir nada (D-037)', () async {
    await _insertSession(db, uuid: 'uuid-a');
    final before = await _rowCounts(db);

    await expectLater(
      repo.importFromJson(
        _backupJson(
          settings: <Map<String, Object?>>[_settingRow(), _settingRow()],
        ),
      ),
      _formatError('settings duplicado'),
    );

    expect(await _rowCounts(db), before);
    expect(dir.listSync(), isEmpty);
  });

  test('import rechaza un negativo sin escribir nada (D-037)', () async {
    await _insertSession(db, uuid: 'uuid-a');
    final before = await _rowCounts(db);

    await expectLater(
      repo.importFromJson(
        _backupJson(
          progress: <Map<String, Object?>>[_progressRow(unlockedUpTo: -5)],
        ),
      ),
      _formatError('negativo'),
    );

    expect(await _rowCounts(db), before);
    expect(dir.listSync(), isEmpty);
  });
}
