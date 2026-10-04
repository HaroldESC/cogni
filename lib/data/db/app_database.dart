import 'package:cogni/data/dao/game_progress_dao.dart';
import 'package:cogni/data/dao/game_sessions_dao.dart';
import 'package:cogni/data/dao/settings_dao.dart';
import 'package:cogni/data/db/connection.dart';
import 'package:cogni/data/db/tables/game_progress.dart';
import 'package:cogni/data/db/tables/game_sessions.dart';
import 'package:cogni/data/db/tables/settings.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Base de datos local de Cogni: Drift sobre SQLite, sin backend (D-010).
///
/// Esquema v1 (§5.3): `game_progress`, `game_sessions` y `settings`, todas con
/// `updated_at` y `deleted_at` (D-015). Los repositorios de
/// `lib/data/repositories/` son los únicos puntos de escritura; los DAOs solo
/// leen y hacen upsert.
@DriftDatabase(
  tables: [GameProgress, GameSessions, Settings],
  daos: [GameProgressDao, GameSessionsDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  /// En producción usa la conexión de `connection.dart` (`app.db`); los tests
  /// inyectan `NativeDatabase.memory()` pasando su executor.
  new([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    // En F1 no hay ninguna migración que aplicar, pero la estrategia se
    // declara ya: ningún cambio de esquema futuro podrá pasar por borrar
    // la BD y perder el progreso del jugador (regla 12, §5.1).
    onUpgrade: (m, from, to) async {},
  );

  /// Semillas de §5.2, escritas solo en `onCreate` (primera ejecución).
  ///
  /// `value` es JSON serializado (D-036): `20`, `1000`, `"system"`.
  Future<void> _seedDefaults() async {
    final now = DateTime.now().toUtc();
    await batch((b) {
      b
        ..insert(
          settings,
          SettingsCompanion.insert(
            key: 'pi.checkpoint_every',
            value: '20',
            updatedAt: now,
          ),
        )
        ..insert(
          settings,
          SettingsCompanion.insert(
            key: 'sums.initial_speed_ms',
            value: '1000',
            updatedAt: now,
          ),
        )
        ..insert(
          settings,
          SettingsCompanion.insert(
            key: 'app.theme',
            value: '"system"',
            updatedAt: now,
          ),
        );
    });
  }
}
