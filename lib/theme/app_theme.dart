import 'package:flutter/material.dart';

class AppTheme {
  // --- Blue & White "Travel/Modern" Palette ---
  // Primary Blue
  static const Color primaryBlue = Color(0xFF0D47A1); 
  
  // Secondary / Gradient End
  static const Color blueAccent = Color(0xFF42A5F5);

  // Background Colors
  static const Color bgLight = Color(0xFFF5F7FA); // Light Grey/Blue
  static const Color surfaceWhite = Colors.white;

  // Text Colors
  static const Color textBlack = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF757575);

  // Success/Error
  static const Color successGreen = Color(0xFF00C853);
  static const Color errorRed = Color(0xFFD32F2F);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [blueAccent, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: blueAccent,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textBlack,
        error: errorRed,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBlack),
        titleTextStyle: TextStyle(
          color: textBlack, 
          fontSize: 20, 
          fontWeight: FontWeight.bold
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        hintStyle: const TextStyle(color: textGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill shape for modern look
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textBlack),
        bodyMedium: TextStyle(color: textGrey), 
      ),
    );
  }
}
