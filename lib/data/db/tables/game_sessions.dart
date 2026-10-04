import 'package:drift/drift.dart';

/// Sesiones de juego: una fila por partida (§5.2).
///
/// "A lo sumo una sesión active por (game_id, mode)" (§5.2) no se delega al
/// repositorio: la impone un índice único PARCIAL (D-019). `@TableIndex.sql`
/// acepta la sentencia completa, `WHERE` incluido, y `m.createAll()` (el
/// `onCreate` por defecto de Drift) crea los índices junto con las tablas: no
/// hace falta `customStatement` a mano.
///
/// Si en una versión futura del esquema se añadiera este índice a una base ya
/// existente, se crea en `onUpgrade`; y si ya hubiera dos filas activas,
/// SQLite rechaza el índice, así que habría que resolver los duplicados antes
/// de crearlo.
@TableIndex.sql('''
  CREATE UNIQUE INDEX idx_one_active_session
    ON game_sessions (game_id, mode)
    WHERE status = 'active' AND deleted_at IS NULL
''')
class GameSessions extends Table {
  /// UUID v4 generado en el cliente ANTES del insert: es la PK y la identidad
  /// global. Sin él, un autoIncrement solo sería único por dispositivo
  /// (D-015).
  TextColumn get uuid => text()();

  /// Juego al que pertenece la sesión (`pi_memory`, `mental_sums`).
  TextColumn get gameId => text()();

  /// Modo de juego; `default` si no se indicó.
  TextColumn get mode => text().withDefault(const Constant('default'))();

  /// Estado de la sesión: `active | completed | abandoned` (sin `paused`,
  /// D-017).
  TextColumn get status => text()();

  /// Checkpoint alcanzado, para la retoma de la sesión.
  IntColumn get checkpoint => integer()();

  /// Posición actual dentro de la secuencia, en dígitos.
  IntColumn get position => integer()();

  /// Puntuación acumulada en la sesión.
  IntColumn get score => integer().withDefault(const Constant(0))();

  /// Estado en memoria de la sesión serializado en JSON; `NULL` si no hay.
  TextColumn get stateJson => text().nullable()();

  /// Momento de inicio de la sesión.
  DateTimeColumn get startedAt => dateTime()();

  /// Momento de fin; `NULL` mientras la sesión no haya terminado.
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  DateTimeColumn get updatedAt => dateTime()();

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// PK: `uuid` (identidad global, D-015).
  @override
  Set<Column<Object>> get primaryKey => {uuid};
}
