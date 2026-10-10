import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/l10n/app_localizations.dart';

/// Shared tick so time-based phases refresh without a timer per widget.
final phaseTicker = Stream<void>.periodic(
  const Duration(seconds: 30),
).asBroadcastStream();

extension SessionPhaseX on Session {
  SessionPhase get phase {
    if (status == SessionStatus.completed) return SessionPhase.verified;
    final now = DateTime.now();
    if (!now.isBefore(estimatedReadyAt)) return SessionPhase.pickup;
    if (now.isBefore(dropOffDate.add(const Duration(minutes: 10)))) {
      return SessionPhase.dropped;
    }
    return SessionPhase.washing;
  }
}

String phaseLabel(SessionPhase p, AppLocalizations l10n) => switch (p) {
  SessionPhase.dropped => l10n.phaseDropped,
  SessionPhase.washing => l10n.phaseWashing,
  SessionPhase.pickup => l10n.phasePickup,
  SessionPhase.verified => l10n.phaseVerified,
};

String phaseLabelLong(SessionPhase p, AppLocalizations l10n) => switch (p) {
  SessionPhase.dropped => l10n.phaseDroppedLong,
  SessionPhase.washing => l10n.phaseWashingLong,
  SessionPhase.pickup => l10n.phasePickupLong,
  SessionPhase.verified => l10n.phaseVerifiedLong,
};
