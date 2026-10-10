import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundryan/data/wardrobe_repository.dart';

enum WardrobeSort { alphabetDesc, alphabetAsc }

class WardrobeProvider extends ChangeNotifier {
  final WardrobeRepository _repo;
  StreamSubscription<List<WardrobeEntry>>? _sub;
  List<WardrobeEntry> _all = [];
  List<WardrobeEntry>? _filtered;
  bool _loaded = false;
  String _query = '';
  String get query => _query;
  List<WardrobeEntry> get allItems => _all;
  int? _categoryId;
  int? get categoryId => _categoryId;

  WardrobeProvider(this._repo) {
    _sub = _repo.watchAll().listen((data) {
      _all = data;
      _filtered = null;
      _loaded = true;
      if (data.isEmpty) {
        _query = '';
        _categoryId = null;
      }
      notifyListeners();
    });
  }

  bool get isLoaded => _loaded;
  bool get isEmpty => _all.isEmpty;

  /// Filtered and sorted list, cached until the data or a filter changes.
  /// The repository already returns items A-Z.
  List<WardrobeEntry> get items => _filtered ??= _filter();

  List<WardrobeEntry> _filter() {
    final q = _query.trim().toLowerCase();
    final list = _all.where((e) {
      final matchCategory =
          _categoryId == null || e.item.categoryId == _categoryId;
      final matchName = q.isEmpty || e.item.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();

    return switch (_sort) {
      WardrobeSort.alphabetAsc => list,
      WardrobeSort.alphabetDesc => list.reversed.toList(),
    };
  }

  void setQuery(String q) {
    _query = q;
    _filtered = null;
    notifyListeners();
  }

  Future<void> add({
    required String name,
    required int categoryId,
    required int totalQty,
    String? photoPath,
    String? note,
  }) => _repo.add(
    name: name,
    categoryId: categoryId,
    totalQty: totalQty,
    photoPath: photoPath,
    note: note,
  );

  Future<bool> update(
    int id, {
    required String name,
    required int categoryId,
    required int totalQty,
    String? photoPath,
    String? note,
  }) => _repo.update(
    id,
    name: name,
    categoryId: categoryId,
    totalQty: totalQty,
    photoPath: photoPath,
    note: note,
  );

  Future<WardrobeDeleteResult> delete(int id) => _repo.delete(id);

  void setCategory(int? id) {
    _categoryId = id;
    _filtered = null;
    notifyListeners();
  }

  WardrobeSort _sort = WardrobeSort.alphabetAsc;
  WardrobeSort get sort => _sort;

  void setSort(WardrobeSort s) {
    _sort = s;
    _filtered = null;
    notifyListeners();
  }

  void toggleSort() => setSort(
    _sort == WardrobeSort.alphabetDesc
        ? WardrobeSort.alphabetAsc
        : WardrobeSort.alphabetDesc,
  );

  int countByCategory(int categoryId) =>
      _all.where((e) => e.item.categoryId == categoryId).length;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
