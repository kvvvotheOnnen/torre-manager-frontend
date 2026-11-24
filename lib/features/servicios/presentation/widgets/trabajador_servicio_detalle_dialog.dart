import 'package:flutter/material.dart';

import '../../../../core/utils/formato_telefono.dart';
import '../../domain/entities/trabajador_servicio.dart';

/// Muestra la fotografía y los datos de un servicio recomendado.
class TrabajadorServicioDetalleDialog extends StatelessWidget {
  const TrabajadorServicioDetalleDialog({
    super.key,
    required this.trabajador,
    this.onEditar,
    this.onEliminar,
  });

  final TrabajadorServicio trabajador;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  static Future<void> mostrar(
    BuildContext context, {
    required TrabajadorServicio trabajador,
    VoidCallback? onEditar,
    VoidCallback? onEliminar,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => TrabajadorServicioDetalleDialog(
        trabajador: trabajador,
        onEditar: onEditar,
        onEliminar: onEliminar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tamanoPantalla = MediaQuery.sizeOf(context);
    final altoImagen = (tamanoPantalla.height * 0.5).clamp(220.0, 480.0);

    void ejecutar(VoidCallback accion) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) => accion());
    }

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
              _Imagen(trabajador: trabajador, alto: altoImagen),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trabajador.nombre,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (trabajador.nombreEmpresa != null) ...[
                      _FilaDetalle(
                        icono: Icons.business_outlined,
                        etiqueta: 'Empresa',
                        valor: trabajador.nombreEmpresa!,
                      ),
                      const SizedBox(height: 4),
                    ],
                    _FilaDetalle(
                      icono: Icons.handyman_outlined,
                      etiqueta: 'Tipo',
                      valor: trabajador.tipo.etiqueta,
                    ),
                    const SizedBox(height: 4),
                    _FilaDetalle(
                      icono: Icons.phone_outlined,
                      etiqueta: 'Contacto',
                      valor: formatearTelefono(trabajador.telefono),
                    ),
                    if (trabajador.descripcion != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Descripción',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trabajador.descripcion!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                        if (onEditar != null)
                          FilledButton.tonalIcon(
                            onPressed: () => ejecutar(onEditar!),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                        if (onEliminar != null)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                            ),
                            onPressed: () => ejecutar(onEliminar!),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar'),
                          ),
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

class _Imagen extends StatelessWidget {
  const _Imagen({required this.trabajador, required this.alto});

  final TrabajadorServicio trabajador;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!trabajador.tieneFoto) {
      return _SinImagen(theme: theme, alto: alto);
    }

    return Container(
      height: alto,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Image.network(
        trabajador.fotoUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _SinImagen(theme: theme, alto: alto),
      ),
    );
  }
}

class _SinImagen extends StatelessWidget {
  const _SinImagen({required this.theme, required this.alto});

  final ThemeData theme;
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: alto,
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
              'Sin imagen',
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
