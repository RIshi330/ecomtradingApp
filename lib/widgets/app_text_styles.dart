import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Font-size tokens copied from the `fontSize` block in the Tailwind config.
/// Manrope -> display-lg / headline-lg / headline-lg-mobile / title-md
/// Inter   -> body-lg / body-sm / label-caps
class AppText {
  AppText._();

  static TextStyle displayLg({Color color = AppColors.onBackground}) =>
      GoogleFonts.manrope(
        fontSize: 48,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.onBackground}) =>
      GoogleFonts.manrope(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle headlineLgMobile({Color color = AppColors.onBackground}) =>
      GoogleFonts.manrope(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle titleMd({Color color = AppColors.onBackground}) =>
      GoogleFonts.manrope(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onBackground}) =>
      GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle labelCaps({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        fontWeight: FontWeight.w600,
        color: color,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    dividerColor: AppColors.outlineVariant,
    fontFamily: GoogleFonts.inter().fontFamily,
  );
}
