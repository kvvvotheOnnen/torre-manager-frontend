import 'package:flutter/material.dart';

import '../../../../core/utils/formato_moneda.dart';
import '../../domain/entities/estado_publicacion.dart';
import '../../domain/entities/publicacion_marketplace.dart';

class PublicacionCard extends StatelessWidget {
  const PublicacionCard({
    super.key,
    required this.publicacion,
    required this.onAbrir,
    this.onEditar,
    this.onEliminar,
    this.onFavorito,
    this.procesando = false,
  });

  final PublicacionMarketplace publicacion;
  final VoidCallback onAbrir;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final VoidCallback? onFavorito;
  final bool procesando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: procesando ? null : onAbrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (procesando) const LinearProgressIndicator(minHeight: 3),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Imagen(publicacion: publicacion),
                  if (!publicacion.estaDisponible)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _EstadoBadge(estado: publicacion.estado),
                    ),
                  if (onFavorito != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _BotonFavorito(
                        esFavorita: publicacion.esFavorita,
                        procesando: procesando,
                        onPressed: onFavorito!,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publicacion.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatearPrecio(publicacion.precio),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Etiqueta(texto: publicacion.condicion.etiqueta),
                      _Etiqueta(
                        texto: publicacion.categoria.etiqueta,
                        suave: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    publicacion.descripcion,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (publicacion.motivoEliminacion != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Motivo: ${publicacion.motivoEliminacion}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (publicacion.estaDisponible && !publicacion.esMia) ...[
                    const SizedBox(height: 8),
                    Tooltip(
                      message: 'Disponible próximamente',
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Contactar'),
                      ),
                    ),
                  ],
                  if (onEditar != null || onEliminar != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEditar != null)
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: procesando ? null : onEditar,
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        if (onEliminar != null)
                          IconButton(
                            tooltip: publicacion.esMia
                                ? 'Opciones de la publicación'
                                : 'Eliminar publicación',
                            onPressed: procesando ? null : onEliminar,
                            icon: Icon(
                              publicacion.esMia && publicacion.estaDisponible
                                  ? Icons.more_horiz
                                  : Icons.delete_outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
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
    if (!publicacion.tieneFoto) {
      return _sinImagen(context);
    }

    return Image.network(
      publicacion.fotoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _sinImagen(context),
    );
  }

  Widget _sinImagen(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text('Sin imagen', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BotonFavorito extends StatelessWidget {
  const _BotonFavorito({
    required this.esFavorita,
    required this.procesando,
    required this.onPressed,
  });

  final bool esFavorita;
  final bool procesando;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: esFavorita ? 'Quitar de favoritos' : 'Agregar a favoritos',
        onPressed: procesando ? null : onPressed,
        icon: procesando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                esFavorita ? Icons.favorite : Icons.favorite_border,
                color: theme.colorScheme.error,
              ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final EstadoPublicacion estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (fondo, texto) = switch (estado) {
      EstadoPublicacion.vendida => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
      EstadoPublicacion.eliminada => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
      ),
      _ => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        estado.etiqueta,
        style: theme.textTheme.labelMedium?.copyWith(
          color: texto,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, this.suave = false});

  final String texto;
  final bool suave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: suave
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: theme.textTheme.labelSmall?.copyWith(
          color: suave
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
