import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/laundry_sessions.dart';
import '../tables/session_items.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [LaundrySessions, SessionItems])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Stream<List<LaundrySession>> watchAllSessions() =>
      (select(laundrySessions)..orderBy([
        (t) => OrderingTerm(expression: t.sessionDate, mode: OrderingMode.desc),
      ])).watch();

  Future<List<SessionItem>> getItemsForSession(int sessionId) =>
      (select(sessionItems)..where((t) => t.sessionId.equals(sessionId))).get();

  // Dipanggil saat submit "Buat Sesi Baru"
  // itemQuantities: map dari wardrobeItemId -> jumlah yang dicuci
  Future<int> createSession(Map<int, int> itemQuantities) async {
    return transaction(() async {
      final sessionId = await into(laundrySessions).insert(
        LaundrySessionsCompanion.insert(),
      );

      final wardrobeDao = db.wardrobeDao;
      for (final entry in itemQuantities.entries) {
        await into(sessionItems).insert(
          SessionItemsCompanion.insert(
            sessionId: sessionId,
            itemId: entry.key,
            quantityWashed: entry.value,
          ),
        );
        await wardrobeDao.decrementQuantity(entry.key, entry.value);
      }

      return sessionId;
    });
  }

  // Dipanggil saat submit "Selesai Verifikasi"
  // foundQuantities: map dari sessionItemId -> jumlah yang ketemu
  Future<void> submitVerification(
    int sessionId,
    Map<int, int> foundQuantities,
  ) async {
    await transaction(() async {
      final wardrobeDao = db.wardrobeDao;
      bool hasLostItem = false;

      for (final entry in foundQuantities.entries) {
        final sessionItem = await (select(sessionItems)
              ..where((t) => t.id.equals(entry.key)))
            .getSingle();

        final foundQty = entry.value;
        final lostQty = sessionItem.quantityWashed - foundQty;
        if (lostQty > 0) hasLostItem = true;

        await (update(sessionItems)..where((t) => t.id.equals(entry.key)))
            .write(SessionItemsCompanion(quantityFound: Value(foundQty)));

        // Unit yang ketemu -> balik ke stok. Unit yang hilang -> tidak.
        if (foundQty > 0) {
          await wardrobeDao.incrementQuantity(sessionItem.itemId, foundQty);
        }
      }

      await (update(laundrySessions)..where((t) => t.id.equals(sessionId))).write(
        LaundrySessionsCompanion(
          status: Value(hasLostItem ? SessionStatus.adaItemHilang : SessionStatus.selesai),
          verifiedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // Dipanggil saat "Hapus Sesi" untuk sesi berstatus "berjalan" -> release semua stok
  Future<void> deleteRunningSession(int sessionId) async {
    await transaction(() async {
      final items = await getItemsForSession(sessionId);
      final wardrobeDao = db.wardrobeDao;

      for (final item in items) {
        await wardrobeDao.incrementQuantity(item.itemId, item.quantityWashed);
      }

      await (delete(laundrySessions)..where((t) => t.id.equals(sessionId))).go();
      // SessionItems ikut kehapus otomatis karena onDelete: KeyAction.cascade
    });
  }
}