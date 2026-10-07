import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/add_session_screen.dart';
import 'package:laundryan/screens/checklist_screen.dart';
import 'package:laundryan/screens/history_detail_screen.dart';
import 'package:laundryan/screens/history_list_screen.dart';
import 'package:laundryan/screens/session_detail_screen.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/session_phase.dart';
import 'package:laundryan/widgets/pulse.dart';
import 'package:laundryan/widgets/session_category_badges.dart';
import 'package:laundryan/widgets/settings_button.dart';
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
      body = Center(
        child: Text(
          l10n.sessionsEmpty,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.activeSessions, style: titleStyle),
          const SizedBox(height: 8),
          if (sessions.active.isEmpty)
            Text(
              l10n.noActiveSessions,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          for (final e in sessions.active)
            SessionCard(
              entry: e,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SessionDetailScreen(sessionId: e.session.id),
                ),
              ),
              onVerify: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChecklistScreen(sessionId: e.session.id),
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
            Text(
              l10n.noHistory,
              style: TextStyle(color: scheme.onSurfaceVariant),
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
        child: const Icon(Icons.add),
      ),
      body: body,
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onVerify;

  const SessionCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final s = entry.session;
    final dateTimeFmt = DateFormat.yMMMd(locale).add_Hm();
    final subStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 30), (i) => i),
      builder: (_, _) {
        final phase = s.phase;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
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
                          size: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .fontSize,
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
                        DateFormat.yMMMd(locale).format(s.dropOffDate),
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
                  if (onVerify != null) ...[
                    const SizedBox(height: 8),
                    SoftButton(
                      label: l10n.verify,
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      onPressed: onVerify,
                      expanded: true,
                    ),
                  ],
                ],
              ),
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
    final locale = Localizations.localeOf(context).toString();
    final s = entry.session;
    final dateTimeFmt = DateFormat.MMMd(locale);
    final subStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    label: entry.missingQty > 0
                        ? l10n.swapMissing(entry.missingQty)
                        : l10n.finishedLabel,
                    horizontalPadding: 8,
                    mode: entry.missingQty > 0
                        ? CountBadgeMode.secondary
                        : CountBadgeMode.tertiary,
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
              Text(
                '${dateTimeFmt.format(s.dropOffDate)} - ${dateTimeFmt.format(s.completedAt!)}',
                style: subStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
