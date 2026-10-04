import 'package:drift/drift.dart';

/// Progreso de un `(gameId, mode)` de un juego (§5.2).
///
/// Identidad global de la tabla: la pareja (gameId, mode) es la que viaja a
/// sync, nunca `id` (D-015). El índice no solo documenta la restricción: la
/// cumple SQLite (no se pueden insertar dos filas con el mismo juego+modo)
/// (D-019).
@TableIndex(name: 'progress_game_mode', columns: {#gameId, #mode}, unique: true)
class GameProgress extends Table {
  /// Surrogate local del progreso: no viaja a sync (D-015).
  IntColumn get id => integer().autoIncrement()();

  /// Juego al que pertenece la fila de progreso (`pi_memory`, `mental_sums`).
  TextColumn get gameId => text()();

  /// Modo de juego; `default` si no se indicó.
  TextColumn get mode => text().withDefault(const Constant('default'))();

  /// Siguiente umbral desbloqueado, en dígitos (π: 120).
  IntColumn get unlockedUpTo => integer().withDefault(const Constant(0))();

  /// Mejor puntuación registrada en el juego.
  IntColumn get bestScore => integer().withDefault(const Constant(0))();

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  DateTimeColumn get updatedAt => dateTime()();

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
