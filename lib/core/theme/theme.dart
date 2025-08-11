import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

/// Typed representation of the tokens present in `design.json`.
class DesignTokens {
  final Map<String, Color> colors;
  final String fontSans;
  final String fontSerif;
  final String fontMono;
  final Map<String, double> radius;
  final Map<String, List<BoxShadow>> shadows;

  DesignTokens({
    required this.colors,
    required this.fontSans,
    required this.fontSerif,
    required this.fontMono,
    required this.radius,
    required this.shadows,
  });
}

/// Loads `design.json` and converts tokens to `ThemeData` following the
/// mild neo-brutalism style (bold borders, flat fills, subtle depth).
class ThemeLoader {
  static Future<DesignTokens> loadTokens(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final colorJson = (jsonMap['color'] as Map<String, dynamic>);
    final fontJson = (jsonMap['font'] as Map<String, dynamic>);
    final radiusJson = (jsonMap['radius'] as Map<String, dynamic>);
    final shadowJson = (jsonMap['shadow'] as Map<String, dynamic>);

    Map<String, Color> colors = {
      for (final entry in colorJson.entries)
        entry.key: _parseRgbColor(entry.value as String),
    };

    Map<String, double> radius = {
      for (final entry in radiusJson.entries)
        entry.key: _parsePx(entry.value as String),
    };

    Map<String, List<BoxShadow>> shadows = {
      for (final entry in shadowJson.entries)
        entry.key: _parseBoxShadows(entry.value as String),
    };

    return DesignTokens(
      colors: colors,
      fontSans: (fontJson['sans'] as String).split(',').first.trim(),
      fontSerif: (fontJson['serif'] as String).split(',').first.trim(),
      fontMono: (fontJson['mono'] as String).split(',').first.trim(),
      radius: radius,
      shadows: shadows,
    );
  }

  static ThemeData buildTheme(DesignTokens tokens, {bool isDarkMode = false}) {
    final colorScheme = isDarkMode ? _buildDarkColorScheme(tokens) : _buildLightColorScheme(tokens);

    final baseTextTheme = GoogleFonts.montserratTextTheme();
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    );

    final mildNeoBrutalBorder = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius['md'] ?? 6),
      side: BorderSide(
        color: tokens.colors['border']!,
        width: 2,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDarkMode 
          ? const Color(0xFF121212) 
          : tokens.colors['background'],
      textTheme: textTheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: isDarkMode ? const Color(0xFF2A2A2A) : tokens.colors['card'],
        shape: mildNeoBrutalBorder,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: mildNeoBrutalBorder,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: tokens.colors['border']!, width: 2),
          shape: mildNeoBrutalBorder,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2A2A2A) : tokens.colors['card'],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius['md'] ?? 6),
          borderSide: BorderSide(color: tokens.colors['border']!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius['md'] ?? 6),
          borderSide: BorderSide(color: tokens.colors['ring']!, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radius['md'] ?? 6),
          borderSide: BorderSide(color: tokens.colors['destructive']!, width: 2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode 
            ? const Color(0xFF1F1F1F) 
            : tokens.colors['background'],
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      dividerColor: isDarkMode 
          ? const Color(0xFF404040) 
          : tokens.colors['border'],
    );
  }

  /// Build light theme color scheme
  static ColorScheme _buildLightColorScheme(DesignTokens tokens) {
    return ColorScheme(
      brightness: Brightness.light,
      primary: tokens.colors['primary']!,
      onPrimary: tokens.colors['primaryForeground']!,
      secondary: tokens.colors['secondary']!,
      onSecondary: tokens.colors['secondaryForeground']!,
      error: tokens.colors['destructive']!,
      onError: tokens.colors['destructiveForeground']!,
      surface: tokens.colors['card']!,
      onSurface: tokens.colors['foreground']!,
      tertiary: tokens.colors['accent']!,
      onTertiary: tokens.colors['accentForeground']!,
    );
  }

  /// Build dark theme color scheme with neo-brutal dark variants
  static ColorScheme _buildDarkColorScheme(DesignTokens tokens) {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: tokens.colors['primary']!,
      onPrimary: tokens.colors['primaryForeground']!,
      secondary: tokens.colors['secondary']!,
      onSecondary: tokens.colors['secondaryForeground']!,
      error: tokens.colors['destructive']!,
      onError: tokens.colors['destructiveForeground']!,
      surface: const Color(0xFF1F1F1F), // Dark surface
      onSurface: const Color(0xFFE5E5E5), // Light text on dark
      tertiary: tokens.colors['accent']!,
      onTertiary: tokens.colors['accentForeground']!,
    );
  }

  /// Build dark theme variant
  static ThemeData buildDarkTheme(DesignTokens tokens) {
    return buildTheme(tokens, isDarkMode: true);
  }

  static Color _parseRgbColor(String rgb) {
    
    final cleaned = rgb.replaceAll(RegExp(r'[^0-9,]'), '');
    final parts = cleaned.split(',').map((e) => int.parse(e.trim())).toList();
    return Color.fromARGB(255, parts[0], parts[1], parts[2]);
  }

  static double _parsePx(String px) {
    return double.tryParse(px.replaceAll('px', '').trim()) ?? 0;
  }

  static List<BoxShadow> _parseBoxShadows(String def) {
    // Multiple shadows separated by ','
    final parts = def.split('),');
    return parts.map((p) {
      final segment = p.contains(')') ? '${p.trim()})' : p.trim();
      final values = segment.replaceAll('px', '').split('rgba').first.trim();
      final nums = values
          .replaceAll('rgb', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toList();

      // Expected like: offsetX offsetY blur spread
      final offsets = nums.map((e) => double.tryParse(e) ?? 0).toList();
      // Extract color
      final colorMatch = RegExp(r'rgba?\(([^)]+)\)').firstMatch(segment);
      Color color = const Color.fromRGBO(0, 0, 0, 0.1);
      if (colorMatch != null) {
        final comps = colorMatch.group(1)!.split(',');
        final r = int.parse(comps[0].trim());
        final g = int.parse(comps[1].trim());
        final b = int.parse(comps[2].trim());
        final a = comps.length > 3 ? double.parse(comps[3].trim()) : 1.0;
        color = Color.fromRGBO(r, g, b, a);
      }
      return BoxShadow(
        color: color,
        offset: Offset(offsets[0], offsets[1]),
        blurRadius: offsets.length > 2 ? offsets[2] : 0,
        spreadRadius: offsets.length > 3 ? offsets[3] : 0,
      );
    }).toList();
  }
}

