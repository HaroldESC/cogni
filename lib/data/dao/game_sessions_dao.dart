import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/db/tables/game_sessions.dart';
import 'package:drift/drift.dart';

part 'game_sessions_dao.g.dart';

/// Lecturas y escrituras de `game_sessions` (§5.3).
///
/// La unicidad de la sesión `active` por `(game_id, mode)` la impone el índice
/// parcial de la tabla (D-019); este DAO solo consulta, no la delega.
@DriftAccessor(tables: [GameSessions])
class GameSessionsDao extends DatabaseAccessor<AppDatabase>
    with _$GameSessionsDaoMixin {
  /// Accede a la misma base de datos que su `AppDatabase` contenedora.
  new(super.attachedDatabase);

  /// Sesión por su UUID (identidad global, D-015), viva o tombstone.
  Future<GameSession?> find(String uuid) {
    final query = select(db.gameSessions)..where((t) => t.uuid.equals(uuid));
    return query.getSingleOrNull();
  }

  /// La sesión `active` de un `(gameId, mode)`, o `null` si no hay.
  ///
  /// El índice parcial garantiza como mucho una fila, así que
  /// `getSingleOrNull` no puede fallar por multiplicidad.
  Future<GameSession?> findActive(String gameId, String mode) {
    final query = select(db.gameSessions)
      ..where(
        (t) =>
            t.gameId.equals(gameId) &
            t.mode.equals(mode) &
            t.status.equals('active') &
            t.deletedAt.isNull(),
      );
    return query.getSingleOrNull();
  }

  /// Sesiones vivas (sin filtrar por `status`), de la más reciente a la más
  /// antigua. Lo que se muestra en el historial y en la retoma.
  Stream<List<GameSession>> watchActiveSessions() {
    final query = select(db.gameSessions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch();
  }

  /// Todas las sesiones, **incluidos** tombstones: export de backup (§5.5).
  Future<List<GameSession>> getAll() => select(db.gameSessions).get();

  /// Inserta una sesión con el UUID ya generado por el repositorio.
  Future<void> insert(GameSessionsCompanion row) =>
      into(db.gameSessions).insert(row);

  /// Actualización por PK (`UPDATE ... WHERE uuid = ?`).
  ///
  /// Se usa `replace` de `UpdateStatement`, nunca `insertOrReplace`:
  /// `INSERT OR REPLACE` borraría físicamente la fila anterior y destruiría el
  /// `deleted_at` (D-015: los borrados son tombstones, no DELETE físico).
  Future<void> replace(GameSession row) => update(db.gameSessions).replace(row);

  /// Vaciado completo, reservado a la restauración de un import.
  Future<void> deleteAll() => delete(db.gameSessions).go();
}
