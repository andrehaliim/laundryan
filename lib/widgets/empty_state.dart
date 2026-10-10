import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:laundryan/widgets/fade_slide_in.dart';
import 'package:laundryan/widgets/soft.dart';

enum EmptyStateTone { primary, secondary, tertiary }

/// Icon-based empty state: layered pastel illustration, title, description
/// and an optional action button. Use [compact] for inline list sections.
class EmptyState extends StatelessWidget {
  final List<List<dynamic>> icon;
  final List<List<List<dynamic>>> orbit;
  final String title;
  final String message;
  final EmptyStateTone tone;
  final String? actionLabel;
  final List<List<dynamic>>? actionIcon;
  final VoidCallback? onAction;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.orbit = const [],
    this.tone = EmptyStateTone.primary,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.compact = false,
  });

  (Color, Color) _colors(ColorScheme s) => switch (tone) {
    EmptyStateTone.primary => (s.primaryContainer, s.onPrimaryContainer),
    EmptyStateTone.secondary => (s.secondaryContainer, s.onSecondaryContainer),
    EmptyStateTone.tertiary => (s.tertiaryContainer, s.onTertiaryContainer),
  };

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (container, onContainer) = _colors(scheme);
    final hasAction = actionLabel != null && onAction != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 96),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeSlideIn(
                child: _Illustration(
                  icon: icon,
                  orbit: orbit,
                  container: container,
                  onContainer: onContainer,
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              if (hasAction) ...[
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: SoftButton(
                    label: actionLabel!,
                    icon: actionIcon,
                    onPressed: onAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (container, onContainer) = _colors(scheme);

    return FadeSlideIn(
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: container,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  size: 24,
                  strokeWidth: 2,
                  color: onContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatefulWidget {
  final List<List<dynamic>> icon;
  final List<List<List<dynamic>>> orbit;
  final Color container;
  final Color onContainer;

  const _Illustration({
    required this.icon,
    required this.orbit,
    required this.container,
    required this.onContainer,
  });

  @override
  State<_Illustration> createState() => _IllustrationState();
}

class _IllustrationState extends State<_Illustration>
    with SingleTickerProviderStateMixin {
  static const _size = 176.0;
  static const _core = 76.0;
  static const _chip = 40.0;
  static const _angles = [-0.7, 2.45];

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

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
    _float.dispose();
    super.dispose();
  }

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

    BoxDecoration card(double radius) => BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: scheme.outlineVariant),
      boxShadow: [shadow],
    );

    return SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, _) {
          final t = _float.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.container.withValues(
                    alpha: isLight ? 0.4 : 0.3,
                  ),
                ),
              ),
              Container(
                width: _size * 0.7,
                height: _size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.container,
                ),
              ),
              Transform.translate(
                offset: Offset(0, math.sin(t) * 3),
                child: Container(
                  width: _core,
                  height: _core,
                  decoration: card(20),
                  child: Center(
                    child: HugeIcon(
                      icon: widget.icon,
                      size: 36,
                      strokeWidth: 1.8,
                      color: widget.onContainer,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < math.min(widget.orbit.length, 2); i++)
                Transform.translate(
                  offset: Offset(
                    math.cos(_angles[i]) * _size * 0.42,
                    math.sin(_angles[i]) * _size * 0.42 +
                        math.sin(t + i * 2.4) * 5,
                  ),
                  child: Container(
                    width: _chip,
                    height: _chip,
                    decoration: card(12),
                    child: Center(
                      child: HugeIcon(
                        icon: widget.orbit[i],
                        size: 18,
                        strokeWidth: 2,
                        color: widget.onContainer,
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
