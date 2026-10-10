import 'package:drift/drift.dart' show OrderingTerm, Value, BaseAggregate;

import 'app_database.dart';

class CategoryRepository {
  final AppDatabase db;
  CategoryRepository(this.db);

  Stream<List<Category>> watchAll() {
    return (db.select(db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch();
  }

  Future<void> add(String name, String iconKey) async {
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(iconKey: iconKey, name: Value(name)),
        );
  }

  Future<void> update(int id, {String? name, required String iconKey}) async {
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(name: Value(name), iconKey: Value(iconKey)),
    );
  }

  Future<int> _countItems(int id, {required bool archived}) async {
    final count = db.wardrobeItems.id.count();
    final query = db.selectOnly(db.wardrobeItems)
      ..addColumns([count])
      ..where(db.wardrobeItems.categoryId.equals(id))
      ..where(
        archived
            ? db.wardrobeItems.archivedAt.isNotNull()
            : db.wardrobeItems.archivedAt.isNull(),
      );
    return await query.map((r) => r.read(count)).getSingle() ?? 0;
  }

  /// Returns false while active wardrobe items still use the category.
  /// Categories used only by archived items are archived so session history
  /// can still show them; unused ones are deleted.
  Future<bool> delete(int id) {
    return db.transaction(() async {
      if (await _countItems(id, archived: false) > 0) return false;

      if (await _countItems(id, archived: true) > 0) {
        await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
          CategoriesCompanion(archivedAt: Value(DateTime.now())),
        );
      } else {
        await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
      }
      return true;
    });
  }
}