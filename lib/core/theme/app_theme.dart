import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF3366FF);
  static const primaryDark = Color(0xFF1A3FA8);
  static const accent = Color(0xFF00CCFF);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Gold / finance
  static const gold = Color(0xFFF59E0B);
  static const goldLight = Color(0xFFFFF3CD);

  // Neutral — Light
  static const lightBackground = Color(0xFFF0F4FF);
  static const lightSurface = Colors.white;
  static const lightOnBackground = Color(0xFF1A202C);
  static const lightOnSurface = Color(0xFF1A202C);

  // Neutral — Dark
  static const darkBackground = Color(0xFF0F0F1A);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkOnBackground = Color(0xFFE2E8F0);
  static const darkOnSurface = Color(0xFFE2E8F0);

  // Aliases (backward compat)
  static const background = lightBackground;
  static const surface = lightSurface;
  static const textPrimary = lightOnBackground;
  static const textSecondary = Color(0xFF718096);
  static const divider = Color(0xFFE2E8F0);
  static const brandBlue = primary;
  static const brandCyan = accent;

  // Gradients
  static const List<Color> primaryGradient = [primary, accent];
  static const List<Color> darkGradient = [Color(0xFF1A1A2E), Color(0xFF16213E)];
}

ThemeData buildAppTheme([ThemeMode mode = ThemeMode.system]) {
  final isDark = mode == ThemeMode.dark;

  final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
  final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
  final onBg = isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
  final dividerColor = isDark ? const Color(0xFF2D3748) : AppColors.divider;

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: bg,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: surface,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: onBg,
      displayColor: onBg,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: onBg,
      contentTextStyle: TextStyle(color: bg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    dividerColor: dividerColor,
    dividerTheme: DividerThemeData(color: dividerColor),
    listTileTheme: ListTileThemeData(
      textColor: onBg,
      iconColor: onBg,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: TextStyle(color: onBg.withValues(alpha: 0.5)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.poppins(fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

