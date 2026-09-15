import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:laundryan/core/theme/app_colors.dart';
import 'package:laundryan/core/utils/onboarding_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
          ),
        );

    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();

    Timer(const Duration(milliseconds: 2100), _navigateNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    final hasSeenOnboarding = await OnboardingPrefs.hasSeenOnboarding();
    if (!mounted) return;
    context.go(hasSeenOnboarding ? '/sessions' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.royalBlue, AppColors.tealBlue],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: SvgPicture.asset(
                        'assets/icons/icon_foreground.svg',
                        width: size.width * 0.25,
                        height: size.height * 0.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'Laundryan',
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.offWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Text(
                        'Biar nggak ada yang ilang pas nyuci',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.offWhite.withValues(alpha: 0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
