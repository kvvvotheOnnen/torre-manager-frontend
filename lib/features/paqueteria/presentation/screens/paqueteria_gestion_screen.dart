import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/paqueteria_bloc.dart';
import '../../domain/entities/paquete.dart';
import '../../domain/entities/paquete_foto.dart';
import '../widgets/paquete_card_image.dart';
import '../widgets/paquete_detalle_dialog.dart';

class PaqueteriaGestionScreen extends StatefulWidget {
  const PaqueteriaGestionScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<PaqueteriaGestionScreen> createState() =>
      _PaqueteriaGestionScreenState();
}

class _PaqueteriaGestionScreenState extends State<PaqueteriaGestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _remitenteController = TextEditingController();
  final _busquedaController = TextEditingController();
  PaqueteFoto? _foto;
  String _busqueda = '';
  Map<String, dynamic>? _unidadSeleccionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaqueteriaBloc>().add(const PaqueteriaSolicitada());
      context.read<PaqueteriaBloc>().add(const PaqueteriaUnidadesSolicitadas());
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _remitenteController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(StateSetter setDialogState) async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      if (!mounted) return;
      setDialogState(
        () => _foto = PaqueteFoto(bytes: bytes, nombre: imagen.name),
      );
    }
  }

  Future<void> _solicitarRetiro(BuildContext context, Paquete paquete) async {
    final nombre = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DialogoRetiro(),
    );

    if (nombre == null || !context.mounted) return;
    context.read<PaqueteriaBloc>().add(PaqueteRetirado(paquete.id, nombre));
  }

  void _registrar() {
    if (!_formKey.currentState!.validate()) return;
    final unidad = _unidadSeleccionada!;
    context.read<PaqueteriaBloc>().add(
      PaqueteRegistrado(
        proyectoId: (unidad['proyecto_id'] as num).toInt(),
        descripcion: _descripcionController.text.trim(),
        remitente: _remitenteController.text.trim(),
        unidadPrincipalId: (unidad['id'] as num).toInt(),
        foto: _foto,
      ),
    );
    _descripcionController.clear();
    _remitenteController.clear();
    setState(() {
      _foto = null;
      _unidadSeleccionada = null;
    });
    Navigator.of(context).pop();
  }

  Future<void> _abrirFormulario() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 540,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.9,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setDialogState) =>
                  BlocBuilder<PaqueteriaBloc, PaqueteriaState>(
                    builder: (context, state) => _FormularioRegistro(
                      formKey: _formKey,
                      descripcionController: _descripcionController,
                      remitenteController: _remitenteController,
                      unidades: state.unidades,
                      unidadSeleccionada: _unidadSeleccionada,
                      onUnidadSeleccionada: (unidad) =>
                          setState(() => _unidadSeleccionada = unidad),
                      foto: _foto,
                      onSeleccionarFoto: () => _seleccionarFoto(setDialogState),
                      onRegistrar: _registrar,
                      onCancelar: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _foto = null;
      _unidadSeleccionada = null;
    });
  }

  Future<void> _mostrarEdicion(BuildContext context, Paquete paquete) async {
    if (paquete.unidadPrincipalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede editar: el paquete no tiene unidad asociada.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final descController = TextEditingController(text: paquete.descripcion);
    final remitenteController = TextEditingController(
      text: paquete.remitente ?? '',
    );
    PaqueteFoto? foto;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Editar paquete'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa una descripción'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: remitenteController,
                    decoration: const InputDecoration(
                      labelText: 'Remitente *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el remitente'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Unidad destinataria',
                      border: OutlineInputBorder(),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(paquete.unidadIdentificador ?? 'Unidad'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final imagen = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (imagen != null) {
                        final bytes = await imagen.readAsBytes();
                        setState(
                          () => foto = PaqueteFoto(
                            bytes: bytes,
                            nombre: imagen.name,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(
                      foto == null
                          ? 'Cambiar foto (opcional)'
                          : 'Foto seleccionada',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<PaqueteriaBloc>().add(
                  PaqueteActualizado(
                    id: paquete.id,
                    descripcion: descController.text.trim(),
                    remitente: remitenteController.text.trim(),
                    unidadPrincipalId: int.parse(paquete.unidadPrincipalId!),
                    foto: foto,
                  ),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    descController.dispose();
    remitenteController.dispose();
  }

  List<Paquete> _paquetesFiltrados(List<Paquete> paquetes) {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return paquetes;
    return paquetes.where((p) {
      return p.descripcion.toLowerCase().contains(q) ||
          (p.remitente?.toLowerCase().contains(q) ?? false) ||
          (p.unidadIdentificador?.toLowerCase().contains(q) ?? false) ||
          p.fechaRecepcion.toLowerCase().contains(q) ||
          p.estado.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetería del recinto'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocConsumer<PaqueteriaBloc, PaqueteriaState>(
        listener: (context, state) {
          if (state.status == PaqueteriaStatus.error && state.mensaje != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.mensaje!)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por descripción, remitente o fecha',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _busqueda = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              Expanded(
                child:
                    state.status == PaqueteriaStatus.cargando &&
                        state.paquetes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _paquetesFiltrados(state.paquetes).isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.paquetes.isEmpty
                                  ? 'No hay paquetes registrados.'
                                  : 'Sin resultados para "$_busqueda".',
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final paquetes = _paquetesFiltrados(state.paquetes);
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 330,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 370,
                                ),
                            itemCount: paquetes.length,
                            itemBuilder: (context, index) {
                              final paquete = paquetes[index];
                              return _TarjetaPaqueteGestion(
                                paquete: paquete,
                                onEditar: () =>
                                    _mostrarEdicion(context, paquete),
                                onRetirar: paquete.estaPendiente
                                    ? () => _solicitarRetiro(context, paquete)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<PaqueteriaBloc>().add(
            const PaqueteriaUnidadesSolicitadas(),
          );
          _abrirFormulario();
        },
        icon: const Icon(Icons.add),
        label: const Text('Registrar paquete'),
      ),
    );
  }
}

class _FormularioRegistro extends StatelessWidget {
  const _FormularioRegistro({
    required this.formKey,
    required this.descripcionController,
    required this.remitenteController,
    required this.unidades,
    required this.unidadSeleccionada,
    required this.onUnidadSeleccionada,
    required this.foto,
    required this.onSeleccionarFoto,
    required this.onRegistrar,
    required this.onCancelar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController descripcionController;
  final TextEditingController remitenteController;
  final List<Map<String, dynamic>> unidades;
  final Map<String, dynamic>? unidadSeleccionada;
  final ValueChanged<Map<String, dynamic>?> onUnidadSeleccionada;
  final PaqueteFoto? foto;
  final VoidCallback onSeleccionarFoto;
  final VoidCallback onRegistrar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Registrar paquete',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa una descripción'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: remitenteController,
              decoration: const InputDecoration(
                labelText: 'Remitente *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa el remitente'
                  : null,
            ),
            const SizedBox(height: 8),
            _BuscadorDepartamento(
              unidades: unidades,
              seleccionado: unidadSeleccionada,
              onSeleccionado: onUnidadSeleccionada,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onSeleccionarFoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                foto == null ? 'Agregar foto (opcional)' : 'Foto seleccionada',
              ),
            ),
            if (foto != null) ...[
              const SizedBox(height: 8),
              Text(
                'Vista previa',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  foto!.bytes,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('No se pudo mostrar la imagen seleccionada.'),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancelar,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onRegistrar,
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuscadorDepartamento extends StatefulWidget {
  const _BuscadorDepartamento({
    required this.unidades,
    required this.seleccionado,
    required this.onSeleccionado,
  });

  final List<Map<String, dynamic>> unidades;
  final Map<String, dynamic>? seleccionado;
  final ValueChanged<Map<String, dynamic>?> onSeleccionado;

  @override
  State<_BuscadorDepartamento> createState() => _BuscadorDepartamentoState();
}

class _BuscadorDepartamentoState extends State<_BuscadorDepartamento> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  Map<String, dynamic>? _seleccionado;

  @override
  void initState() {
    super.initState();
    _seleccionado = widget.seleccionado;
    if (widget.seleccionado != null) {
      _controller.text = (widget.seleccionado!['identificador'] ?? '')
          .toString();
    }
  }

  @override
  void didUpdateWidget(covariant _BuscadorDepartamento oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seleccionado != oldWidget.seleccionado) {
      _seleccionado = widget.seleccionado;
      if (_seleccionado != null) {
        _controller.text = (_seleccionado!['identificador'] ?? '').toString();
      }
    }
    if (widget.unidades != oldWidget.unidades && _overlayEntry != null) {
      _actualizarOverlay();
    }
  }

  @override
  void dispose() {
    _ocultarOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _ocultarOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<Map<String, dynamic>> _filtradas(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return widget.unidades;
    return widget.unidades
        .where(
          (u) =>
              (u['identificador'] ?? '').toString().toLowerCase().contains(q),
        )
        .toList();
  }

  void _seleccionar(Map<String, dynamic> unidad) {
    setState(() => _seleccionado = unidad);
    _controller.text = (unidad['identificador'] ?? '').toString();
    widget.onSeleccionado(unidad);
    _ocultarOverlay();
  }

  void _mostrarOverlay() {
    if (_overlayEntry != null) return;
    final fieldWidth = _fieldKey.currentContext?.size?.width ?? 300.0;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _ocultarOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: fieldWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 56),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: _buildLista(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _actualizarOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  Widget _buildLista() {
    final filtradas = _filtradas(_controller.text);
    if (filtradas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          widget.unidades.isEmpty
              ? 'Cargando departamentos...'
              : 'Sin coincidencias',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: filtradas.length,
      itemBuilder: (context, index) {
        final unidad = filtradas[index];
        final id = (unidad['identificador'] ?? '').toString();
        return InkWell(
          onTap: () => _seleccionar(unidad),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(id, style: Theme.of(context).textTheme.bodyMedium),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seleccionado = _seleccionado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CompositedTransformTarget(
          key: _fieldKey,
          link: _layerLink,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Departamento destinatario *',
              hintText: 'Toca para ver la lista o escribe para buscar',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: seleccionado != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _seleccionado = null);
                        widget.onSeleccionado(null);
                        _ocultarOverlay();
                      },
                    )
                  : null,
            ),
            validator: (_) =>
                seleccionado == null ? 'Selecciona un departamento' : null,
            onTap: () {
              _mostrarOverlay();
            },
            onChanged: (_) {
              if (_seleccionado != null) {
                setState(() => _seleccionado = null);
              }
              widget.onSeleccionado(null);
              if (_overlayEntry != null) {
                _actualizarOverlay();
              } else {
                _mostrarOverlay();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            widget.unidades.isEmpty
                ? 'Cargando departamentos...'
                : '${widget.unidades.length} departamentos cargados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.unidades.isEmpty ? Colors.orange : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogoRetiro extends StatefulWidget {
  const _DialogoRetiro();

  @override
  State<_DialogoRetiro> createState() => _DialogoRetiroState();
}

class _DialogoRetiroState extends State<_DialogoRetiro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_nombreController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar retiro'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreController,
          autofocus: true,
          maxLength: 255,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombres y apellidos de quien retira *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Ingresa nombres y apellidos'
              : null,
          onFieldSubmitted: (_) => _confirmar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Confirmar retiro'),
        ),
      ],
    );
  }
}

class _TarjetaPaqueteGestion extends StatelessWidget {
  const _TarjetaPaqueteGestion({
    required this.paquete,
    this.onRetirar,
    this.onEditar,
  });

  final Paquete paquete;
  final VoidCallback? onRetirar;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendiente = paquete.estaPendiente;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) =>
              PaqueteDetalleDialog(paquete: paquete, onRetirar: onRetirar),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: PaqueteCardImage(fotoUrl: paquete.fotoUrl)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paquete.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (paquete.remitente != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'De: ${paquete.remitente}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (paquete.unidadIdentificador != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      'Unidad: ${paquete.unidadIdentificador}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Recibido: ${paquete.fechaRecepcion}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(pendiente ? 'Pendiente' : 'Retirado'),
                        backgroundColor: pendiente
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.tertiaryContainer,
                        labelStyle: TextStyle(
                          color: pendiente
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onTertiaryContainer,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (pendiente)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: onEditar,
                            ),
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                              onPressed: onRetirar,
                              icon: const Icon(Icons.check),
                              label: const Text('Retirar'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
