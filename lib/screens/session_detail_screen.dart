import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:provider/provider.dart';

class SessionDetailScreen extends StatefulWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late bool _reminder;
  late DateTime _readyAt;
  late final Future<List<SessionItemView>> _items;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SessionProvider>();
    final s = provider.active.firstWhere((e) => e.session.id == widget.sessionId).session;
    _title = TextEditingController(text: s.title);
    _reminder = s.reminderEnabled;
    _readyAt = s.estimatedReadyAt;
    _items = provider.items(widget.sessionId);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickReadyAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _readyAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_readyAt),
    );
    if (time == null) return;
    setState(() {
      _readyAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    await context.read<SessionProvider>().update(
          widget.sessionId,
          title: _title.text.trim(),
          reminderEnabled: _reminder,
          estimatedReadyAt: _readyAt,
        );
    navigator.pop();
  }

  Future<void> _cancelSession(AppLocalizations l10n) async {
    final provider = context.read<SessionProvider>();
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelSessionTitle),
        content: Text(l10n.cancelSessionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.keepSession),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.cancelSession),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await provider.cancel(widget.sessionId);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateTimeFmt = DateFormat.yMMMd(locale).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            tooltip: l10n.cancelSession,
            onPressed: () => _cancelSession(l10n),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.sessionTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickReadyAt,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.estimatedReady,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.event_outlined),
                ),
                child: Text(dateTimeFmt.format(_readyAt)),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.reminder),
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
            const SizedBox(height: 8),
            Text(l10n.items, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.itemsLocked,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<SessionItemView>>(
              future: _items,
              builder: (_, snap) {
                final list = snap.data ?? const <SessionItemView>[];
                return Column(
                  children: [
                    for (final v in list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(v.item.name),
                        trailing: Text('x${v.sessionItem.quantity}'),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}