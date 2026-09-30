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

  Future<bool> isUsed(int id) async {
    final count = db.wardrobeItems.id.count();
    final query = db.selectOnly(db.wardrobeItems)
      ..addColumns([count])
      ..where(db.wardrobeItems.categoryId.equals(id));
    final result = await query.map((r) => r.read(count)).getSingle();
    return (result ?? 0) > 0;
  }

  Future<void> delete(int id) async {
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }
}