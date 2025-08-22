import 'package:flutter/material.dart';

/// Application-wide style constants for consistent UI design
class AppStyles {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
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
    color: textPrimaryColor,
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
}