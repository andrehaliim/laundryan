import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Background sampled from `assets/icon/icon.png` so the icon blends into
  /// the screen.
  static const _bg = Color(0xFFE1F3FA);
  static const _charcoal = Color(0xFF1E252D);
  static const _muted = Color(0xFF586574);
  static const _sky = Color(0xFF87CEEB);

  late final AnimationController _main = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  late final Animation<double> _logoIn = CurvedAnimation(
    parent: _main,
    curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
  );
  late final Animation<double> _titleIn = CurvedAnimation(
    parent: _main,
    curve: const Interval(0.04, 0.18, curve: Curves.easeOut),
  );
  late final Animation<double> _taglineIn = CurvedAnimation(
    parent: _main,
    curve: const Interval(0.08, 0.22, curve: Curves.easeOut),
  );
  late final Animation<double> _level = CurvedAnimation(
    parent: _main,
    curve: const Interval(0.12, 0.95, curve: Curves.easeInOutSine),
  );
  late final Animation<double> _contentOut = CurvedAnimation(
    parent: _main,
    curve: const Interval(0.78, 1.0, curve: Curves.easeInCubic),
  );

  @override
  void initState() {
    super.initState();
    _main.forward().whenComplete(_goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final done = context.read<SettingsProvider>().onboardingDone;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) =>
            done ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 1.04, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _main.dispose();
    _wave.dispose();
    super.dispose();
  }

  Widget _entry(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final tagline = l10n.tagline.split(' - ').last;
    final logoSize = math.min(MediaQuery.sizeOf(context).width * 0.62, 260.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _bg,
      ),
      child: Material(
        color: _bg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _contentOut,
              builder: (_, child) => Opacity(
                opacity: 1 - _contentOut.value,
                child: Transform.translate(
                  offset: Offset(0, -24 * _contentOut.value),
                  child: Transform.scale(
                    scale: 1 + 0.06 * _contentOut.value,
                    child: child,
                  ),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _entry(
                        _logoIn,
                        Image.asset(
                          'assets/icon/icon.png',
                          width: logoSize,
                          height: logoSize,
                        ),
                      ),
                      _entry(
                        _titleIn,
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: text.displaySmall?.copyWith(
                            color: _charcoal,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _entry(
                        _taglineIn,
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Text(
                            tagline,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(
                              color: _muted,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _WaterPainter(
                  level: _level,
                  wave: _wave,
                  clock: _main,
                  color: _sky,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final Animation<double> level;
  final Animation<double> wave;
  final Animation<double> clock;
  final Color color;

  _WaterPainter({
    required this.level,
    required this.wave,
    required this.clock,
    required this.color,
  }) : super(repaint: Listenable.merge([level, wave]));

  static const _amplitude = 10.0;

  static const _bubbles = [
    (x: 0.12, r: 3.0, speed: 1.0, offset: 0.10),
    (x: 0.24, r: 5.0, speed: 0.7, offset: 0.55),
    (x: 0.37, r: 2.5, speed: 1.3, offset: 0.30),
    (x: 0.50, r: 4.0, speed: 0.9, offset: 0.80),
    (x: 0.63, r: 3.0, speed: 1.1, offset: 0.05),
    (x: 0.74, r: 6.0, speed: 0.6, offset: 0.40),
    (x: 0.86, r: 3.5, speed: 1.2, offset: 0.65),
    (x: 0.94, r: 2.5, speed: 0.8, offset: 0.20),
  ];

  Path _wavePath(Size size, double top, double phase, int waves, double amp) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 4) {
      final y =
          top + math.sin(x / size.width * waves * 2 * math.pi + phase) * amp;
      path.lineTo(x, y);
    }
    return path
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = level.value;
    if (p <= 0) return;

    final top =
        size.height + _amplitude * 2 - p * (size.height + _amplitude * 4);
    // Waves calm down as the water reaches the top.
    final amp = _amplitude * (1 - Curves.easeIn.transform(p) * 0.6);
    final phase = wave.value * 2 * math.pi;

    canvas.drawPath(
      _wavePath(size, top - 6, -phase, 1, amp * 1.2),
      Paint()..color = color.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      _wavePath(size, top, phase, 2, amp),
      Paint()..color = color.withValues(alpha: 0.6),
    );

    final waterHeight = size.height - top;
    if (waterHeight <= 0) return;
    final bubble = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final b in _bubbles) {
      final t = (clock.value * 2 * b.speed + b.offset) % 1;
      final y = size.height - t * waterHeight;
      if (y < top + amp + b.r) continue;
      bubble.color = Colors.white.withValues(alpha: 0.9 * (1 - t));
      canvas.drawCircle(Offset(b.x * size.width, y), b.r, bubble);
    }
  }

  @override
  bool shouldRepaint(_WaterPainter old) => old.color != color;
}
