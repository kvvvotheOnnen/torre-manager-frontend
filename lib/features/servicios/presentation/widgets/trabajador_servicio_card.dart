import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/trabajador_servicio.dart';

class TrabajadorServicioCard extends StatelessWidget {
  const TrabajadorServicioCard({
    super.key,
    required this.trabajador,
    this.onAbrir,
    this.onEditar,
    this.onEliminar,
  });

  final TrabajadorServicio trabajador;
  final VoidCallback? onAbrir;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  bool get _tieneAcciones => onEditar != null || onEliminar != null;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onAbrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _Imagen(trabajador: trabajador),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trabajador.nombre,
                    style: textos.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trabajador.nombreEmpresa != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      trabajador.nombreEmpresa!,
                      style: textos.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(trabajador.tipo.etiqueta),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: colores.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trabajador.telefono,
                          style: textos.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (trabajador.descripcion != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      trabajador.descripcion!,
                      style: textos.bodySmall,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (_tieneAcciones) ...[
                    const Divider(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (onEditar != null)
                          TextButton.icon(
                            onPressed: onEditar,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar'),
                          ),
                        if (onEliminar != null)
                          TextButton.icon(
                            onPressed: onEliminar,
                            style: TextButton.styleFrom(
                              foregroundColor: colores.error,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Eliminar'),
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
  const _Imagen({required this.trabajador});

  final TrabajadorServicio trabajador;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    if (!trabajador.tieneFoto) {
      return _sinImagen(colores);
    }

    return ColoredBox(
      color: colores.surfaceContainerHighest,
      child: Image.network(
        trabajador.fotoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progreso) =>
            progreso == null ? child : _sinImagen(colores),
        errorBuilder: (context, error, stackTrace) => _sinImagen(colores),
      ),
    );
  }

  Widget _sinImagen(ColorScheme colores) {
    return Container(
      color: colores.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 36, color: colores.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            'Sin imagen',
            style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
