import 'package:flutter/material.dart';

Future<int?> solicitarCantidadAccesorias(
  BuildContext context, {
  required String etiqueta,
}) async {
  final cantidad = await showDialog<int>(
    context: context,
    builder: (_) => _CantidadAccesoriasDialog(etiqueta: etiqueta),
  );

  if (cantidad == null) return null;
  if (!context.mounted) return null;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar creación'),
      content: Text(
        'Estás a punto de crear $cantidad $etiqueta para este proyecto. '
        '¿Es correcto?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sí, crear'),
        ),
      ],
    ),
  );

  return confirmado == true ? cantidad : null;
}

class _CantidadAccesoriasDialog extends StatefulWidget {
  const _CantidadAccesoriasDialog({required this.etiqueta});

  final String etiqueta;

  @override
  State<_CantidadAccesoriasDialog> createState() =>
      _CantidadAccesoriasDialogState();
}

class _CantidadAccesoriasDialogState extends State<_CantidadAccesoriasDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cantidad de ${widget.etiqueta}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            helperText: 'Entre 1 y 999',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final cantidad = int.tryParse(value?.trim() ?? '');
            if (cantidad == null) return 'Ingresa un número entero';
            if (cantidad < 1 || cantidad > 999) {
              return 'La cantidad debe estar entre 1 y 999';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continuar')),
      ],
    );
  }
}
