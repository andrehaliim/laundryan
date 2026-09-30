import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundryan/data/session_repository.dart';

class SessionProvider extends ChangeNotifier {
  final SessionRepository _repo;
  StreamSubscription<List<SessionEntry>>? _activeSub;
  StreamSubscription<List<SessionEntry>>? _historySub;
  List<SessionEntry> _active = [];
  List<SessionEntry> _history = [];

  SessionProvider(this._repo) {
    _activeSub = _repo.watchActive().listen((d) {
      _active = d;
      notifyListeners();
    });
    _historySub = _repo.watchHistory().listen((d) {
      _history = d;
      notifyListeners();
    });
  }

  List<SessionEntry> get active => _active;
  List<SessionEntry> get history => _history;

  Future<List<SessionItemView>> items(int sessionId) => _repo.items(sessionId);

  // TODO (Step 9): jadwalkan notifikasi setelah sesi dibuat.
  Future<int> create({
    required String title,
    required String placeName,
    String? placeAddress,
    String? placePhone,
    required DateTime dropOffDate,
    required DateTime estimatedReadyAt,
    required bool reminderEnabled,
    required List<SessionItemInput> items,
  }) =>
      _repo.create(
        title: title,
        placeName: placeName,
        placeAddress: placeAddress,
        placePhone: placePhone,
        dropOffDate: dropOffDate,
        estimatedReadyAt: estimatedReadyAt,
        reminderEnabled: reminderEnabled,
        items: items,
      );

  // TODO (Step 9): jadwalkan ulang / batalkan notifikasi di sini.
  Future<void> update(
    int id, {
    required String title,
    required bool reminderEnabled,
    required DateTime estimatedReadyAt,
  }) =>
      _repo.update(
        id,
        title: title,
        reminderEnabled: reminderEnabled,
        estimatedReadyAt: estimatedReadyAt,
      );

  Future<void> cancel(int id) => _repo.cancel(id);

  @override
  void dispose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}