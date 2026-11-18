import 'package:flutter/material.dart';

import '../../../../core/utils/formato_moneda.dart';
import '../../domain/entities/publicacion_marketplace.dart';

class PublicacionDetalleDialog extends StatelessWidget {
  const PublicacionDetalleDialog({
    super.key,
    required this.publicacion,
    this.onEditar,
    this.onEliminar,
    this.onFavorito,
  });

  final PublicacionMarketplace publicacion;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onFavorito;

  static Future<void> mostrar(
    BuildContext context,
    PublicacionMarketplace publicacion, {
    VoidCallback? onEditar,
    VoidCallback? onEliminar,
    VoidCallback? onFavorito,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => PublicacionDetalleDialog(
        publicacion: publicacion,
        onEditar: onEditar,
        onEliminar: onEliminar,
        onFavorito: onFavorito,
      ),
    );
  }

  void _ejecutar(BuildContext context, VoidCallback accion) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => accion());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      publicacion.titulo,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  if (onFavorito != null)
                    IconButton(
                      tooltip: publicacion.esFavorita
                          ? 'Quitar de favoritos'
                          : 'Agregar a favoritos',
                      onPressed: () => _ejecutar(context, onFavorito!),
                      icon: Icon(
                        publicacion.esFavorita
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _Imagen(publicacion: publicacion),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formatearPrecio(publicacion.precio),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(label: Text(publicacion.condicion.etiqueta)),
                          Chip(
                            label: Text(publicacion.categoria.etiqueta),
                            avatar: const Icon(
                              Icons.category_outlined,
                              size: 18,
                            ),
                          ),
                          Chip(label: Text(publicacion.estado.etiqueta)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        publicacion.descripcion,
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (publicacion.vendidoEn != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Vendida el ${formatearFecha(publicacion.vendidoEn)}.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (publicacion.eliminadoEn != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Eliminada el ${formatearFecha(publicacion.eliminadoEn)}'
                          '${publicacion.eliminadoPorRol == null ? '' : ' por el ${publicacion.eliminadoPorRol}'}.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (publicacion.motivoEliminacion != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Motivo de eliminación: ${publicacion.motivoEliminacion}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      if (publicacion.estaDisponible && !publicacion.esMia) ...[
                        const SizedBox(height: 16),
                        Tooltip(
                          message: 'Disponible próximamente',
                          child: OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Contactar'),
                          ),
                        ),
                      ],
                    ],
                  ),
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
                  if (onEditar != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _ejecutar(context, onEditar!),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ],
                  if (onEliminar != null) ...[
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _ejecutar(context, onEliminar!),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Imagen extends StatelessWidget {
  const _Imagen({required this.publicacion});

  final PublicacionMarketplace publicacion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!publicacion.tieneFoto) {
      return ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Text('Sin imagen', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Image.network(
      publicacion.fotoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Text('Sin imagen', style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
