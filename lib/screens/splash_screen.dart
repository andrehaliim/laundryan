import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/screens/home_screen.dart';
import 'package:laundryan/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final done = context.read<SettingsProvider>().onboardingDone;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => done ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/splash/logo.png', width: 120),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              decoration: TextDecoration.none,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
