import 'package:flutter/material.dart';

/// Fade + translate-Y (16px → 0) over 420ms ease-out after [delay].
/// Replays each time [active] turns true and resets when it turns false.
class FadeSlideIn extends StatefulWidget {
  final bool active;
  final Duration delay;
  final Widget child;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.active = true,
    this.delay = Duration.zero,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _play();
  }

  @override
  void didUpdateWidget(FadeSlideIn old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _play();
    } else if (!widget.active && old.active) {
      _c.value = 0;
    }
  }

  Future<void> _play() async {
    _c.value = 0;
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
      if (!mounted || !widget.active) return;
    }
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
