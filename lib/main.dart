import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:laundryan/utils/notification_service.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/category_repository.dart';
import 'data/session_repository.dart';
import 'data/wardrobe_repository.dart';
import 'l10n/app_localizations.dart';
import 'providers/category_provider.dart';
import 'providers/session_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wardrobe_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/photo_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PhotoStorage.init();
  await NotificationService.init();
  final settings = await SettingsProvider.load();

  runApp(
    AppScope(settings: settings, db: AppDatabase(), child: const MyApp()),
  );
}

/// Provides the settings, database and feature providers to [child].
class AppScope extends StatelessWidget {
  final SettingsProvider settings;
  final AppDatabase db;
  final Widget child;

  const AppScope({
    super.key,
    required this.settings,
    required this.db,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => CategoryProvider(CategoryRepository(db)),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => WardrobeProvider(WardrobeRepository(db)),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) =>
              SessionProvider(SessionRepository(db), () => settings.locale),
        ),
      ],
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  final Widget home;
  final GlobalKey<NavigatorState>? navigatorKey;

  const MyApp({
    super.key,
    this.home = const SplashScreen(),
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
      home: home,
    );
  }
}
