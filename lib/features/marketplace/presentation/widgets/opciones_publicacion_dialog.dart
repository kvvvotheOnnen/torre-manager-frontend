import 'package:flutter/material.dart';

enum AccionPropietario { retirar, vender }

class OpcionesPublicacionDialog extends StatelessWidget {
  const OpcionesPublicacionDialog({super.key});

  static Future<AccionPropietario?> mostrar(BuildContext context) {
    return showDialog<AccionPropietario>(
      context: context,
      builder: (context) => const OpcionesPublicacionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('¿Qué pasó con tu publicación?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige cómo quieres cerrarla. Esta acción no se puede deshacer.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.remove_shopping_cart_outlined),
              title: const Text('Retirar de la venta'),
              subtitle: const Text(
                'Desaparece de inmediato del catálogo y de los favoritos.',
              ),
              onTap: () => Navigator.of(context).pop(AccionPropietario.retirar),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('Se vendió'),
              subtitle: const Text(
                'Queda visible como vendida por 3 días en los favoritos.',
              ),
              onTap: () => Navigator.of(context).pop(AccionPropietario.vender),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
