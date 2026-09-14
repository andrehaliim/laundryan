import 'package:drift/drift.dart';

class WardrobeItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get iconName => text()();
  IntColumn get quantityOwned => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}