import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografía del sistema: Space Grotesk para títulos, Manrope para cuerpo.
class AppTypography {
  const AppTypography._();

  static const String displayFamily = 'Space Grotesk';
  static const String bodyFamily = 'Manrope';

  static TextTheme textTheme(Brightness brightness, Color ink, Color inkMuted) {
    final base = ThemeData(brightness: brightness).textTheme;
    final display = GoogleFonts.spaceGroteskTextTheme(base);
    final body = GoogleFonts.manropeTextTheme(base);

    TextStyle? d(TextStyle? style, {required double size, FontWeight weight = FontWeight.w700, double spacing = -0.6}) {
      return style?.copyWith(
        fontFamily: displayFamily,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: 1.1,
        color: ink,
      );
    }

    TextStyle? b(
      TextStyle? style, {
      required double size,
      FontWeight weight = FontWeight.w500,
      double spacing = 0,
      double height = 1.45,
      Color? color,
    }) {
      return style?.copyWith(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
        color: color ?? ink,
      );
    }

    return body.copyWith(
      displayLarge: d(display.displayLarge, size: 56, spacing: -1.6),
      displayMedium: d(display.displayMedium, size: 44, spacing: -1.2),
      displaySmall: d(display.displaySmall, size: 36, spacing: -1),
      headlineLarge: d(display.headlineLarge, size: 30, spacing: -0.8),
      headlineMedium: d(display.headlineMedium, size: 26, spacing: -0.6),
      headlineSmall: d(display.headlineSmall, size: 22, spacing: -0.4),
      titleLarge: b(body.titleLarge, size: 19, weight: FontWeight.w700, spacing: -0.2),
      titleMedium: b(body.titleMedium, size: 16, weight: FontWeight.w700, spacing: -0.1),
      titleSmall: b(body.titleSmall, size: 14, weight: FontWeight.w700),
      bodyLarge: b(body.bodyLarge, size: 16),
      bodyMedium: b(body.bodyMedium, size: 14),
      bodySmall: b(body.bodySmall, size: 12.5, color: inkMuted),
      labelLarge: b(body.labelLarge, size: 14, weight: FontWeight.w700, spacing: 0.2),
      labelMedium: b(body.labelMedium, size: 12, weight: FontWeight.w700, spacing: 0.4),
      labelSmall: b(body.labelSmall, size: 11, weight: FontWeight.w700, spacing: 0.8, color: inkMuted),
    );
  }

  /// Pre-carga los pesos usados para evitar el cambio de fuente al primer render.
  static Future<void> preload() async {
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500),
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        GoogleFonts.manrope(fontWeight: FontWeight.w400),
        GoogleFonts.manrope(fontWeight: FontWeight.w500),
        GoogleFonts.manrope(fontWeight: FontWeight.w600),
        GoogleFonts.manrope(fontWeight: FontWeight.w700),
        GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ]);
    } catch (_) {
      // Si no hay red, GoogleFonts hará fallback y cargará bajo demanda.
    }
  }
}
