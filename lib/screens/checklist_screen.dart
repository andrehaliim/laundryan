import 'package:flutter/material.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/checklist_summary_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/widgets/item_thumb.dart';
import 'package:provider/provider.dart';

class _Draft {
  bool checked = false;
  int returned;
  ItemStatus lostStatus = ItemStatus.hilang;
  String note = '';
  _Draft(this.returned);
}

class ChecklistScreen extends StatefulWidget {
  final int sessionId;
  const ChecklistScreen({super.key, required this.sessionId});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<SessionItemView>? _items;
  final Map<int, _Draft> _drafts = {};
  String _title = '';
  String? _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<SessionProvider>();
    final s = provider.active
        .where((e) => e.session.id == widget.sessionId)
        .firstOrNull
        ?.session;
    _title = s?.title ?? '';
    _phone = s?.placePhone;
    final list = await provider.items(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _items = list;
      for (final v in list) {
        _drafts[v.sessionItem.id] = _Draft(v.sessionItem.quantity);
      }
    });
  }

  bool get _allChecked =>
      _drafts.isNotEmpty && _drafts.values.every((d) => d.checked);

  void _openDetail(SessionItemView v, _Draft d) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DetailSheet(
        view: v,
        draft: d,
        onChanged: () => setState(() {}),
      ),
    );
  }

  Future<void> _finish() async {
    final items = _items;
    if (items == null) return;
    final provider = context.read<SessionProvider>();
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final results = <ItemVerification>[];
    final lost = <LostLine>[];
    for (final v in items) {
      final d = _drafts[v.sessionItem.id]!;
      final lostQty = v.sessionItem.quantity - d.returned;
      final status = lostQty == 0 ? ItemStatus.kembali : d.lostStatus;
      final note = d.note.trim();
      results.add(ItemVerification(
        v.sessionItem.id,
        d.returned,
        status,
        lostQty > 0 && note.isNotEmpty ? note : null,
      ));
      if (lostQty > 0) lost.add(LostLine(v.item.name, lostQty, status));
    }

    await provider.complete(widget.sessionId, results);
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChecklistSummaryScreen(
          title: _title,
          phone: _phone,
          lost: lost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cats = context.watch<CategoryProvider>().categories;
    final items = _items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyItems)),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final v in items)
                  _buildCard(v, cats, l10n, scheme),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_allChecked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.checkAllHint,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _allChecked && !_saving ? _finish : null,
                  child: Text(l10n.finish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    SessionItemView v,
    List cats,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final d = _drafts[v.sessionItem.id]!;
    final total = v.sessionItem.quantity;
    final lostQty = total - d.returned;
    final cat = cats.where((c) => c.id == v.item.categoryId).firstOrNull;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: d.checked,
              onChanged: (x) => setState(() => d.checked = x ?? false),
            ),
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
                    lostQty > 0
                        ? l10n.missingCount(lostQty)
                        : '${d.returned}/$total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: lostQty > 0
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => _openDetail(v, d),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final SessionItemView view;
  final _Draft draft;
  final VoidCallback onChanged;
  const _DetailSheet({
    required this.view,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: widget.draft.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _setReturned(int v) {
    setState(() => widget.draft.returned = v);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final cats = context.watch<CategoryProvider>().categories;
    final v = widget.view;
    final d = widget.draft;
    final total = v.sessionItem.quantity;
    final lostQty = total - d.returned;
    final cat = cats.where((c) => c.id == v.item.categoryId).firstOrNull;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ItemThumb(photo: v.item.photoPath, category: cat, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.item.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (cat != null)
                      Text(
                        categoryName(cat, l10n),
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    if (v.item.note != null && v.item.note!.isNotEmpty)
                      Text(
                        v.item.note!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(l10n.returnedQty,
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              IconButton.filledTonal(
                icon: const Icon(Icons.remove),
                onPressed:
                    d.returned > 0 ? () => _setReturned(d.returned - 1) : null,
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '${d.returned} ${l10n.ofTotal(total)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed:
                    d.returned < total ? () => _setReturned(d.returned + 1) : null,
              ),
            ],
          ),
          if (lostQty > 0) ...[
            const SizedBox(height: 16),
            Text(
              '${l10n.missingStatus} ($lostQty)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ItemStatus>(
              segments: [
                ButtonSegment(
                    value: ItemStatus.hilang, label: Text(l10n.statusLost)),
                ButtonSegment(
                    value: ItemStatus.tertukar, label: Text(l10n.statusSwapped)),
              ],
              selected: {d.lostStatus},
              onSelectionChanged: (s) {
                setState(() => d.lostStatus = s.first);
                widget.onChanged();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (t) => d.note = t,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}