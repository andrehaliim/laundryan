import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/l10n/app_localizations.dart';
import 'package:laundryan/providers/settings_provider.dart';
import 'package:laundryan/screens/home_screen.dart';
import 'package:laundryan/widgets/fade_slide_in.dart';
import 'package:laundryan/widgets/soft.dart';
import 'package:provider/provider.dart';

class _OnboardPage {
  final List<List<dynamic>> icon;
  final List<List<List<dynamic>>> orbit;
  final String title;
  final String desc;
  final Color accent;
  final Color container;
  final Color onContainer;

  const _OnboardPage({
    required this.icon,
    required this.orbit,
    required this.title,
    required this.desc,
    required this.accent,
    required this.container,
    required this.onContainer,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  bool _finishing = false;
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  int _page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _float.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final navigator = Navigator.of(context);
    await context.read<SettingsProvider>().completeOnboarding();
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (_) => false,
    );
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final pages = [
      _OnboardPage(
        icon: HugeIcons.strokeRoundedWardrobe01,
        orbit: const [
          HugeIcons.strokeRoundedTShirt,
          HugeIcons.strokeRoundedDress01,
          HugeIcons.strokeRoundedHoodie,
        ],
        title: l10n.onboardingTitle1,
        desc: l10n.onboardingDesc1,
        accent: scheme.primary,
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
      ),
      _OnboardPage(
        icon: HugeIcons.strokeRoundedWashingMachine,
        orbit: const [
          HugeIcons.strokeRoundedClock01,
          HugeIcons.strokeRoundedNotification01,
          HugeIcons.strokeRoundedDroplet,
        ],
        title: l10n.onboardingTitle2,
        desc: l10n.onboardingDesc2,
        accent: scheme.tertiary,
        container: scheme.tertiaryContainer,
        onContainer: scheme.onTertiaryContainer,
      ),
      _OnboardPage(
        icon: HugeIcons.strokeRoundedTaskDone01,
        orbit: const [
          HugeIcons.strokeRoundedTick02,
          HugeIcons.strokeRoundedPackageReceive,
          HugeIcons.strokeRoundedCheckmarkCircle02,
        ],
        title: l10n.onboardingTitle3,
        desc: l10n.onboardingDesc3,
        accent: scheme.secondary,
        container: scheme.secondaryContainer,
        onContainer: scheme.onSecondaryContainer,
      ),
    ];
    final isLast = _page == pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          for (var i = 0; i < pages.length; i++)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: i == _page ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _Backdrop(color: pages[i].accent),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedOpacity(
                        opacity: isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: isLast,
                          child: SoftButton(
                            label: l10n.skip,
                            variant: SoftButtonVariant.ghost,
                            onPressed: _finish,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => _PageBody(
                      page: pages[i],
                      index: i,
                      active: i == _page,
                      controller: _controller,
                      float: _float,
                    ),
                  ),
                ),
                _Dots(pages: pages, current: _page),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SoftButton(
                      key: ValueKey(isLast),
                      label: isLast ? l10n.start : l10n.next,
                      icon: isLast
                          ? HugeIcons.strokeRoundedTick02
                          : HugeIcons.strokeRoundedArrowRight01,
                      expanded: true,
                      onPressed: isLast ? _finish : _next,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  final Color color;

  const _Backdrop({required this.color});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final alpha = isLight ? 0.28 : 0.14;

    Widget blob(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (_, c) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -c.maxWidth * 0.35,
            right: -c.maxWidth * 0.3,
            child: blob(c.maxWidth * 1.1),
          ),
          Positioned(
            bottom: -c.maxWidth * 0.4,
            left: -c.maxWidth * 0.45,
            child: blob(c.maxWidth * 1.0),
          ),
        ],
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  final _OnboardPage page;
  final int index;
  final bool active;
  final PageController controller;
  final Animation<double> float;

  const _PageBody({
    required this.page,
    required this.index,
    required this.active,
    required this.controller,
    required this.float,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (_, c) {
        final heroSize = math.min(c.maxWidth * 0.78, c.maxHeight * 0.55);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (_, child) {
                  final pos =
                      controller.hasClients &&
                          controller.position.haveDimensions
                      ? controller.page ?? index.toDouble()
                      : index.toDouble();
                  final delta = (index - pos).clamp(-1.0, 1.0);
                  return Transform.translate(
                    offset: Offset(delta * c.maxWidth * 0.25, 0),
                    child: Opacity(
                      opacity: (1 - delta.abs() * 0.6).clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: FadeSlideIn(
                  active: active,
                  child: _Hero(page: page, size: heroSize, float: float),
                ),
              ),
              const SizedBox(height: 40),
              FadeSlideIn(
                active: active,
                delay: const Duration(milliseconds: 80),
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                active: active,
                delay: const Duration(milliseconds: 160),
                child: Text(
                  page.desc,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final _OnboardPage page;
  final double size;
  final Animation<double> float;

  const _Hero({required this.page, required this.size, required this.float});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final cardColor = theme.cardTheme.color;
    final shadow = BoxShadow(
      color: scheme.shadow.withValues(alpha: isLight ? 0.06 : 0.3),
      blurRadius: 12,
      offset: const Offset(0, 2),
    );
    final core = size * 0.42;
    final chip = size * 0.2;

    const angles = [-2.4, -0.5, 1.6];

    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: float,
        builder: (_, _) {
          final t = float.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.92,
                height: size * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.container.withValues(
                    alpha: isLight ? 0.45 : 0.35,
                  ),
                ),
              ),
              Container(
                width: size * 0.66,
                height: size * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.container,
                ),
              ),
              Transform.translate(
                offset: Offset(0, math.sin(t) * 4),
                child: Container(
                  width: core,
                  height: core,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: scheme.outlineVariant),
                    boxShadow: [shadow],
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: page.icon,
                      size: core * 0.48,
                      strokeWidth: 1.8,
                      color: page.onContainer,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < page.orbit.length; i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(angles[i]) * size * 0.4,
                    math.sin(angles[i]) * size * 0.4 +
                        math.sin(t + i * 2.1) * 6,
                  ),
                  child: Container(
                    width: chip,
                    height: chip,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.outlineVariant),
                      boxShadow: [shadow],
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: page.orbit[i],
                        size: chip * 0.46,
                        strokeWidth: 2,
                        color: page.onContainer,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final List<_OnboardPage> pages;
  final int current;

  const _Dots({required this.pages, required this.current});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (i) {
        final on = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: on ? pages[current].accent : muted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
