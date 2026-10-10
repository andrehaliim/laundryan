import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/add_session_screen.dart';
import 'package:laundryan/screens/history_detail_screen.dart';
import 'package:laundryan/screens/history_list_screen.dart';
import 'package:laundryan/screens/session_detail_screen.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/session_phase.dart';
import 'package:laundryan/utils/time_format.dart';
import 'package:laundryan/widgets/pulse.dart';
import 'package:laundryan/widgets/session_category_badges.dart';
import 'package:laundryan/widgets/settings_button.dart';
import 'package:laundryan/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessions = context.watch<SessionProvider>();
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    Widget body;
    if (sessions.active.isEmpty && sessions.history.isEmpty) {
      body = EmptyState(
        icon: HugeIcons.strokeRoundedWashingMachine,
        orbit: const [
          HugeIcons.strokeRoundedTShirt,
          HugeIcons.strokeRoundedClock01,
        ],
        title: l10n.sessionsEmpty,
        message: l10n.sessionsEmptyHint,
        actionLabel: l10n.addSession,
        actionIcon: HugeIcons.strokeRoundedPlusSign,
        onAction: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddSessionScreen())),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.activeSessions, style: titleStyle),
          const SizedBox(height: 8),
          if (sessions.active.isEmpty)
            EmptyState(
              compact: true,
              tone: EmptyStateTone.tertiary,
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              title: l10n.noActiveSessions,
              message: l10n.noActiveSessionsHint,
            ),
          for (final e in sessions.active)
            SessionCard(
              entry: e,
              onViewDetails: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SessionDetailScreen(sessionId: e.session.id),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(l10n.history, style: titleStyle)),
              if (sessions.history.isNotEmpty)
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryListScreen(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      l10n.viewAllHistory(sessions.history.length),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (sessions.history.isEmpty)
            EmptyState(
              compact: true,
              tone: EmptyStateTone.secondary,
              icon: HugeIcons.strokeRoundedArchive02,
              title: l10n.noHistory,
              message: l10n.noHistoryHint,
            ),
          for (final e in sessions.history.take(3))
            HistoryCard(
              entry: e,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryDetailScreen(sessionId: e.session.id),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/icon/icon.png', height: 40),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  l10n.sessions,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        actions: [const SettingsButton()],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_sessions',
        tooltip: l10n.addSession,
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddSessionScreen())),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedPlusSign,
          strokeWidth: 2,
        ),
      ),
      body: body,
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionEntry entry;
  final VoidCallback? onViewDetails;

  const SessionCard({super.key, required this.entry, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final s = entry.session;
    final dateTimeFmt = with12hTime(DateFormat.yMMMd(locale));
    final subStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 30), (i) => i),
      builder: (_, _) {
        final phase = s.phase;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.title.isEmpty ? l10n.sessionTitle : s.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CountBadge(
                      label: phaseLabel(phase, l10n),
                      horizontalPadding: 8,
                      mode: CountBadgeMode.normal,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  (s.placeAddress == null || s.placeAddress!.isEmpty)
                      ? s.placeName
                      : '${s.placeName} (${s.placeAddress})',
                  style: subStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                SoftCardOutline(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusIndicator(
                        context: context,
                        title: phaseLabel(SessionPhase.dropped, l10n),
                        icon: HugeIcons.strokeRoundedPackageMoving,
                        status: SessionPhase.dropped,
                        current: s.phase,
                      ),
                      _statusIndicator(
                        context: context,
                        title: phaseLabel(SessionPhase.washing, l10n),
                        icon: HugeIcons.strokeRoundedWashingMachine,
                        status: SessionPhase.washing,
                        current: s.phase,
                      ),
                      _statusIndicator(
                        context: context,
                        title: phaseLabel(SessionPhase.pickup, l10n),
                        icon: HugeIcons.strokeRoundedShoppingBag02,
                        status: SessionPhase.pickup,
                        current: s.phase,
                      ),
                      _statusIndicator(
                        context: context,
                        title: phaseLabel(SessionPhase.verified, l10n),
                        icon: HugeIcons.strokeRoundedTaskDone01,
                        status: SessionPhase.verified,
                        current: s.phase,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.totalItems(entry.totalItems)} ${l10n.dropOff.toLowerCase()}',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    if (s.placePhone != null)
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedWhatsapp,
                        color: scheme.tertiary,
                        size: Theme.of(context).textTheme.titleLarge!.fontSize,
                        strokeWidth: 2,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SessionCategoryBadges(sessionId: s.id),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      color: scheme.primary,
                      size: Theme.of(context).textTheme.titleLarge!.fontSize,
                      strokeWidth: 2,
                    ),
                    const SizedBox(width: 8),
                    Text('${l10n.dropOffDate}: ', style: subStyle),
                    const Spacer(),
                    Text(
                      dateTimeFmt.format(s.dropOffDate),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: scheme.primary,
                      size: Theme.of(context).textTheme.titleLarge!.fontSize,
                      strokeWidth: 2,
                    ),
                    const SizedBox(width: 8),
                    Text('${l10n.estimatedReady}: ', style: subStyle),
                    const Spacer(),
                    Text(
                      dateTimeFmt.format(s.estimatedReadyAt),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedNotification01,
                      color: scheme.primary,
                      size: Theme.of(context).textTheme.titleLarge!.fontSize,
                      strokeWidth: 2,
                    ),
                    const SizedBox(width: 8),
                    Text('${l10n.notification}: ', style: subStyle),
                    const Spacer(),
                    Text(
                      s.reminderEnabled ? l10n.statusOn : l10n.statusOff,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: s.reminderEnabled
                            ? scheme.tertiary
                            : scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (onViewDetails != null) ...[
                  const SizedBox(height: 8),
                  SoftButton(
                    label: l10n.viewDetails,
                    onPressed: onViewDetails,
                    expanded: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusIndicator({
    required BuildContext context,
    required String title,
    required List<List<dynamic>> icon,
    required SessionPhase status,
    required SessionPhase current,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = current == status;
    final reached = current.index >= status.index;

    final bg = isCurrent
        ? scheme.primary
        : reached
        ? scheme.tertiary
        : scheme.surfaceContainerHighest;
    final fg = isCurrent
        ? scheme.onPrimary
        : reached
        ? scheme.onTertiary
        : scheme.outline;

    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: reached ? scheme.onSurface : scheme.onSurfaceVariant,
      fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
    );

    return Column(
      children: [
        Pulse(
          active: isCurrent && status != SessionPhase.verified,
          color: bg,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: HugeIcon(icon: icon, color: fg, size: 18),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: subStyle),
      ],
    );
  }
}

class HistoryCard extends StatelessWidget {
  final SessionEntry entry;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final s = entry.session;
    final dateFmt = DateFormat.MMMd(locale);
    final yearFmt = DateFormat.yMMMd(locale);

    final total = entry.totalItems;
    final missing = entry.missingQty;
    final returned = (total - missing).clamp(0, total);
    final safe = missing == 0;

    // all back → green, something still missing → pink.
    final (
      List<List<dynamic>> statusIcon,
      Color statusBg,
      Color statusFg,
    ) = safe
        ? (
            HugeIcons.strokeRoundedCheckmarkCircle02,
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          )
        : (
            HugeIcons.strokeRoundedAlert02,
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          );

    final end = s.completedAt;
    final range = end == null
        ? yearFmt.format(s.dropOffDate)
        : '${dateFmt.format(s.dropOffDate)} – ${yearFmt.format(end)}';
    final days = end == null
        ? null
        : DateUtils.dateOnly(end)
              .difference(DateUtils.dateOnly(s.dropOffDate))
              .inDays
              .clamp(0, 9999);
    final place = [
      s.placeName,
      if (s.placeAddress != null && s.placeAddress!.isNotEmpty) s.placeAddress!,
    ].join(' • ');

    return SoftCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HugeIcon(
                  icon: statusIcon,
                  strokeWidth: 2,
                  size: 22,
                  color: statusFg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title.isEmpty ? l10n.sessionTitle : s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedLocation01,
                          strokeWidth: 2,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CountBadge(
                label: safe ? l10n.statusAllSafe : l10n.swapMissing(missing),
                horizontalPadding: 8,
                mode: safe ? CountBadgeMode.tertiary : CountBadgeMode.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      strokeWidth: 2,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        range,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ),
                    if (days != null) ...[
                      const SizedBox(width: 8),
                      CountBadge(
                        label: l10n.durationDays(days),
                        horizontalPadding: 8,
                        mode: CountBadgeMode.normal,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedTShirt,
                      strokeWidth: 2,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : returned / total,
                          minHeight: 6,
                          color: safe ? scheme.tertiary : scheme.secondary,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.returnedBadge(returned, total),
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
