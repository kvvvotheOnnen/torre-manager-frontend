import 'package:flutter/material.dart';

/// Tarjeta común para módulos y funciones del dashboard.
///
/// Mantiene la misma apariencia en los paneles de administrador, residente y
/// conserje. No conoce roles ni permisos: recibe los datos ya resueltos por el
/// backend y solo dibuja.
class TarjetaModuloDashboard extends StatelessWidget {
  const TarjetaModuloDashboard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onTap,
    this.habilitado = true,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback onTap;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = habilitado
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: habilitado ? null : theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icono,
                    size: 32,
                    color: habilitado ? theme.colorScheme.primary : color,
                  ),
                  const Spacer(),
                  if (!habilitado)
                    Icon(Icons.lock_outline, size: 20, color: color),
                ],
              ),
              const Spacer(),
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                habilitado ? descripcion : 'No habilitado para este proyecto.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
