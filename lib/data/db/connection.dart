import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Conexión de producción a la base de datos local (§5.1).
///
/// El fichero se llama `app.db` y vive en el directorio de soporte de la
/// aplicación (en Windows, `%APPDATA%`). Se abre de forma perezosa con
/// `LazyDatabase`: el disco no se toca hasta la primera consulta.
///
/// Los tests no usan esta función: inyectan `NativeDatabase.memory()` en el
/// constructor de `AppDatabase` (ver `test/data/helpers/test_database.dart`).
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
