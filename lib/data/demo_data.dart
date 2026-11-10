import 'package:drift/drift.dart';

import 'app_database.dart';
import 'enums.dart';

/// One row of a demo session: wardrobe item id, qty, returned qty, status
/// and an optional note.
typedef _Line = (int, int, int?, ItemStatus, String?);

/// Replaces every wardrobe item, session and custom category in [db] with
/// realistic demo data for store screenshots. Debug tooling only.
///
/// Text follows [lang] (`en` or `id`); times are relative to now so every
/// session lands in the intended phase. The "dropped" phase only lasts for
/// 10 minutes after seeding.
///
/// Photos already set on the existing items are carried over to the demo
/// items in the same order, so reseeding in another language keeps them.
Future<void> seedDemoData(AppDatabase db, String lang) {
  return db.transaction(() async {
    final id = lang == 'id';
    final now = DateTime.now();

    final oldPhotos =
        await (db.select(db.wardrobeItems)
              ..where((t) => t.archivedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .map((w) => w.photoPath)
            .get();

    await db.delete(db.sessionItems).go();
    await db.delete(db.sessions).go();
    await db.delete(db.wardrobeItems).go();
    await (db.delete(db.categories)..where((t) => t.defaultKey.isNull())).go();
    await (db.update(db.categories)..where((t) => t.archivedAt.isNotNull()))
        .write(const CategoriesCompanion(archivedAt: Value(null)));

    final defaults = {
      for (final c in await db.select(db.categories).get()) ?c.defaultKey: c.id,
    };

    Future<int> category(String key) async =>
        defaults[key] ??
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(iconKey: key, defaultKey: Value(key)),
            );

    Future<int> customCategory(String en, String idName, String iconKey) {
      return db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              iconKey: iconKey,
              name: Value(id ? idName : en),
            ),
          );
    }

    final shirt = await category('shirt');
    final tshirt = await category('tshirt');
    final hoodieCat = await category('hoodie');
    final cardiganCat = await category('cardigan');
    final longPants = await category('longPants');
    final shortsCat = await category('shorts');
    final skirtCat = await category('skirt');
    final underwear = await category('underwear');
    final socksCat = await category('socks');
    final bedding = await customCategory('Bedding', 'Sprei & Selimut', 'home');
    final bags = await customCategory('Bags', 'Tas', 'bag');
    await customCategory('Sportswear', 'Baju Olahraga', 'star');

    var itemIndex = 0;
    Future<int> item(String en, String idName, int categoryId, int qty) {
      final photo = itemIndex < oldPhotos.length ? oldPhotos[itemIndex] : null;
      itemIndex++;
      return db
          .into(db.wardrobeItems)
          .insert(
            WardrobeItemsCompanion.insert(
              name: id ? idName : en,
              categoryId: categoryId,
              totalQty: qty,
              photoPath: Value(photo),
            ),
          );
    }

    final whiteTee = await item(
      'Plain White Tee',
      'Kaos Putih Polos',
      tshirt,
      5,
    );
    final navyTee = await item(
      'Navy Graphic Tee',
      'Kaos Navy Bergambar',
      tshirt,
      3,
    );
    final oxford = await item(
      'Blue Oxford Shirt',
      'Kemeja Oxford Biru',
      shirt,
      3,
    );
    final flannel = await item('Flannel Shirt', 'Kemeja Flanel', shirt, 2);
    final cardigan = await item(
      'Beige Cardigan',
      'Kardigan Krem',
      cardiganCat,
      1,
    );
    final hoodie = await item('Grey Hoodie', 'Hoodie Abu-abu', hoodieCat, 2);
    final chinos = await item(
      'Black Chinos',
      'Celana Chino Hitam',
      longPants,
      2,
    );
    final jeans = await item('Blue Jeans', 'Celana Jeans Biru', longPants, 3);
    final shorts = await item(
      'Running Shorts',
      'Celana Pendek Olahraga',
      shortsCat,
      4,
    );
    final skirt = await item('Pleated Skirt', 'Rok Plisket', skirtCat, 1);
    final boxers = await item('Boxer Briefs', 'Celana Dalam', underwear, 6);
    final socks = await item('Cotton Socks', 'Kaos Kaki Katun', socksCat, 8);
    final bedSheet = await item('Bed Sheet Set', 'Set Sprei', bedding, 2);
    await item('Canvas Tote Bag', 'Tas Kanvas', bags, 1);

    Future<void> session({
      required String title,
      required String place,
      required String address,
      required String phone,
      required DateTime dropOff,
      required DateTime readyAt,
      DateTime? completedAt,
      bool reminder = false,
      required List<_Line> lines,
    }) async {
      final sessionId = await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              title: title,
              placeName: place,
              placeAddress: Value(address),
              placePhone: Value(phone),
              dropOffDate: dropOff,
              estimatedReadyAt: readyAt,
              completedAt: Value(completedAt),
              status: completedAt == null
                  ? SessionStatus.active
                  : SessionStatus.completed,
              reminderEnabled: Value(reminder),
              createdAt: Value(dropOff),
            ),
          );
      await db.batch((b) {
        b.insertAll(db.sessionItems, [
          for (final (itemId, qty, returnedQty, status, note) in lines)
            SessionItemsCompanion.insert(
              sessionId: sessionId,
              itemId: itemId,
              quantity: qty,
              returnedQty: Value(returnedQty),
              status: status,
              note: Value(note),
            ),
        ]);
      });
    }

    _Line carried(int itemId, int qty) =>
        (itemId, qty, null, ItemStatus.dibawa, null);
    _Line returned(int itemId, int qty) =>
        (itemId, qty, qty, ItemStatus.kembali, null);

    final cleanName = id ? 'Laundry Bersih Kilat' : 'Fresh & Clean Laundry';
    final cleanAddress = id
        ? 'Jl. Melati No. 12, Bandung'
        : '12 Jasmine Street, Bandung';
    const cleanPhone = '081234567890';
    final expressName = id ? 'Laundry Express 24 Jam' : '24h Express Laundry';
    final expressAddress = id
        ? 'Jl. Kenanga No. 5, Bandung'
        : '5 Kenanga Street, Bandung';
    const expressPhone = '082198765432';

    // History, oldest first.
    await session(
      title: id ? 'Cucian bulanan' : 'Monthly laundry',
      place: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      dropOff: now.subtract(const Duration(days: 14)),
      readyAt: now.subtract(const Duration(days: 13)),
      completedAt: now.subtract(const Duration(days: 13)),
      lines: [returned(whiteTee, 3), returned(jeans, 2), returned(socks, 4)],
    );
    await session(
      title: id ? 'Baju kantor' : 'Office clothes',
      place: expressName,
      address: expressAddress,
      phone: expressPhone,
      dropOff: now.subtract(const Duration(days: 8)),
      readyAt: now.subtract(const Duration(days: 7)),
      completedAt: now.subtract(const Duration(days: 7)),
      lines: [returned(oxford, 2), returned(chinos, 2)],
    );
    await session(
      title: id ? 'Cucian akhir pekan' : 'Weekend laundry',
      place: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      dropOff: now.subtract(const Duration(days: 4)),
      readyAt: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 3)),
      lines: [
        returned(navyTee, 2),
        returned(skirt, 1),
        (
          socks,
          2,
          1,
          ItemStatus.hilang,
          id ? 'Satu kaos kaki tidak kembali' : 'One sock did not come back',
        ),
        returned(boxers, 4),
      ],
    );

    // Active: two ready for pickup, one washing, one just dropped off.
    await session(
      title: id ? 'Sprei & selimut' : 'Bedding',
      place: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      dropOff: now.subtract(const Duration(days: 2)),
      readyAt: now.subtract(const Duration(hours: 5)),
      lines: [carried(bedSheet, 2), carried(cardigan, 1)],
    );
    await session(
      title: id ? 'Kemeja kerja' : 'Work shirts',
      place: expressName,
      address: expressAddress,
      phone: expressPhone,
      dropOff: now.subtract(const Duration(days: 1)),
      readyAt: now.subtract(const Duration(hours: 1)),
      lines: [
        carried(oxford, 2),
        carried(flannel, 1),
        carried(jeans, 1),
        carried(hoodie, 1),
        carried(socks, 3),
      ],
    );
    await session(
      title: id ? 'Cucian mingguan' : 'Weekly laundry',
      place: cleanName,
      address: cleanAddress,
      phone: cleanPhone,
      dropOff: now.subtract(const Duration(hours: 3)),
      readyAt: now.add(const Duration(hours: 5)),
      reminder: true,
      lines: [
        carried(whiteTee, 3),
        carried(navyTee, 2),
        carried(chinos, 1),
        carried(shorts, 2),
        carried(boxers, 4),
      ],
    );
    await session(
      title: id ? 'Baju olahraga' : 'Gym clothes',
      place: expressName,
      address: expressAddress,
      phone: expressPhone,
      dropOff: now,
      readyAt: now.add(const Duration(days: 1)),
      lines: [carried(whiteTee, 1), carried(shorts, 1), carried(socks, 2)],
    );
  });
}
