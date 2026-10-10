import 'package:drift/drift.dart' show Value, Variable, BaseAggregate;

import 'app_database.dart';

class WardrobeEntry {
  final WardrobeItem item;
  final int inWashQty;
  final int missingQty;
  const WardrobeEntry(this.item, this.inWashQty, this.missingQty);

  int get lockedQty => inWashQty + missingQty;
  int get availableQty => item.totalQty - lockedQty;
}

enum WardrobeDeleteResult { deleted, archived, blocked }

class WardrobeRepository {
  final AppDatabase db;
  WardrobeRepository(this.db);

  static const _inWash = '''
COALESCE((
  SELECT SUM(si.quantity)
  FROM session_items si
  JOIN sessions s ON s.id = si.session_id
  WHERE si.item_id = w.id AND s.status = 'active'
), 0)''';

  static const _missing = '''
COALESCE((
  SELECT SUM(si.quantity - COALESCE(si.returned_qty, 0))
  FROM session_items si
  JOIN sessions s ON s.id = si.session_id
  WHERE si.item_id = w.id
    AND s.status = 'completed'
    AND si.status IN ('hilang', 'tertukar')
), 0)''';

  Stream<List<WardrobeEntry>> watchAll() {
    return db
        .customSelect(
          'SELECT w.*, $_inWash AS in_wash_qty, $_missing AS missing_qty '
          'FROM wardrobe_items w WHERE w.archived_at IS NULL '
          'ORDER BY w.name COLLATE NOCASE',
          readsFrom: {db.wardrobeItems, db.sessionItems, db.sessions},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => WardrobeEntry(
                  db.wardrobeItems.map(r.data),
                  r.read<int>('in_wash_qty'),
                  r.read<int>('missing_qty'),
                ),
              )
              .toList(),
        );
  }

  Future<int> lockedQty(int id) async {
    final row = await db
        .customSelect(
          'SELECT $_inWash + $_missing AS locked_qty '
          'FROM wardrobe_items w WHERE w.id = ?',
          variables: [Variable.withInt(id)],
          readsFrom: {db.wardrobeItems, db.sessionItems, db.sessions},
        )
        .getSingle();
    return row.read<int>('locked_qty');
  }

  Future<void> add({
    required String name,
    required int categoryId,
    required int totalQty,
    String? photoPath,
    String? note,
  }) async {
    await db
        .into(db.wardrobeItems)
        .insert(
          WardrobeItemsCompanion.insert(
            name: name,
            categoryId: categoryId,
            totalQty: totalQty,
            photoPath: Value(photoPath),
            note: Value(note),
          ),
        );
  }

  /// false if totalQty is less than the currently locked qty.
  Future<bool> update(
    int id, {
    required String name,
    required int categoryId,
    required int totalQty,
    String? photoPath,
    String? note,
  }) async {
    if (totalQty < await lockedQty(id)) return false;
    await (db.update(db.wardrobeItems)..where((t) => t.id.equals(id))).write(
      WardrobeItemsCompanion(
        name: Value(name),
        categoryId: Value(categoryId),
        totalQty: Value(totalQty),
        photoPath: Value(photoPath),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return true;
  }

  /// Rejected while the item is still in an active session or has an unresolved
  /// lost/swapped entry. Items used in past sessions are archived so history
  /// stays intact; items never used are deleted permanently.
  Future<WardrobeDeleteResult> delete(int id) {
    return db.transaction(() async {
      if (await lockedQty(id) > 0) return WardrobeDeleteResult.blocked;

      final count = db.sessionItems.id.count();
      final query = db.selectOnly(db.sessionItems)
        ..addColumns([count])
        ..where(db.sessionItems.itemId.equals(id));
      final used = await query.map((r) => r.read(count)).getSingle();

      if ((used ?? 0) > 0) {
        await (db.update(db.wardrobeItems)..where((t) => t.id.equals(id)))
            .write(WardrobeItemsCompanion(archivedAt: Value(DateTime.now())));
        return WardrobeDeleteResult.archived;
      }

      await (db.delete(db.wardrobeItems)..where((t) => t.id.equals(id))).go();
      return WardrobeDeleteResult.deleted;
    });
  }

  Future<int> countByCategory(int categoryId) async {
    final count = db.wardrobeItems.id.count();
    final query = db.selectOnly(db.wardrobeItems)
      ..addColumns([count])
      ..where(db.wardrobeItems.categoryId.equals(categoryId));
    return await query.map((r) => r.read(count)).getSingle() ?? 0;
  }
}
