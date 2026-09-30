import 'package:drift/drift.dart' show Value, Variable, BaseAggregate;

import 'app_database.dart';

class WardrobeEntry {
  final WardrobeItem item;
  final int lockedQty;
  const WardrobeEntry(this.item, this.lockedQty);

  int get availableQty => item.totalQty - lockedQty;
}

class WardrobeRepository {
  final AppDatabase db;
  WardrobeRepository(this.db);

  // qty terkunci = qty di sesi aktif + qty hilang/tertukar yang belum diselesaikan
  static const _locked = '''
COALESCE((
  SELECT SUM(CASE
    WHEN s.status = 'active' THEN si.quantity
    WHEN si.status IN ('hilang', 'tertukar')
      THEN si.quantity - COALESCE(si.returned_qty, 0)
    ELSE 0 END)
  FROM session_items si
  JOIN sessions s ON s.id = si.session_id
  WHERE si.item_id = w.id
), 0)''';

  Stream<List<WardrobeEntry>> watchAll() {
    return db
        .customSelect(
          'SELECT w.*, $_locked AS locked_qty FROM wardrobe_items w '
          'ORDER BY w.name COLLATE NOCASE',
          readsFrom: {db.wardrobeItems, db.sessionItems, db.sessions},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => WardrobeEntry(
                  db.wardrobeItems.map(r.data),
                  r.read<int>('locked_qty'),
                ),
              )
              .toList(),
        );
  }

  Future<int> lockedQty(int id) async {
    final row = await db.customSelect(
      'SELECT $_locked AS locked_qty FROM wardrobe_items w WHERE w.id = ?',
      variables: [Variable.withInt(id)],
      readsFrom: {db.wardrobeItems, db.sessionItems, db.sessions},
    ).getSingle();
    return row.read<int>('locked_qty');
  }

  Future<void> add({
    required String name,
    required int categoryId,
    required int totalQty,
    String? photoPath,
    String? note,
  }) async {
    await db.into(db.wardrobeItems).insert(
          WardrobeItemsCompanion.insert(
            name: name,
            categoryId: categoryId,
            totalQty: totalQty,
            photoPath: Value(photoPath),
            note: Value(note),
          ),
        );
  }

  /// false kalau totalQty lebih kecil dari qty yang sedang terkunci.
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

  /// false kalau item pernah dipakai di sesi (aktif maupun riwayat).
  Future<bool> delete(int id) async {
    final count = db.sessionItems.id.count();
    final query = db.selectOnly(db.sessionItems)
      ..addColumns([count])
      ..where(db.sessionItems.itemId.equals(id));
    final used = await query.map((r) => r.read(count)).getSingle();
    if ((used ?? 0) > 0) return false;
    await (db.delete(db.wardrobeItems)..where((t) => t.id.equals(id))).go();
    return true;
  }
}