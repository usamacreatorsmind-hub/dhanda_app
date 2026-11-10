import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized, low-saturation SaaS design tokens and Material 3 theme
/// for Dhanda App. Uses soft porcelain surfaces, crisp 1px hairlines,
/// and muted slate-indigo accents instead of harsh dark or neon tones.
class AppTheme {
  // Brand & Accent Tokens (Muted Slate Indigo + Warm Sand)
  static const Color primaryColor = Color(0xFF4A5899);
  static const Color primaryLight = Color(0xFF6674B3);
  static const Color primaryDark = Color(0xFF39447A);
  static const Color primarySoft = Color(0xFFEEF1F8);
  static const Color primaryBorder = Color(0xFFD6DDF0);

  static const Color secondaryColor = Color(0xFF9A5934);
  static const Color secondarySoft = Color(0xFFFAF2EC);

  // Neutral Surface & Border Tokens
  static const Color backgroundColor = Color(0xFFF7F8FB);
  static const Color cardColor = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F3F8);
  static const Color borderColor = Color(0xFFE6E9F0);
  static const Color dividerColor = Color(0xFFECEFF5);

  // Ink / Typography Tokens
  static const Color textPrimary = Color(0xFF181D27);
  static const Color textSecondary = Color(0xFF5A6475);
  static const Color textMuted = Color(0xFF6E7787);

  // Muted Semantic Status Tokens
  static const Color success = Color(0xFF2B7A5B);
  static const Color successSoft = Color(0xFFECF6F1);
  static const Color successBorder = Color(0xFFCBE6DA);

  static const Color warning = Color(0xFF9E5A1F);
  static const Color warningSoft = Color(0xFFFDF3EA);
  static const Color warningBorder = Color(0xFFF2DBC4);

  static const Color danger = Color(0xFFB34040);
  static const Color dangerSoft = Color(0xFFFDF0F0);
  static const Color dangerBorder = Color(0xFFF3D0D0);

  static const Color gold = Color(0xFFC99233);

  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primarySoft,
      onPrimaryContainer: primaryDark,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: secondarySoft,
      surface: cardColor,
      onSurface: textPrimary,
      error: danger,
      outline: borderColor,
      outlineVariant: dividerColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: lightStatusBar,
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: primaryBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return const Color(0xFFD5DBE6);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primarySoft,
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14.5,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF232936),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
