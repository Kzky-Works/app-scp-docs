import 'dart:convert';

import 'package:flutter/material.dart';

/// 将来のスキン共有を想定し、色・フォントを JSON でやり取りしやすい形で保持する。
class AppTheme {
  const AppTheme({
    required this.primaryColorHex,
    required this.surfaceColorHex,
    required this.fontFamily,
    this.fontSizeScale = 1.0,
  });

  final String primaryColorHex;
  final String surfaceColorHex;
  final String fontFamily;
  final double fontSizeScale;

  factory AppTheme.defaults() => const AppTheme(
        primaryColorHex: '#1A237E',
        surfaceColorHex: '#FFF8E1',
        fontFamily: 'Roboto',
        fontSizeScale: 1.0,
      );

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      primaryColorHex: json['primaryColorHex'] as String? ?? '#1A237E',
      surfaceColorHex: json['surfaceColorHex'] as String? ?? '#FFF8E1',
      fontFamily: json['fontFamily'] as String? ?? 'Roboto',
      fontSizeScale: (json['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'primaryColorHex': primaryColorHex,
        'surfaceColorHex': surfaceColorHex,
        'fontFamily': fontFamily,
        'fontSizeScale': fontSizeScale,
      };

  static AppTheme fromJsonString(String source) =>
      AppTheme.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  Color _colorFromHex(String hex) {
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  ThemeData toMaterialTheme() {
    final primary = _colorFromHex(primaryColorHex);
    final surface = _colorFromHex(surfaceColorHex);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
      ),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 14 * fontSizeScale),
        bodyMedium: TextStyle(fontSize: 13 * fontSizeScale),
      ),
      useMaterial3: true,
    );
  }
}
