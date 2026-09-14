// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $LaundrySessionsTable get laundrySessions => attachedDatabase.laundrySessions;
  $WardrobeItemsTable get wardrobeItems => attachedDatabase.wardrobeItems;
  $SessionItemsTable get sessionItems => attachedDatabase.sessionItems;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$LaundrySessionsTableTableManager get laundrySessions =>
      $$LaundrySessionsTableTableManager(
        _db.attachedDatabase,
        _db.laundrySessions,
      );
  $$WardrobeItemsTableTableManager get wardrobeItems =>
      $$WardrobeItemsTableTableManager(_db.attachedDatabase, _db.wardrobeItems);
  $$SessionItemsTableTableManager get sessionItems =>
      $$SessionItemsTableTableManager(_db.attachedDatabase, _db.sessionItems);
}
