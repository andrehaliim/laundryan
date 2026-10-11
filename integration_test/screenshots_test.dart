import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laundryan/data/app_database.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/main.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/screens/checklist_screen.dart';
import 'package:laundryan/screens/history_detail_screen.dart';
import 'package:laundryan/screens/home_screen.dart';
import 'package:laundryan/screens/session_detail_screen.dart';
import 'package:laundryan/utils/notification_service.dart';
import 'package:laundryan/utils/photo_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_data.dart';
import 'store_frame.dart';

/// Store captions per language; `*word*` is highlighted and every
/// title breaks into two lines so the phone sits at the same spot.
const _captions = {
  'en': {
    '01_sessions': FrameSpec(
      'Track every\n*laundry drop-off*',
      "See what's washing and what's ready to pick up, at a glance.",
    ),
    '02_session_detail': FrameSpec(
      "Know *exactly*\nwhen it's ready",
      'Follow every step, from drop-off to pickup.',
    ),
    '03_checklist': FrameSpec(
      'Check *every piece*\nat pickup',
      'Tick items off one by one so nothing gets left behind.',
    ),
    '04_history_detail': FrameSpec(
      'No more\n*missing socks*',
      "Lost or swapped items stay flagged until they're found.",
    ),
    '05_wardrobe': FrameSpec(
      'Your wardrobe,\n*all in one place*',
      "Know what's at home, in the wash, or missing.",
    ),
    '06_sessions_dark': FrameSpec(
      'Easy on the eyes\n*at night*',
      'A dark mode that looks just as good.',
      dark: true,
    ),
  },
  'id': {
    '01_sessions': FrameSpec(
      'Pantau *semua*\ncucianmu',
      'Lihat mana yang masih dicuci dan mana yang siap diambil.',
    ),
    '02_session_detail': FrameSpec(
      'Tahu *kapan*\ncucian selesai',
      'Ikuti tiap tahap, dari dititipkan sampai siap diambil.',
    ),
    '03_checklist': FrameSpec(
      'Cek *satu per satu*\nsaat ambil',
      'Centang tiap item, pastikan tak ada yang tertinggal.',
    ),
    '04_history_detail': FrameSpec(
      'Tak ada lagi\nbaju *raib*',
      'Item hilang atau tertukar ditandai sampai ketemu.',
    ),
    '05_wardrobe': FrameSpec(
      'Semua pakaian,\n*tercatat rapi*',
      'Tahu mana yang di rumah, sedang dicuci, atau hilang.',
    ),
    '06_sessions_dark': FrameSpec(
      'Nyaman dipakai\n*malam hari*',
      'Mode gelap yang tetap enak dilihat.',
      dark: true,
    ),
  },
};

/// Captures Play Store screenshots for every supported language.
///
/// Run with:
/// ```sh
/// fvm flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/screenshots_test.dart -d <device>
/// ```
///
/// Framed 1080x1920 images land in `screenshots/<lang>/`, bare phone
/// screens in `screenshots/<lang>/raw/`. Output size does not depend on
/// the device.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots', (tester) async {
    await PhotoStorage.init();
    await NotificationService.init();

    for (final lang in _captions.keys) {
      SharedPreferences.setMockInitialValues({
        'language': lang,
        'theme': 'light',
        'onboarding_done': true,
      });
      final settings = await SettingsProvider.load();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final ids = await seedDemoData(db, lang);
      final l10n = lookupAppLocalizations(Locale(lang));
      final captions = _captions[lang]!;
      final nav = GlobalKey<NavigatorState>();
      final canvasKey = GlobalKey();
      final screenKey = GlobalKey();
      final spec = ValueNotifier(captions.values.first);

      await tester.pumpWidget(
        StoreFrame(
          spec: spec,
          canvasKey: canvasKey,
          screenKey: screenKey,
          app: AppScope(
            settings: settings,
            db: db,
            child: MyApp(home: const HomeScreen(), navigatorKey: nav),
          ),
        ),
      );
      await GoogleFonts.pendingFonts();
      await _wait(tester, 2000);

      Future<void> shot(String name) async {
        spec.value = captions[name]!;
        await _wait(tester);
        await _capture(
          binding,
          canvasKey,
          '$lang/$name',
          storeCanvasPixelRatio,
        );
        await _capture(
          binding,
          screenKey,
          '$lang/raw/$name',
          1080 / phoneScreenSize.width,
        );
      }

      Future<void> pushShot(Widget screen, String name) async {
        nav.currentState!.push(MaterialPageRoute(builder: (_) => screen));
        await shot(name);
        nav.currentState!.pop();
        await _wait(tester);
      }

      await shot('01_sessions');
      await pushShot(
        SessionDetailScreen(sessionId: ids.washingSession),
        '02_session_detail',
      );
      await pushShot(
        ChecklistScreen(sessionId: ids.pickupSession),
        '03_checklist',
      );
      await pushShot(
        HistoryDetailScreen(sessionId: ids.historyWithLoss),
        '04_history_detail',
      );

      await tester.tap(find.text(l10n.wardrobe).hitTestable().first);
      await shot('05_wardrobe');

      await tester.tap(find.text(l10n.sessions).hitTestable().first);
      await settings.setThemeMode(ThemeMode.dark);
      await shot('06_sessions_dark');

      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    }
  });
}

/// Renders the repaint boundary behind [key] to a PNG and queues it for
/// the driver under [name], the same way `takeScreenshot` does.
Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  GlobalKey key,
  String name,
  double pixelRatio,
) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final report = binding.reportData ??= <String, dynamic>{};
  final shots = (report['screenshots'] ??= <dynamic>[]) as List<dynamic>;
  shots.add({
    'screenshotName': name,
    'bytes': png!.buffer.asUint8List().toList(),
  });
}

/// Pumps frames for [ms] milliseconds. `pumpAndSettle` never returns here
/// because some widgets (e.g. `Pulse`) animate forever.
Future<void> _wait(WidgetTester tester, [int ms = 1200]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
