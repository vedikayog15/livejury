import 'package:flutter/material.dart';

abstract final class Palette {
  static const midnight = Color(0xFF101426);
  static const paper = Color(0xFFF6F5FA);
  static const white = Color(0xFFFFFFFF);
  static const apricot = Color(0xFFF5CAA5);
  static const lilac = Color(0xFFECE9F5);
  static const violet = Color(0xFF6554B8);
  static const glow = Color(0xFFA99AE3);
  static const muted = Color(0xFF646579);
  static const mist = Color(0xFFC1C3D4);
  static const rule = Color(0xFFE1DFEB);
  static const clay = Color(0xFFA73D37);
  static const forest = Color(0xFF286650);
  static const nightRaised = Color(0xFF282D49);
  static const blue = Color(0xFF9FBBCD);
}

abstract final class JColors {
  static const ink = Palette.midnight,
      canvas = Palette.paper,
      surface = Palette.white;
  static const accent = Palette.apricot, secondary = Palette.lilac;
  static const brand = Palette.violet, glow = Palette.glow, blue = Palette.blue;
  static const muted = Palette.muted,
      onDarkMuted = Palette.mist,
      border = Palette.rule;
  static const error = Palette.clay,
      success = Palette.forest,
      raised = Palette.nightRaised;
}

abstract final class JSpace {
  static const xs = 4.0,
      sm = 8.0,
      md = 12.0,
      lg = 16.0,
      xl = 24.0,
      xxl = 32.0,
      section = 40.0;
  static const maxWidth = 560.0, touch = 48.0, button = 56.0;
  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360 ? 20 : 24;
}

abstract final class JType {
  static TextStyle display([double size = 38, Color color = JColors.ink]) =>
      TextStyle(
        fontFamily: 'Outfit',
        fontSize: size,
        height: 1.12,
        letterSpacing: -size * .027,
        fontWeight: FontWeight.w500,
        color: color,
      );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.65,
    color: JColors.ink,
  );
  static const caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    height: 1.4,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w700,
  );
}
