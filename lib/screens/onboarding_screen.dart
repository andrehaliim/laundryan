import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laundryan/core/utils/onboarding_prefs.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    await OnboardingPrefs.setSeenOnboarding();
    if (context.mounted) context.go('/sessions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _finishOnboarding(context),
          child: const Text('Mulai Sekarang'),
        ),
      ),
    );
  }
}