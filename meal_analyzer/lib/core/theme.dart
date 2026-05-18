import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF2E7D32); // deep green
  static const Color primaryLight   = Color(0xFF4CAF50); // medium green
  static const Color accent         = Color(0xFFFF6F00); // warm orange
  static const Color background     = Color(0xFFF5F5F0); // warm off-white
  static const Color surface        = Colors.white;

  static const Color proteinColor   = Color(0xFF1565C0); // blue
  static const Color carbsColor     = Color(0xFFE65100); // deep orange
  static const Color fatColor       = Color(0xFFC62828); // deep red

  static const Color successBg      = Color(0xFFF0F7F0);
  static const Color successText    = Color(0xFF2E7D32);
  static const Color cardShadow     = Color(0x0F000000);

  // ── Text Styles ───────────────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF555555),
        height: 1.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF888888),
      );

  static TextStyle get calorieBadge => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  // ── Reusable Decorations ──────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get imagePlaceholderDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          background: background,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      );
}