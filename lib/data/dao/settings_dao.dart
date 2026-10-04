import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/db/tables/settings.dart';
import 'package:drift/drift.dart';

part 'settings_dao.g.dart';

/// Lecturas y escrituras de `settings`, la tabla clave-valor (§5.2).
///
/// `key` es la PK (clave natural namespaciada por feature) y `value` guarda
/// JSON serializado (D-036). Las lecturas normales ignoran los tombstones;
/// `find` y `selectAll` no, porque el export necesita verlos (§5.5).
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  /// Accede a la misma base de datos que su `AppDatabase` contenedora.
  new(super.attachedDatabase);

  /// Fila de la clave, viva o tombstone. Para la UI usar [read].
  Future<Setting?> find(String key) {
    final query = select(db.settings)..where((t) => t.key.equals(key));
    return query.getSingleOrNull();
  }

  /// Valor de la clave, o `null` si no existe o está borrada (`deleted_at`).
  Future<String?> read(String key) {
    final query = select(db.settings)
      ..where((t) => t.key.equals(key) & t.deletedAt.isNull());
    return query.getSingleOrNull().then((row) => row?.value);
  }

  /// Igual que [read] pero reactivo, para la pantalla de ajustes.
  Stream<String?> watch(String key) {
    final query = select(db.settings)
      ..where((t) => t.key.equals(key) & t.deletedAt.isNull());
    return query.watch().map((rows) => rows.isEmpty ? null : rows.first.value);
  }

  /// Upsert por la PK `key` a partir del companion que construye el
  /// repositorio.
  ///
  /// No se firma con `(key, value, updatedAt)` porque el único punto de
  /// escritura (regla 8 de `AGENTS.md`) necesita poder enviar
  /// `deletedAt: const Value(null)` para **reactivar** un tombstone: en
  /// `ON CONFLICT DO UPDATE` solo se pisan las columnas presentes en el
  /// companion, y `null` explícito sí está presente.
  Future<void> upsert(SettingsCompanion row) {
    return into(db.settings).insertOnConflictUpdate(row);
  }

  /// Todas las filas, **incluidos** tombstones: export de backup (§5.5).
  Future<List<Setting>> selectAll() => select(db.settings).get();

  /// Vaciado completo, reservado a la restauración de un import.
  Future<void> deleteAll() => delete(db.settings).go();
}
