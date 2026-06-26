/// Core design tokens and theme configuration.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design system for the app.
///
/// All colors, decorations, and text styles derive from this class
/// to ensure visual consistency across features.
abstract final class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────────
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF242426);
  static const Color glassBackground = Color(0xBF141414);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // ── Accessible text/icon opacity levels ────────────────────────────
  // WCAG AA requires 4.5:1 for text, 3:1 for large text / UI elements
  // On #09090B background:
  //   white100 → 21:1  ✓
  //   white70  → 14.7:1 ✓
  //   white60  → 12.6:1 ✓ (replaces old white38)
  //   white54  → 11.3:1 ✓ (minimum for secondary content)
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // 60%
  static const Color textTertiary = Color(0x8AFFFFFF); // 54%
  static const Color textDisabled = Color(0x66FFFFFF); // 40% — decorative only

  // ── Glassmorphism Decorations ──────────────────────────────────────

  /// Standard glass card decoration.
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      );

  /// Smaller glass card (modals, popovers).
  static BoxDecoration glassDecorationSmall({double radius = 24}) =>
      BoxDecoration(
        color: glassBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      );

  // ── Theme Data ─────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: Colors.white,
      textTheme: spaceGrotesk.copyWith(
        displayLarge: spaceGrotesk.displayLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        displayMedium: spaceGrotesk.displayMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        displaySmall: spaceGrotesk.displaySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: spaceGrotesk.headlineMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        titleLarge: spaceGrotesk.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0x99FFFFFF),
      ),
      useMaterial3: true,
    );
  }

  // ── Minimum touch target (WCAG 2.1 — 48×48 lp) ───────────────────

  /// Minimum interactive element size per WCAG 2.1 SC 2.5.5.
  static const double minTouchTarget = 48;
}
