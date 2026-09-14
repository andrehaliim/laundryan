import 'package:drift/drift.dart';
import 'wardrobe_items.dart';
import 'laundry_sessions.dart';

class SessionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(LaundrySessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get itemId =>
      integer().references(WardrobeItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get quantityWashed => integer()(); // fixed saat sesi dibuat, read-only setelahnya
  IntColumn get quantityFound => integer().nullable()(); // null = belum diverifikasi
}