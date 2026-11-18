import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/condicion_producto.dart';
import '../../domain/entities/publicacion_foto.dart';
import '../../domain/entities/publicacion_marketplace.dart';

class DatosPublicacion {
  const DatosPublicacion({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.condicion,
    this.foto,
  });

  final String? id;
  final String titulo;
  final String descripcion;
  final int precio;
  final CategoriaProducto categoria;
  final CondicionProducto condicion;
  final PublicacionFoto? foto;
}

class PublicacionFormDialog extends StatefulWidget {
  const PublicacionFormDialog({super.key, this.publicacion});

  final PublicacionMarketplace? publicacion;

  static Future<DatosPublicacion?> mostrar(
    BuildContext context, {
    PublicacionMarketplace? publicacion,
  }) {
    return showDialog<DatosPublicacion>(
      context: context,
      builder: (context) => PublicacionFormDialog(publicacion: publicacion),
    );
  }

  @override
  State<PublicacionFormDialog> createState() => _PublicacionFormDialogState();
}

class _PublicacionFormDialogState extends State<PublicacionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late CategoriaProducto _categoria;
  late CondicionProducto _condicion;
  PublicacionFoto? _foto;
  bool _cargandoFoto = false;

  bool get _editando => widget.publicacion != null;

  @override
  void initState() {
    super.initState();
    final publicacion = widget.publicacion;
    _titulo = TextEditingController(text: publicacion?.titulo ?? '');
    _descripcion = TextEditingController(text: publicacion?.descripcion ?? '');
    _precio = TextEditingController(
      text: publicacion == null ? '' : '${publicacion.precio}',
    );
    _categoria = publicacion?.categoria ?? CategoriaProducto.otros;
    _condicion = publicacion?.condicion ?? CondicionProducto.usado;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _precio.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    setState(() => _cargandoFoto = true);

    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (archivo == null) {
        return;
      }

      final bytes = await archivo.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _foto = PublicacionFoto(bytes: bytes, nombre: archivo.name);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen.')),
      );
    } finally {
      if (mounted) {
        setState(() => _cargandoFoto = false);
      }
    }
  }

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      DatosPublicacion(
        id: widget.publicacion?.id,
        titulo: _titulo.text.trim(),
        descripcion: _descripcion.text.trim(),
        precio: int.tryParse(_precio.text.trim()) ?? 0,
        categoria: _categoria,
        condicion: _condicion,
        foto: _foto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editando ? 'Editar publicación' : 'Nueva publicación',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titulo,
                          maxLength: 120,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del artículo',
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (texto.isEmpty) {
                              return 'Ingresa el nombre del artículo.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descripcion,
                          maxLength: 1000,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (texto.isEmpty) {
                              return 'Ingresa una descripción.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _precio,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Precio (CLP)',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                            helperText: 'Puedes dejar 0 si lo regalas.',
                          ),
                          validator: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (texto.isEmpty) {
                              return 'Ingresa el precio.';
                            }
                            if (int.tryParse(texto) == null) {
                              return 'Ingresa un precio válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CategoriaProducto>(
                          initialValue: _categoria,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final categoria in CategoriaProducto.values)
                              DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria.etiqueta),
                              ),
                          ],
                          onChanged: (valor) {
                            if (valor != null) {
                              setState(() => _categoria = valor);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<CondicionProducto>(
                          initialValue: _condicion,
                          decoration: const InputDecoration(
                            labelText: 'Estado del artículo',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final condicion in CondicionProducto.values)
                              DropdownMenuItem(
                                value: condicion,
                                child: Text(condicion.etiqueta),
                              ),
                          ],
                          onChanged: (valor) {
                            if (valor != null) {
                              setState(() => _condicion = valor);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Imagen (opcional)',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _VistaPreviaImagen(
                          foto: _foto,
                          fotoUrl: widget.publicacion?.fotoUrl,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _cargandoFoto
                                  ? null
                                  : _seleccionarFoto,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                _cargandoFoto
                                    ? 'Cargando...'
                                    : 'Seleccionar imagen',
                              ),
                            ),
                            if (_foto != null) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => setState(() => _foto = null),
                                child: const Text('Quitar'),
                              ),
                            ],
                          ],
                        ),
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
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _guardar,
                      child: Text(_editando ? 'Guardar cambios' : 'Publicar'),
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

class _VistaPreviaImagen extends StatelessWidget {
  const _VistaPreviaImagen({required this.foto, required this.fotoUrl});

  final PublicacionFoto? foto;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget contenido;
    if (foto != null) {
      contenido = Image.memory(foto!.bytes, fit: BoxFit.cover);
    } else if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      contenido = Image.network(
        fotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _vacio(theme),
      );
    } else {
      contenido = _vacio(theme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(aspectRatio: 16 / 9, child: contenido),
    );
  }

  Widget _vacio(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text('Sin imagen', style: theme.textTheme.bodySmall),
      ),
    );
  }
}
