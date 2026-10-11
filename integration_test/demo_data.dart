import 'package:drift/drift.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';

/// Ids of the demo rows the screenshot test navigates to.
class DemoIds {
  final int washingSession;
  final int pickupSession;
  final int historyWithLoss;

  const DemoIds({
    required this.washingSession,
    required this.pickupSession,
    required this.historyWithLoss,
  });
}

/// Category ids in the order `AppDatabase._seedCategories` inserts them.
const _tshirt = 1;
const _shirt = 2;
const _outerwear = 3;
const _longPants = 4;
const _shorts = 5;
const _skirt = 6;
const _underwear = 7;
const _socks = 8;

/// Fills [db] with realistic wardrobe items and sessions for store
/// screenshots. Text follows [lang] (`en` or `id`); times are relative to
/// now so every session lands in the intended phase.
Future<DemoIds> seedDemoData(AppDatabase db, String lang) async {
  final id = lang == 'id';
  final now = DateTime.now();

  Future<int> item(String en, String idName, int category, int qty) {
    return db
        .into(db.wardrobeItems)
        .insert(
          WardrobeItemsCompanion.insert(
            name: id ? idName : en,
            categoryId: category,
            totalQty: qty,
          ),
        );
  }

  final whiteTee = await item(
    'Plain White Tee',
    'Kaos Putih Polos',
    _tshirt,
    4,
  );
  final navyTee = await item(
    'Navy Graphic Tee',
    'Kaos Navy Bergambar',
    _tshirt,
    3,
  );
  final oxford = await item('Oxford Shirt', 'Kemeja Oxford Biru', _shirt, 2);
  final flannel = await item('Flannel Shirt', 'Kemeja Flanel', _shirt, 2);
  await item('Denim Jacket', 'Jaket Denim', _outerwear, 1);
  await item('Grey Hoodie', 'Hoodie Abu-abu', _outerwear, 1);
  final chinos = await item(
    'Black Chinos',
    'Celana Chino Hitam',
    _longPants,
    2,
  );
  final jeans = await item('Blue Jeans', 'Celana Jeans Biru', _longPants, 2);
  final shorts = await item(
    'Running Shorts',
    'Celana Pendek Olahraga',
    _shorts,
    3,
  );
  final skirt = await item('Pleated Skirt', 'Rok Plisket', _skirt, 1);
  final boxers = await item('Boxer Briefs', 'Celana Dalam', _underwear, 6);
  final socks = await item('Cotton Socks', 'Kaos Kaki Katun', _socks, 6);

  Future<int> session({
    required String title,
    required String place,
    String? address,
    String? phone,
    required DateTime dropOff,
    required DateTime readyAt,
    DateTime? completedAt,
    required List<(int, int, int?, ItemStatus)> items,
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
            createdAt: Value(dropOff),
          ),
        );
    await db.batch((b) {
      b.insertAll(db.sessionItems, [
        for (final (itemId, qty, returned, status) in items)
          SessionItemsCompanion.insert(
            sessionId: sessionId,
            itemId: itemId,
            quantity: qty,
            returnedQty: Value(returned),
            status: status,
          ),
      ]);
    });
    return sessionId;
  }

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
  const returned = ItemStatus.kembali;
  const carried = ItemStatus.dibawa;

  await session(
    title: id ? 'Cucian bulanan' : 'Monthly laundry',
    place: cleanName,
    address: cleanAddress,
    phone: cleanPhone,
    dropOff: now.subtract(const Duration(days: 14)),
    readyAt: now.subtract(const Duration(days: 13)),
    completedAt: now.subtract(const Duration(days: 13)),
    items: [
      (whiteTee, 3, 3, returned),
      (jeans, 2, 2, returned),
      (socks, 4, 4, returned),
    ],
  );
  await session(
    title: id ? 'Baju kantor' : 'Office clothes',
    place: expressName,
    address: expressAddress,
    phone: expressPhone,
    dropOff: now.subtract(const Duration(days: 8)),
    readyAt: now.subtract(const Duration(days: 7)),
    completedAt: now.subtract(const Duration(days: 7)),
    items: [(oxford, 2, 2, returned), (chinos, 2, 2, returned)],
  );
  final historyWithLoss = await session(
    title: id ? 'Cucian akhir pekan' : 'Weekend laundry',
    place: cleanName,
    address: cleanAddress,
    phone: cleanPhone,
    dropOff: now.subtract(const Duration(days: 4)),
    readyAt: now.subtract(const Duration(days: 3)),
    completedAt: now.subtract(const Duration(days: 3)),
    items: [
      (navyTee, 2, 2, returned),
      (skirt, 1, 1, returned),
      (socks, 2, 1, ItemStatus.hilang),
      (boxers, 4, 4, returned),
    ],
  );
  final pickupSession = await session(
    title: id ? 'Kemeja kerja' : 'Work shirts',
    place: expressName,
    address: expressAddress,
    phone: expressPhone,
    dropOff: now.subtract(const Duration(days: 1)),
    readyAt: now.subtract(const Duration(hours: 1)),
    items: [
      (oxford, 2, null, carried),
      (flannel, 1, null, carried),
      (jeans, 1, null, carried),
    ],
  );
  final washingSession = await session(
    title: id ? 'Cucian mingguan' : 'Weekly laundry',
    place: cleanName,
    address: cleanAddress,
    phone: cleanPhone,
    dropOff: now.subtract(const Duration(hours: 3)),
    readyAt: now.add(const Duration(hours: 5)),
    items: [
      (whiteTee, 3, null, carried),
      (navyTee, 2, null, carried),
      (chinos, 1, null, carried),
      (shorts, 2, null, carried),
      (socks, 4, null, carried),
    ],
  );
  return DemoIds(
    washingSession: washingSession,
    pickupSession: pickupSession,
    historyWithLoss: historyWithLoss,
  );
}
