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
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:laundryan/utils/time_format.dart';
import 'package:laundryan/widgets/confirm_dialog.dart';
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

  /// itemId -> qty to wash (in selection order)
  final Map<int, int> _selected = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dropOff = DateTime(now.year, now.month, now.day, now.hour, now.minute);
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

  bool get _dirty =>
      _selected.isNotEmpty ||
      [_title, _place, _address, _phone].any((c) => c.text.trim().isNotEmpty);

  Future<void> _onPop(bool didPop) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    if (_dirty && !await showDiscardChangesDialog(context)) return;
    navigator.pop();
  }

  Future<void> _pickDropOff() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dropOff,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker12h(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dropOff),
    );
    if (t == null || !mounted) return;
    setState(
      () => _dropOff = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
  }

  Future<void> _pickReady() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _ready,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker12h(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.estimateBeforeDropOff)));
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
                              return _pickerCard(e, cat, l10n, () {
                                _toggle(e);
                                setSheet(() {});
                              });
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
      color: scheme.surfaceContainerLowest,
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
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            color: scheme.onPrimary,
                            strokeWidth: 2.5,
                            size: 16,
                          ),
                        ),
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
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
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
    return SoftCardOutline(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(
                    alpha: scheme.brightness == Brightness.light ? 0.06 : 0.3,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMinusSign,
                    strokeWidth: 2,
                  ),
                  onPressed: qty > 1
                      ? () => setState(() => _selected[id] = qty - 1)
                      : null,
                ),
                Text('$qty', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPlusSign,
                    strokeWidth: 2,
                  ),
                  onPressed: qty < e.availableQty
                      ? () => setState(() => _selected[id] = qty + 1)
                      : null,
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedDelete01,
              strokeWidth: 2,
              size: 20,
            ),
            onPressed: () => setState(() => _selected.remove(id)),
          ),
        ],
      ),
    );
  }

  Widget _dateField(
    String label,
    String value,
    Widget? suffixIcon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(12);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c, width: w),
    );

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 20,
          ),
          filled: true,
          fillColor: scheme.primaryContainer.withValues(alpha: 0.4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: border(Colors.transparent),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(scheme.primary, 2),
          errorBorder: border(scheme.error),
          focusedErrorBorder: border(scheme.error, 2),
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
    String dateTimeText(DateTime dt) => with12hTime(dateFmt).format(dt);

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    final titleStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith();
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(didPop),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.addSession)),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text(l10n.sessionTitleLabel, style: titleStyle),
                  SizedBox(width: 4),
                  Text('*', style: TextStyle(color: scheme.error)),
                ],
              ),
              const SizedBox(height: 8),
              SoftTextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                validator: required,
              ),
              const SizedBox(height: 16),
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedWashingMachine,
                            color: scheme.onPrimaryContainer,
                            size: 20,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.laundromatInfo, style: titleStyle),
                            Text(
                              l10n.laundromatInfoSubtitle,
                              style: subtitleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(l10n.laundryServiceName, style: subtitleStyle),
                        SizedBox(width: 4),
                        Text('*', style: TextStyle(color: scheme.error)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SoftTextFieldOutline(
                      controller: _place,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedStore01,
                        size: 20,
                        strokeWidth: 2,
                      ),
                      validator: required,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.dropOffAddress, style: subtitleStyle),
                    const SizedBox(height: 8),
                    SoftTextFieldOutline(
                      controller: _address,
                      textCapitalization: TextCapitalization.sentences,
                      prefixIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        size: 20,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.contactPhone, style: subtitleStyle),
                    const SizedBox(height: 8),
                    SoftTextFieldOutline(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCall02,
                        size: 20,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTimeSchedule,
                            color: scheme.onPrimaryContainer,
                            size: 20,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.scheduleAndTiming, style: titleStyle),
                            Text(
                              l10n.scheduleAndTimingSubtitle,
                              style: subtitleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.dropOffDate, style: subtitleStyle),
                    const SizedBox(height: 8),
                    _dateField(
                      '',
                      dateTimeText(_dropOff),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDateTime,
                        size: 20,
                        strokeWidth: 2,
                      ),
                      _pickDropOff,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.estimatedReady, style: subtitleStyle),
                    const SizedBox(height: 8),
                    _dateField(
                      '',
                      dateTimeText(_ready),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedClock01,
                        size: 20,
                        strokeWidth: 2,
                      ),
                      _pickReady,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.reminder, style: titleStyle),
                      subtitle: Text(l10n.reminderHint, style: subtitleStyle),
                      value: _reminder,
                      onChanged: (v) => setState(() => _reminder = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTimeSchedule,
                            color: scheme.onPrimaryContainer,
                            size: 20,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.selectedItems, style: titleStyle),
                            Text(
                              l10n.totalItems(_selected.length),
                              style: subtitleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openPicker,
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedPlusSign,
                            size: 18,
                            strokeWidth: 2,
                          ),
                          label: Text(l10n.wardrobe),
                          style: TextButton.styleFrom(
                            backgroundColor: scheme.surfaceContainerHigh,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_selected.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.noItemsSelected,
                            style: subtitleStyle,
                          ),
                        ),
                      )
                    else
                      for (final id in _selected.keys)
                        if (byId[id] != null)
                          _itemTile(
                            byId[id]!,
                            cats
                                .where((c) => c.id == byId[id]!.item.categoryId)
                                .firstOrNull,
                            l10n,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftButton(
                label: l10n.startSession,
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                onPressed: _selected.isEmpty ? null : () => _save(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
