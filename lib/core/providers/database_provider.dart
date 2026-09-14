import 'package:laundryan/core/database/daos/session_dao.dart';
import 'package:laundryan/core/database/daos/wardrobe_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';

part 'database_provider.g.dart';

// keepAlive: true -> instance AppDatabase (dan koneksi SQLite-nya) hidup
// sepanjang app berjalan, nggak di-dispose pas widget yang nge-watch hilang.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@riverpod
WardrobeDao wardrobeDao(Ref ref) {
  return ref.watch(appDatabaseProvider).wardrobeDao;
}

@riverpod
SessionDao sessionDao(Ref ref) {
  return ref.watch(appDatabaseProvider).sessionDao;
}