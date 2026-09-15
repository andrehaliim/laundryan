import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

final wardrobeItemsStreamProvider =
    StreamProvider.autoDispose<List<WardrobeItem>>((ref) {
  final dao = ref.watch(wardrobeDaoProvider);
  return dao.watchAllItems();
});