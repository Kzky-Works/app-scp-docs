import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ダーク専用。背景 #000000 / テキスト #FFFFFF / アクセント #C0C0C0
class ScpReaderTheme {
  ScpReaderTheme._();

  static const Color background = Color(0xFF000000);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFC0C0C0);

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: background,
        onSurface: onBackground,
        primary: accent,
        onPrimary: background,
        secondary: accent,
        onSecondary: background,
        surfaceContainerHighest: Color(0xFF141414),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0A0A0A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: accent, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: accent, thickness: 1),
    );

    return base.copyWith(
      textTheme: GoogleFonts.notoSansJpTextTheme(base.textTheme).apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
    );
  }
}
