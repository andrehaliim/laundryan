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
  final db = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(CategoryRepository(db)),
        ),
        ChangeNotifierProvider(
          create: (_) => WardrobeProvider(WardrobeRepository(db)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SessionProvider(SessionRepository(db), () => settings.locale),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
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
      home: const SplashScreen(),
    );
  }
}
