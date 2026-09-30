import 'package:flutter/material.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/utils/phone_utils.dart';

class LostLine {
  final String name;
  final int qty;
  final ItemStatus status;
  const LostLine(this.name, this.qty, this.status);
}

class ChecklistSummaryScreen extends StatelessWidget {
  final String title;
  final String? phone;
  final List<LostLine> lost;
  const ChecklistSummaryScreen({
    super.key,
    required this.title,
    required this.phone,
    required this.lost,
  });

  String _label(ItemStatus s, AppLocalizations l10n) =>
      s == ItemStatus.tertukar ? l10n.statusSwapped : l10n.statusLost;

  Future<void> _chat(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final items = lost
        .map((e) => '- ${e.name} x${e.qty} (${_label(e.status, l10n)})')
        .join('\n');
    final ok = await openWhatsApp(phone!, l10n.waMessage(title, items));
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.whatsappFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final hasPhone = phone != null && phone!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionFinished)),
      body: lost.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(l10n.allReturned,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.missingItems,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final e in lost)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.name),
                    subtitle: Text(_label(e.status, l10n)),
                    trailing: Text('x${e.qty}'),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lost.isNotEmpty && hasPhone)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _chat(context, l10n),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(l10n.chatWhatsapp),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}