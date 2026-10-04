import 'package:cogni/data/db/app_database.dart';
import 'package:cogni/data/repositories/settings_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = SettingsRepository(db);
  });

  test('write y read hacen roundtrip de int y String (JSON tipado)', () async {
    await repository.write<int>('pi.checkpoint_every', 50);
    await repository.write<String>('app.theme', 'dark');

    expect(await repository.read<int>('pi.checkpoint_every'), 50);
    expect(await repository.read<String>('app.theme'), 'dark');

    final row = await db.settingsDao.find('app.theme');
    expect(row!.value, '"dark"');
    expect(row.updatedAt.isUtc, isTrue);
  });

  test('read lee las semillas de onCreate con su tipo', () async {
    expect(await repository.read<int>('pi.checkpoint_every'), 20);
    expect(await repository.read<String>('app.theme'), 'system');
    expect(await repository.read<int>('sums.initial_speed_ms'), 1000);
  });

  test('read devuelve null para una clave ausente', () async {
    expect(await repository.read<int>('no.existe'), isNull);
  });

  test('write sobre un tombstone reactiva la fila', () async {
    await db.settingsDao.upsert(
      SettingsCompanion.insert(
        key: 'app.theme',
        value: '"light"',
        updatedAt: DateTime.now().toUtc(),
        deletedAt: Value(DateTime.now().toUtc()),
      ),
    );
    expect(await repository.read<String>('app.theme'), isNull);

    await repository.write<String>('app.theme', 'dark');

    final row = await db.settingsDao.find('app.theme');
    expect(row!.deletedAt, isNull);
    expect(await repository.read<String>('app.theme'), 'dark');
  });

  test('watch emite al escribir (reactivo)', () async {
    final future = repository
        .watch<int>('pi.checkpoint_every')
        .firstWhere((value) => value == 50);

    await repository.write<int>('pi.checkpoint_every', 50);

    expect(await future, 50);
  });

  test('read<int> de una clave que guarda texto lanza FormatException, no '
      'TypeError', () async {
    expect(await repository.read<String>('app.theme'), 'system');

    await expectLater(repository.read<int>('app.theme'), throwsFormatException);
  });
}
