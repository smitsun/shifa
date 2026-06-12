import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant colors for premium design
  static const Color primaryLight = Color(0xFF4F46E5);    // Indigo
  static const Color secondaryLight = Color(0xFF06B6D4);  // Cyan
  static const Color bgLight = Color(0xFFF3F4F6);
  static const Color cardLight = Colors.white;

  static const Color primaryDark = Color(0xFF6366F1);     // Bright Indigo
  static const Color secondaryDark = Color(0xFF22D3EE);   // Cyan
  static const Color bgDark = Color(0xFF090D16);          // Dark Navy/Slate
  static const Color cardDark = Color(0xFF111827);        // Deep Grey

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        background: bgLight,
        surface: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF111827),
        onSurface: Color(0xFF111827),
      ),
      scaffoldBackgroundColor: bgLight,
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111827),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: const Color(0xFF4B5563),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF6B7280),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        background: bgDark,
        surface: cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Color(0xFFF9FAFB),
        onSurface: Color(0xFFF9FAFB),
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF9FAFB),
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF9FAFB),
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: const Color(0xFFD1D5DB),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFF9FAFB),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
