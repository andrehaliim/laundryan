import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:showcaseview/showcaseview.dart';

/// Coach-mark tour ids, showcase scopes and the target keys each tour
/// highlights.
///
/// Since showcaseview 5 the keys are registry ids only (not attached to
/// elements), so sharing them as statics across screens is safe.
class AppTour {
  AppTour._();

  /// Delay before a tour starts, so route fades and entry animations settle
  /// before the spotlight is measured.
  static const startDelay = Duration(milliseconds: 400);

  // Showcase scopes, one per screen that registers a [ShowcaseView].
  static const homeScope = 'tour_home';
  static const wardrobeItemScope = 'tour_wardrobe_item';
  static const addSessionScope = 'tour_add_session';
  static const checklistScope = 'tour_checklist';

  // Tour ids (persisted as "seen" flags).
  static const sessions = 'sessions';
  static const sessionsFirst = 'sessions_first';
  static const sessionsActive = 'sessions_active';
  static const wardrobe = 'wardrobe';
  static const wardrobeEmpty = 'wardrobe_empty';
  static const wardrobeItem = 'wardrobe_item';
  static const addSession = 'add_session';
  static const checklist = 'checklist';

  // Home: Sessions tab.
  static final sessionsTab = GlobalKey(debugLabel: 'tour_sessions_tab');
  static final sessionsAdd = GlobalKey(debugLabel: 'tour_sessions_add');
  static final sessionsWardrobeTab = GlobalKey(
    debugLabel: 'tour_sessions_wardrobe_tab',
  );
  static final sessionsEmptyAdd = GlobalKey(
    debugLabel: 'tour_sessions_empty_add',
  );

  // Home: Sessions tab, once a session exists.
  static final activeStatus = GlobalKey(debugLabel: 'tour_active_status');
  static final activeDetails = GlobalKey(debugLabel: 'tour_active_details');
  static final sessionsHistory = GlobalKey(debugLabel: 'tour_sessions_history');

  // Home: Wardrobe tab.
  static final wardrobeSearch = GlobalKey(debugLabel: 'tour_wardrobe_search');
  static final wardrobeSort = GlobalKey(debugLabel: 'tour_wardrobe_sort');
  static final wardrobeItemCard = GlobalKey(
    debugLabel: 'tour_wardrobe_item_card',
  );
  static final wardrobeEmptyAdd = GlobalKey(
    debugLabel: 'tour_wardrobe_empty_add',
  );

  // Add wardrobe item screen.
  static final itemPhoto = GlobalKey(debugLabel: 'tour_item_photo');
  static final itemCategory = GlobalKey(debugLabel: 'tour_item_category');
  static final itemQty = GlobalKey(debugLabel: 'tour_item_qty');

  // Add session screen.
  static final sessionPlace = GlobalKey(debugLabel: 'tour_session_place');
  static final sessionSchedule = GlobalKey(debugLabel: 'tour_session_schedule');
  static final sessionItems = GlobalKey(debugLabel: 'tour_session_items');
  static final sessionStart = GlobalKey(debugLabel: 'tour_session_start');

  // Verify (checklist) screen.
  static final checkProgress = GlobalKey(debugLabel: 'tour_check_progress');
  static final checkItem = GlobalKey(debugLabel: 'tour_check_item');
  static final checkToggle = GlobalKey(debugLabel: 'tour_check_toggle');
  static final checkFinish = GlobalKey(debugLabel: 'tour_check_finish');

  static const sessionsStepCount = 2;

  /// First step points at the add button once sessions exist, otherwise at
  /// the Sessions tab itself (first install).
  static List<GlobalKey> sessionsSteps({required bool hasSessions}) => [
    hasSessions ? sessionsAdd : sessionsTab,
    sessionsWardrobeTab,
  ];

  static List<GlobalKey> get activeSessionSteps => [
    activeStatus,
    activeDetails,
    sessionsHistory,
  ];

  static List<GlobalKey> get checklistSteps => [
    checkProgress,
    checkItem,
    checkToggle,
    checkFinish,
  ];

  static List<GlobalKey> get wardrobeSteps => [
    wardrobeSearch,
    wardrobeSort,
    wardrobeItemCard,
  ];

  static List<GlobalKey> get wardrobeItemSteps => [
    itemPhoto,
    itemCategory,
    itemQty,
  ];

  static List<GlobalKey> get addSessionSteps => [
    sessionPlace,
    sessionSchedule,
    sessionItems,
    sessionStart,
  ];
}

/// A one-shot tour for a single pushed screen: registers its own showcase
/// scope and marks the tour seen when it finishes or is skipped.
class ScreenTour {
  final String id;
  final SettingsProvider _settings;
  late final ShowcaseView _view;

  ScreenTour({
    required String scope,
    required this.id,
    required this._settings,
  }) {
    _view = ShowcaseView.register(
      scope: scope,
      disableBarrierInteraction: true,
      enableAutoScroll: true,
      onFinish: _markDone,
      onDismiss: (_) => _markDone(),
    );
  }

  Timer? _startTimer;

  void _markDone() => _settings.completeTour(id);

  /// Starts the tour after [AppTour.startDelay] unless the user has already
  /// seen it. Uses its own cancellable timer: showcaseview's built-in delay
  /// would still fire after the screen is disposed.
  void startIfNew(List<GlobalKey> steps) {
    if (_settings.isTourDone(id)) return;
    _startTimer?.cancel();
    _startTimer = Timer(AppTour.startDelay, () => _view.startShowCase(steps));
  }

  void dispose() {
    _startTimer?.cancel();
    _view.unregister();
  }
}
