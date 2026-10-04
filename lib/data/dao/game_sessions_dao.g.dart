// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_sessions_dao.dart';

// ignore_for_file: type=lint
mixin _$GameSessionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GameSessionsTable get gameSessions => attachedDatabase.gameSessions;
  GameSessionsDaoManager get managers => GameSessionsDaoManager(this);
}

class GameSessionsDaoManager {
  final _$GameSessionsDaoMixin _db;
  GameSessionsDaoManager(this._db);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db.attachedDatabase, _db.gameSessions);
}
