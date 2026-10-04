// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_progress_dao.dart';

// ignore_for_file: type=lint
mixin _$GameProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $GameProgressTable get gameProgress => attachedDatabase.gameProgress;
  GameProgressDaoManager get managers => GameProgressDaoManager(this);
}

class GameProgressDaoManager {
  final _$GameProgressDaoMixin _db;
  GameProgressDaoManager(this._db);
  $$GameProgressTableTableManager get gameProgress =>
      $$GameProgressTableTableManager(_db.attachedDatabase, _db.gameProgress);
}
