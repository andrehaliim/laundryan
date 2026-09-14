// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_dao.dart';

// ignore_for_file: type=lint
mixin _$WardrobeDaoMixin on DatabaseAccessor<AppDatabase> {
  $WardrobeItemsTable get wardrobeItems => attachedDatabase.wardrobeItems;
  WardrobeDaoManager get managers => WardrobeDaoManager(this);
}

class WardrobeDaoManager {
  final _$WardrobeDaoMixin _db;
  WardrobeDaoManager(this._db);
  $$WardrobeItemsTableTableManager get wardrobeItems =>
      $$WardrobeItemsTableTableManager(_db.attachedDatabase, _db.wardrobeItems);
}
