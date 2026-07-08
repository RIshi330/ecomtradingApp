import 'package:flutter/material.dart';

/// Color tokens copied 1:1 from the `tailwind.config` blocks that appear in
/// all four source HTML files (they share the same "Serene" teal palette).
class AppColors {
  AppColors._();

  static const background = Color(0xFFF9F9F9);
  static const outlineVariant = Color(0xFFBDC9C8);
  static const onTertiaryFixedVariant = Color(0xFF454747);
  static const surface = Color(0xFFF9F9F9);
  static const onTertiaryContainer = Color(0xFFFAFAF9);
  static const surfaceDim = Color(0xFFDADAD9);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF93000A);
  static const error = Color(0xFFBA1A1A);
  static const secondaryFixedDim = Color(0xFF95D1D1);
  static const onSecondary = Color(0xFFFFFFFF);
  static const statusPr = Color(0xFF6750A4);
  static const surfaceVariant = Color(0xFFE2E2E2);
  static const secondary = Color(0xFF296767);
  static const tertiaryFixed = Color(0xFFE2E2E1);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSecondaryFixed = Color(0xFF002020);
  static const errorContainer = Color(0xFFFFDAD6);
  static const secondaryContainer = Color(0xFFB0EEED);
  static const onBackground = Color(0xFF1A1C1C);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFF595B5A);
  static const onSecondaryContainer = Color(0xFF306E6D);
  static const primary = Color(0xFF006565);
  static const onPrimary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF727372);
  static const surfaceBright = Color(0xFFF9F9F9);
  static const surfaceTint = Color(0xFF006A6A);
  static const surfaceContainerHighest = Color(0xFFE2E2E2);
  static const inversePrimary = Color(0xFF76D6D5);
  static const inverseOnSurface = Color(0xFFF1F1F0);
  static const primaryContainer = Color(0xFF008080);
  static const outline = Color(0xFF6E7979);
  static const onPrimaryFixed = Color(0xFF002020);
  static const primaryFixed = Color(0xFF93F2F2);
  static const statusNegotiation = Color(0xFFB45309);
  static const onSecondaryFixedVariant = Color(0xFF064F4F);
  static const containerTeal = Color(0xFFE3FFFE);
  static const primaryFixedDim = Color(0xFF76D6D5);
  static const onTertiaryFixed = Color(0xFF1A1C1C);
  static const surfaceContainerLow = Color(0xFFF4F3F3);
  static const onSurface = Color(0xFF1A1C1C);
  static const inverseSurface = Color(0xFF2F3131);
  static const tertiaryFixedDim = Color(0xFFC6C6C6);
  static const onSurfaceVariant = Color(0xFF3E4949);
  static const surfaceContainerHigh = Color(0xFFE8E8E8);
  static const onPrimaryContainer = Color(0xFFE3FFFE);
  static const surfaceContainer = Color(0xFFEEEEED);
  static const onPrimaryFixedVariant = Color(0xFF004F4F);
  static const secondaryFixed = Color(0xFFB0EEED);
}

/// Spacing tokens (`spacing` block in the Tailwind config).
class AppSpacing {
  AppSpacing._();

  static const double unit = 4;
  static const double stackSm = 8;
  static const double stackMd = 16;
  static const double stackLg = 32;
  static const double gutter = 24;
  static const double marginMobile = 16;
  static const double marginDesktop = 40;
}

/// Radii tokens (`borderRadius` block in the Tailwind config).
class AppRadius {
  AppRadius._();

  static const double sm = 2;
  static const double lg = 4;
  static const double xl = 8;
  static const double full = 12;
}

/// Simple responsive breakpoint helper (Tailwind's `md` breakpoint == 768).
class Breakpoints {
  Breakpoints._();
  static const double md = 768;
  static const double lg = 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= md;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= lg;
}
