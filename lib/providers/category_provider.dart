import 'dart:async';

import 'package:laundryan/data/app_database.dart';
import 'package:flutter/material.dart';
import 'package:laundryan/data/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo;
  StreamSubscription<List<Category>>? _sub;
  List<Category> _categories = [];

  CategoryProvider(this._repo) {
    _sub = _repo.watchAll().listen((data) {
      _categories = data;
      notifyListeners();
    });
  }

  List<Category> get categories => _categories;
  Category? byId(int id) => _categories.where((c) => c.id == id).firstOrNull;

  Future<void> add(String name, String iconKey) => _repo.add(name, iconKey);

  Future<void> update(int id, {String? name, required String iconKey}) =>
      _repo.update(id, name: name, iconKey: iconKey);

  /// Returns false if the category is still used by wardrobe items.
  Future<bool> delete(Category c) async {
    if (await _repo.isUsed(c.id)) return false;
    await _repo.delete(c.id);
    return true;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
