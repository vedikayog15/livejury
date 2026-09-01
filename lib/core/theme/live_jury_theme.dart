import 'package:flutter/material.dart';

import '../design/design_tokens.dart';

/// Refined Emerald semantic palette extracted from the supplied Stitch project.
abstract final class AppColors {
  static const surfaceLowest = Color(0xFF0C0F0E);
  static const canvas = Color(0xFF111413);
  static const surfaceLow = Color(0xFF191C1B);
  static const surface = Color(0xFF1D201F);
  static const surfaceHigh = Color(0xFF272B29);
  static const surfaceHighest = Color(0xFF323534);

  static const primary = Color(0xFF95D3BA);
  static const primaryPressed = Color(0xFF80BEA6);
  static const primaryContainer = Color(0xFF064E3B);
  static const onPrimary = Color(0xFF003829);
  static const textPrimary = Color(0xFFE1E3E1);
  static const textSecondary = Color(0xFFBFC9C3);
  static const outline = Color(0xFF404944);
  static const outlineStrong = Color(0xFF89938D);
  static const urgent = Color(0xFFFFB4A3);
  static const urgentContainer = Color(0xFF871800);
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);
  static const secondary = Color(0xFFFFB1C2);
  static const warning = Color(0xFFE7C374);
  static const shadow = Color(0x70000000);

  // Compatibility aliases for the existing, working feature layer.
  static const ink = surfaceLowest;
  static const surfaceAlt = surfaceLow;
  static const surfaceRaised = surfaceHigh;
  static const primarySoft = primaryPressed;
  static const positive = primary;
  static const negative = error;
  static const highlight = primary;
  static const navy = canvas;
  static const navySoft = surface;
  static const cream = textPrimary;
  static const gold = primary;
  static const teal = primary;
  static const burgundy = urgent;
  static const muted = textSecondary;
}

abstract final class LiveJuryTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF541D2D),
      tertiary: AppColors.urgent,
      onTertiary: Color(0xFF630F00),
      error: AppColors.error,
      onError: Color(0xFF690005),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outline,
      shadow: AppColors.shadow,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'Jost',
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTypography.display.copyWith(
          fontSize: 52,
          color: AppColors.textPrimary,
        ),
        headlineLarge: AppTypography.headline.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineMedium: AppTypography.editorialTitle.copyWith(
          color: AppColors.textPrimary,
        ),
        titleLarge: AppTypography.title.copyWith(
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        titleMedium: AppTypography.title.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyLarge: AppTypography.body.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.body.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: AppTypography.label.copyWith(color: AppColors.textPrimary),
        labelMedium: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 15,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: .65),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(AppSizes.primaryButtonHeight),
          ),
          foregroundColor: const WidgetStatePropertyAll(AppColors.onPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.surfaceHighest;
            }
            return states.contains(WidgetState.pressed)
                ? AppColors.primaryPressed
                : AppColors.primary;
          }),
          overlayColor: const WidgetStatePropertyAll(Color(0x18000000)),
          elevation: const WidgetStatePropertyAll(0),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.input),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Jost',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: .15,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
          textStyle: AppTypography.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: AppTypography.label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceLow,
        selectedColor: AppColors.primaryContainer,
        labelStyle: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
        ),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.outlineStrong,
        modalElevation: 0,
        shadowColor: AppColors.shadow,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHighest,
        contentTextStyle: AppTypography.body.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.input),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceHighest,
        circularTrackColor: AppColors.surfaceHighest,
      ),
    );
  }

  static ThemeData light() => dark();
}
