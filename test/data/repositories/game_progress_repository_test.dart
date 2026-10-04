import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/game_progress_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late GameProgressRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = GameProgressRepository(db);
  });

  test('record crea la fila con los valores dados', () async {
    final row = await repository.record(
      'pi_memory',
      unlockedUpTo: 100,
      bestScore: 250,
    );

    expect(row.gameId, 'pi_memory');
    expect(row.mode, 'default');
    expect(row.unlockedUpTo, 100);
    expect(row.bestScore, 250);
    expect(row.deletedAt, isNull);
    expect(row.updatedAt.isUtc, isTrue);
  });

  test('record es monótono: ni unlockedUpTo ni bestScore retroceden', () async {
    await repository.record('pi_memory', unlockedUpTo: 100, bestScore: 250);
    final row = await repository.record(
      'pi_memory',
      unlockedUpTo: 40,
      bestScore: 10,
    );

    expect(row.unlockedUpTo, 100);
    expect(row.bestScore, 250);
  });

  test('record revive un tombstone conservando los máximos', () async {
    await db.gameProgressDao.upsert(
      GameProgressCompanion.insert(
        gameId: 'pi_memory',
        unlockedUpTo: const Value(60),
        bestScore: const Value(80),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: Value(DateTime.now().toUtc()),
      ),
    );

    final row = await repository.record(
      'pi_memory',
      unlockedUpTo: 20,
      bestScore: 5,
    );

    expect(row.deletedAt, isNull);
    expect(row.unlockedUpTo, 60);
    expect(row.bestScore, 80);
  });

  test('watchForGame solo emite filas vivas', () async {
    await db.gameProgressDao.upsert(
      GameProgressCompanion.insert(
        gameId: 'pi_memory',
        unlockedUpTo: const Value(60),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await db.gameProgressDao.upsert(
      GameProgressCompanion.insert(
        gameId: 'pi_memory',
        mode: const Value('expert'),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: Value(DateTime.now().toUtc()),
      ),
    );

    final rows = await repository.watchForGame('pi_memory').first;

    expect(rows, hasLength(1));
    expect(rows.single.mode, 'default');
    expect(rows.single.unlockedUpTo, 60);
    expect(rows.single.deletedAt, isNull);
  });

  test(
    'record concurrente es atómico: se conserva el máximo, no el último',
    () async {
      await repository.record('pi_memory', unlockedUpTo: 100);

      await Future.wait<void>(<Future<void>>[
        repository.record('pi_memory', unlockedUpTo: 120, bestScore: 5),
        repository.record('pi_memory', unlockedUpTo: 110, bestScore: 3),
      ]);

      final row = await db.gameProgressDao.find('pi_memory', 'default');
      expect(row!.unlockedUpTo, 120);
      expect(row.bestScore, 5);
    },
  );
}
