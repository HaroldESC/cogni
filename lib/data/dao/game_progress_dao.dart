import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/db/tables/game_progress.dart';
import 'package:drift/drift.dart';

part 'game_progress_dao.g.dart';

/// Lecturas y upserts de `game_progress` (§5.3).
///
/// Este DAO no genera identidad ni escribe `deleted_at`: los tombstones los
/// escribe solo el repositorio (D-015, regla 8 de AGENTS.md). El upsert va por
/// la clave natural `(game_id, mode)`, no por el surrogate `id` (D-019).
@DriftAccessor(tables: [GameProgress])
class GameProgressDao extends DatabaseAccessor<AppDatabase>
    with _$GameProgressDaoMixin {
  /// Accede a la misma base de datos que su `AppDatabase` contenedora.
  new(super.attachedDatabase);

  /// Fila de progreso de `(gameId, mode)`, viva o tombstone.
  Future<GameProgressData?> find(String gameId, String mode) {
    final query = select(db.gameProgress)
      ..where((t) => t.gameId.equals(gameId) & t.mode.equals(mode));
    return query.getSingleOrNull();
  }

  /// Progreso vivo (`deleted_at IS NULL`) de un juego, para la UI.
  Stream<List<GameProgressData>> watchForGame(
    String gameId, {
    String mode = 'default',
  }) {
    final query = select(db.gameProgress)
      ..where(
        (t) =>
            t.gameId.equals(gameId) &
            t.mode.equals(mode) &
            t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.mode)]);
    return query.watch();
  }

  /// Upsert por la clave natural `(game_id, mode)`.
  ///
  /// No toca `deleted_at`: la fila viene del repositorio y, si está ausente,
  /// SQLite conserva el valor que ya tuviera (no se reactivan tombstones).
  Future<void> upsert(GameProgressCompanion row) {
    return into(db.gameProgress).insert(
      row,
      onConflict: DoUpdate(
        (_) => row,
        target: [db.gameProgress.gameId, db.gameProgress.mode],
      ),
    );
  }

  /// Todas las filas, **incluidos** tombstones: es el origen del export de
  /// backup (§5.5), que debe poder restaurar borrados lógicos.
  Future<List<GameProgressData>> selectAll() => select(db.gameProgress).get();

  /// Vaciado completo, reservado a la restauración de un import.
  Future<void> deleteAll() => delete(db.gameProgress).go();
}
