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
  static const Color backgroundColor = Colors.white70;
  static const Color surfaceColor =
      Color.fromARGB(255, 201, 200, 202); // Light lavender-grey
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
  static String getFontFamilyFromLocale(Locale locale) {
    // Example: return different font for Arabic
    if (locale.languageCode == 'ar') {
      return 'IBMPlexSansArabic'; // Replace with your Arabic font family
    }
    return 'SFProDisplay'; // Replace with your default font family
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color.fromARGB(255, 217, 214, 214),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 12,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textColor.withOpacity(0.5),
      selectedIconTheme: const IconThemeData(
        size: 26,
        color: AppTheme.primaryColor,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24,
        color: AppTheme.textColor.withOpacity(0.5),
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fallbackFontFamily,
        color: AppTheme.primaryColor,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: AppTheme.fallbackFontFamily,
        color: AppTheme.textColor.withOpacity(0.5),
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
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
        fontFamily: 'SFProDisplay',
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'SFProDisplay',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'SFProDisplay',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'SFProDisplay',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'SFProDisplay',
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 12,
      selectedItemColor: AppTheme.secondaryColor,
      unselectedItemColor: Colors.white60,
      selectedIconTheme: const IconThemeData(
        size: 26,
        color: AppTheme.secondaryColor,
      ),
      unselectedIconTheme: const IconThemeData(
        size: 24,
        color: Colors.white60,
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fallbackFontFamily,
        color: AppTheme.secondaryColor,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: AppTheme.fallbackFontFamily,
        color: Colors.white.withOpacity(0.6),
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
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
        fontFamily: 'SFProDisplay',
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'SFProDisplay',
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'SFProDisplay',
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'SFProDisplay',
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'SFProDisplay',
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
  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String _getFont(BuildContext context) =>
      AppTheme.getFontFamilyFromLocale(Localizations.localeOf(context));

  // Display Styles
  static TextStyle displayLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  static TextStyle displayMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  static TextStyle displaySmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  static TextStyle headlineMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  static TextStyle headlineSmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  // Title Styles
  static TextStyle titleLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  static TextStyle titleMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  static TextStyle titleSmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.3,
      );

  // Body Styles
  static TextStyle bodyLarge(BuildContext context, {Color? color}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.6 : 1.4,
      );

  static TextStyle bodyMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.6 : 1.4,
      );

  static TextStyle bodySmall(BuildContext context, {Color? color}) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.6 : 1.4,
      );

  // Label Styles
  static TextStyle labelLarge(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  static TextStyle labelMedium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  static TextStyle labelSmall(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );

  // Button & Caption
  static TextStyle button(BuildContext context, {Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: _getFont(context),
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle caption(BuildContext context, {Color? color}) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: _getFont(context),
        color: color,
        height: _isArabic(context) ? 1.4 : 1.2,
      );
}
