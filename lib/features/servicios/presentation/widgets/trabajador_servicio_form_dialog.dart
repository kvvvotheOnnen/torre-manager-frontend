import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/formato_telefono.dart';
import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio.dart';
import '../../domain/entities/trabajador_servicio_foto.dart';

class DatosTrabajador {
  const DatosTrabajador({
    this.id,
    required this.nombre,
    this.nombreEmpresa,
    required this.telefono,
    required this.tipo,
    this.descripcion,
    this.foto,
  });

  final String? id;
  final String nombre;
  final String? nombreEmpresa;
  final String telefono;
  final TipoServicio tipo;
  final String? descripcion;
  final TrabajadorServicioFoto? foto;
}

class TrabajadorServicioFormDialog extends StatefulWidget {
  const TrabajadorServicioFormDialog({super.key, this.inicial});

  final TrabajadorServicio? inicial;

  static Future<DatosTrabajador?> mostrar(
    BuildContext context, {
    TrabajadorServicio? inicial,
  }) {
    return showDialog<DatosTrabajador>(
      context: context,
      builder: (context) => TrabajadorServicioFormDialog(inicial: inicial),
    );
  }

  @override
  State<TrabajadorServicioFormDialog> createState() =>
      _TrabajadorServicioFormDialogState();
}

class _TrabajadorServicioFormDialogState
    extends State<TrabajadorServicioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _empresa;
  late final TextEditingController _telefono;
  late final TextEditingController _descripcion;
  TipoServicio? _tipo;
  TrabajadorServicioFoto? _foto;
  bool _cargandoFoto = false;

  @override
  void initState() {
    super.initState();
    final inicial = widget.inicial;
    _nombre = TextEditingController(text: inicial?.nombre ?? '');
    _empresa = TextEditingController(text: inicial?.nombreEmpresa ?? '');
    _telefono = TextEditingController(text: inicial?.telefono ?? '');
    _descripcion = TextEditingController(text: inicial?.descripcion ?? '');
    _tipo = inicial?.tipo;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _empresa.dispose();
    _telefono.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    setState(() => _cargandoFoto = true);
    try {
      final picker = ImagePicker();
      final imagen = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (imagen == null) {
        return;
      }
      final bytes = await imagen.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _foto = TrabajadorServicioFoto(bytes: bytes, nombre: imagen.name);
      });
    } finally {
      if (mounted) {
        setState(() => _cargandoFoto = false);
      }
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate() || _tipo == null) {
      if (_tipo == null) {
        setState(() {});
      }
      return;
    }

    final empresa = _empresa.text.trim();
    final descripcion = _descripcion.text.trim();

    Navigator.of(context).pop(
      DatosTrabajador(
        id: widget.inicial?.id,
        nombre: _nombre.text.trim(),
        nombreEmpresa: empresa.isEmpty ? null : empresa,
        telefono: _telefono.text.trim(),
        tipo: _tipo!,
        descripcion: descripcion.isEmpty ? null : descripcion,
        foto: _foto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.inicial != null;
    final theme = Theme.of(context);
    final fotoActual = _foto == null && esEdicion
        ? widget.inicial!.fotoUrl
        : null;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  esEdicion ? 'Editar servicio' : 'Nuevo servicio',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombre,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de quien ofrece el servicio *',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (valor) => (valor == null || valor.trim().isEmpty)
                      ? 'Ingresa el nombre.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _empresa,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Empresa o servicio (opcional)',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefono,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Número de contacto *',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [FormateadorTelefono()],
                  validator: (valor) => (valor == null || valor.trim().isEmpty)
                      ? 'Ingresa un número de contacto.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TipoServicio>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de servicio *',
                  ),
                  items: TipoServicio.values
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.etiqueta),
                        ),
                      )
                      .toList(),
                  onChanged: (tipo) => setState(() => _tipo = tipo),
                  validator: (valor) =>
                      valor == null ? 'Selecciona un tipo de servicio.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del servicio (opcional)',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _cargandoFoto ? null : _seleccionarFoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        _foto == null ? 'Agregar imagen' : 'Cambiar imagen',
                      ),
                    ),
                    if (_foto != null) ...[
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _foto!.bytes,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Quitar imagen',
                        onPressed: () => setState(() => _foto = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ],
                ),
                if (fotoActual != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          fotoActual,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Imagen actual (se conserva si no eliges otra).',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _guardar,
                      child: Text(esEdicion ? 'Guardar cambios' : 'Agregar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
