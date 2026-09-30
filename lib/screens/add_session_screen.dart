import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/data/wardrobe_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:provider/provider.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  late DateTime _dropOff;
  late DateTime _ready;
  bool _reminder = true;

  /// itemId -> qty yang dicuci (urutan sesuai pemilihan)
  final Map<int, int> _selected = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dropOff = DateTime(now.year, now.month, now.day);
    _ready = DateTime(now.year, now.month, now.day + 2, 17);
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDropOff() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dropOff,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _dropOff = d);
  }

  Future<void> _pickReady() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _ready,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_ready),
    );
    if (t == null || !mounted) return;
    setState(() => _ready = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  void _toggle(WardrobeEntry e) {
    setState(() {
      if (_selected.containsKey(e.item.id)) {
        _selected.remove(e.item.id);
      } else if (e.availableQty > 0) {
        _selected[e.item.id] = 1;
      }
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate() || _selected.isEmpty) return;
    if (_ready.isBefore(_dropOff)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.estimateBeforeDropOff)),
      );
      return;
    }
    final provider = context.read<SessionProvider>();
    final navigator = Navigator.of(context);
    String? orNull(String s) => s.trim().isEmpty ? null : s.trim();

    await provider.create(
      title: _title.text.trim(),
      placeName: _place.text.trim(),
      placeAddress: orNull(_address.text),
      placePhone: orNull(_phone.text),
      dropOffDate: _dropOff,
      estimatedReadyAt: _ready,
      reminderEnabled: _reminder,
      items: [
        for (final e in _selected.entries) SessionItemInput(e.key, e.value),
      ],
    );
    navigator.pop();
  }

  void _openPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final l10n = AppLocalizations.of(ctx)!;
          final items = ctx.watch<WardrobeProvider>().allItems;
          final cats = ctx.watch<CategoryProvider>().categories;
          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.addItems,
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: items.isEmpty
                        ? Center(child: Text(l10n.noWardrobeItems))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final e = items[i];
                              final cat = cats
                                  .where((c) => c.id == e.item.categoryId)
                                  .firstOrNull;
                              return _pickerCard(
                                e,
                                cat,
                                l10n,
                                () {
                                  _toggle(e);
                                  setSheet(() {});
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.done),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _thumb(String? photo, Category? cat, {double? size}) {
    final scheme = Theme.of(context).colorScheme;
    final file = PhotoStorage.file(photo);
    final w = size ?? double.infinity;
    final icon = Container(
      width: w,
      height: size ?? double.infinity,
      color: scheme.primaryContainer.withValues(alpha: 0.4),
      alignment: Alignment.center,
      child: HugeIcon(
        icon: iconFor(cat?.iconKey ?? ''),
        size: size == null ? 40 : size * 0.5,
        color: scheme.primary,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: file == null
          ? icon
          : Image.file(
              file,
              width: w,
              height: size ?? double.infinity,
              fit: BoxFit.cover,
              cacheWidth: 300,
              errorBuilder: (_, _, _) => icon,
            ),
    );
  }

  Widget _pickerCard(
    WardrobeEntry e,
    Category? cat,
    AppLocalizations l10n,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected.containsKey(e.item.id);
    final disabled = e.availableQty <= 0 && !selected;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: scheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Opacity(
          opacity: disabled ? 0.4 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _thumb(e.item.photoPath, cat),
                    if (selected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(Icons.check_circle, color: scheme.primary),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      l10n.available(e.availableQty),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemTile(WardrobeEntry e, Category? cat, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final id = e.item.id;
    final qty = _selected[id]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _thumb(e.item.photoPath, cat, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    l10n.maxQty(e.availableQty),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove),
              onPressed:
                  qty > 1 ? () => setState(() => _selected[id] = qty - 1) : null,
            ),
            Text('$qty', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add),
              onPressed: qty < e.availableQty
                  ? () => setState(() => _selected[id] = qty + 1)
                  : null,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => _selected.remove(id)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(icon),
        ),
        child: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wardrobe = context.watch<WardrobeProvider>().allItems;
    final cats = context.watch<CategoryProvider>().categories;
    final byId = {for (final e in wardrobe) e.item.id: e};
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final readyText =
        '${dateFmt.format(_ready)}, ${TimeOfDay.fromDateTime(_ready).format(context)}';

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSession)),
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
              validator: required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _place,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.placeName,
                border: const OutlineInputBorder(),
              ),
              validator: required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.placeAddress,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.placePhone,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _dateField(
              l10n.dropOffDate,
              dateFmt.format(_dropOff),
              Icons.calendar_today_outlined,
              _pickDropOff,
            ),
            const SizedBox(height: 16),
            _dateField(
              l10n.estimatedReady,
              readyText,
              Icons.schedule,
              _pickReady,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.reminder),
              subtitle: Text(l10n.reminderHint),
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
            const Divider(),
            Row(
              children: [
                Text(
                  l10n.sessionItems,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openPicker,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addItems),
                ),
              ],
            ),
            if (_selected.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text(l10n.noItemsSelected)),
              )
            else
              for (final id in _selected.keys)
                if (byId[id] != null)
                  _itemTile(
                    byId[id]!,
                    cats.where((c) => c.id == byId[id]!.item.categoryId).firstOrNull,
                    l10n,
                  ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _selected.isEmpty ? null : () => _save(l10n),
              child: Text(l10n.startSession),
            ),
          ],
        ),
      ),
    );
  }
}