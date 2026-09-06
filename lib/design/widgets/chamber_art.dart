import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens.dart';

/// Original scenes built from projected geometry, light and surface gradients.
/// The renderer has no images, network requests, or external scene assets.
class ChamberArt extends StatelessWidget {
  const ChamberArt({
    super.key,
    this.seated = 6,
    this.height = 260,
    this.compact = false,
  });
  final int seated;
  final double height;
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'A dimensional jury chamber with $seated of six seats occupied',
    image: true,
    child: RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRect(
          child: CustomPaint(painter: _ChamberPainter(seated, compact)),
        ),
      ),
    ),
  );
}

void _polygon(Canvas c, List<Offset> points, Paint p) {
  final path = Path()..addPolygon(points, true);
  c.drawPath(path, p);
}

void _glow(
  Canvas c,
  Offset center,
  double radius,
  Color color, {
  double intensity = .35,
}) {
  c.drawCircle(
    center,
    radius,
    Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: intensity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

class _ChamberPainter extends CustomPainter {
  const _ChamberPainter(this.seated, this.compact);
  final int seated;
  final bool compact;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 400, s.height / 300);
    const center = Offset(200, 171);
    _glow(c, const Offset(195, 110), 170, JColors.glow, intensity: .28);
    _glow(c, const Offset(340, 190), 120, JColors.accent, intensity: .12);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = JColors.glow.withValues(alpha: .12);
    for (var i = 0; i < 12; i++) {
      final x = -160 + i * 70.0;
      c.drawLine(Offset(200 + (x - 200) * .25, 125), Offset(x, 300), line);
    }
    for (var i = 0; i < 6; i++) {
      final y = 135 + i * i * 5.2;
      c.drawLine(Offset(0, y), Offset(400, y), line);
    }
    // The pendant halo is separated from the plane of the table.
    c.drawOval(
      const Rect.fromLTWH(90, 24, 220, 65),
      Paint()
        ..color = JColors.glow.withValues(alpha: .22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    c.drawOval(
      const Rect.fromLTWH(90, 24, 220, 65),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = const LinearGradient(
          colors: [JColors.glow, JColors.surface, JColors.accent],
        ).createShader(const Rect.fromLTWH(90, 24, 220, 65)),
    );
    c.drawLine(
      const Offset(112, 0),
      const Offset(112, 36),
      line..color = JColors.onDarkMuted.withValues(alpha: .3),
    );
    c.drawLine(const Offset(288, 0), const Offset(288, 36), line);
    _polygon(
      c,
      [
        const Offset(95, 54),
        const Offset(305, 54),
        const Offset(355, 250),
        const Offset(45, 250),
      ],
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JColors.glow.withValues(alpha: .06),
            JColors.glow.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTWH(45, 54, 310, 196)),
    );
    c.drawOval(
      const Rect.fromLTWH(55, 205, 290, 65),
      Paint()
        ..color = JColors.ink.withValues(alpha: .85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    void chair(int i) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final x = center.dx + math.cos(angle) * 142,
          y = center.dy + math.sin(angle) * 74;
      final filled = i < seated;
      final selected = i == 0 && filled;
      c.save();
      c.translate(x, y);
      c.rotate(math.cos(angle) * -.23);
      final fill = selected ? JColors.accent : JColors.raised;
      c.drawOval(
        const Rect.fromLTWH(-23, 20, 51, 16),
        Paint()
          ..color = JColors.ink.withValues(alpha: .6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      for (final x in [-15.0, 15.0]) {
        c.drawLine(
          Offset(x, 9),
          Offset(x + 3, 29),
          Paint()
            ..color = JColors.onDarkMuted.withValues(alpha: .35)
            ..strokeWidth = 2,
        );
      }
      final back = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, -23, 50, 40),
        const Radius.circular(14),
      );
      c.drawRRect(
        back,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: filled
                ? [
                    Color.lerp(fill, JColors.surface, .18)!,
                    fill,
                    Color.lerp(fill, JColors.ink, .5)!,
                  ]
                : [JColors.raised.withValues(alpha: .3), JColors.ink],
          ).createShader(back.outerRect),
      );
      c.drawRRect(
        back,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = (selected ? JColors.surface : JColors.onDarkMuted)
              .withValues(alpha: filled ? .5 : .18),
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-22, 0, 44, 22),
          const Radius.circular(8),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill, Color.lerp(fill, JColors.ink, .25)!],
          ).createShader(const Rect.fromLTWH(-22, 0, 44, 22)),
      );
      c.drawLine(
        const Offset(-15, -15),
        const Offset(15, -15),
        Paint()
          ..color = (selected ? JColors.surface : JColors.glow).withValues(
            alpha: .25,
          )
          ..strokeWidth = 1,
      );
      c.restore();
    }

    for (final i in [0, 1, 5]) {
      chair(i);
    }
    // Table pedestal and two layers of polished edge.
    _polygon(
      c,
      [
        const Offset(161, 175),
        const Offset(239, 175),
        const Offset(228, 235),
        const Offset(173, 235),
      ],
      Paint()
        ..shader = const LinearGradient(
          colors: [JColors.ink, JColors.raised, JColors.ink],
        ).createShader(const Rect.fromLTWH(161, 175, 78, 60)),
    );
    c.drawOval(
      const Rect.fromLTWH(77, 131, 246, 110),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [JColors.raised, JColors.ink],
        ).createShader(const Rect.fromLTWH(77, 131, 246, 110)),
    );
    c.drawOval(
      const Rect.fromLTWH(77, 121, 246, 110),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(JColors.raised, JColors.glow, .28)!,
            JColors.raised,
            JColors.ink,
          ],
        ).createShader(const Rect.fromLTWH(77, 121, 246, 110)),
    );
    c.drawOval(
      const Rect.fromLTWH(77, 121, 246, 110),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          colors: [
            JColors.glow.withValues(alpha: .7),
            JColors.accent.withValues(alpha: .3),
            JColors.raised,
          ],
        ).createShader(const Rect.fromLTWH(77, 121, 246, 110)),
    );
    c.drawOval(
      const Rect.fromLTWH(89, 126, 222, 99),
      line..color = JColors.glow.withValues(alpha: .15),
    );
    c.drawOval(
      const Rect.fromLTWH(157, 151, 86, 39),
      Paint()
        ..shader = RadialGradient(
          colors: [
            JColors.glow.withValues(alpha: .13),
            JColors.glow.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTWH(157, 151, 86, 39)),
    );
    for (final i in [2, 4, 3]) {
      chair(i);
    }
    final label = TextPainter(
      text: TextSpan(
        text: 'VI',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: compact ? 24 : 26,
          fontWeight: FontWeight.w300,
          color: JColors.accent.withValues(alpha: .9),
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(c, Offset(200 - label.width / 2, 151));
    // Six small evidence lights on the table.
    for (var i = 0; i < 6; i++) {
      c.drawCircle(
        Offset(182 + i * 7.0, 188),
        1.4,
        Paint()
          ..color = i < seated
              ? JColors.accent
              : JColors.onDarkMuted.withValues(alpha: .3),
      );
    }
    c.restore();
  }

  @override
  bool shouldRepaint(_ChamberPainter old) =>
      seated != old.seated || compact != old.compact;
}

class DossierArt extends StatelessWidget {
  const DossierArt({super.key, this.variant = 0, this.height = 200});
  final int variant;
  final double height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRect(
          child: CustomPaint(painter: _CaseScenePainter(variant)),
        ),
      ),
    ),
  );
}

class _CaseScenePainter extends CustomPainter {
  const _CaseScenePainter(this.variant);
  final int variant;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 400, s.height / 260);
    final rect = const Rect.fromLTWH(0, 0, 400, 260);
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JColors.raised,
            Color.lerp(JColors.ink, JColors.glow, .11)!,
            JColors.ink,
          ],
        ).createShader(rect),
    );
    switch (variant) {
      case 1:
        _rooftop(c);
      case 2:
        _station(c);
      default:
        _gallery(c);
    }
    // Fine deterministic film grain stays inside the artwork, away from copy.
    final noise = Paint()..color = JColors.surface.withValues(alpha: .025);
    for (var i = 0; i < 950; i++) {
      c.drawCircle(Offset((i * 73.31) % 400, (i * 31.91) % 260), .55, noise);
    }
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, .72, 1],
          colors: [
            JColors.ink.withValues(alpha: 0),
            JColors.ink.withValues(alpha: 0),
            JColors.ink,
          ],
        ).createShader(rect),
    );
    c.restore();
  }

  void _gallery(Canvas c) {
    _glow(c, const Offset(280, 62), 185, JColors.glow, intensity: .34);
    _glow(c, const Offset(100, 180), 130, JColors.blue, intensity: .13);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = JColors.glow.withValues(alpha: .22);
    for (var i = 0; i < 4; i++) {
      final left = 28 + i * 18.0, top = -28 + i * 17.0;
      final arch = Path()
        ..moveTo(left, 227)
        ..lineTo(left, top + 80)
        ..quadraticBezierTo(200, top - 76, 400 - left, top + 80)
        ..lineTo(400 - left, 227);
      c.drawPath(
        arch,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..shader = LinearGradient(
            colors: [
              JColors.glow.withValues(alpha: .08),
              JColors.glow.withValues(alpha: .23),
              JColors.glow.withValues(alpha: .04),
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 400, 240)),
      );
      c.drawPath(arch, line);
    }
    _polygon(
      c,
      [
        const Offset(302, -15),
        const Offset(328, -15),
        const Offset(261, 230),
        const Offset(102, 230),
      ],
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            JColors.accent.withValues(alpha: .25),
            JColors.glow.withValues(alpha: .025),
          ],
        ).createShader(const Rect.fromLTWH(100, 0, 230, 230)),
    );
    for (var i = 0; i < 6; i++) {
      final y = 190 + i * 13.0;
      c.drawLine(
        Offset(0, y),
        Offset(400, y),
        line..color = JColors.glow.withValues(alpha: .11),
      );
    }
    for (var i = 0; i < 7; i++) {
      c.drawLine(const Offset(214, 152), Offset(-90 + i * 95.0, 280), line);
    }
    c.drawOval(
      const Rect.fromLTWH(123, 207, 170, 28),
      Paint()
        ..color = JColors.ink.withValues(alpha: .65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    _polygon(
      c,
      [
        const Offset(162, 168),
        const Offset(246, 168),
        const Offset(257, 210),
        const Offset(151, 210),
      ],
      Paint()
        ..shader = const LinearGradient(
          colors: [JColors.raised, JColors.ink],
        ).createShader(const Rect.fromLTWH(151, 168, 106, 42)),
    );
    _polygon(c, [
      const Offset(151, 210),
      const Offset(257, 210),
      const Offset(257, 224),
      const Offset(151, 224),
    ], Paint()..color = JColors.raised);
    _polygon(
      c,
      [
        const Offset(162, 168),
        const Offset(186, 155),
        const Offset(267, 155),
        const Offset(246, 168),
      ],
      Paint()
        ..shader = LinearGradient(
          colors: [JColors.glow.withValues(alpha: .4), JColors.raised],
        ).createShader(const Rect.fromLTWH(162, 155, 105, 13)),
    );
    // A faceted hourglass sculpture: distinct front, side and refracted core.
    final front = [
      const Offset(176, 51),
      const Offset(231, 51),
      const Offset(211, 100),
      const Offset(231, 146),
      const Offset(176, 146),
      const Offset(195, 100),
    ];
    _polygon(
      c,
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JColors.surface.withValues(alpha: .42),
            JColors.blue.withValues(alpha: .14),
            JColors.glow.withValues(alpha: .5),
            JColors.surface.withValues(alpha: .25),
          ],
        ).createShader(const Rect.fromLTWH(176, 51, 55, 95)),
    );
    _polygon(
      c,
      [
        const Offset(231, 51),
        const Offset(250, 41),
        const Offset(231, 92),
        const Offset(250, 136),
        const Offset(231, 146),
        const Offset(211, 100),
      ],
      Paint()
        ..shader = LinearGradient(
          colors: [
            JColors.blue.withValues(alpha: .15),
            JColors.glow.withValues(alpha: .65),
          ],
        ).createShader(const Rect.fromLTWH(211, 41, 39, 105)),
    );
    _polygon(c, [
      const Offset(176, 51),
      const Offset(195, 41),
      const Offset(250, 41),
      const Offset(231, 51),
    ], Paint()..color = JColors.surface.withValues(alpha: .36));
    c.drawPath(
      Path()..addPolygon(front, true),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = JColors.surface.withValues(alpha: .75),
    );
    c.drawLine(
      const Offset(250, 41),
      const Offset(231, 92),
      line..color = JColors.blue.withValues(alpha: .8),
    );
    c.drawLine(const Offset(231, 92), const Offset(250, 136), line);
    c.drawLine(const Offset(250, 136), const Offset(231, 146), line);
    _polygon(c, [
      const Offset(194, 61),
      const Offset(220, 61),
      const Offset(206, 95),
    ], Paint()..color = JColors.accent.withValues(alpha: .45));
    _polygon(
      c,
      [const Offset(206, 107), const Offset(218, 138), const Offset(186, 138)],
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JColors.accent.withValues(alpha: .12),
            JColors.accent.withValues(alpha: .8),
          ],
        ).createShader(const Rect.fromLTWH(186, 107, 32, 31)),
    );
    _glow(c, const Offset(206, 100), 26, JColors.surface, intensity: .28);
    c.drawCircle(const Offset(206, 100), 1.5, Paint()..color = JColors.surface);
  }

  void _rooftop(Canvas c) {
    _glow(c, const Offset(297, 112), 180, JColors.accent, intensity: .42);
    _glow(c, const Offset(92, 56), 130, JColors.glow, intensity: .28);
    c.drawCircle(
      const Offset(304, 102),
      30,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [JColors.accent, JColors.glow],
        ).createShader(const Rect.fromLTWH(274, 72, 60, 60)),
    );
    for (var i = 0; i < 18; i++) {
      final x = i * 26.0 - 20;
      final h = 25.0 + (i * 39) % 70;
      c.drawRect(
        Rect.fromLTWH(x, 185 - h, 22, h),
        Paint()..color = i.isEven ? JColors.ink : JColors.raised,
      );
      for (var j = 0; j < 3; j++) {
        c.drawRect(
          Rect.fromLTWH(x + 5, 190 - h + j * 14, 3, 4),
          Paint()..color = JColors.accent.withValues(alpha: .3),
        );
      }
    }
    _polygon(
      c,
      [
        const Offset(38, 196),
        const Offset(310, 157),
        const Offset(416, 207),
        const Offset(74, 270),
      ],
      Paint()
        ..shader = const LinearGradient(
          colors: [JColors.raised, JColors.ink],
        ).createShader(const Rect.fromLTWH(38, 157, 378, 113)),
    );
    final line = Paint()
      ..strokeWidth = 2
      ..color = JColors.onDarkMuted.withValues(alpha: .5);
    c.drawLine(const Offset(78, 98), const Offset(78, 204), line);
    c.drawLine(const Offset(290, 77), const Offset(290, 175), line);
    final cable = Path()
      ..moveTo(78, 98)
      ..quadraticBezierTo(180, 140, 290, 77);
    c.drawPath(
      cable,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = JColors.onDarkMuted,
    );
    for (var i = 0; i < 9; i++) {
      final t = i / 8;
      final x = 78 + 212 * t;
      final y = (1 - t) * (1 - t) * 98 + 2 * (1 - t) * t * 140 + t * t * 77;
      _glow(c, Offset(x, y + 8), 18, JColors.accent, intensity: .6);
      c.drawLine(Offset(x, y), Offset(x, y + 7), line..strokeWidth = 1);
      c.drawCircle(
        Offset(x, y + 9),
        3,
        Paint()..color = i < 6 ? JColors.accent : JColors.onDarkMuted,
      );
    }
    for (var i = 0; i < 32; i++) {
      final x = (i * 63.3) % 400, y = (i * 31.9) % 230;
      c.drawLine(
        Offset(x, y),
        Offset(x - 9, y + 22),
        Paint()
          ..color = JColors.blue.withValues(alpha: .15)
          ..strokeWidth = .8,
      );
    }
    c.drawLine(
      const Offset(55, 203),
      const Offset(307, 166),
      Paint()
        ..color = JColors.accent.withValues(alpha: .4)
        ..strokeWidth = 1.5,
    );
  }

  void _station(Canvas c) {
    _glow(c, const Offset(244, 108), 145, JColors.glow, intensity: .35);
    final p = Paint()..style = PaintingStyle.stroke;
    for (var i = 0; i < 7; i++) {
      final scale = 1 - i * .11;
      final w = 380 * scale, h = 280 * scale;
      final x = 244 - w * .5, y = 122 - h * .65;
      final path = Path()
        ..moveTo(x, y + h)
        ..lineTo(x, y + 70 * scale)
        ..quadraticBezierTo(244, y - 80 * scale, x + w, y + 70 * scale)
        ..lineTo(x + w, y + h);
      c.drawPath(
        path,
        p
          ..strokeWidth = 10 * scale
          ..color = Color.lerp(JColors.raised, JColors.glow, .1 + i * .025)!,
      );
      c.drawPath(
        path,
        p
          ..strokeWidth = .8
          ..color = JColors.glow.withValues(alpha: .3),
      );
    }
    _polygon(c, [
      const Offset(240, 132),
      const Offset(260, 132),
      const Offset(430, 270),
      const Offset(82, 270),
    ], Paint()..color = JColors.ink);
    for (final x in [118.0, 335.0]) {
      c.drawLine(
        const Offset(250, 133),
        Offset(x, 280),
        Paint()
          ..strokeWidth = 2
          ..color = JColors.onDarkMuted.withValues(alpha: .3),
      );
    }
    for (var i = 0; i < 7; i++) {
      final y = 140 + i * i * 3.0;
      final t = (y - 132) / 148;
      c.drawLine(
        Offset(250 - 132 * t, y),
        Offset(250 + 85 * t, y),
        Paint()
          ..color = JColors.onDarkMuted.withValues(alpha: .2)
          ..strokeWidth = 2,
      );
    }
    c.drawLine(
      const Offset(229, 134),
      const Offset(43, 280),
      Paint()
        ..strokeWidth = 5
        ..color = JColors.accent.withValues(alpha: .85),
    );
    _glow(c, const Offset(120, 194), 65, JColors.accent, intensity: .15);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(76, 168, 68, 50),
        const Radius.circular(9),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [JColors.glow, JColors.raised, JColors.ink],
        ).createShader(const Rect.fromLTWH(76, 168, 68, 50)),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(94, 156, 31, 20),
        const Radius.circular(7),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = JColors.onDarkMuted,
    );
    c.drawLine(
      const Offset(82, 179),
      const Offset(137, 179),
      Paint()
        ..color = JColors.accent.withValues(alpha: .6)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_CaseScenePainter old) => variant != old.variant;
}
