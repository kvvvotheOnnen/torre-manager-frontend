import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppLayout {
  const AppLayout._();

  /// Ancho máximo del contenido de una pantalla en web/escritorio.
  static const double maxContent = 1200;

  /// Ancho máximo de un formulario en una sola columna.
  static const double maxForm = 560;

  /// Ancho máximo de un campo suelto (buscadores y similares).
  static const double maxField = 520;
}

class AppRadii {
  const AppRadii._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(bool dark) => [
    BoxShadow(
      color: dark ? const Color(0x66000000) : const Color(0x140B1220),
      blurRadius: dark ? 24 : 28,
      offset: const Offset(0, 14),
    ),
  ];

  static List<BoxShadow> lift(bool dark) => [
    BoxShadow(
      color: dark ? const Color(0x99000000) : const Color(0x240B1220),
      blurRadius: 36,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
}
