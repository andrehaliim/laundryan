import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/widgets/item_thumb.dart';
import 'package:provider/provider.dart';

class HistoryDetailScreen extends StatefulWidget {
  final int sessionId;
  const HistoryDetailScreen({super.key, required this.sessionId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<List<SessionItemView>> _items;

  @override
  void initState() {
    super.initState();
    _items = context.read<SessionProvider>().items(widget.sessionId);
  }

  void _reload() {
    setState(() {
      _items = context.read<SessionProvider>().items(widget.sessionId);
    });
  }

  String _label(ItemStatus s, AppLocalizations l10n) => switch (s) {
        ItemStatus.kembali => l10n.statusReturned,
        ItemStatus.hilang => l10n.statusLost,
        ItemStatus.tertukar => l10n.statusSwapped,
        ItemStatus.hilangPermanen => l10n.statusPermanentlyLost,
        ItemStatus.ditemukan => l10n.statusFound,
        ItemStatus.dibawa => '',
      };

  Future<void> _resolve(
    SessionItemView v,
    ItemStatus result,
    AppLocalizations l10n,
  ) async {
    final provider = context.read<SessionProvider>();
    final lostQty = v.sessionItem.quantity - (v.sessionItem.returnedQty ?? 0);

    if (result == ItemStatus.hilangPermanen) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.permanentLostTitle),
          content: Text(l10n.permanentLostMessage(lostQty)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    await provider.resolveLost(v.sessionItem.id, result);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final dateTimeFmt = DateFormat.yMMMd(locale).add_Hm();
    final cats = context.watch<CategoryProvider>().categories;
    final session = context
        .watch<SessionProvider>()
        .history
        .where((e) => e.session.id == widget.sessionId)
        .firstOrNull
        ?.session;

    if (session == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.sessionDetail)));
    }

    final sub = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionDetail)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(session.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(session.placeName, style: sub),
          if (session.placeAddress != null) Text(session.placeAddress!, style: sub),
          if (session.placePhone != null) Text(session.placePhone!, style: sub),
          const SizedBox(height: 8),
          Text('${l10n.dropOff}: ${dateFmt.format(session.dropOffDate)}', style: sub),
          Text(
            '${l10n.estimatedReady}: ${dateTimeFmt.format(session.estimatedReadyAt)}',
            style: sub,
          ),
          if (session.completedAt != null)
            Text(
              '${l10n.completedAt}: ${dateTimeFmt.format(session.completedAt!)}',
              style: sub,
            ),
          const SizedBox(height: 16),
          Text(l10n.items, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<SessionItemView>>(
            future: _items,
            builder: (_, snap) {
              final list = snap.data;
              if (list == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  for (final v in list) _buildItem(v, cats, l10n, scheme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    SessionItemView v,
    List cats,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final si = v.sessionItem;
    final total = si.quantity;
    final returned = si.returnedQty ?? 0;
    final lostQty = total - returned;
    final cat = cats.where((c) => c.id == v.item.categoryId).firstOrNull;
    final unresolved =
        si.status == ItemStatus.hilang || si.status == ItemStatus.tertukar;
    final bad = si.status != ItemStatus.kembali &&
        si.status != ItemStatus.ditemukan;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ItemThumb(photo: v.item.photoPath, category: cat),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '$returned/$total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _label(si.status, l10n),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: bad ? scheme.error : scheme.primary,
                  ),
                ),
              ],
            ),
            if (si.note != null && si.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(si.note!, style: Theme.of(context).textTheme.bodySmall),
              ),
            if (unresolved) ...[
              const SizedBox(height: 4),
              Text(
                l10n.resolveHint(lostQty),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _resolve(v, ItemStatus.hilangPermanen, l10n),
                      child: Text(l10n.statusPermanentlyLost),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _resolve(v, ItemStatus.ditemukan, l10n),
                      child: Text(l10n.statusFound),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}