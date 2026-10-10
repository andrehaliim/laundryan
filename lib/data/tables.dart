import 'package:drift/drift.dart';
import 'enums.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get defaultKey => text().nullable()();
  TextColumn get iconKey => text()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

class WardrobeItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get note => text().nullable()();
  IntColumn get totalQty => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get placeName => text()();
  TextColumn get placeAddress => text().nullable()();
  TextColumn get placePhone => text().nullable()();
  DateTimeColumn get dropOffDate => dateTime()();
  DateTimeColumn get estimatedReadyAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => textEnum<SessionStatus>()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SessionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get itemId =>
      integer().references(WardrobeItems, #id, onDelete: KeyAction.restrict)();
  IntColumn get quantity => integer()();
  IntColumn get returnedQty => integer().nullable()();
  TextColumn get status => textEnum<ItemStatus>()();
  TextColumn get note => text().nullable()();
}