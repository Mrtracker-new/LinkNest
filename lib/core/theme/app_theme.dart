import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = _buildTheme(Brightness.light);
  static final darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: const Color(0xFF6750A4), // Deep Purple seed
      textTheme: GoogleFonts.outfitTextTheme(
         brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
      ),
    );
    
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
