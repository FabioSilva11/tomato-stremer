import 'package:flutter/material.dart';

class AppTheme {
  static const Color _darkBg = Color(0xFF111113);
  static const Color _darkPanel = Color(0xFF1B1C22);
  static const Color _darkPanelSoft = Color(0xFF252733);
  static const Color _darkText = Color(0xFFF9F9F9);
  static const Color _darkMuted = Color(0xFFC9C6CC);

  static const Color _lightBg = Color(0xFFFAF7F4);
  static const Color _lightPanel = Color(0xFFFFFFFF);
  static const Color _lightPanelSoft = Color(0xFFF0E9E4);
  static const Color _lightText = Color(0xFF211D20);
  static const Color _lightMuted = Color(0xFF6F656D);

  static const Color primary = Color(0xFFEA3448);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF40A86A);
  static const Color gold = Color(0xFFE0A93B);

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      bg: _lightBg,
      panel: _lightPanel,
      panelSoft: _lightPanelSoft,
      text: _lightText,
      muted: _lightMuted,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      bg: _darkBg,
      panel: _darkPanel,
      panelSoft: _darkPanelSoft,
      text: _darkText,
      muted: _darkMuted,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color panel,
    required Color panelSoft,
    required Color text,
    required Color muted,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: panel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme.copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: accent,
        tertiary: gold,
        surface: panel,
        onSurface: text,
        surfaceContainerHighest: panelSoft,
        onSurfaceVariant: muted,
      ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: text,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelSoft,
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.3),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panel,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? primary : muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  static Color bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color panelOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color panelSoftOf(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color mutedOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color onPrimaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color goldOf(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;
}
