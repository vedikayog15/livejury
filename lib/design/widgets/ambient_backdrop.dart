import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens.dart';

class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key, this.dark = false, required this.child});
  final bool dark;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                JColors.ink,
                Color.lerp(JColors.ink, JColors.glow, .07)!,
                JColors.ink,
              ]
            : [
                Color.lerp(JColors.canvas, JColors.secondary, .65)!,
                JColors.canvas,
                JColors.surface,
              ],
      ),
    ),
    child: CustomPaint(painter: _AmbientPainter(dark), child: child),
  );
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter(this.dark);
  final bool dark;
  @override
  void paint(Canvas c, Size s) {
    final radius = s.width * .85;
    void glow(Offset p, Color color, double alpha) {
      c.drawCircle(
        p,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: p, radius: radius)),
      );
    }

    glow(Offset(s.width * .96, s.height * .1), JColors.glow, dark ? .18 : .16);
    glow(
      Offset(s.width * .05, s.height * .55),
      JColors.accent,
      dark ? .06 : .12,
    );
    if (dark) {
      final p = Paint()..color = JColors.surface.withValues(alpha: .03);
      for (var i = 0; i < 320; i++) {
        c.drawCircle(
          Offset((i * 73.31) % s.width, (i * 47.83) % s.height),
          .5,
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.dark != dark;
}

class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    required this.child,
    this.radius = 28,
    this.dark = false,
    this.tint = .88,
    this.blur = 18,
  });
  final Widget child;
  final double radius;
  final bool dark;

  /// How much the surface is filled in. A lower tint lets more of the blurred
  /// content read through; [MediaQuery.highContrastOf] always overrides it to
  /// fully opaque so text keeps its contrast guarantee.
  final double tint;
  final double blur;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: JColors.ink.withValues(alpha: .09),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (dark ? JColors.raised : JColors.surface).withValues(
              alpha: MediaQuery.highContrastOf(context) ? 1 : tint,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: JColors.surface.withValues(alpha: dark ? .15 : .9),
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

class EntryReveal extends StatelessWidget {
  const EntryReveal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
