import 'package:cogni/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// Tests de esquema de `AppDatabase` (§5.1, §5.2, §5.3).
///
/// Cada test arranca con una base en memoria recién creada: la primera
/// consulta dispara `onCreate` (`m.createAll()` + semillas).
void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  test('spike: sqlite3 del host responde a la primera consulta', () async {
    // Si el binario de SQLite no se pudiera cargar en el host, esta línea
    // lanza aquí con el error exacto del driver.
    final rows = await db.select(db.settings).get();
    expect(rows, hasLength(3));
  });

  test('onCreate crea las tres semillas de §5.2 como JSON (D-036)', () async {
    final rows = await db.select(db.settings).get();
    final byKey = {for (final row in rows) row.key: row};

    expect(byKey, hasLength(3));
    expect(byKey['pi.checkpoint_every']?.value, '20');
    expect(byKey['sums.initial_speed_ms']?.value, '1000');
    expect(byKey['app.theme']?.value, '"system"');
    expect(byKey['pi.checkpoint_every']?.deletedAt, isNull);
    expect(byKey['sums.initial_speed_ms']?.deletedAt, isNull);
    expect(byKey['app.theme']?.deletedAt, isNull);
  });

  test('el índice único de progress admite un solo (gameId, mode)', () async {
    final now = DateTime.now().toUtc();
    final first = GameProgressCompanion.insert(
      gameId: 'pi_memory',
      updatedAt: now,
    );
    final duplicate = GameProgressCompanion.insert(
      gameId: 'pi_memory',
      updatedAt: now,
    );
    final otherMode = GameProgressCompanion.insert(
      gameId: 'pi_memory',
      mode: const Value('other'),
      updatedAt: now,
    );

    await db.into(db.gameProgress).insert(first);

    await expectLater(
      db.into(db.gameProgress).insert(duplicate),
      throwsA(
        isA<Exception>().having(
          (e) => '$e',
          'mensaje',
          contains('UNIQUE constraint failed'),
        ),
      ),
    );

    await db.into(db.gameProgress).insert(otherMode);
    expect(await db.select(db.gameProgress).get(), hasLength(2));
  });

  test('el índice parcial admite una sola active por (gameId, mode)', () async {
    final now = DateTime.now().toUtc();

    GameSessionsCompanion session(String uuid) => GameSessionsCompanion.insert(
      uuid: uuid,
      gameId: 'pi_memory',
      status: 'active',
      checkpoint: 0,
      position: 0,
      startedAt: now,
      updatedAt: now,
    );

    await db.into(db.gameSessions).insert(session('u1'));

    await expectLater(
      db.into(db.gameSessions).insert(session('u2')),
      throwsA(
        isA<Exception>().having(
          (e) => '$e',
          'mensaje',
          contains('UNIQUE constraint failed'),
        ),
      ),
    );

    // Pasar la primera a `abandoned` (UPDATE por PK, nunca INSERT OR REPLACE)
    // libera la ventana del índice y la segunda entra.
    final first = await db.gameSessionsDao.find('u1');
    expect(first, isNotNull);
    await db.gameSessionsDao.replace(first!.copyWith(status: 'abandoned'));
    await db.into(db.gameSessions).insert(session('u2'));

    // Un tombstone en la fila `active` también libera el hueco, aunque su
    // `status` siga siendo `active` (§5.4.2).
    final second = await db.gameSessionsDao.find('u2');
    expect(second, isNotNull);
    await db.gameSessionsDao.replace(second!.copyWith(deletedAt: Value(now)));
    await db.into(db.gameSessions).insert(session('u3'));

    expect(await db.gameSessionsDao.getAll(), hasLength(3));
    expect(
      await db.gameSessionsDao.findActive('pi_memory', 'default'),
      isNotNull,
    );
  });

  test('updatedAt y startedAt se leen en UTC (D-033)', () async {
    final now = DateTime.now().toUtc();

    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(key: 'test.utc', value: '1', updatedAt: now),
        );
    await db
        .into(db.gameProgress)
        .insert(
          GameProgressCompanion.insert(gameId: 'pi_memory', updatedAt: now),
        );
    await db
        .into(db.gameSessions)
        .insert(
          GameSessionsCompanion.insert(
            uuid: 'u1',
            gameId: 'pi_memory',
            status: 'active',
            checkpoint: 0,
            position: 0,
            startedAt: now,
            updatedAt: now,
          ),
        );

    final setting = await (db.select(
      db.settings,
    )..where((t) => t.key.equals('test.utc'))).getSingle();
    final progress = await db.select(db.gameProgress).getSingle();
    final session = await db.select(db.gameSessions).getSingle();

    expect(setting.updatedAt.isUtc, isTrue);
    expect(progress.updatedAt.isUtc, isTrue);
    expect(session.startedAt.isUtc, isTrue);
    expect(session.updatedAt.isUtc, isTrue);
  });
}
