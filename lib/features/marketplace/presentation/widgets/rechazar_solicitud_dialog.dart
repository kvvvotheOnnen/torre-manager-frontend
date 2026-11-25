import 'package:flutter/material.dart';

import '../../domain/entities/publicacion_marketplace.dart';

class RechazarSolicitudDialog extends StatefulWidget {
  const RechazarSolicitudDialog({super.key, required this.publicacion});

  final PublicacionMarketplace publicacion;

  static Future<String?> mostrar(
    BuildContext context,
    PublicacionMarketplace publicacion,
  ) {
    return showDialog<String>(
      context: context,
      builder: (context) => RechazarSolicitudDialog(publicacion: publicacion),
    );
  }

  @override
  State<RechazarSolicitudDialog> createState() =>
      _RechazarSolicitudDialogState();
}

class _RechazarSolicitudDialogState extends State<RechazarSolicitudDialog> {
  final _formKey = GlobalKey<FormState>();
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(_motivo.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rechazar solicitud'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'La publicación "${widget.publicacion.titulo}" será rechazada '
                'y no se publicará. El dueño verá el motivo y podrá publicar '
                'una nueva versión.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivo,
                autofocus: true,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Motivo del rechazo',
                  hintText: 'Explica brevemente por qué se rechaza.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().length < 5) {
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
          icon: const Icon(Icons.block_outlined),
          label: const Text('Rechazar'),
        ),
      ],
    );
  }
}
