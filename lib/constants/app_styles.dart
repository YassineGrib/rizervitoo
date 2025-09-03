import 'package:flutter/material.dart';

/// Application-wide style constants for consistent UI design
class AppStyles {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF4CAF50);
  static const Color darkSecondaryColor = Color(0xFF42A5F5);
  static const Color darkTextPrimaryColor = Color(0xFFE1E1E1);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2D2D2D);
  
  // AppBar Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle appBarTitleStyleDark = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkTextPrimaryColor,
  );
  
  // Page Title Styles (for content within screens)
  static const TextStyle pageTitleStyle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static const TextStyle sectionTitleStyle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  // Body Text Styles
  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16,
    color: textPrimaryColor,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14,
    color: Colors.grey,
  );
  
  // Button Text Styles
  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  // AppBar Themes
  static AppBarTheme get primaryAppBarTheme => const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: appBarTitleStyle,
  );
  
  static AppBarTheme get lightAppBarTheme => const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: textPrimaryColor,
    elevation: 1,
    centerTitle: false,
    titleTextStyle: appBarTitleStyleDark,
  );
  
  // Theme Data for Light and Dark modes
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: primaryAppBarTheme,
    cardColor: Colors.white,
    textTheme: const TextTheme(
      headlineLarge: pageTitleStyle,
      headlineMedium: sectionTitleStyle,
      bodyLarge: bodyTextStyle,
      bodyMedium: subtitleStyle,
    ),
    fontFamily: 'Tajawal',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
  );
  
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkTextPrimaryColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: appBarTitleStyleDark,
    ),
    cardColor: darkCardColor,
    textTheme: TextTheme(
      headlineLarge: pageTitleStyle.copyWith(color: darkTextPrimaryColor),
      headlineMedium: sectionTitleStyle.copyWith(color: darkTextPrimaryColor),
      bodyLarge: bodyTextStyle.copyWith(color: darkTextPrimaryColor),
      bodyMedium: subtitleStyle.copyWith(color: Colors.grey[400]),
    ),
    fontFamily: 'Tajawal',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
    ),
  );
}