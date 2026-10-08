import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:laundryan/data/enums.dart';
import 'package:laundryan/data/session_repository.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/screens/test_screen.dart';
import 'package:laundryan/utils/session_phase.dart';
import 'package:laundryan/widgets/pulse.dart';
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
    final dateTimeFmt = DateFormat.yMMMMEEEEd(locale).add_jm();
    final dateTimeFmtShort = DateFormat.MMMd(locale).add_jm();
    final hoursFromNow = _readyAt.difference(DateTime.now()).inHours;

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
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
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
                          color: scheme.onPrimaryContainer,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                        trackColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primaryContainer,
                        ),
                        thumbColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
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
            const SizedBox(height: 8),
            Text(l10n.items, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.itemsLocked,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
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
          ],
        ),
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
