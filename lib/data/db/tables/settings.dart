import 'package:drift/drift.dart';

/// Ajustes clave-valor (§5.2).
///
/// La clave es namespaciada por feature (`pi.`, `sums.`, `app.`), así que es
/// una clave natural globalmente única: es la identidad global de la tabla
/// (D-015) y por eso es la PK, no un surrogate.
///
/// `value` guarda JSON serializado (D-036): `20`, `1000`, `"system"`.
class Settings extends Table {
  /// Clave namespaciada por feature; es la PK (identidad global, D-015).
  TextColumn get key => text()();

  /// Valor de la clave, como JSON serializado (D-036): `20`, `1000`,
  /// `"system"`.
  TextColumn get value => text()();

  /// Marca `updated_at`: base del last-write-wins (§5.4).
  DateTimeColumn get updatedAt => dateTime()();

  /// *Tombstone*: `NULL` = fila viva; nunca `DELETE` físico (D-015).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// PK: `key` (clave natural, sin surrogate).
  @override
  Set<Column<Object>> get primaryKey => {key};
}
