import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/utils/notification_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionRepository _repo;
  final Locale Function() _locale;
  StreamSubscription<List<SessionEntry>>? _activeSub;
  StreamSubscription<List<SessionEntry>>? _historySub;
  StreamSubscription<Map<int, Map<int, int>>>? _countsSub;
  Map<int, Map<int, int>> _categoryCounts = {};
  List<SessionEntry> _active = [];
  List<SessionEntry> _history = [];
  bool _activeLoaded = false;
  bool _historyLoaded = false;

  SessionProvider(this._repo, this._locale) {
    _activeSub = _repo.watchActive().listen((d) {
      _active = d;
      _activeLoaded = true;
      notifyListeners();
    });
    _historySub = _repo.watchHistory().listen((d) {
      _history = d;
      _historyLoaded = true;
      notifyListeners();
    });
    _countsSub = _repo.watchActiveCategoryCounts().listen((d) {
      _categoryCounts = d;
      notifyListeners();
    });
  }

  List<SessionEntry> get active => _active;
  List<SessionEntry> get history => _history;
  bool get isLoaded => _activeLoaded && _historyLoaded;

  /// categoryId -> qty for an active session.
  Map<int, int> categoryCounts(int sessionId) =>
      _categoryCounts[sessionId] ?? const {};

  Future<List<SessionItemView>> items(int sessionId) => _repo.items(sessionId);

  /// Cancels the old schedule, then reschedules if the reminder is enabled.
  Future<void> _syncReminder({
    required int id,
    required String title,
    required String place,
    required bool enabled,
    required DateTime readyAt,
  }) async {
    await NotificationService.cancel(id);
    if (!enabled) return;
    final l10n = lookupAppLocalizations(_locale());
    await NotificationService.schedule(
      id: id,
      title: l10n.reminderTitle,
      body: l10n.reminderBody(title, place),
      fireAt: readyAt.subtract(const Duration(hours: 2)),
    );
  }

  Future<int> create({
    required String title,
    required String placeName,
    String? placeAddress,
    String? placePhone,
    required DateTime dropOffDate,
    required DateTime estimatedReadyAt,
    required bool reminderEnabled,
    required List<SessionItemInput> items,
  }) async {
    final id = await _repo.create(
      title: title,
      placeName: placeName,
      placeAddress: placeAddress,
      placePhone: placePhone,
      dropOffDate: dropOffDate,
      estimatedReadyAt: estimatedReadyAt,
      reminderEnabled: reminderEnabled,
      items: items,
    );
    await _syncReminder(
      id: id,
      title: title,
      place: placeName,
      enabled: reminderEnabled,
      readyAt: estimatedReadyAt,
    );
    return id;
  }

  Future<void> update(
    int id, {
    required String title,
    required bool reminderEnabled,
    required DateTime estimatedReadyAt,
  }) async {
    await _repo.update(
      id,
      title: title,
      reminderEnabled: reminderEnabled,
      estimatedReadyAt: estimatedReadyAt,
    );
    final place =
        _active
            .where((e) => e.session.id == id)
            .firstOrNull
            ?.session
            .placeName ??
        '';
    await _syncReminder(
      id: id,
      title: title,
      place: place,
      enabled: reminderEnabled,
      readyAt: estimatedReadyAt,
    );
  }

  Future<void> cancel(int id) async {
    await _repo.cancel(id);
    await NotificationService.cancel(id);
  }

  Future<void> complete(int id, List<ItemVerification> results) async {
    await _repo.complete(id, results);
    await NotificationService.cancel(id);
  }

  Future<void> resolveLost(int sessionItemId, ItemStatus result) =>
      _repo.resolveLost(sessionItemId, result);

  @override
  void dispose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    _countsSub?.cancel();
    super.dispose();
  }
}
