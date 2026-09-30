import 'package:drift/drift.dart' show Value;

import 'app_database.dart';
import 'enums.dart';

class SessionItemInput {
  final int itemId;
  final int quantity;
  const SessionItemInput(this.itemId, this.quantity);
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
}