import 'package:flutter/material.dart';

class WizardStepMap extends StatelessWidget {
  const WizardStepMap({
    super.key,
    required this.pasos,
    required this.pasoActual,
  });

  final List<String> pasos;
  final int pasoActual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < pasos.length; i++) ...[
            _Nodo(
              numero: i + 1,
              etiqueta: pasos[i],
              estado: i < pasoActual
                  ? _EstadoNodo.completado
                  : i == pasoActual
                  ? _EstadoNodo.actual
                  : _EstadoNodo.pendiente,
            ),
            if (i < pasos.length - 1)
              Container(
                width: 32,
                height: 2,
                margin: const EdgeInsets.only(top: 16),
                color: i < pasoActual
                    ? colores.primary
                    : colores.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

enum _EstadoNodo { completado, actual, pendiente }

class _Nodo extends StatelessWidget {
  const _Nodo({
    required this.numero,
    required this.etiqueta,
    required this.estado,
  });

  final int numero;
  final String etiqueta;
  final _EstadoNodo estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = theme.colorScheme;

    final (Color fondo, Color texto, Color borde) = switch (estado) {
      _EstadoNodo.completado => (
        colores.primary,
        colores.onPrimary,
        colores.primary,
      ),
      _EstadoNodo.actual => (
        colores.primaryContainer,
        colores.onPrimaryContainer,
        colores.primary,
      ),
      _EstadoNodo.pendiente => (
        colores.surfaceContainerHighest,
        colores.onSurfaceVariant,
        colores.outlineVariant,
      ),
    };

    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fondo,
              shape: BoxShape.circle,
              border: Border.all(color: borde, width: 2),
            ),
            child: estado == _EstadoNodo.completado
                ? Icon(Icons.check, size: 18, color: texto)
                : Text(
                    '$numero',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: texto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: estado == _EstadoNodo.pendiente
                  ? colores.onSurfaceVariant
                  : colores.onSurface,
              fontWeight: estado == _EstadoNodo.actual
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
