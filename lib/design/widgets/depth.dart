import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens.dart';

/// Colour recipes for raised icon tiles. These match the `.icon` variants in
/// website/assets/css/site.css so the app, web app and website read as one
/// system: a light-to-dark body, a cast shadow in the tile's own hue, and a
/// glyph colour that stays legible on it.
enum DepthTone {
  violet(
    Color(0xFF8A78E6),
    Color(0xFF4A3B98),
    Color(0x8C6554B8),
    JColors.surface,
  ),
  apricot(Color(0xFFFFE0C4), Color(0xFFE59A62), Color(0x8CE59A62), JColors.ink),
  night(
    Color(0xFF3A4170),
    Color(0xFF0D1022),
    Color(0x99101426),
    JColors.accent,
  ),
  forest(
    Color(0xFF4FAE8A),
    Color(0xFF1D4D3C),
    Color(0x80286650),
    JColors.surface,
  ),
  clay(
    Color(0xFFE27A6E),
    Color(0xFF8C2F2A),
    Color(0x80A73D37),
    JColors.surface,
  ),
  glow(Color(0xFFD6CCFF), Color(0xFF8F7FD6), Color(0x808F7FD6), JColors.ink);

  const DepthTone(this.light, this.dark, this.cast, this.ink);
  final Color light, dark, cast, ink;
  bool get _lightBody => ink == JColors.ink;
}

/// Layered shadows: a tight contact shadow, a soft mid shadow and a wide
/// ambient one. A single blur reads as flat; three read as distance.
abstract final class JDepth {
  static const card = [
    BoxShadow(color: Color(0x0F101426), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x1F101426),
      blurRadius: 21,
      spreadRadius: -8,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x2E101426),
      blurRadius: 42,
      spreadRadius: -24,
      offset: Offset(0, 24),
    ),
  ];
  static const lifted = [
    BoxShadow(color: Color(0x14101426), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(
      color: Color(0x33101426),
      blurRadius: 28,
      spreadRadius: -10,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x596554B8),
      blurRadius: 56,
      spreadRadius: -32,
      offset: Offset(0, 40),
    ),
  ];
  static const onDark = [
    BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 52,
      spreadRadius: -30,
      offset: Offset(0, 30),
    ),
  ];

  static Duration motion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 320);
}

/// Tells [DepthIcon]s inside a [HoverLift] that the pointer is over the card,
/// so the whole card responds as one object.
class LiftScope extends InheritedWidget {
  const LiftScope({super.key, required this.hovered, required super.child});
  final bool hovered;
  static bool hoveredOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LiftScope>()?.hovered ?? false;
  @override
  bool updateShouldNotify(LiftScope oldWidget) => oldWidget.hovered != hovered;
}

/// Raises a card slightly while a pointer rests on it. Touch screens never
/// hover, so on a phone this is inert and the resting design is the design.
class HoverLift extends StatefulWidget {
  const HoverLift({super.key, required this.child, this.distance = 4});
  final Widget child;
  final double distance;
  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedContainer(
      duration: JDepth.motion(context),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(
        0,
        hovered ? -widget.distance : 0,
        0,
      ),
      child: LiftScope(hovered: hovered, child: widget.child),
    ),
  );
}

/// An icon on a raised, glossy tile: the app's version of the website's
/// depth icons. It rests with a slight 3D tilt and straightens on hover.
class DepthIcon extends StatefulWidget {
  const DepthIcon(
    this.icon, {
    super.key,
    this.tone = DepthTone.violet,
    this.size = 48,
    this.tilt = true,
  });
  final IconData icon;
  final DepthTone tone;
  final double size;
  final bool tilt;
  @override
  State<DepthIcon> createState() => _DepthIconState();
}

class _DepthIconState extends State<DepthIcon> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size, tone = widget.tone;
    final radius = s * .3;
    final raised = hovered || LiftScope.hoveredOf(context);
    final tile = Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: const Alignment(-.6, -1),
          end: const Alignment(.6, 1),
          colors: [tone.light, tone.dark],
        ),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2E101426),
            blurRadius: 3,
            offset: Offset(0, s * .03),
          ),
          BoxShadow(
            color: tone.cast,
            blurRadius: s * .32,
            spreadRadius: -s * .12,
            offset: Offset(0, s * .19),
          ),
          BoxShadow(
            color: const Color(0x59101426),
            blurRadius: s * .5,
            spreadRadius: -s * .3,
            offset: Offset(0, s * .42),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The lower edge sits in shadow, like an inset bevel.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0x47000000),
                  ],
                  stops: [0, .55, 1],
                ),
              ),
            ),
            // Gloss across the top half, curving where it meets the body.
            Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: .52,
                widthFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(s * .5, s * .16),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x61FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),
            // Specular line along the top edge.
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 1.2, color: const Color(0x73FFFFFF)),
            ),
            Center(
              child: Icon(
                widget.icon,
                size: s * .46,
                color: tone.ink,
                // A drop shadow below and a light edge above make the glyph
                // read as embossed into the tile.
                shadows: [
                  Shadow(
                    color: tone._lightBody
                        ? const Color(0x59783C14)
                        : const Color(0x59000000),
                    offset: Offset(0, s * .03),
                    blurRadius: s * .03,
                  ),
                  Shadow(
                    color: tone._lightBody
                        ? const Color(0x99FFFFFF)
                        : const Color(0x40FFFFFF),
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.tilt && !raised ? 1 : 0),
        duration: JDepth.motion(context),
        curve: Curves.easeOutCubic,
        child: tile,
        builder: (context, t, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0018)
            ..translateByDouble(0, raised ? -s * .06 * (1 - t) : 0, 0, 1)
            ..rotateX(-10 * math.pi / 180 * t)
            ..rotateY(-8 * math.pi / 180 * t),
          child: child,
        ),
      ),
    );
  }
}

/// A primary action with a bevelled gradient face and a glow in its own
/// colour, matching the website's buttons.
class DepthButtonFace extends StatelessWidget {
  const DepthButtonFace({
    super.key,
    required this.enabled,
    required this.apricot,
    required this.hovered,
    required this.child,
  });
  final bool enabled, apricot, hovered;
  final Widget child;
  static const _violet = [Color(0xFF8A78E6), JColors.brand, Color(0xFF4A3B98)];
  static const _apricot = [
    Color(0xFFFFE2C8),
    JColors.accent,
    Color(0xFFEEB88D),
  ];
  @override
  Widget build(BuildContext context) {
    final glow = apricot ? const Color(0x99F5CAA5) : const Color(0x8C6554B8);
    return AnimatedContainer(
      duration: JDepth.motion(context),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, enabled && hovered ? -2 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: enabled
            ? null
            : (apricot ? JColors.raised : const Color(0x1F101426)),
        gradient: enabled
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: apricot ? _apricot : _violet,
                stops: const [0, .45, 1],
              )
            : null,
        boxShadow: enabled
            ? [
                const BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: glow,
                  blurRadius: hovered ? 28 : 21,
                  spreadRadius: -8,
                  offset: Offset(0, hovered ? 16 : 10),
                ),
              ]
            : null,
        border: enabled ? Border.all(color: const Color(0x2EFFFFFF)) : null,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Gloss on the upper face and a darker lip at the bottom: the
          // website's inset bevel, painted beneath the label.
          if (enabled)
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(17)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x38FFFFFF),
                        Color(0x00FFFFFF),
                        Color(0x00000000),
                        Color(0x24000000),
                      ],
                      stops: [0, .45, .78, 1],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
