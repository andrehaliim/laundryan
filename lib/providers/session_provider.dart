import 'package:flutter/material.dart';
import 'package:laundryan/data/session_repository.dart';

class SessionProvider extends ChangeNotifier {
  final SessionRepository _repo;
  SessionProvider(this._repo);

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
}