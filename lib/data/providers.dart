import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/backup_repository.dart';
import 'package:cogni/data/repositories/game_progress_repository.dart';
import 'package:cogni/data/repositories/game_session_repository.dart';
import 'package:cogni/data/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abre la base de datos local y la cierra cuando el provider se descarta.
///
/// Se declara a mano, sin `@riverpod`, porque no hay estado que observar: solo
/// una dependencia de vida única. Así `lib/data/` no depende del codegen y los
/// tests pueden sobrescribirlo en el `ProviderScope` sin `@riverpod` también.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Repositorio de sesiones: único punto de escritura de `game_sessions`.
final gameSessionRepositoryProvider = Provider<GameSessionRepository>(
  (ref) => GameSessionRepository(ref.watch(appDatabaseProvider)),
);

/// Repositorio de progreso por juego.
final gameProgressRepositoryProvider = Provider<GameProgressRepository>(
  (ref) => GameProgressRepository(ref.watch(appDatabaseProvider)),
);

/// Repositorio de ajustes clave-valor.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Repositorio de backup: export e import del progreso del jugador (§5.5).
final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(ref.watch(appDatabaseProvider)),
);
