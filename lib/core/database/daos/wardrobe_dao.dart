import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/wardrobe_items.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [WardrobeItems])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  // Reactive stream — dipakai di Wardrobe screen biar auto-update pas quantity berubah
  Stream<List<WardrobeItem>> watchAllItems() => select(wardrobeItems).watch();

  Future<WardrobeItem> getItemById(int id) =>
      (select(wardrobeItems)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertItem(WardrobeItemsCompanion item) =>
      into(wardrobeItems).insert(item);

  Future<bool> updateItem(WardrobeItemsCompanion item) =>
      update(wardrobeItems).replace(item);

  Future<int> deleteItem(int id) =>
      (delete(wardrobeItems)..where((t) => t.id.equals(id))).go();

  // Dipanggil saat submit "Buat Sesi Baru" — kurangi stok
  Future<void> decrementQuantity(int itemId, int amount) async {
    final item = await getItemById(itemId);
    final newQty = item.quantityOwned - amount;
    await (update(wardrobeItems)..where((t) => t.id.equals(itemId))).write(
      WardrobeItemsCompanion(quantityOwned: Value(newQty)),
    );
  }

  // Dipanggil saat verifikasi "Ketemu" ATAU hapus sesi yang masih berjalan (release)
  Future<void> incrementQuantity(int itemId, int amount) async {
    final item = await getItemById(itemId);
    final newQty = item.quantityOwned + amount;
    await (update(wardrobeItems)..where((t) => t.id.equals(itemId))).write(
      WardrobeItemsCompanion(quantityOwned: Value(newQty)),
    );
  }

  Future<WardrobeItem?> findByNameIgnoreCase(String name) async {
    final items = await select(wardrobeItems).get();
    for (final item in items) {
      if (item.name.toLowerCase() == name.toLowerCase()) return item;
    }
    return null;
  }
}
