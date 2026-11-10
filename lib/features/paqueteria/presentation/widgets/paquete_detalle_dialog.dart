import 'package:flutter/material.dart';

import '../../domain/entities/paquete.dart';

/// Muestra la fotografía y los datos de un paquete.
class PaqueteDetalleDialog extends StatelessWidget {
  const PaqueteDetalleDialog({
    super.key,
    required this.paquete,
    this.onRetirar,
  });

  final Paquete paquete;
  final VoidCallback? onRetirar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendiente = paquete.estaPendiente;
    final tamanoPantalla = MediaQuery.sizeOf(context);
    final altoImagen = (tamanoPantalla.height * 0.55).clamp(240.0, 540.0);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: tamanoPantalla.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (paquete.fotoUrl != null)
                Container(
                  height: altoImagen,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Image.network(
                    paquete.fotoUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        _PlaceholderSinImagen(theme: theme, height: altoImagen),
                  ),
                )
              else
                _PlaceholderSinImagen(theme: theme, height: altoImagen),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paquete.descripcion,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (paquete.remitente != null)
                      _FilaDetalle(
                        icono: Icons.person_outline,
                        etiqueta: 'Remitente',
                        valor: paquete.remitente!,
                      ),
                    if (paquete.unidadIdentificador != null) ...[
                      const SizedBox(height: 4),
                      _FilaDetalle(
                        icono: Icons.door_front_door_outlined,
                        etiqueta: 'Unidad',
                        valor: paquete.unidadIdentificador!,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _FilaDetalle(
                      icono: Icons.calendar_today_outlined,
                      etiqueta: 'Recibido',
                      valor: paquete.fechaRecepcion,
                    ),
                    if (paquete.fechaRetiro != null) ...[
                      const SizedBox(height: 4),
                      _FilaDetalle(
                        icono: Icons.check_circle_outline,
                        etiqueta: 'Retirado',
                        valor: paquete.fechaRetiro!,
                      ),
                    ],
                    if (paquete.retiradoPorNombre != null &&
                        paquete.retiradoPorNombre!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _FilaDetalle(
                        icono: Icons.badge_outlined,
                        etiqueta: 'Retirado por',
                        valor: paquete.retiradoPorNombre!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(pendiente ? 'Pendiente' : 'Retirado'),
                      backgroundColor: pendiente
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.tertiaryContainer,
                      labelStyle: TextStyle(
                        color: pendiente
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                        if (pendiente && onRetirar != null) ...[
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => onRetirar!(),
                              );
                            },
                            child: const Text('Marcar retirado'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderSinImagen extends StatelessWidget {
  const _PlaceholderSinImagen({required this.theme, required this.height});

  final ThemeData theme;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay imagen',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaDetalle extends StatelessWidget {
  const _FilaDetalle({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icono, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text('$etiqueta: ', style: theme.textTheme.bodySmall),
        Expanded(
          child: Text(
            valor,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
