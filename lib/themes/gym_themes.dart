import 'package:flutter/material.dart';

class GymThemes {
  // Custom colors for gym theme
  static const Color primaryBlue = Color(0xFF1A237E);    // Deep, professional blue
  static const Color accentGold = Color(0xFFFFC107);     // Energetic gold
  static const Color charcoal = Color(0xFF263238);       // Dark charcoal for depth
  static const Color successGreen = Color(0xFF43A047);   // Positive action green
  static const Color errorRed = Color(0xFFD32F2F);       // Alert/error red
  static const Color surfaceGrey = Color(0xFFF5F5F5);    // Light surface grey
  static const Color textDark = Color(0xFF212121);       // Primary text
  static const Color textLight = Color(0xFFFAFAFA);      // Light text

  // Define light and dark color schemes
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    hintColor: accentGold,
    scaffoldBackgroundColor: surfaceGrey,
    appBarTheme: AppBarTheme(
      color: primaryBlue,
      titleTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: textLight,
      ),
      iconTheme: const IconThemeData(color: textLight),
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: textDark,
      ),
      displayLarge: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: primaryBlue,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: primaryBlue,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentGold,
      foregroundColor: textDark,
      elevation: 4,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerColor: Colors.grey[300],
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: accentGold,
      background: surfaceGrey,
      surface: Colors.white,
      error: errorRed,
      onPrimary: textLight,
      onSecondary: textDark,
      onBackground: textDark,
      onSurface: textDark,
      onError: textLight,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    hintColor: accentGold,
    scaffoldBackgroundColor: charcoal,
    appBarTheme: AppBarTheme(
      color: Colors.black,
      titleTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: textLight,
      ),
      iconTheme: const IconThemeData(color: textLight),
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        color: textLight,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: textLight,
      ),
      displayLarge: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: textLight,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: textLight,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentGold,
      foregroundColor: textDark,
      elevation: 4,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerColor: Colors.grey[800],
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentGold,
      background: charcoal,
      surface: Color(0xFF1E1E1E),
      error: errorRed,
      onPrimary: textLight,
      onSecondary: textDark,
      onBackground: textLight,
      onSurface: textLight,
      onError: textLight,
    ),
  );
}