import 'package:cogni/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Único punto de escritura de `game_sessions` (regla 8 de `AGENTS.md`).
///
/// Aquí se generan los UUID v4 (D-015) y se escriben `updated_at` y
/// `ended_at`; ni widgets ni notifiers tocan Drift directamente. La
/// invariante de una sola sesión `active` por `(game_id, mode)` (D-019) se
/// respeta degradando a `abandoned` la anterior **antes** de insertar, no
/// delegándola en el índice parcial de SQLite.
class GameSessionRepository {
  /// Crea el repositorio sobre la base de datos dada.
  new(this._db);

  final AppDatabase _db;

  /// Generador de identidad global; v4, cliente (D-015).
  static const _uuid = Uuid();

  /// Sesiones vivas (sin `deleted_at`), de la más reciente a la más antigua.
  Stream<List<GameSession>> watchActiveSessions() {
    return _db.gameSessionsDao.watchActiveSessions();
  }

  /// La sesión `active` de `(gameId, mode)`, o `null` si no hay ninguna.
  Future<GameSession?> findActive(String gameId, {String mode = 'default'}) {
    return _db.gameSessionsDao.findActive(gameId, mode);
  }

  /// Arranca una sesión y devuelve su UUID v4.
  ///
  /// Si ya existía una `active` para la misma pareja `(gameId, mode)`, se la
  /// degrada a `abandoned` primero: el índice parcial (D-019) rechazaría dos
  /// `active` a la vez, así que el orden de las escrituras es lo que sostiene
  /// la invariante.
  Future<String> startSession(String gameId, {String mode = 'default'}) {
    return _db.transaction(() async {
      final previous = await findActive(gameId, mode: mode);
      if (previous != null) {
        await _db.gameSessionsDao.replace(
          previous.copyWith(status: 'abandoned', updatedAt: _now()),
        );
      }
      final now = _now();
      final uuid = _uuid.v4();
      await _db.gameSessionsDao.insert(
        GameSessionsCompanion.insert(
          uuid: uuid,
          gameId: gameId,
          mode: Value(mode),
          status: 'active',
          checkpoint: 0,
          position: 0,
          score: const Value(0),
          startedAt: now,
          updatedAt: now,
        ),
      );
      return uuid;
    });
  }

  /// Guarda checkpoint y posición de la sesión activa.
  ///
  /// `score` y `stateJson` solo se escriben si vienen informed: omitirlos no
  /// borra lo que ya había. Nunca cambia `status`; guardar no es pausar, y
  /// `paused` no existe como estado persistido (D-017).
  Future<void> updateSession(
    String uuid, {
    required int checkpoint,
    required int position,
    int? score,
    String? stateJson,
  }) async {
    final session = await _requireActive(uuid);
    await _db.gameSessionsDao.replace(
      session.copyWith(
        checkpoint: checkpoint,
        position: position,
        score: score ?? session.score,
        stateJson: Value(stateJson ?? session.stateJson),
        updatedAt: _now(),
      ),
    );
  }

  /// Cierra la sesión activa como `completed` y marca `ended_at`.
  Future<void> completeSession(String uuid) async {
    final session = await _requireActive(uuid);
    final now = _now();
    await _db.gameSessionsDao.replace(
      session.copyWith(
        status: 'completed',
        endedAt: Value(now),
        updatedAt: now,
      ),
    );
  }

  /// Cierra la sesión activa como `abandoned`, sin tocar `ended_at`.
  ///
  /// Es el mismo camino que usa [startSession] al degradar la activa previa.
  Future<void> abandonSession(String uuid) async {
    final session = await _requireActive(uuid);
    await _db.gameSessionsDao.replace(
      session.copyWith(status: 'abandoned', updatedAt: _now()),
    );
  }

  /// Lee la sesión y comprueba que es operable: existe, no es tombstone y
  /// sigue `active`.
  Future<GameSession> _requireActive(String uuid) async {
    final session = await _db.gameSessionsDao.find(uuid);
    if (session == null || session.deletedAt != null) {
      throw StateError('session not found: $uuid');
    }
    if (session.status != 'active') {
      throw StateError('session is not active: $uuid');
    }
    return session;
  }

  /// Instante actual en UTC para todo lo que se persiste (D-033).
  DateTime _now() => DateTime.now().toUtc();
}
