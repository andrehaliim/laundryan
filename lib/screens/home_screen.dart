import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/session_provider.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/providers/wardrobe_provider.dart';
import 'package:laundryan/screens/sessions_screen.dart';
import 'package:laundryan/screens/wardrobe_screen.dart';
import 'package:laundryan/utils/app_tour.dart';
import 'package:laundryan/widgets/tour_step.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final ShowcaseView _showcase;
  late final SettingsProvider _settings;
  late final SessionProvider _sessions;
  late final WardrobeProvider _wardrobe;

  /// Id of the tour currently on screen (or about to start), if any.
  String? _runningTour;
  bool _tourScheduled = false;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsProvider>();
    _sessions = context.read<SessionProvider>()..addListener(_scheduleTour);
    _wardrobe = context.read<WardrobeProvider>()..addListener(_scheduleTour);
    _showcase = ShowcaseView.register(
      scope: AppTour.homeScope,
      disableBarrierInteraction: true,
      skipIfTargetNotPresent: true,
      enableAutoScroll: true,
      onFinish: _endTour,
      onDismiss: (_) => _endTour(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-runs whenever this route becomes current again (e.g. after popping
    // a pushed screen), so a tour whose data arrived meanwhile can start.
    if (_isCurrentRoute) _scheduleTour();
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _sessions.removeListener(_scheduleTour);
    _wardrobe.removeListener(_scheduleTour);
    _showcase.unregister();
    super.dispose();
  }

  bool get _isCurrentRoute => ModalRoute.of(context)?.isCurrent ?? true;

  bool get _hasSessions =>
      _sessions.active.isNotEmpty || _sessions.history.isNotEmpty;

  void _scheduleTour() {
    if (_tourScheduled) return;
    _tourScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tourScheduled = false;
      _maybeStartTour();
    });
  }

  /// Picks the tour for the visible tab and its current data, or null when
  /// there is nothing new to show.
  ({String id, List<GlobalKey> steps})? _pendingTour() {
    bool isNew(String id) => !_settings.isTourDone(id);

    if (_index == 0) {
      if (!_sessions.isLoaded || !_wardrobe.isLoaded) return null;
      if (isNew(AppTour.sessions)) {
        return (
          id: AppTour.sessions,
          steps: AppTour.sessionsSteps(hasSessions: _hasSessions),
        );
      }
      // Clothes saved but no session yet: point at "New session".
      if (!_hasSessions && !_wardrobe.isEmpty && isNew(AppTour.sessionsFirst)) {
        return (id: AppTour.sessionsFirst, steps: [AppTour.sessionsEmptyAdd]);
      }
      // First session created: explain the active card and history.
      if (_sessions.active.isNotEmpty && isNew(AppTour.sessionsActive)) {
        return (id: AppTour.sessionsActive, steps: AppTour.activeSessionSteps);
      }
      return null;
    }

    if (!_wardrobe.isLoaded) return null;
    if (_wardrobe.isEmpty) {
      return isNew(AppTour.wardrobeEmpty)
          ? (id: AppTour.wardrobeEmpty, steps: [AppTour.wardrobeEmptyAdd])
          : null;
    }
    return isNew(AppTour.wardrobe)
        ? (id: AppTour.wardrobe, steps: AppTour.wardrobeSteps)
        : null;
  }

  void _maybeStartTour() {
    if (!mounted || _runningTour != null || !_isCurrentRoute) return;
    final tour = _pendingTour();
    if (tour == null) return;

    _runningTour = tour.id;
    _startTimer = Timer(AppTour.startDelay, () {
      // The user may have switched tab or opened a screen meanwhile.
      if (!mounted || !_isCurrentRoute || _pendingTour()?.id != tour.id) {
        _runningTour = null;
        return;
      }
      _showcase.startShowCase(_pendingTour()!.steps);
    });
  }

  void _endTour() {
    final id = _runningTour;
    _runningTour = null;
    if (id != null) _settings.completeTour(id);
    // Chain into the next pending tour (e.g. after "Open wardrobe").
    _scheduleTour();
  }

  void _selectTab(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _scheduleTour();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const SessionsScreen(),
          WardrobeScreen(onOpenSessions: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: _FloatingNavBar(
            index: _index,
            onTap: _selectTab,
            items: [
              _NavData(
                HugeIcons.strokeRoundedWashingMachine,
                l10n.sessions,
                wrap: (child) => _NavTourStep(
                  showcaseKey: AppTour.sessionsTab,
                  step: 1,
                  title: l10n.sessions,
                  description: l10n.tourSessionsTabDesc,
                  child: child,
                ),
              ),
              _NavData(
                HugeIcons.strokeRoundedHanger,
                l10n.wardrobe,
                wrap: (child) => _NavTourStep(
                  showcaseKey: AppTour.sessionsWardrobeTab,
                  step: 2,
                  title: l10n.wardrobe,
                  description: l10n.tourWardrobeTabDesc,
                  finishLabel: l10n.tourOpenWardrobe,
                  onFinish: () => _selectTab(1),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A nav bar item as a step of the Sessions tour (pill-shaped spotlight).
class _NavTourStep extends StatelessWidget {
  final GlobalKey showcaseKey;
  final int step;
  final String title;
  final String description;
  final String? finishLabel;
  final VoidCallback? onFinish;
  final Widget child;

  const _NavTourStep({
    required this.showcaseKey,
    required this.step,
    required this.title,
    required this.description,
    required this.child,
    this.finishLabel,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return TourStep(
      scope: AppTour.homeScope,
      showcaseKey: showcaseKey,
      step: step,
      total: AppTour.sessionsStepCount,
      title: title,
      description: description,
      finishLabel: finishLabel,
      onFinish: onFinish,
      targetBorderRadius: const BorderRadius.all(Radius.circular(999)),
      targetPadding: const EdgeInsets.all(2),
      child: child,
    );
  }
}

class _NavData {
  final List<List<dynamic>> icon;
  final String label;

  /// Wraps the built item, e.g. to make it a coach-mark tour step.
  final Widget Function(Widget child)? wrap;

  const _NavData(this.icon, this.label, {this.wrap});
}

class _FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<_NavData> items;

  const _FloatingNavBar({
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;

    final alignX = items.length == 1
        ? 0.0
        : -1 + 2 * index / (items.length - 1);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isLight ? 0.08 : 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment(alignX, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / items.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                // Items fill the pill's height, so taps and tour spotlights
                // cover the whole button, not just its icon and label.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _wrapItem(
                        items[i],
                        _NavItem(
                          data: items[i],
                          selected: i == index,
                          onTap: () => onTap(i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _wrapItem(_NavData data, Widget item) =>
      data.wrap?.call(item) ?? item;
}

class _NavItem extends StatelessWidget {
  final _NavData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: target),
        duration: const Duration(milliseconds: 300),
        builder: (context, color, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: data.icon,
              color: color,
              size: 22,
              strokeWidth: selected ? 2.2 : 1.8,
            ),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
