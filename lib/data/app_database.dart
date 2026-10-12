import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, WardrobeItems, Sessions, SessionItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'laundryan'));

  /// Opens the database on a custom executor, e.g. an in-memory one for
  /// tests and store screenshots.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

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
      if (from < 4) {
        await _migrateCategoriesV4();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedCategories() => _insertDefaultCategories(const [
    'shirt',
    'tshirt',
    'longSleeves',
    'sleeveless',
    'tankTop',
    'turtleNeck',
    'hoodie',
    'cardigan',
    'vest',
    'suit',
    'longPants',
    'shorts',
    'skirt',
    'underwear',
    'socks',
  ]);

  /// Renames `outerwear` to `hoodie` and adds the default categories
  /// introduced in v4. They get appended after existing ones since
  /// categories are ordered by id.
  Future<void> _migrateCategoriesV4() async {
    await customStatement(
      "UPDATE categories SET default_key = 'hoodie' "
      "WHERE default_key = 'outerwear'",
    );
    await customStatement(
      "UPDATE categories SET icon_key = 'hoodie' "
      "WHERE icon_key = 'outerwear'",
    );
    await _insertDefaultCategories(const [
      'longSleeves',
      'sleeveless',
      'tankTop',
      'turtleNeck',
      'cardigan',
      'vest',
      'suit',
    ]);
  }

  Future<void> _insertDefaultCategories(List<String> keys) async {
    await batch((b) {
      b.insertAll(
        categories,
        keys.map(
          (key) =>
              CategoriesCompanion.insert(iconKey: key, defaultKey: Value(key)),
        ),
      );
    });
  }
}
