import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/add_session_screen.dart';
import 'package:laundryan/screens/checklist_screen.dart';
import 'package:laundryan/screens/history_detail_screen.dart';
import 'package:laundryan/screens/session_detail_screen.dart';
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
          Text(l10n.history, style: titleStyle),
          const SizedBox(height: 8),
          if (sessions.history.isEmpty)
            Text(
              l10n.noHistory,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          for (final e in sessions.history)
            SessionCard(
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
        title: Text(l10n.sessions),
        actions: const [SettingsButton()],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addSession,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddSessionScreen()),
        ),
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
    final dateFmt = DateFormat.yMMMd(locale);
    final dateTimeFmt = DateFormat.yMMMd(locale).add_Hm();
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        );

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
              Text(s.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(s.placeName, style: subStyle),
              const SizedBox(height: 8),
              Text('${l10n.dropOff}: ${dateFmt.format(s.dropOffDate)}',
                  style: subStyle),
              Text(
                '${l10n.estimatedReady}: ${dateTimeFmt.format(s.estimatedReadyAt)}',
                style: subStyle,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.totalItems(entry.totalItems),
                        style: subStyle),
                  ),
                  if (onVerify != null)
                    FilledButton(
                      onPressed: onVerify,
                      child: Text(l10n.verify),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}