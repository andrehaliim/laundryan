import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/phone_utils.dart';
import 'package:laundryan/widgets/item_thumb.dart';

class SummaryLine {
  final String name;
  final String? photo;
  final Category? category;
  final int total;
  final int returned;
  final ItemStatus status;
  const SummaryLine({
    required this.name,
    required this.photo,
    required this.category,
    required this.total,
    required this.returned,
    required this.status,
  });

  int get lostQty => total - returned;
}

class ChecklistSummaryScreen extends StatelessWidget {
  final String placeName;
  final DateTime? dropOffAt;
  final String? phone;
  final List<SummaryLine> lines;
  const ChecklistSummaryScreen({
    super.key,
    required this.placeName,
    required this.dropOffAt,
    required this.phone,
    required this.lines,
  });

  List<SummaryLine> get _lost => lines.where((e) => e.lostQty > 0).toList();

  String _label(ItemStatus s, AppLocalizations l10n) =>
      s == ItemStatus.tertukar ? l10n.statusSwapped : l10n.statusLost;

  Future<void> _chat(BuildContext context, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final items = _lost
        .map((e) => '- ${e.name} x${e.lostQty} (${_label(e.status, l10n)})')
        .join('\n');
    final date = dropOffAt == null
        ? ''
        : DateFormat.yMMMMd(
            Localizations.localeOf(context).toString(),
          ).format(dropOffAt!);
    final ok = await openWhatsApp(phone!, l10n.waMessage(date, items));
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.whatsappFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPhone = phone != null && phone!.trim().isNotEmpty;
    final contact = _lost.isNotEmpty && hasPhone;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionFinished)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(context),
          if (lines.isNotEmpty) ...[
            const SizedBox(height: 16),
            _itemsCard(context),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact) ...[
              SoftButton(
                label: l10n.chatWhatsapp,
                icon: HugeIcons.strokeRoundedWhatsapp,
                onPressed: () => _chat(context, l10n),
                expanded: true,
              ),
              const SizedBox(height: 8),
            ],
            SoftButton(
              label: l10n.done,
              icon: HugeIcons.strokeRoundedTShirt,
              variant: contact
                  ? SoftButtonVariant.secondary
                  : SoftButtonVariant.primary,
              onPressed: () => Navigator.of(context).pop(),
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final allBack = _lost.isEmpty;
    final total = lines.fold(0, (sum, e) => sum + e.total);
    final returned = lines.fold(0, (sum, e) => sum + e.returned);
    final badge = allBack ? scheme.tertiary : scheme.secondary;

    Widget glow(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
        ),
      ),
    );

    Widget ring(double size, double alpha, Widget child) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badge.withValues(alpha: alpha),
      ),
      child: child,
    );

    return SoftCard(
      child: Stack(
        children: [
          Positioned(top: -48, right: -48, child: glow(scheme.tertiary, 180)),
          Positioned(bottom: -40, left: -40, child: glow(scheme.primary, 160)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ring(
                  96,
                  0.15,
                  ring(
                    80,
                    0.3,
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badge,
                        boxShadow: [
                          BoxShadow(
                            color: badge.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: HugeIcon(
                        icon: allBack
                            ? HugeIcons.strokeRoundedCheckmarkBadge01
                            : HugeIcons.strokeRoundedAlert02,
                        strokeWidth: 2,
                        size: 30,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  allBack ? l10n.allReturned : l10n.someItemsMissing,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allBack ? l10n.allReturnedBody : l10n.missingBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      label: l10n.piecesVerified(returned, total),
                      bg: scheme.tertiaryContainer,
                      fg: scheme.onTertiaryContainer,
                    ),
                    _Pill(
                      icon: HugeIcons.strokeRoundedAlertDiamond,
                      label: l10n.discrepancyCount(total - returned),
                      bg: allBack
                          ? scheme.primaryContainer
                          : scheme.secondaryContainer,
                      fg: allBack
                          ? scheme.onPrimaryContainer
                          : scheme.onSecondaryContainer,
                    ),
                    if (placeName.isNotEmpty)
                      _Pill(
                        icon: HugeIcons.strokeRoundedWashingMachine,
                        label: placeName,
                        bg: scheme.surfaceContainerHigh,
                        fg: scheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = lines.fold(0, (sum, e) => sum + e.total);
    final returned = lines.fold(0, (sum, e) => sum + e.returned);

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckList,
                  strokeWidth: 2,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.verifiedItems,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.itemsSummary(lines.length, total).toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final e in lines) ...[
            _itemRow(context, e),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  strokeWidth: 2,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.wardrobeUpdated,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.wardrobeUpdatedBody(returned),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, SummaryLine e) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surface;
    final cat = e.category;

    final (
      List<List<dynamic>> icon,
      String label,
      Color bg,
      Color fg,
    ) = e.lostQty == 0
        ? (
            HugeIcons.strokeRoundedTick02,
            l10n.returnedBadge(e.returned, e.total),
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          )
        : e.status == ItemStatus.tertukar
        ? (
            HugeIcons.strokeRoundedArrowDataTransferHorizontal,
            l10n.swappedBadge(e.returned, e.total, e.lostQty),
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          )
        : (
            HugeIcons.strokeRoundedAlert02,
            l10n.lostBadge(e.returned, e.total, e.lostQty),
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: e.lostQty > 0
            ? scheme.secondaryContainer.withValues(alpha: 0.35)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ItemThumb(
              photo: e.photo,
              category: cat,
              size: 36,
              background: cardColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cat != null)
                  Text(
                    categoryName(cat, l10n),
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
          Flexible(
            child: _Pill(icon: icon, label: label, bg: bg, fg: fg),
          ),
        ],
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
