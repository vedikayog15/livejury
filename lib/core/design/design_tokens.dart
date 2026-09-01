import 'package:flutter/material.dart';

/// Primitive spacing values. All layout decisions use this 4dp rhythm.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const section = 36.0;
}

/// Primitive corner values, promoted into semantic component shapes below.
abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const dock = 28.0;

  static const card = BorderRadius.all(Radius.circular(xl));
  static const feature = BorderRadius.all(Radius.circular(xxl));
  static const input = BorderRadius.all(Radius.circular(lg));
}

abstract final class AppSizes {
  static const minTouchTarget = 48.0;
  static const primaryButtonHeight = 54.0;
  static const compactBreakpoint = 360.0;
  static const expandedBreakpoint = 600.0;
  static const maxContentWidth = 560.0;

  static const iconSm = 18.0;
  static const iconMd = 22.0;
  static const iconLg = 28.0;
}

abstract final class AppElevation {
  static const none = <BoxShadow>[];
  static const level1 = <BoxShadow>[
    BoxShadow(color: Color(0x52000000), blurRadius: 18, offset: Offset(0, 8)),
  ];
  static const level2 = <BoxShadow>[
    BoxShadow(color: Color(0x70000000), blurRadius: 30, offset: Offset(0, 14)),
  ];
  static const glowPrimary = <BoxShadow>[
    BoxShadow(color: Color(0x3095D3BA), blurRadius: 22),
  ];
  static const glowUrgent = <BoxShadow>[
    BoxShadow(color: Color(0x30FFB4A3), blurRadius: 18),
  ];
}

abstract final class AppShadowColor {
  static const tint = Color(0x52000000);
}

abstract final class AppOpacity {
  static const disabled = 0.38;
  static const pressedOverlay = 0.10;
  static const scrim = 0.72;
}

abstract final class AppMotion {
  static const micro = Duration(milliseconds: 110);
  static const fast = Duration(milliseconds: 170);
  static const standard = Duration(milliseconds: 260);
  static const staggerStep = Duration(milliseconds: 36);

  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
  static const pressScale = 0.98;
}

/// Component-ready type roles based on the Stitch Bodoni Moda + Jost pairing.
abstract final class AppTypography {
  static const display = TextStyle(
    fontFamily: 'BodoniModa',
    fontSize: 46,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.1,
  );
  static const headline = TextStyle(
    fontFamily: 'BodoniModa',
    fontSize: 32,
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -.55,
  );
  static const editorialTitle = TextStyle(
    fontFamily: 'BodoniModa',
    fontSize: 28,
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -.4,
  );
  static const title = TextStyle(
    fontFamily: 'Jost',
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -.1,
  );
  static const body = TextStyle(
    fontFamily: 'Jost',
    fontSize: 16,
    height: 1.55,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontFamily: 'Jost',
    fontSize: 13,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: .2,
  );
  static const caption = TextStyle(
    fontFamily: 'Jost',
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );
  static const overline = TextStyle(
    fontFamily: 'Jost',
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );
}
