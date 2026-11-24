import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Centra el contenido de una pantalla y limita su ancho en vistas amplias
/// (web/escritorio) para que los campos y tarjetas no se estiren de borde a
/// borde.
class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContent,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Limita el ancho de un campo suelto (por ejemplo un buscador) para que no
/// ocupe toda la fila en pantallas grandes. En móvil no cambia nada porque el
/// ancho disponible es menor que el límite.
class AppFieldWidth extends StatelessWidget {
  const AppFieldWidth({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxField,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
