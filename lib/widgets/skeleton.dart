import 'package:flutter/material.dart';
import 'package:laundryan/widgets/soft.dart';

/// Sweeps a soft highlight across its [child]'s painted shapes.
/// Stays static when the OS asks to reduce motion.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;
    final base = scheme.surfaceContainerHigh;
    final highlight = isLight
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: _SlideGradient(_c.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double t;

  const _SlideGradient(this.t);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * t - 1), 0, 0);
}

/// A single placeholder shape. Its color is replaced by [Shimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Placeholder for session detail style pages: a summary card, a section
/// header and a list of item cards.
class SessionDetailSkeleton extends StatelessWidget {
  final int items;

  const SessionDetailSkeleton({super.key, this.items = 4});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SoftCard(
          padding: const EdgeInsets.all(16),
          child: Shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: SkeletonBox(height: 20),
                          ),
                          SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.4,
                            child: SkeletonBox(height: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    SkeletonBox(width: 40, height: 40, radius: 12),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonBox(height: 40, radius: 10),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      const Expanded(
                        child: SkeletonBox(height: 64, radius: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Shimmer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                SkeletonBox(width: 140, height: 14),
                Spacer(),
                SkeletonBox(width: 64, height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items; i++) ...[
          const SoftCard(
            padding: EdgeInsets.all(12),
            child: Shimmer(
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, radius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          child: SkeletonBox(height: 14),
                        ),
                        SizedBox(height: 8),
                        SkeletonBox(width: 96, height: 20, radius: 999),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  SkeletonBox(width: 32, height: 32, radius: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
