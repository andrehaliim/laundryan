import 'package:drift/drift.dart';

import 'app_database.dart';
import 'enums.dart';

class SessionItemInput {
  final int itemId;
  final int quantity;
  const SessionItemInput(this.itemId, this.quantity);
}

class SessionEntry {
  final Session session;
  final int totalItems;
  final int missingQty;
  const SessionEntry(this.session, this.totalItems, this.missingQty);
}

class SessionItemView {
  final SessionItem sessionItem;
  final WardrobeItem item;
  const SessionItemView(this.sessionItem, this.item);
}

class ItemVerification {
  final int sessionItemId;
  final int returnedQty;
  final ItemStatus status;
  final String? note;
  const ItemVerification(
    this.sessionItemId,
    this.returnedQty,
    this.status,
    this.note,
  );
}

class SessionRepository {
  final AppDatabase db;
  SessionRepository(this.db);

  /// Simpan sesi + item-nya dalam satu transaksi. Return id sesi.
  Future<int> create({
    required String title,
    required String placeName,
    String? placeAddress,
    String? placePhone,
    required DateTime dropOffDate,
    required DateTime estimatedReadyAt,
    required bool reminderEnabled,
    required List<SessionItemInput> items,
  }) {
    return db.transaction(() async {
      final id = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              title: title,
              placeName: placeName,
              placeAddress: Value(placeAddress),
              placePhone: Value(placePhone),
              dropOffDate: dropOffDate,
              estimatedReadyAt: estimatedReadyAt,
              status: SessionStatus.active,
              reminderEnabled: Value(reminderEnabled),
            ),
          );
      await db.batch((b) {
        b.insertAll(
          db.sessionItems,
          items.map(
            (i) => SessionItemsCompanion.insert(
              sessionId: id,
              itemId: i.itemId,
              quantity: i.quantity,
              status: ItemStatus.dibawa,
            ),
          ),
        );
      });
      return id;
    });
  }

  Stream<List<SessionEntry>> _watch(SessionStatus status, String order) {
    return db
        .customSelect(
          'SELECT s.*, '
          'COALESCE((SELECT SUM(si.quantity) FROM session_items si '
          'WHERE si.session_id = s.id), 0) AS total_items, '
          'COALESCE((SELECT SUM(si.quantity - COALESCE(si.returned_qty, 0)) '
          'FROM session_items si WHERE si.session_id = s.id '
          "AND si.status IN ('hilang', 'tertukar')), 0) AS missing_qty "
          'FROM sessions s WHERE s.status = ? ORDER BY $order',
          variables: [Variable.withString(status.name)],
          readsFrom: {db.sessions, db.sessionItems},
        )
        .watch()
        .map(
          (rows) => rows
              .map((r) => SessionEntry(
                    db.sessions.map(r.data),
                    r.read<int>('total_items'),
                    r.read<int>('missing_qty'),
                  ))
              .toList(),
        );
  }

  Stream<List<SessionEntry>> watchActive() =>
      _watch(SessionStatus.active, 's.created_at DESC');

  Stream<List<SessionEntry>> watchHistory() =>
      _watch(SessionStatus.completed, 's.completed_at DESC');

  Future<List<SessionItemView>> items(int sessionId) async {
    final query = db.select(db.sessionItems).join([
      innerJoin(
        db.wardrobeItems,
        db.wardrobeItems.id.equalsExp(db.sessionItems.itemId),
      ),
    ])
      ..where(db.sessionItems.sessionId.equals(sessionId));
    final rows = await query.get();
    return rows
        .map((r) => SessionItemView(
              r.readTable(db.sessionItems),
              r.readTable(db.wardrobeItems),
            ))
        .toList();
  }

  /// Hanya judul, reminder, dan estimasi selesai yang boleh diubah.
  Future<void> update(
    int id, {
    required String title,
    required bool reminderEnabled,
    required DateTime estimatedReadyAt,
  }) async {
    await (db.update(db.sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        title: Value(title),
        reminderEnabled: Value(reminderEnabled),
        estimatedReadyAt: Value(estimatedReadyAt),
      ),
    );
  }

  /// Hapus sesi aktif. session_items ikut terhapus (cascade),
  /// jadi qty otomatis kembali tersedia.
  Future<void> cancel(int id) async {
    await (db.delete(db.sessions)
          ..where((t) =>
              t.id.equals(id) & t.status.equalsValue(SessionStatus.active)))
        .go();
  }

    Future<void> complete(int sessionId, List<ItemVerification> results) {
    return db.transaction(() async {
      for (final r in results) {
        await (db.update(db.sessionItems)
              ..where((t) => t.id.equals(r.sessionItemId)))
            .write(SessionItemsCompanion(
          returnedQty: Value(r.returnedQty),
          status: Value(r.status),
          note: Value(r.note),
        ));
      }
      await (db.update(db.sessions)..where((t) => t.id.equals(sessionId)))
          .write(SessionsCompanion(
        status: const Value(SessionStatus.completed),
        completedAt: Value(DateTime.now()),
      ));
    });
  }

  /// Selesaikan item hilang/tertukar untuk seluruh qty hilang sekaligus.
  /// ditemukan -> qty tersedia kembali otomatis (status tidak lagi mengunci).
  /// hilangPermanen -> totalQty wardrobe berkurang sebesar lostQty.
  Future<void> resolveLost(int sessionItemId, ItemStatus result) {
    assert(result == ItemStatus.ditemukan ||
        result == ItemStatus.hilangPermanen);
    return db.transaction(() async {
      final si = await (db.select(db.sessionItems)
            ..where((t) => t.id.equals(sessionItemId)))
          .getSingle();
      if (si.status != ItemStatus.hilang &&
          si.status != ItemStatus.tertukar) {
        return;
      }
      final lostQty = si.quantity - (si.returnedQty ?? 0);

      await (db.update(db.sessionItems)
            ..where((t) => t.id.equals(sessionItemId)))
          .write(SessionItemsCompanion(status: Value(result)));

      if (result == ItemStatus.hilangPermanen) {
        final w = await (db.select(db.wardrobeItems)
              ..where((t) => t.id.equals(si.itemId)))
            .getSingle();
        await (db.update(db.wardrobeItems)
              ..where((t) => t.id.equals(si.itemId)))
            .write(WardrobeItemsCompanion(
          totalQty: Value(w.totalQty - lostQty),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
  }
}