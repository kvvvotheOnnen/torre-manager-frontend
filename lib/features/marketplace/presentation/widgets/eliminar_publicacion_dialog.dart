import 'package:flutter/material.dart';

import '../../domain/entities/publicacion_marketplace.dart';

class EliminarPublicacionDialog extends StatefulWidget {
  const EliminarPublicacionDialog({super.key, required this.publicacion});

  final PublicacionMarketplace publicacion;

  static Future<String?> mostrar(
    BuildContext context,
    PublicacionMarketplace publicacion,
  ) {
    return showDialog<String>(
      context: context,
      builder: (context) => EliminarPublicacionDialog(publicacion: publicacion),
    );
  }

  @override
  State<EliminarPublicacionDialog> createState() =>
      _EliminarPublicacionDialogState();
}

class _EliminarPublicacionDialogState extends State<EliminarPublicacionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_motivo.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Eliminar publicación'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'La publicación "${widget.publicacion.titulo}" será eliminada '
                'del catálogo. El dueño verá el motivo en su historial.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivo,
                maxLength: 500,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Motivo de la eliminación',
                  hintText: 'Explica brevemente por qué se elimina.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.length < 5) {
                    return 'Escribe un motivo de al menos 5 caracteres.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _confirmar,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar'),
        ),
      ],
    );
  }
}
