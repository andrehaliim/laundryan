import 'package:flutter/material.dart';

class Pulse extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool active;
  const Pulse({
    super.key,
    required this.child,
    required this.color,
    this.active = true,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: 1 + t * 0.9,
              child: Opacity(
                opacity: (1 - t) * 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                  child: const SizedBox(width: 30, height: 30),
                ),
              ),
            ),
            Transform.scale(scale: 1 + 0.08 * (1 - t), child: child),
          ],
        );
      },
      child: widget.child,
    );
  }
}