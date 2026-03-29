import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  static const _bg = Color(0xFF0A0A12);
  static const _surface = Color(0xFF12121F);
  static const _cyan = Color(0xFF06B6D4);
  static const _purple = Color(0xFF8B5CF6);
  static const _neonGreen = Color(0xFF22D3EE);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        primaryColor: _cyan,
        colorScheme: const ColorScheme.dark(
          primary: _cyan,
          secondary: _purple,
          surface: _surface,
        ),
        textTheme: GoogleFonts.tajawalTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );

  // Neon glow box decoration
  static BoxDecoration neonCard({Color color = _cyan, double opacity = 0.08}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xFF12121F),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Gradient for buttons
  static const neonGradient = LinearGradient(
    colors: [_cyan, _purple],
  );
}
