import 'package:flutter/material.dart';

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

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const feature = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppSizes {
  static const minTouchTarget = 44.0;
  static const primaryButtonHeight = 54.0;
  static const compactBreakpoint = 360.0;
  static const expandedBreakpoint = 600.0;
  static const maxContentWidth = 560.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
}

abstract final class AppTypography {
  static const display = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 42,
    height: .98,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.1,
  );
  static const headline = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 30,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -.55,
  );
  static const title = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.15,
  );
  static const body = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );
  static const label = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const editorialTitle = TextStyle(
    fontFamily: 'SourceSerif4',
    fontSize: 28,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -.4,
  );
}
