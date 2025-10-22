// lib/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // --- DEFINE COLORS ---
  static const Color primary = Color(0xFF8b5cf6); // Vibrant Purple for accents
  static const Color background = Color(0xFF0f0f16); // Very dark, near-black background
  static const Color surface = Color(0xFF13131b); // Slightly elevated dark color for cards/bars
  static final Color text = Colors.grey[200]!;

  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primary, // Use primary purple for secondary accents as well
      surface: surface,
      background: background,
      error: Colors.red[400]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: text,
      onBackground: text,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: surface, // Same as bottom nav bar
      elevation: 0,
      toolbarHeight: 80.0, // Increased top space for the app bar
      titleTextStyle: TextStyle(color: text, fontSize: 22, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: primary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shadowColor: primary.withOpacity(0.3),
        elevation: 8,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary, // Use full vibrant purple
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      selectedIconTheme: IconThemeData(
        color: primary, // Use full vibrant purple
        shadows: [ Shadow( color: primary.withOpacity(0.5), blurRadius: 15.0) ],
      ),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primary.withOpacity(0.6), width: 1), // Added purple border
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
  );
}