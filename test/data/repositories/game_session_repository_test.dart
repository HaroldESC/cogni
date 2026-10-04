import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/game_session_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// Forma de un UUID v4 generado en cliente (D-015).
final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// Instante UTC para los arrangements que escriben filas a mano.
DateTime _utcNow() => DateTime.now().toUtc();

void main() {
  late AppDatabase db;
  late GameSessionRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = GameSessionRepository(db);
  });

  test('startSession devuelve un uuid v4 y crea la sesión activa', () async {
    final uuid = await repository.startSession('pi_memory');

    expect(uuid, matches(_uuidV4));

    final session = await repository.findActive('pi_memory');
    expect(session, isNotNull);
    expect(session!.uuid, uuid);
    expect(session.gameId, 'pi_memory');
    expect(session.mode, 'default');
    expect(session.status, 'active');
    expect(session.checkpoint, 0);
    expect(session.position, 0);
    expect(session.score, 0);
    expect(session.endedAt, isNull);
    expect(session.deletedAt, isNull);
    expect(session.startedAt.isUtc, isTrue);
    expect(session.updatedAt.isUtc, isTrue);
  });

  test('startSession degrada a abandoned la activa previa', () async {
    final first = await repository.startSession('pi_memory');
    final second = await repository.startSession('pi_memory');

    final degraded = await db.gameSessionsDao.find(first);
    expect(degraded!.status, 'abandoned');

    final active = await repository.findActive('pi_memory');
    expect(active!.uuid, second);
    expect(active.status, 'active');
  });

  test('startSession no degrada la activa de otro modo', () async {
    final normal = await repository.startSession('pi_memory');
    final expert = await repository.startSession('pi_memory', mode: 'expert');

    expect(normal, isNot(expert));
    expect((await repository.findActive('pi_memory'))!.status, 'active');
    expect(
      (await repository.findActive('pi_memory', mode: 'expert'))!.status,
      'active',
    );
  });

  test('updateSession guarda checkpoint y posición sin tocar status', () async {
    final uuid = await repository.startSession('pi_memory');
    await repository.updateSession(
      uuid,
      checkpoint: 20,
      position: 42,
      stateJson: '{"digits":"3.14"}',
    );

    final saved = await repository.findActive('pi_memory');
    expect(saved!.checkpoint, 20);
    expect(saved.position, 42);
    expect(saved.stateJson, '{"digits":"3.14"}');
    expect(saved.status, 'active');
  });

  test('updateSession no borra score ni stateJson si no se informan', () async {
    final uuid = await repository.startSession('pi_memory');
    await repository.updateSession(
      uuid,
      checkpoint: 20,
      position: 42,
      score: 7,
      stateJson: '{"digits":"3.14"}',
    );
    await repository.updateSession(uuid, checkpoint: 40, position: 80);

    final saved = await repository.findActive('pi_memory');
    expect(saved!.checkpoint, 40);
    expect(saved.position, 80);
    expect(saved.score, 7);
    expect(saved.stateJson, '{"digits":"3.14"}');
  });

  test(
    'StateError si la sesión no existe, es tombstone o no está activa',
    () async {
      // 1. UUID inexistente.
      await expectLater(
        repository.updateSession('no-existe', checkpoint: 1, position: 1),
        throwsStateError,
      );

      // 2. Fila con `deleted_at`: para el repositorio no existe.
      final ghost = await repository.startSession('mental_sums');
      final tombstoned = await db.gameSessionsDao.find(ghost);
      await db.gameSessionsDao.replace(
        tombstoned!.copyWith(deletedAt: Value(_utcNow())),
      );
      await expectLater(
        repository.updateSession(ghost, checkpoint: 1, position: 1),
        throwsStateError,
      );

      // 3. Sesión ya cerrada.
      final done = await repository.startSession('pi_memory');
      await repository.completeSession(done);
      await expectLater(repository.abandonSession(done), throwsStateError);
    },
  );

  test('completeSession y abandonSession cierran la sesión', () async {
    final done = await repository.startSession('pi_memory');
    await repository.completeSession(done);

    final completed = await db.gameSessionsDao.find(done);
    expect(completed!.status, 'completed');
    expect(completed.endedAt, isNotNull);
    expect(completed.updatedAt.isUtc, isTrue);
    expect(await repository.findActive('pi_memory'), isNull);

    final dropped = await repository.startSession('mental_sums');
    await repository.abandonSession(dropped);

    final abandoned = await db.gameSessionsDao.find(dropped);
    expect(abandoned!.status, 'abandoned');
    expect(abandoned.endedAt, isNull);
    expect(await repository.findActive('mental_sums'), isNull);
  });
}
