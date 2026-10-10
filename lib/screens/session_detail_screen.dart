import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/category_provider.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/checklist_screen.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:laundryan/utils/category_utils.dart';
import 'package:laundryan/utils/phone_utils.dart';
import 'package:laundryan/utils/session_phase.dart';
import 'package:laundryan/utils/time_format.dart';
import 'package:laundryan/widgets/item_thumb.dart';
import 'package:laundryan/widgets/pulse.dart';
import 'package:laundryan/widgets/confirm_dialog.dart';
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
  late String _savedTitle;
  bool _editingTitle = false;
  late bool _reminder;
  late DateTime _readyAt;
  late DateTime _dropOffAt;
  late DateTime? _completedAt;
  late final Future<List<SessionItemView>> _items;
  late final SessionPhase _phase;
  late final String? _phone;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SessionProvider>();
    final s = provider.active
        .firstWhere((e) => e.session.id == widget.sessionId)
        .session;
    _title = TextEditingController(text: s.title);
    _savedTitle = s.title;
    _reminder = s.reminderEnabled;
    _readyAt = s.estimatedReadyAt;
    _dropOffAt = s.dropOffDate;
    _completedAt = s.completedAt;
    _phase = s.phase;
    final phone = s.placePhone?.trim();
    _phone = (phone == null || phone.isEmpty) ? null : phone;
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
    final time = await showTimePicker12h(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_readyAt),
    );
    if (time == null) return;
    setState(() {
      _readyAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    await _save();
  }

  Future<void> _toggleEditTitle() async {
    if (!_editingTitle) {
      setState(() => _editingTitle = true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _editingTitle = false;
      _savedTitle = _title.text.trim();
    });
    await _save();
  }

  Future<void> _save() {
    return context.read<SessionProvider>().update(
      widget.sessionId,
      title: _savedTitle,
      reminderEnabled: _reminder,
      estimatedReadyAt: _readyAt,
    );
  }

  Future<void> _cancelSession(AppLocalizations l10n) async {
    final provider = context.read<SessionProvider>();
    final navigator = Navigator.of(context);
    final confirm = await showConfirmDialog(
      context,
      title: l10n.cancelSessionTitle,
      message: l10n.cancelSessionMessage,
      confirmLabel: l10n.cancelSession,
      cancelLabel: l10n.keepSession,
      icon: HugeIcons.strokeRoundedCancelCircle,
      tone: ConfirmTone.danger,
    );
    if (!confirm) return;
    await provider.cancel(widget.sessionId);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateTimeFmt = with12hTime(DateFormat.yMMMMEEEEd(locale));
    final dateTimeFmtShort = with12hTime(DateFormat.MMMd(locale));
    final hoursFromNow = _readyAt.difference(DateTime.now()).inHours;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetail),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancelCircle,
              strokeWidth: 2,
            ),
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
            SoftCard(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _editingTitle
                            ? TextFormField(
                                controller: _title,
                                autofocus: true,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: Theme.of(context).textTheme.titleLarge,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                ),
                                onFieldSubmitted: (_) => _toggleEditTitle(),
                                maxLines: 1,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? l10n.nameRequired
                                    : null,
                              )
                            : Text(
                                _title.text,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _toggleEditTitle,
                        child: HugeIcon(
                          icon: _editingTitle
                              ? HugeIcons.strokeRoundedTick02
                              : HugeIcons.strokeRoundedEdit02,
                          strokeWidth: 2,
                          size: 20,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftCardOutline(
                    padding: EdgeInsetsGeometry.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              strokeWidth: 2,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.estimatedReady.toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () => _pickReadyAt(),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedEdit02,
                                strokeWidth: 2,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateTimeFmt.format(_readyAt),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.estHoursFromNow(hoursFromNow),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        strokeWidth: 2,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.notificationReminder,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              l10n.notificationReminderHint,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _reminder,
                        onChanged: (v) {
                          setState(() => _reminder = v);
                          _save();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _statusIndicator(
                    context: context,
                    title: phaseLabelLong(SessionPhase.dropped, l10n),
                    subTitleText: dateTimeFmtShort.format(_dropOffAt),
                    icon: HugeIcons.strokeRoundedPackageMoving,
                    status: SessionPhase.dropped,
                    current: _phase,
                  ),
                  _statusIndicator(
                    context: context,
                    title: phaseLabelLong(SessionPhase.washing, l10n),
                    subTitleText: dateTimeFmtShort.format(
                      _dropOffAt.add(const Duration(minutes: 10)),
                    ),
                    icon: HugeIcons.strokeRoundedWashingMachine,
                    status: SessionPhase.washing,
                    current: _phase,
                  ),
                  _statusIndicator(
                    context: context,
                    title: phaseLabelLong(SessionPhase.pickup, l10n),
                    subTitleText: dateTimeFmtShort.format(_readyAt),
                    icon: HugeIcons.strokeRoundedShoppingBag02,
                    status: SessionPhase.pickup,
                    current: _phase,
                  ),
                  _statusIndicator(
                    context: context,
                    title: phaseLabelLong(SessionPhase.verified, l10n),
                    subTitleText: _completedAt != null
                        ? dateTimeFmtShort.format(_completedAt!)
                        : l10n.notCompletedYet,
                    icon: HugeIcons.strokeRoundedTaskDone01,
                    status: SessionPhase.verified,
                    current: _phase,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_phone != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _contactButton(
                      context: context,
                      icon: HugeIcons.strokeRoundedWhatsapp,
                      title: 'WhatsApp',
                      subtitle: l10n.whatsappSubtitle,
                      bg: scheme.tertiaryContainer,
                      fg: scheme.onTertiaryContainer,
                      onTap: () => _openWhatsApp(l10n),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _contactButton(
                      context: context,
                      icon: HugeIcons.strokeRoundedCall02,
                      title: l10n.callPlace,
                      subtitle: l10n.callSubtitle,
                      bg: scheme.surfaceContainerHigh,
                      fg: scheme.onSurface,
                      onTap: () => _call(l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            FutureBuilder<List<SessionItemView>>(
              future: _items,
              builder: (_, snap) {
                final list = snap.data ?? const <SessionItemView>[];
                return _itemsCard(context, list);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SoftButton(
          label: l10n.verify,
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChecklistScreen(sessionId: widget.sessionId),
            ),
          ),
          expanded: true,
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await openWhatsApp(_phone!, '');
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.whatsappFailed)));
    }
  }

  Future<void> _call(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await callPhone(_phone!);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.callFailed)));
    }
  }

  Widget _contactButton({
    required BuildContext context,
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            alignment: Alignment.center,
            child: HugeIcon(icon: icon, color: fg, size: 18, strokeWidth: 2),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }

  Widget _itemsCard(BuildContext context, List<SessionItemView> list) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = context.watch<CategoryProvider>().allCategories;
    final pieces = list.fold<int>(0, (sum, v) => sum + v.sessionItem.quantity);

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedPackage,
                strokeWidth: 2,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.items,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              CountBadge(
                label: l10n.itemsSummary(list.length, pieces),
                horizontalPadding: 10,
                mode: CountBadgeMode.normal,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.itemsLocked,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (final v in list) ...[
            _itemRow(
              context,
              v,
              cats.where((c) => c.id == v.item.categoryId).firstOrNull,
            ),
            if (v != list.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, SessionItemView v, Category? cat) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surface;
    final shadow = [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.06),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];

    return SoftCardOutline(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ItemThumb(
            photo: v.item.photoPath,
            category: cat,
            size: 40,
            background: scheme.surface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.item.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cat != null)
                  Text(
                    categoryName(cat, l10n),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: shadow,
            ),
            child: Text(
              l10n.pieces(v.sessionItem.quantity),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIndicator({
    required BuildContext context,
    required String title,
    required String subTitleText,
    required List<List<dynamic>> icon,
    required SessionPhase status,
    required SessionPhase current,
    bool isLast = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isCurrent = current == status;
    final reached = current.index >= status.index;

    final bg = isCurrent
        ? scheme.primary
        : reached
        ? scheme.tertiary
        : scheme.surfaceContainerHighest;
    final fg = isCurrent
        ? scheme.onPrimary
        : reached
        ? scheme.onTertiary
        : scheme.outline;

    final badgeLabel = isCurrent
        ? l10n.phaseCurrent
        : reached
        ? l10n.done
        : '';

    final badgeType = isCurrent
        ? CountBadgeMode.primary
        : reached
        ? CountBadgeMode.tertiary
        : CountBadgeMode.normal;

    final titleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: reached ? scheme.onSurface : scheme.onSurfaceVariant,
      fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
    );

    final subStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    return Column(
      children: [
        Row(
          children: [
            Pulse(
              active: isCurrent && status != SessionPhase.verified,
              color: bg,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                child: HugeIcon(icon: icon, color: fg, size: 18),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: titleStyle),

                    const SizedBox(width: 8),
                    CountBadge(
                      label: badgeLabel,
                      horizontalPadding: !reached ? 0 : 10,
                      mode: badgeType,
                    ),
                  ],
                ),
                Text(subTitleText, style: subStyle),
              ],
            ),
          ],
        ),
        if (!isLast)
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 30,
              child: Center(
                child: Container(
                  width: 2,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: current.index > status.index
                        ? scheme.tertiary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
