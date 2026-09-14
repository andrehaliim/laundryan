import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/wardrobe_items.dart';
import 'tables/laundry_sessions.dart';
import 'tables/session_items.dart';
import 'daos/wardrobe_dao.dart';
import 'daos/session_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [WardrobeItems, LaundrySessions, SessionItems],
  daos: [WardrobeDao, SessionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'laundryan.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}