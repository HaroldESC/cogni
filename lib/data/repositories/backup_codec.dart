import 'dart:convert';

/// Versión de la app que escribe el backup (`app_version`).
///
/// Mantener en sincronía con `version:` de `pubspec.yaml`. Cuando F7 añada
/// `tool/bump_version.dart` (§9, fila 4), el bump de versión tendrá que
/// actualizar también esta constante.
const String kBackupAppVersion = '1.0.0';

/// Versión del FORMATO del backup (`format_version`), no la de la app.
///
/// Es la que lee [BackupCodec.decode]: mientras no se suba, todo archivo
/// `cogni-backup` v1 es legible. Subirla obliga a que `decode` acepte
/// explícitamente la versión antigua mientras siga siendo soportada; nunca se
/// renumera ni se reinterpreta en silencio.
const int kBackupFormatVersion = 1;

/// Etiqueta que identifica el formato (`format`).
///
/// Si no coincide exactamente, el archivo no es un backup de Cogni y no se
/// toca la base: es lo que impide que un JSON cualquiera se restaure encima del
/// progreso del jugador (§5.5).
const String kBackupFormat = 'cogni-backup';

/// Contenido de un backup, ya validado: el vehículo entre [BackupCodec] y
/// `BackupRepository`.
///
/// Las tres listas son las filas de `game_progress`, `game_sessions` y
/// `settings` **tal cual viajan en el JSON**: claves `snake_case` (los nombres
/// de columna, no los del campo Dart) y fechas en ISO-8601 UTC (D-033). Los
/// tombstones no se filtran: un backup que no pudiera restaurar un borrado
/// lógico perdería información (D-015).
///
/// `game_progress` no lleva el surrogate `id`: no viaja a sync y SQLite lo
/// reasigna al restaurar (D-015).
class BackupData {
  /// Crea el contenido de un backup.
  const new({
    required this.exportedAt,
    required this.gameProgress,
    required this.gameSessions,
    required this.settings,
  });

  /// Instante de la exportación (`exported_at`), en UTC (D-033).
  final DateTime exportedAt;

  /// Filas de `game_progress`, incluidas las borradas lógicamente.
  final List<Map<String, Object?>> gameProgress;

  /// Filas de `game_sessions`, incluidas las borradas lógicamente.
  final List<Map<String, Object?>> gameSessions;

  /// Filas de `settings`, incluidas las borradas lógicamente.
  final List<Map<String, Object?>> settings;
}

/// Codec del fichero de backup (§5.5, D-035): JSON puro, sin Drift ni Flutter.
///
/// Solo traduce entre [BackupData] y el texto del archivo, y **valida**: nunca
/// devuelve contenido sin comprobar antes que el archivo es un backup de Cogni
/// de una versión soportada. Cualquier problema lanza [FormatException] con un
/// mensaje legible en español, para que la UI pueda mostrarlo tal cual en vez
/// de un `FormatException: Unexpected character` de `jsonDecode`.
class BackupCodec {
  /// Crea el codec. No tiene estado: una instancia se puede reutilizar.
  new();

  /// Serializa [data] al JSON del formato v1.
  ///
  /// Va indentado a propósito: el backup es un fichero que el jugador puede
  /// abrir a ojo (y del que puede conservar una copia), así que la legibilidad
  /// prima sobre el tamaño. `exported_at` se normaliza a UTC (D-033).
  String encode(BackupData data) {
    return const JsonEncoder.withIndent('  ').convert({
      'format': kBackupFormat,
      'format_version': kBackupFormatVersion,
      'app_version': kBackupAppVersion,
      'exported_at': data.exportedAt.toUtc().toIso8601String(),
      'data': {
        'game_progress': data.gameProgress,
        'game_sessions': data.gameSessions,
        'settings': data.settings,
      },
    });
  }

  /// Valida [source] y devuelve su contenido.
  ///
  /// Valida **antes** de devolver nada: que el texto sea JSON legible, que sea
  /// un objeto, que `format` sea [kBackupFormat], que `format_version` sea
  /// [kBackupFormatVersion], que exista `data` con las tres listas de filas y
  /// que `exported_at` sea una fecha ISO-8601. Si algo falla, lanza
  /// [FormatException] con un mensaje legible en español.
  ///
  /// No valida el contenido de cada fila (tipos de columna, `status`): eso es
  /// cosa de `BackupRepository`, que es quien las convierte a companions.
  BackupData decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException(
        'El archivo no es un JSON legible: no se puede leer como backup.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El archivo no es un backup válido: la raíz no es un objeto JSON.',
      );
    }

    final format = decoded['format'];
    if (format != kBackupFormat) {
      throw FormatException(
        'Formato de backup desconocido: "$format". Solo se admite '
        '"$kBackupFormat".',
      );
    }

    final version = decoded['format_version'];
    if (version != kBackupFormatVersion) {
      throw FormatException(
        'Versión de backup no soportada: "$version". Esta versión de la app '
        'solo lee la $kBackupFormatVersion.',
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'El backup no contiene la clave "data" con las tablas exportadas.',
      );
    }

    return BackupData(
      exportedAt: _readExportedAt(decoded['exported_at']),
      gameProgress: _readRows(data, 'game_progress'),
      gameSessions: _readRows(data, 'game_sessions'),
      settings: _readRows(data, 'settings'),
    );
  }

  /// Lee `exported_at` y lo normaliza a UTC (D-033).
  DateTime _readExportedAt(Object? raw) {
    if (raw is! String) {
      throw const FormatException(
        'El backup no contiene "exported_at" como texto ISO-8601.',
      );
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException(
        'El backup trae un "exported_at" que no es una fecha: "$raw".',
      );
    }
    return parsed.toUtc();
  }

  /// Lee la lista de filas de [table], comprobando que existe y que cada
  /// elemento es un objeto JSON.
  List<Map<String, Object?>> _readRows(
    Map<String, dynamic> data,
    String table,
  ) {
    final rows = data[table];
    if (rows is! List) {
      throw FormatException(
        'El backup no contiene la lista "$table" dentro de "data".',
      );
    }
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          row
        else
          throw FormatException(
            'La lista "$table" del backup trae una fila que no es un objeto '
            'JSON.',
          ),
    ];
  }
}
