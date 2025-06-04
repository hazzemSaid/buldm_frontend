// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(
    0xFF7C54E2,
  ); // Updated to match logo purple
  static const Color secondaryColor = Color(
    0xFFB8A9F1,
  ); // Soft lavender variant
  static const Color accentColor = Color(0xFFA683E3); // Light purple accent
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color surfaceColor = Color(0xFFF4F2FA); // Light lavender-grey
  static const Color textColor = Color(0xFF212529); // Dark grey

  static const background = Color(0xFF111112); // Light lavender-grey background

  // Font families
  static const String arabicFontFamily = 'IBMPlexSansArabic';
  static const String englishFontFamily = 'SFProDisplay';
  static const String fallbackFontFamily = 'Roboto';

  // Helper method to detect Arabic text
  static bool _isArabicText(String text) {
    return RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(text);
  }

  // Helper method to get appropriate font family
  static String _getFontFamily(String? text) {
    if (text == null || text.isEmpty) return englishFontFamily;
    return _isArabicText(text) ? arabicFontFamily : englishFontFamily;
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: textColor,
      onSurface: textColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: primaryColor, size: 24),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: primaryColor, size: 24),
  );
}

class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge({String? text, Color? color}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  static TextStyle displayMedium({String? text, Color? color}) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  static TextStyle displaySmall({String? text, Color? color}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  // Headline Styles
  static TextStyle headlineLarge({String? text, Color? color}) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  static TextStyle headlineMedium({String? text, Color? color}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  static TextStyle headlineSmall({String? text, Color? color}) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  // Title Styles
  static TextStyle titleLarge({String? text, Color? color}) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  static TextStyle titleMedium({String? text, Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  static TextStyle titleSmall({String? text, Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.3,
  );

  // Body Styles
  static TextStyle bodyLarge({String? text, Color? color}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.6 : 1.4,
  );

  static TextStyle bodyMedium({String? text, Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.6 : 1.4,
  );

  static TextStyle bodySmall({String? text, Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.6 : 1.4,
  );

  // Label Styles
  static TextStyle labelLarge({String? text, Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  static TextStyle labelMedium({String? text, Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  static TextStyle labelSmall({String? text, Color? color}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );

  // Special Purpose Styles
  static TextStyle button({String? text, Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    letterSpacing: 0.5,
  );

  static TextStyle caption({String? text, Color? color}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: AppTheme._getFontFamily(text),
    color: color,
    height: AppTheme._isArabicText(text ?? '') ? 1.4 : 1.2,
  );
}
