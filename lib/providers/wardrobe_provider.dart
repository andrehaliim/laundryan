import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundryan/data/wardrobe_repository.dart';

class WardrobeProvider extends ChangeNotifier {
  final WardrobeRepository _repo;
  StreamSubscription<List<WardrobeEntry>>? _sub;
  List<WardrobeEntry> _all = [];
  String _query = '';
  List<WardrobeEntry> get allItems => _all;
  int? _categoryId;
  int? get categoryId => _categoryId;

  WardrobeProvider(this._repo) {
    _sub = _repo.watchAll().listen((data) {
      _all = data;
      notifyListeners();
    });
  }

  bool get isEmpty => _all.isEmpty;

  List<WardrobeEntry> get items {
    final q = _query.trim().toLowerCase();
    return _all.where((e) {
      final matchCategory =
          _categoryId == null || e.item.categoryId == _categoryId;
      final matchName = q.isEmpty || e.item.name.toLowerCase().contains(q);
      return matchCategory && matchName;
    }).toList();
  }

  void setQuery(String q) {
    _query = q;
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

  Future<bool> delete(int id) => _repo.delete(id);

  void setCategory(int? id) {
    _categoryId = id;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
