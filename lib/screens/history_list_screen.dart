import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/history_detail_screen.dart';
import 'package:laundryan/screens/sessions_screen.dart';
import 'package:laundryan/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final history = context.watch<SessionProvider>().history;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history)),
      body: history.isEmpty
          ? EmptyState(
              tone: EmptyStateTone.secondary,
              icon: HugeIcons.strokeRoundedArchive02,
              orbit: const [
                HugeIcons.strokeRoundedTick02,
                HugeIcons.strokeRoundedCalendar03,
              ],
              title: l10n.noHistory,
              message: l10n.noHistoryHint,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final e = history[i];
                return HistoryCard(
                  entry: e,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          HistoryDetailScreen(sessionId: e.session.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}