import 'dart:convert';

import 'package:cogni/data/db/app_database.dart';
import 'package:drift/drift.dart';

/// Único punto de escritura de `settings` (regla 8 de `AGENTS.md`).
///
/// Los valores se guardan como JSON (D-036), así que [read] devuelve el tipo
/// pedido en lugar de un `String` que hay que parsear a mano en cada
/// consumidor. Un JSON ilegible, o legible pero de otro tipo del pedido,
/// propaga un [FormatException] con un mensaje legible: se prefiere fallar en
/// voz alto a devolver un valor por defecto silencioso.
class SettingsRepository {
  /// Crea el repositorio sobre la base de datos dada.
  new(AppDatabase db) : _db = db;

  final AppDatabase _db;

  /// Valor de la clave, o `null` si no existe o es tombstone (`deleted_at`).
  Future<T?> read<T>(String key) async {
    return _decode<T>(await _db.settingsDao.read(key), key);
  }

  /// Igual que [read] pero reactivo, para la pantalla de ajustes.
  Stream<T?> watch<T>(String key) {
    return _db.settingsDao.watch(key).map((raw) => _decode<T>(raw, key));
  }

  /// Guarda [value] serializado como JSON y reactiva la fila si era tombstone.
  Future<void> write<T>(String key, T value) async {
    await _db.settingsDao.upsert(
      SettingsCompanion.insert(
        key: key,
        value: jsonEncode(value),
        updatedAt: DateTime.now().toUtc(),
        deletedAt: const Value(null),
      ),
    );
  }

  /// Decodifica el JSON almacenado; `null` es ausencia, no un valor.
  ///
  /// Un `as T` lanzaría un [TypeError] —un [Error], no un [Exception], y por
  /// tanto invisible para un `catch (e)`, que es el manejo de errores que la
  /// app usa— cuando la fila es un JSON válido de otro tipo. Se comprueba el
  /// tipo a propósito y se lanza [FormatException], que ya es lo que documenta
  /// esta clase. El mensaje nombra la clave, el tipo esperado y el valor
  /// leído, para que el fallo sea diagnosticable sin abrir la base.
  T? _decode<T>(String? raw, String key) {
    if (raw == null) return null;
    final value = jsonDecode(raw);
    if (value is! T) {
      throw FormatException('valor de "$key" no es un $T: $value');
    }
    return value;
  }
}
