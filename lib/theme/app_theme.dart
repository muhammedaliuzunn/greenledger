import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2D7A4F);
  static const Color primaryLight = Color(0xFF3A9E65);
  static const Color accent = Color(0xFFD4A017);
  static const Color background = Color(0xFFF4FAF6);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sidebarBg = Color(0xFF142B1F);
  static const Color border = Color(0xFFD4E8DC);
  static const Color muted = Color(0xFF6B8F78);
  static const Color destructive = Color(0xFFDC2626);
  static const Color chart1 = Color(0xFF2D7A4F);
  static const Color chart2 = Color(0xFFD4A017);
  static const Color chart3 = Color(0xFF0EA5E9);
  static const Color chart4 = Color(0xFF9333EA);
  static const Color chart5 = Color(0xFFEC4899);

  // Dark theme colors
  static const Color darkBg = Color(0xFF0D1A12);
  static const Color darkCard = Color(0xFF162A1C);
  static const Color darkBorder = Color(0xFF253D2D);
  static const Color darkText = Color(0xFFE8F5EE);
  static const Color darkMuted = Color(0xFF7BAD8C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: cardBg,
        error: destructive,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF0D2617),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0D2617)),
        displayMedium: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0D2617)),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0D2617)),
        titleMedium: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0D2617)),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF0D2617)),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0D2617)),
        bodySmall: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B8F78)),
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0D2617)),
        iconTheme: const IconThemeData(color: Color(0xFF0D2617)),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F7F3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: muted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primary);
          }
          return GoogleFonts.inter(fontSize: 11, color: muted);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: darkCard,
        error: destructive,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
        iconTheme: const IconThemeData(color: darkText),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.bold, color: darkText),
        displayMedium: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: darkText),
        titleMedium: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: darkText),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: darkText),
        bodyMedium: GoogleFonts.inter(fontSize: 13, color: darkText),
        bodySmall: GoogleFonts.inter(fontSize: 11, color: darkMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E3828),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: darkMuted),
        hintStyle: const TextStyle(color: darkMuted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: darkMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primary);
          }
          return GoogleFonts.inter(fontSize: 11, color: darkMuted);
        }),
      ),
    );
  }
}
