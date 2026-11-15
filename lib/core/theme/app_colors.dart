import 'package:flutter/material.dart';

/// Paleta "Arquitectura nocturna": azul marino profundo con acentos ámbar.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceStrong,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.primaryDeep,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.danger,
    required this.border,
    required this.brandGradient,
    required this.heroGradient,
    required this.goldGradient,
    required this.scrim,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceStrong;
  final Color ink;
  final Color inkMuted;
  final Color primary;
  final Color primaryDeep;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color danger;
  final Color border;
  final List<Color> brandGradient;
  final List<Color> heroGradient;
  final List<Color> goldGradient;
  final Color scrim;

  bool get isDark => brightness == Brightness.dark;

  LinearGradient get brand => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brandGradient,
  );

  LinearGradient get hero => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: heroGradient,
  );

  LinearGradient get gold => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: goldGradient,
  );
}

const AppPalette lightPalette = AppPalette(
  brightness: Brightness.light,
  background: Color(0xFFF4F6FB),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEEF2F9),
  surfaceStrong: Color(0xFFE2E8F4),
  ink: Color(0xFF0B1220),
  inkMuted: Color(0xFF55627A),
  primary: Color(0xFF2F5BFF),
  primaryDeep: Color(0xFF1E3A8A),
  onPrimary: Color(0xFFFFFFFF),
  accent: Color(0xFFF5B544),
  onAccent: Color(0xFF1B1405),
  success: Color(0xFF16A34A),
  danger: Color(0xFFE5484D),
  border: Color(0xFFDDE3EE),
  brandGradient: <Color>[Color(0xFF0B1220), Color(0xFF14264A), Color(0xFF2F5BFF)],
  heroGradient: <Color>[Color(0xFF0B1220), Color(0xFF132447), Color(0xFF1E3A8A)],
  goldGradient: <Color>[Color(0xFFF5B544), Color(0xFFFFD98A)],
  scrim: Color(0x14000000),
);

const AppPalette darkPalette = AppPalette(
  brightness: Brightness.dark,
  background: Color(0xFF070B14),
  surface: Color(0xFF0F1626),
  surfaceAlt: Color(0xFF141E33),
  surfaceStrong: Color(0xFF1C2942),
  ink: Color(0xFFF3F6FC),
  inkMuted: Color(0xFF9AA7BE),
  primary: Color(0xFF6D8BFF),
  primaryDeep: Color(0xFF1E3A8A),
  onPrimary: Color(0xFF060A12),
  accent: Color(0xFFFFC65C),
  onAccent: Color(0xFF1B1405),
  success: Color(0xFF34D399),
  danger: Color(0xFFFF6B7A),
  border: Color(0xFF22304A),
  brandGradient: <Color>[Color(0xFF070B14), Color(0xFF0F1B33), Color(0xFF22418C)],
  heroGradient: <Color>[Color(0xFF070B14), Color(0xFF101C36), Color(0xFF1E3A8A)],
  goldGradient: <Color>[Color(0xFFFFC65C), Color(0xFFFFE4A8)],
  scrim: Color(0x66000000),
);

/// Acceso rápido a la paleta activa desde cualquier widget.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).brightness == Brightness.dark ? darkPalette : lightPalette;
}
