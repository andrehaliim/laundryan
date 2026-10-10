import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/checklist_summary_screen.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/time_format.dart';
import 'package:laundryan/widgets/confirm_dialog.dart';
import 'package:laundryan/widgets/item_thumb.dart';
import 'package:laundryan/widgets/skeleton.dart';
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
  String _placeName = '';
  DateTime? _dropOffAt;
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
    _placeName = s?.placeName ?? '';
    _dropOffAt = s?.dropOffDate;
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
      builder: (_) =>
          _DetailSheet(view: v, draft: d, onChanged: () => setState(() {})),
    );
  }

  Future<void> _finish() async {
    final items = _items;
    if (items == null) return;
    final provider = context.read<SessionProvider>();
    final cats = context.read<CategoryProvider>().allCategories;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showConfirmDialog(
      context,
      title: l10n.finishVerificationTitle,
      message: l10n.finishVerificationMessage,
      confirmLabel: l10n.finishVerification,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    );
    if (!confirm || !mounted) return;
    setState(() => _saving = true);

    final results = <ItemVerification>[];
    final lines = <SummaryLine>[];
    for (final v in items) {
      final d = _drafts[v.sessionItem.id]!;
      final lostQty = v.sessionItem.quantity - d.returned;
      final status = lostQty == 0 ? ItemStatus.kembali : d.lostStatus;
      final note = d.note.trim();
      results.add(
        ItemVerification(
          v.sessionItem.id,
          d.returned,
          status,
          lostQty > 0 && note.isNotEmpty ? note : null,
        ),
      );
      lines.add(
        SummaryLine(
          name: v.item.name,
          photo: v.item.photoPath,
          category: cats.where((c) => c.id == v.item.categoryId).firstOrNull,
          total: v.sessionItem.quantity,
          returned: d.returned,
          status: status,
        ),
      );
    }

    try {
      await provider.complete(widget.sessionId, results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            ChecklistSummaryScreen(title: _title, phone: _phone, lines: lines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final cats = context.watch<CategoryProvider>().allCategories;
    final items = _items;
    final pending = _drafts.values.where((d) => !d.checked).length;

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.verifyReturnedTitle)),
        body: items == null
            ? const SessionDetailSkeleton()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _progressCard(context, items),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.dropOffChecklist(items.length),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          l10n.tapToInspect,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final v in items) ...[
                    _itemCard(
                      context,
                      v,
                      cats.where((c) => c.id == v.item.categoryId).firstOrNull,
                    ),
                    if (v != items.last) const SizedBox(height: 8),
                  ],
                ],
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? scheme.surface,
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _allChecked
                              ? l10n.verificationReady
                              : l10n.verificationInProgress,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (pending > 0)
                        Text(
                          l10n.itemsNeedAction(pending).toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                    ],
                  ),
                ),
                SoftButton(
                  label: l10n.finishVerification,
                  icon: HugeIcons.strokeRoundedTaskDone01,
                  onPressed: _allChecked && !_saving ? _finish : null,
                  expanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressCard(BuildContext context, List<SessionItemView> items) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    var total = 0, returned = 0, missing = 0, checkedPieces = 0;
    for (final v in items) {
      final d = _drafts[v.sessionItem.id]!;
      final qty = v.sessionItem.quantity;
      total += qty;
      if (!d.checked) continue;
      checkedPieces += qty;
      returned += d.returned;
      missing += qty - d.returned;
    }
    final percent = total == 0 ? 0 : (checkedPieces * 100 / total).round();
    final subtitle = [
      if (_placeName.isNotEmpty) _placeName,
      if (_dropOffAt != null)
        with12hTime(DateFormat.MMMd(locale)).format(_dropOffAt!),
    ].join(' • ');

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedPackage,
                  strokeWidth: 2,
                  size: 22,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.piecesVerified(returned, total),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.percentDone(percent),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ProgressBar(
            total: total,
            segments: [
              (returned, scheme.tertiary),
              (missing, scheme.secondary),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckList,
                  strokeWidth: 2,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.verifyInstruction,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, SessionItemView v, Category? cat) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final d = _drafts[v.sessionItem.id]!;
    final total = v.sessionItem.quantity;
    final lostQty = total - d.returned;
    final discrepancy = d.checked && lostQty > 0;

    final (
      List<List<dynamic>> badgeIcon,
      String badgeLabel,
      Color badgeBg,
      Color badgeFg,
    ) = !d.checked
        ? (
            HugeIcons.strokeRoundedClock01,
            l10n.pendingBadge(total),
            scheme.surfaceContainerHighest,
            scheme.onSurfaceVariant,
          )
        : lostQty == 0
        ? (
            HugeIcons.strokeRoundedTick02,
            l10n.returnedBadge(d.returned, total),
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          )
        : d.lostStatus == ItemStatus.tertukar
        ? (
            HugeIcons.strokeRoundedArrowDataTransferHorizontal,
            l10n.swappedBadge(d.returned, total, lostQty),
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          )
        : (
            HugeIcons.strokeRoundedAlert02,
            l10n.lostBadge(d.returned, total, lostQty),
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          );

    final (
      List<List<dynamic>> toggleIcon,
      Color toggleBg,
      Color toggleFg,
    ) = !d.checked
        ? (
            HugeIcons.strokeRoundedSquare,
            scheme.surfaceContainer,
            scheme.onSurfaceVariant,
          )
        : lostQty == 0
        ? (
            HugeIcons.strokeRoundedTick02,
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          )
        : (
            HugeIcons.strokeRoundedAlertCircle,
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          );

    return SoftCard(
      onTap: () => _openDetail(v, d),
      padding: const EdgeInsets.all(12),
      child: Column(
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
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (cat != null)
                      Text(
                        categoryName(cat, l10n),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    _StatusPill(
                      icon: badgeIcon,
                      label: badgeLabel,
                      bg: badgeBg,
                      fg: badgeFg,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: toggleBg,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => d.checked = !d.checked),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: HugeIcon(
                        icon: toggleIcon,
                        strokeWidth: 2,
                        size: 20,
                        color: toggleFg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (discrepancy) ...[
            const SizedBox(height: 8),
            Material(
              color: scheme.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openDetail(v, d),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAlertDiamond,
                        strokeWidth: 2,
                        size: 16,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.reportDiscrepancy,
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color bg;
  final Color fg;
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, strokeWidth: 2, size: 13, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int total;
  final List<(int, Color)> segments;
  const _ProgressBar({required this.total, required this.segments});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const gap = 4.0;
    final visible = segments.where((s) => s.$1 > 0).toList();
    return Container(
      height: 12,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (_, c) {
          final gaps = visible.isEmpty ? 0 : visible.length - 1;
          final width = c.maxWidth - gap * gaps;
          return Row(
            children: [
              for (final (i, s) in visible.indexed) ...[
                if (i > 0) const SizedBox(width: gap),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: total == 0 ? 0 : width * s.$1 / total,
                  decoration: BoxDecoration(
                    color: s.$2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ],
          );
        },
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
  late int _returned = widget.draft.returned;
  late ItemStatus _lostStatus = widget.draft.lostStatus;
  late final TextEditingController _note = TextEditingController(
    text: widget.draft.note,
  );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _confirm() {
    widget.draft
      ..returned = _returned
      ..lostStatus = _lostStatus
      ..note = _note.text
      ..checked = true;
    widget.onChanged();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = context.watch<CategoryProvider>().allCategories;
    final v = widget.view;
    final total = v.sessionItem.quantity;
    final lostQty = total - _returned;
    final missing = lostQty > 0;
    final cat = cats.where((c) => c.id == v.item.categoryId).firstOrNull;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final subtitle = [
      v.item.name,
      if (cat != null) categoryName(cat, l10n),
    ].join(' • ');

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: missing
                                  ? scheme.secondary
                                  : scheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (missing ? l10n.reconcileCase : l10n.inspectCase)
                                .toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: missing
                                  ? scheme.onSecondaryContainer
                                  : scheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        l10n.reconcileItem,
                        style: textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: scheme.surfaceContainer,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          strokeWidth: 2,
                          size: 18,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ItemThumb(
                    photo: v.item.photoPath,
                    category: cat,
                    size: 40,
                    background: scheme.surface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.expectedDropOff.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          l10n.piecesDroppedOff(total),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Stepper(
                    value: _returned,
                    onDecrement: _returned > 0
                        ? () => setState(() => _returned--)
                        : null,
                    onIncrement: _returned < total
                        ? () => setState(() => _returned++)
                        : null,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: !missing
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          '${l10n.discrepancyType} ($lostQty)',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _Segmented(
                          value: _lostStatus,
                          onChanged: (s) => setState(() => _lostStatus = s),
                          options: [
                            (
                              ItemStatus.hilang,
                              HugeIcons.strokeRoundedCancelCircle,
                              l10n.statusLost,
                            ),
                            (
                              ItemStatus.tertukar,
                              HugeIcons
                                  .strokeRoundedArrowDataTransferHorizontal,
                              l10n.statusSwapped,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.describeIssue,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SoftTextFieldOutline(
                          controller: _note,
                          hint: l10n.describeIssueHint,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: l10n.cancel,
                    bg: scheme.surfaceContainer,
                    fg: scheme.onSurface,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SheetButton(
                    label: missing ? l10n.confirmAlert : l10n.confirmReturned,
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    bg: missing
                        ? scheme.secondaryContainer
                        : scheme.tertiaryContainer,
                    fg: missing
                        ? scheme.onSecondaryContainer
                        : scheme.onTertiaryContainer,
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  const _Stepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget button(List<List<dynamic>> icon, VoidCallback? onTap) => Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: HugeIcon(
              icon: icon,
              strokeWidth: 2,
              size: 16,
              color: onTap == null
                  ? scheme.onSurface.withValues(alpha: 0.3)
                  : scheme.onSurface,
            ),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(HugeIcons.strokeRoundedMinusSign, onDecrement),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          button(HugeIcons.strokeRoundedPlusSign, onIncrement),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final ItemStatus value;
  final ValueChanged<ItemStatus> onChanged;
  final List<(ItemStatus, List<List<dynamic>>, String)> options;
  const _Segmented({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surface;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (i, (status, icon, label)) in options.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: status == value ? cardColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: status == value
                        ? [
                            BoxShadow(
                              color: scheme.shadow.withValues(alpha: 0.06),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: icon,
                        strokeWidth: 2,
                        size: 16,
                        color: status == value
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: textTheme.labelLarge?.copyWith(
                          color: status == value
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight: status == value
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final List<List<dynamic>>? icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _SheetButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                HugeIcon(icon: icon!, strokeWidth: 2, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: fg, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
