import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, WardrobeItems, Sessions, SessionItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'laundryan'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(wardrobeItems, wardrobeItems.archivedAt);
          }
          if (from < 3) {
            await m.addColumn(categories, categories.archivedAt);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedCategories() async {
    const defaults = [
      'tshirt',
      'shirt',
      'outerwear',
      'longPants',
      'shorts',
      'skirt',
      'underwear',
      'socks',
    ];
    await batch((b) {
      b.insertAll(
        categories,
        defaults.map(
          (key) => CategoriesCompanion.insert(
            iconKey: key,
            defaultKey: Value(key),
          ),
        ),
      );
    });
  }
}