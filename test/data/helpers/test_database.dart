import 'package:cogni/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Crea una [AppDatabase] en memoria y registra su cierre automático.
///
/// Se usa con `setUp`: cada test parte de un esquema recién creado (lo que
/// dispara `onCreate`, `m.createAll()` y las semillas de §5.2) y no toca nunca
/// el `app.db` de producción (§5.1).
///
/// `closeStreamsSynchronously` hace que al cerrar la base no queden streams
/// de Drift pendientes de cerrar entre tests: sin él, un `watch()` olvidado
/// puede dejar trabajo asíncrono vivo durante el siguiente test.
///
/// El cierre se registra con `addTearDown`, así que ningún fichero de test
/// necesita su propio `tearDown(() => db.close())`.
AppDatabase createTestDatabase() {
  final db = AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
  addTearDown(db.close);
  return db;
}
