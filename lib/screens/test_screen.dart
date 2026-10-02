import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SoftCard(height: height / 3, child: const SizedBox()),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final EdgeInsetsGeometry padding;

  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.height,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final radius = BorderRadius.circular(20);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isLight ? 0.06 : 0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

enum CountBadgeMode { primary, secondary, tertiary }

class CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final CountBadgeMode mode;
  final double horizontalPadding;

  const CountBadge({
    super.key,
    required this.count,
    required this.label,
    required this.horizontalPadding,
    this.mode = CountBadgeMode.primary,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg) = switch (mode) {
      CountBadgeMode.primary => (scheme.primary, scheme.onPrimary),
      CountBadgeMode.secondary => (scheme.secondary, scheme.onSecondary),
      CountBadgeMode.tertiary => (scheme.tertiary, scheme.onTertiary),
    };

    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: fg, fontWeight: FontWeight.w600);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count $label', style: style),
    );
  }
}
