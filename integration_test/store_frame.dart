import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Caption and theme of the store frame currently on screen.
class FrameSpec {
  /// Headline; words wrapped in `*` are highlighted.
  final String title;
  final String subtitle;
  final bool dark;

  const FrameSpec(this.title, this.subtitle, {this.dark = false});
}

/// Logical size of the store canvas; captured at 3x for 1080x1920.
const storeCanvasSize = Size(360, 640);
const storeCanvasPixelRatio = 3.0;

/// Logical size of the phone the app is rendered on (20:9, like most
/// current Android phones).
const phoneScreenSize = Size(412, 915);

/// Play Store canvas: caption on top and the running app inside a phone
/// mockup below. [canvasKey] and [screenKey] wrap repaint boundaries for
/// the framed image and the bare phone screen.
class StoreFrame extends StatelessWidget {
  final ValueListenable<FrameSpec> spec;
  final GlobalKey canvasKey;
  final GlobalKey screenKey;
  final Widget app;

  const StoreFrame({
    super.key,
    required this.spec,
    required this.canvasKey,
    required this.screenKey,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).copyWith(
      textScaler: TextScaler.noScaling,
    );
    final screen = RepaintBoundary(
      key: screenKey,
      child: SizedBox.fromSize(
        size: phoneScreenSize,
        child: MediaQuery(
          data: mq.copyWith(
            size: phoneScreenSize,
            padding: const EdgeInsets.only(top: _StatusBar.height),
            viewPadding: const EdgeInsets.only(top: _StatusBar.height),
            viewInsets: EdgeInsets.zero,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: app),
              ValueListenableBuilder(
                valueListenable: spec,
                builder: (_, s, _) => _StatusBar(dark: s.dark),
              ),
            ],
          ),
        ),
      ),
    );

    return MediaQuery(
      data: mq,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Colors.black,
          child: Center(
            child: RepaintBoundary(
              key: canvasKey,
              child: SizedBox.fromSize(
                size: storeCanvasSize,
                child: ValueListenableBuilder(
                  valueListenable: spec,
                  builder: (_, s, phone) => _Canvas(spec: s, phone: phone!),
                  child: _Phone(screen: screen),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  final FrameSpec spec;
  final Widget phone;

  const _Canvas({required this.spec, required this.phone});

  @override
  Widget build(BuildContext context) {
    final dark = spec.dark;
    final ink = dark ? Colors.white : const Color(0xFF0F2A36);
    final accent = dark ? const Color(0xFF87CEEB) : const Color(0xFF0C6780);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF12161A), Color(0xFF1C2B36)]
              : const [Color(0xFFE1F3FA), Color(0xFFBFE4F4)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: 150,
            child: _Blob(size: 260, color: accent.withValues(alpha: 0.08)),
          ),
          Positioned(
            left: -70,
            bottom: 40,
            child: _Blob(size: 200, color: accent.withValues(alpha: 0.07)),
          ),
          Column(
            children: [
              Container(
                height: 170,
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 0),
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(children: _highlight(spec.title, accent)),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.6,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      spec.subtitle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: ink.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
                  child: Center(child: phone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Splits `a *b* c` into spans with the starred parts in [accent].
  static List<TextSpan> _highlight(String text, Color accent) {
    final parts = text.split('*');
    return [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: i.isOdd ? TextStyle(color: accent) : null,
        ),
    ];
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Phone extends StatelessWidget {
  final Widget screen;

  const _Phone({required this.screen});

  static const _bezel = 6.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final screenHeight = box.maxHeight - 2 * _bezel;
        final screenWidth = screenHeight * phoneScreenSize.aspectRatio;
        return Container(
          width: screenWidth + 2 * _bezel,
          height: box.maxHeight,
          padding: const EdgeInsets.all(_bezel),
          decoration: BoxDecoration(
            color: const Color(0xFF15191E),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFF3A424C), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: FittedBox(child: screen),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  final bool dark;

  const _StatusBar({required this.dark});

  static const height = 40.0;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : const Color(0xFF1E252D);
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Text(
                  '9:41',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(Icons.signal_cellular_alt, size: 17, color: color),
                const SizedBox(width: 4),
                Icon(Icons.wifi, size: 17, color: color),
                const SizedBox(width: 4),
                Icon(Icons.battery_full, size: 17, color: color),
              ],
            ),
          ),
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
