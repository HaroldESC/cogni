import 'dart:convert';

import 'package:cogni/data/repositories/backup_codec.dart';
import 'package:flutter_test/flutter_test.dart';

/// Instante UTC fijo para que los backups sean byte a byte reproducibles.
final _exportedAt = DateTime.utc(2026, 10, 3, 10);

/// Fila de sesión tal y como viaja en el archivo: `snake_case` y fechas ya
/// serializadas en ISO-8601 UTC (§5.5).
Map<String, Object?> _sessionRow({
  required String uuid,
  String status = 'active',
  int checkpoint = 20,
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'uuid': uuid,
    'game_id': 'pi_memory',
    'mode': 'default',
    'status': status,
    'checkpoint': checkpoint,
    'position': checkpoint,
    'score': 0,
    'state_json': null,
    'started_at': '2026-10-03T10:00:00.000Z',
    'ended_at': null,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Fila de progreso: no lleva `id` surrogate, solo su clave natural (D-015).
Map<String, Object?> _progressRow({
  String gameId = 'pi_memory',
  int unlockedUpTo = 120,
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'game_id': gameId,
    'mode': 'default',
    'unlocked_up_to': unlockedUpTo,
    'best_score': 40,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Fila de settings con el `value` ya serializado como JSON (D-036).
Map<String, Object?> _settingRow({
  String key = 'pi.checkpoint_every',
  String value = '20',
  String updatedAt = '2026-10-03T10:00:00.000Z',
  String? deletedAt,
}) {
  return <String, Object?>{
    'key': key,
    'value': value,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };
}

/// Compara campo a campo: si el roundtrip pierde, cambia o reordena una clave,
/// el fallo dice exactamente cuál y con qué valor.
void _expectSameFields(
  List<Map<String, Object?>> actual,
  List<Map<String, Object?>> expected,
) {
  expect(actual.length, expected.length, reason: 'nº de filas');
  for (var i = 0; i < expected.length; i++) {
    final row = actual[i];
    expected[i].forEach((key, value) {
      expect(row[key], value, reason: 'fila $i, campo $key');
    });
  }
}

/// Tests del codec de backup de la Fase B.
///
/// Son tests puros (solo `dart:convert`): no tocan Drift ni el disco, porque la
/// escritura es cosa de `BackupRepository`. Lo que se fija aquí es el contrato
/// del archivo —`format`, `format_version` y las tres listas de `data`—, el
/// roundtrip sin pérdidas de `uuid`/`updated_at`/`deleted_at` (D-015) y que
/// cualquier JSON que no sea un backup de Cogni se rechace con un mensaje en
/// español, no con una excepción opaca.
void main() {
  final codec = BackupCodec();

  test('encode genera el JSON versionado', () {
    final encoded = codec.encode(
      BackupData(
        exportedAt: _exportedAt,
        gameProgress: const [],
        gameSessions: const [],
        settings: const [],
      ),
    );

    final root = jsonDecode(encoded) as Map<String, Object?>;
    expect(root['format'], 'cogni-backup');
    expect(root['format_version'], 1);
    expect(root['app_version'], '1.0.0');
    expect(root.containsKey('exported_at'), isTrue);

    final exportedText = root['exported_at']! as String;
    expect(exportedText, endsWith('Z'));
    expect(DateTime.parse(exportedText).toUtc(), _exportedAt);

    final data = root['data']! as Map<String, Object?>;
    expect(
      data.keys,
      containsAll(<String>['game_progress', 'game_sessions', 'settings']),
    );
    expect(data['game_progress'], isEmpty);
    expect(data['game_sessions'], isEmpty);
    expect(data['settings'], isEmpty);
  });

  test('roundtrip encode→decode conserva uuid, updated_at y deleted_at', () {
    final data = BackupData(
      exportedAt: _exportedAt,
      gameProgress: [_progressRow()],
      gameSessions: [
        _sessionRow(uuid: 'uuid-viva'),
        _sessionRow(
          uuid: 'uuid-tombstone',
          status: 'completed',
          checkpoint: 40,
          updatedAt: '2026-10-03T11:30:00.000Z',
          deletedAt: '2026-10-03T12:00:00.000Z',
        ),
      ],
      settings: [_settingRow()],
    );

    final decoded = codec.decode(codec.encode(data));

    _expectSameFields(decoded.gameSessions, data.gameSessions);
    _expectSameFields(decoded.gameProgress, data.gameProgress);
    _expectSameFields(decoded.settings, data.settings);

    final tombstones = decoded.gameSessions
        .where((row) => row['uuid'] == 'uuid-tombstone')
        .toList();
    expect(tombstones.single['deleted_at'], '2026-10-03T12:00:00.000Z');
    expect(tombstones.single['updated_at'], '2026-10-03T11:30:00.000Z');
    expect(tombstones.single['checkpoint'], 40);
  });

  test('decode rechaza un formato desconocido con mensaje legible', () {
    final source = jsonEncode(<String, Object?>{
      'format': 'otra-cosa',
      'format_version': kBackupFormatVersion,
      'app_version': kBackupAppVersion,
      'exported_at': '2026-10-03T10:00:00.000Z',
      'data': <String, Object?>{
        'game_progress': <Object?>[],
        'game_sessions': <Object?>[],
        'settings': <Object?>[],
      },
    });

    expect(
      () => codec.decode(source),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Formato de backup desconocido'),
        ),
      ),
    );
  });

  test('decode rechaza una format_version desconocida', () {
    final source = jsonEncode(<String, Object?>{
      'format': kBackupFormat,
      'format_version': 99,
      'app_version': kBackupAppVersion,
      'exported_at': '2026-10-03T10:00:00.000Z',
      'data': <String, Object?>{
        'game_progress': <Object?>[],
        'game_sessions': <Object?>[],
        'settings': <Object?>[],
      },
    });

    expect(
      () => codec.decode(source),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('no soportada'),
        ),
      ),
    );
  });

  test('decode rechaza JSON ilegible y raíces que no son objeto', () {
    expect(() => codec.decode('{{{'), throwsFormatException);
    expect(() => codec.decode('[]'), throwsFormatException);
  });
}
