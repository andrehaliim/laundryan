import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/phone_utils.dart';
import 'package:laundryan/widgets/item_thumb.dart';
import 'package:laundryan/widgets/confirm_dialog.dart';
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

  static int _lostQty(SessionItem si) => si.quantity - (si.returnedQty ?? 0);

  static bool _unresolved(SessionItem si) =>
      si.status == ItemStatus.hilang || si.status == ItemStatus.tertukar;

  Future<void> _resolve(
    SessionItemView v,
    ItemStatus result,
    AppLocalizations l10n,
  ) async {
    final provider = context.read<SessionProvider>();

    if (result == ItemStatus.hilangPermanen) {
      final ok = await showConfirmDialog(
        context,
        title: l10n.permanentLostTitle,
        message: l10n.permanentLostMessage(_lostQty(v.sessionItem)),
        tone: ConfirmTone.danger,
      );
      if (!ok) return;
    }

    await provider.resolveLost(v.sessionItem.id, result);
    if (mounted) _reload();
  }

  Future<void> _chat(
    Session session,
    List<SessionItemView> list,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final pending = list
        .where((v) => _unresolved(v.sessionItem))
        .map((v) {
          final label = v.sessionItem.status == ItemStatus.tertukar
              ? l10n.statusSwapped
              : l10n.statusLost;
          return '- ${v.item.name} x${_lostQty(v.sessionItem)} ($label)';
        })
        .join('\n');
    final message = pending.isEmpty
        ? ''
        : l10n.waMessage(session.title, pending);
    final ok = await openWhatsApp(session.placePhone!, message);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.whatsappFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = context
        .watch<SessionProvider>()
        .history
        .where((e) => e.session.id == widget.sessionId)
        .firstOrNull
        ?.session;

    if (session == null) {
      return Scaffold(appBar: AppBar(title: Text(l10n.sessionDetail)));
    }

    final hasPhone =
        session.placePhone != null && session.placePhone!.trim().isNotEmpty;

    return FutureBuilder<List<SessionItemView>>(
      future: _items,
      builder: (context, snap) {
        final list = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.sessionDetail)),
          body: list == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(context, session, list),
                    const SizedBox(height: 20),
                    _sectionHeader(context, list),
                    const SizedBox(height: 12),
                    for (final v in list) ...[
                      _itemCard(context, v),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPhone && list != null) ...[
                  SoftButton(
                    label: l10n.chatWhatsapp,
                    icon: HugeIcons.strokeRoundedWhatsapp,
                    variant: SoftButtonVariant.secondary,
                    onPressed: () => _chat(session, list, l10n),
                    expanded: true,
                  ),
                  const SizedBox(height: 8),
                ],
                SoftButton(
                  label: l10n.backToHistory,
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onPressed: () => Navigator.of(context).pop(),
                  expanded: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context,
    Session session,
    List<SessionItemView> list,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFmt = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final yearFmt = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    final total = list.fold(0, (sum, v) => sum + v.sessionItem.quantity);
    final safe = list.fold(
      0,
      (sum, v) => sum + (v.sessionItem.returnedQty ?? 0),
    );
    final lost = total - safe;
    final pending = list
        .where((v) => _unresolved(v.sessionItem))
        .fold(0, (sum, v) => sum + _lostQty(v.sessionItem));
    final pendingItems = list.where((v) => _unresolved(v.sessionItem)).length;

    final (
      List<List<dynamic>> statusIcon,
      String statusLabel,
      Color statusBg,
      Color statusFg,
    ) = lost == 0
        ? (
            HugeIcons.strokeRoundedCheckmarkCircle02,
            l10n.statusAllSafe,
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          )
        : pending > 0
        ? (
            HugeIcons.strokeRoundedAlert02,
            l10n.itemsNeedAction(pendingItems),
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          )
        : (
            HugeIcons.strokeRoundedCheckmarkCircle02,
            l10n.statusResolved,
            scheme.primaryContainer,
            scheme.onPrimaryContainer,
          );

    final end = session.completedAt;
    final range = end == null
        ? yearFmt.format(session.dropOffDate)
        : '${dateFmt.format(session.dropOffDate)} – ${yearFmt.format(end)}';
    final place = [
      session.placeName,
      if (session.placeAddress != null && session.placeAddress!.isNotEmpty)
        session.placeAddress!,
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
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedWashingMachine,
                          strokeWidth: 2,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.orderArchive.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                icon: statusIcon,
                label: statusLabel,
                bg: statusBg,
                fg: statusFg,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  strokeWidth: 2,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    range,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.finishedLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _statTile(
                  context,
                  label: l10n.totalGarments,
                  value: total,
                  valueColor: scheme.onSurface,
                  footIcon: HugeIcons.strokeRoundedTickDouble02,
                  foot: l10n.safeOnPickup(safe),
                  footColor: scheme.inversePrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statTile(
                  context,
                  label: l10n.discrepancyLog,
                  value: lost,
                  valueColor: lost > 0 ? scheme.secondary : scheme.onSurface,
                  footIcon: lost == 0
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : pending > 0
                      ? HugeIcons.strokeRoundedAlert02
                      : HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                  foot: lost == 0
                      ? l10n.noDiscrepancy
                      : pending > 0
                      ? l10n.pendingBadge(pending)
                      : l10n.discrepancyResolved(lost),
                  footColor: lost == 0
                      ? scheme.onSurfaceVariant
                      : scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    BuildContext context, {
    required String label,
    required int value,
    required Color valueColor,
    required List<List<dynamic>> footIcon,
    required String foot,
    required Color footColor,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.piecesUnit,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              HugeIcon(
                icon: footIcon,
                strokeWidth: 2,
                size: 13,
                color: footColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  foot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: footColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, List<SessionItemView> list) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pieces = list.fold(0, (sum, v) => sum + v.sessionItem.quantity);

    return Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedPackage,
          strokeWidth: 2,
          size: 20,
          color: scheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.inventoryAndStatus,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        CountBadge(
          label: l10n.itemsSummary(list.length, pieces),
          mode: CountBadgeMode.normal,
          horizontalPadding: 10,
        ),
      ],
    );
  }

  Widget _itemCard(BuildContext context, SessionItemView v) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = context.watch<CategoryProvider>().categories;
    final cat = cats.where((c) => c.id == v.item.categoryId).firstOrNull;
    final si = v.sessionItem;
    final lostQty = _lostQty(si);
    final unresolved = _unresolved(si);
    final note = si.note?.trim();

    final (
      List<List<dynamic>> icon,
      String label,
      Color bg,
      Color fg,
      Color thumbBg,
    ) = switch (si.status) {
      ItemStatus.tertukar => (
        HugeIcons.strokeRoundedArrowDataTransferHorizontal,
        l10n.swappedBadge(si.returnedQty ?? 0, si.quantity, lostQty),
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
      ),
      ItemStatus.hilang => (
        HugeIcons.strokeRoundedAlert02,
        l10n.lostBadge(si.returnedQty ?? 0, si.quantity, lostQty),
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
      ),
      ItemStatus.ditemukan => (
        HugeIcons.strokeRoundedCheckmarkBadge01,
        l10n.statusFound,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        scheme.primaryContainer,
      ),
      ItemStatus.hilangPermanen => (
        HugeIcons.strokeRoundedCancelCircle,
        l10n.statusPermanentlyLost,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        scheme.surfaceContainerHigh,
      ),
      ItemStatus.kembali || ItemStatus.dibawa => (
        HugeIcons.strokeRoundedTick02,
        l10n.statusReturned,
        scheme.tertiaryContainer.withValues(alpha: 0.5),
        scheme.onTertiaryContainer,
        scheme.surfaceContainer,
      ),
    };

    final (List<List<dynamic>>, String, Color)? info = switch (si.status) {
      ItemStatus.hilang || ItemStatus.tertukar => (
        HugeIcons.strokeRoundedAlert02,
        note == null || note.isEmpty
            ? l10n.resolveHint(lostQty)
            : '$note\n${l10n.resolveHint(lostQty)}',
        scheme.secondary,
      ),
      ItemStatus.ditemukan => (
        HugeIcons.strokeRoundedPackageReceive,
        note == null || note.isEmpty ? l10n.foundNote : note,
        scheme.tertiary,
      ),
      ItemStatus.hilangPermanen => (
        HugeIcons.strokeRoundedPackageRemove,
        note == null || note.isEmpty ? l10n.permanentLostNote(lostQty) : note,
        scheme.onSurfaceVariant,
      ),
      _ when note != null && note.isNotEmpty => (
        HugeIcons.strokeRoundedNote,
        note,
        scheme.onSurfaceVariant,
      ),
      _ => null,
    };

    final subtitle = [
      if (cat != null) categoryName(cat, l10n),
      l10n.pieces(si.quantity),
    ].join(' • ');

    return SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ItemThumb(
                photo: v.item.photoPath,
                category: cat,
                size: 40,
                background: thumbBg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Pill(icon: icon, label: label, bg: bg, fg: fg),
            ],
          ),
          if (info != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: info.$1,
                    strokeWidth: 2,
                    size: 18,
                    color: info.$3,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      info.$2,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (unresolved) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    icon: HugeIcons.strokeRoundedTick02,
                    label: l10n.markFound,
                    bg: scheme.tertiaryContainer,
                    fg: scheme.onTertiaryContainer,
                    onPressed: () => _resolve(v, ItemStatus.ditemukan, l10n),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    context,
                    icon: HugeIcons.strokeRoundedCancel01,
                    label: l10n.statusPermanentlyLost,
                    bg: scheme.surfaceContainer,
                    fg: scheme.onSurface,
                    onPressed: () =>
                        _resolve(v, ItemStatus.hilangPermanen, l10n),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: HugeIcon(icon: icon, strokeWidth: 2, size: 18, color: fg),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color bg;
  final Color fg;
  const _Pill({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
