import 'dart:math' as math;

import 'package:cogni/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// Único punto de escritura de `game_progress` (regla 8 de `AGENTS.md`).
///
/// El progreso del jugador se protege: `unlocked_up_to` y `best_score` son
/// monótonos (§5.4.2), nunca retroceden, y los borrados son tombstones que
/// [record] revive conservando el máximo en vez de borrar la fila (D-015).
class GameProgressRepository {
  /// Crea el repositorio sobre la base de datos dada.
  new(AppDatabase db) : _db = db;

  final AppDatabase _db;

  /// Fila de `(gameId, mode)`, viva o tombstone.
  Future<GameProgressData?> find(String gameId, {String mode = 'default'}) {
    return _db.gameProgressDao.find(gameId, mode);
  }

  /// Progreso vivo de un juego, reactivo.
  Stream<List<GameProgressData>> watchForGame(
    String gameId, {
    String mode = 'default',
  }) {
    return _db.gameProgressDao.watchForGame(gameId, mode: mode);
  }

  /// Registra el progreso de `(gameId, mode)` y devuelve la fila resultante.
  ///
  /// Cada campo se queda con el máximo entre lo ya guardado y lo recibido, de
  /// modo que un `record` atrasado o con valores menores no hace retroceder el
  /// progreso.
  ///
  /// La lectura del máximo actual y el upsert ocurren dentro de la **misma
  /// transacción**, y por eso la monotonía se sostiene aunque dos `record`
  /// concurrentes se intercalen (el ejecutor de producción corre en el isolate
  /// de fondo, §5.1): sin ella ambos leerían el mismo máximo y el último en
  /// escribir dejaría por debajo al otro (§5.4.2).
  ///
  /// El companion lleva `deletedAt: const Value(null)`, así que un tombstone
  /// se revive (`deleted_at` a `NULL`) sin perder ese máximo (D-015).
  Future<GameProgressData> record(
    String gameId, {
    required int unlockedUpTo,
    String mode = 'default',
    int bestScore = 0,
  }) {
    return _db.transaction(() async {
      final current = await find(gameId, mode: mode);
      final now = DateTime.now().toUtc();
      await _db.gameProgressDao.upsert(
        GameProgressCompanion.insert(
          gameId: gameId,
          mode: Value(mode),
          unlockedUpTo: Value(
            math.max(current?.unlockedUpTo ?? 0, unlockedUpTo),
          ),
          bestScore: Value(math.max(current?.bestScore ?? 0, bestScore)),
          updatedAt: now,
          deletedAt: const Value(null),
        ),
      );
      final saved = await find(gameId, mode: mode);
      if (saved == null) {
        throw StateError('progress row missing after upsert: $gameId/$mode');
      }
      return saved;
    });
  }
}
