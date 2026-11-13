import 'package:flutter/material.dart';

/// Palet warna "Tactile Financial Ledger" (Anti-AI-Slop).
/// Tanpa gradien neon; menggunakan permukaan kertas hangat di Light Mode
/// dan permukaan karbon slate tegas di Dark Mode.
class AppColors {
  AppColors._();

  // ======================== LIGHT MODE TOKENS ========================
  static const Color lightBackground = Color(0xFFF7F6F2); // Warm Alabaster
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceSecondary = Color(0xFFEFECE6); // Soft Stone
  static const Color lightBorder = Color(0xFFE4E2DD); // 1px Crisp Border
  static const Color lightTextPrimary = Color(0xFF141518); // Deep Ink
  static const Color lightTextSecondary = Color(0xFF686B73); // Slate Grey
  static const Color lightAccentPrimary = Color(0xFF0F5247); // Deep Forest Teal

  // Semantic Light
  static const Color lightPositive = Color(0xFF0D7A5F); // Emerald Ink (Pemasukan / Piutang)
  static const Color lightPositiveBg = Color(0xFFECFDF5);
  static const Color lightNegative = Color(0xFFC83349); // Crimson Terra (Pengeluaran / Hutang)
  static const Color lightNegativeBg = Color(0xFFFFF1F2);
  static const Color lightMutation = Color(0xFF1D4ED8); // Ledger Blue (Transfer / Pelunasan)
  static const Color lightMutationBg = Color(0xFFEFF6FF);
  static const Color lightWarning = Color(0xFFB45309); // Amber Ochre (LATE / Rem Piutang)
  static const Color lightWarningBg = Color(0xFFFEF3C7);

  // ======================== DARK MODE TOKENS ========================
  static const Color darkBackground = Color(0xFF0E1014); // Carbon Slate
  static const Color darkSurface = Color(0xFF161920); // Elevated Slate
  static const Color darkSurfaceSecondary = Color(0xFF1F242D); // Muted Slate
  static const Color darkBorder = Color(0xFF282E3A); // 1px Dark Border
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // Crisp White
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Cool Grey
  static const Color darkAccentPrimary = Color(0xFF2DD4BF); // Mint Teal

  // Semantic Dark
  static const Color darkPositive = Color(0xFF34D399); // Emerald Light
  static const Color darkPositiveBg = Color(0xFF064E3B);
  static const Color darkNegative = Color(0xFFFB7185); // Rose Light
  static const Color darkNegativeBg = Color(0xFF4C0519);
  static const Color darkMutation = Color(0xFF60A5FA); // Sky Blue
  static const Color darkMutationBg = Color(0xFF1E3A8A);
  static const Color darkWarning = Color(0xFFFBBF24); // Warm Amber
  static const Color darkWarningBg = Color(0xFF451A03);

  // ======================== CONTEXT HELPERS ========================
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color surfaceSecondary(BuildContext context) =>
      isDark(context) ? darkSurfaceSecondary : lightSurfaceSecondary;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color accent(BuildContext context) =>
      isDark(context) ? darkAccentPrimary : lightAccentPrimary;

  static Color positive(BuildContext context) =>
      isDark(context) ? darkPositive : lightPositive;

  static Color positiveBg(BuildContext context) =>
      isDark(context) ? darkPositiveBg : lightPositiveBg;

  static Color negative(BuildContext context) =>
      isDark(context) ? darkNegative : lightNegative;

  static Color negativeBg(BuildContext context) =>
      isDark(context) ? darkNegativeBg : lightNegativeBg;

  static Color mutation(BuildContext context) =>
      isDark(context) ? darkMutation : lightMutation;

  static Color mutationBg(BuildContext context) =>
      isDark(context) ? darkMutationBg : lightMutationBg;

  static Color warning(BuildContext context) =>
      isDark(context) ? darkWarning : lightWarning;

  static Color warningBg(BuildContext context) =>
      isDark(context) ? darkWarningBg : lightWarningBg;
}

