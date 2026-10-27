import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../infraestructura/domain/entities/tipo_agrupacion.dart';
import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/proyecto_detalle.dart';
import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/entities/tipo_condominio.dart';
import '../bloc/administradores_bloc.dart';
import '../bloc/superadmin_bloc.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Proyectos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_business),
        label: const Text('Proyecto'),
      ),
      body: BlocConsumer<SuperadminBloc, SuperadminState>(
        listener: (context, state) {
          if (state.mensaje != null) {
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.mensaje!),
                  backgroundColor: state.exito
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              );
            context.read<SuperadminBloc>().add(
              const SuperadminMensajeConsumido(),
            );
          }
        },
        builder: (context, state) {
          if (state.proyectos.isEmpty &&
              !state.cargando &&
              state.mensaje == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SuperadminBloc>().add(const ProyectosSolicitados());
            });
          }

          if (state.cargando && state.proyectos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SuperadminBloc>().add(const ProyectosSolicitados());
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (state.cargando) const LinearProgressIndicator(),
                if (state.proyectos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('No hay proyectos registrados.')),
                  ),
                ...state.proyectos.map(
                  (proyecto) => _TarjetaProyecto(proyecto: proyecto),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _abrirFormulario(BuildContext context, {String? proyectoId}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ProyectoFormScreen(proyectoId: proyectoId),
    ),
  );
}

class _TarjetaProyecto extends StatelessWidget {
  const _TarjetaProyecto({required this.proyecto});

  final ResumenProyecto proyecto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.domain, size: 36),
        title: Text(
          proyecto.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(proyecto.descripcion ?? 'Proyecto (tenant)'),
        onTap: () => _abrirFormulario(context, proyectoId: proyecto.id),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${proyecto.agrupaciones} agrup.'),
                Text('${proyecto.unidadesPrincipales} unidades'),
                Text('${proyecto.unidadesAccesorias} accesorias'),
              ],
            ),
            IconButton(
              tooltip: 'Editar proyecto',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  _abrirFormulario(context, proyectoId: proyecto.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProyectoFormScreen extends StatefulWidget {
  const _ProyectoFormScreen({this.proyectoId});

  /// Si es `null` el formulario crea un proyecto; si tiene valor, lo edita.
  final String? proyectoId;

  @override
  State<_ProyectoFormScreen> createState() => _ProyectoFormScreenState();
}

class _ProyectoFormScreenState extends State<_ProyectoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  late final SuperadminBloc _superadminBloc;
  StreamSubscription<SuperadminState>? _suscripcion;
  bool _prefillHecho = false;

  TipoCondominio _tipo = TipoCondominio.torres;
  final Set<ModuloSistema> _modulos = {ModuloSistema.infraestructura};
  final List<_InstalacionForm> _instalaciones = [];
  final Set<String> _adminIds = {};

  final List<_AgrupacionPisosForm> _torres = [
    _AgrupacionPisosForm(nombre: 'Torre A'),
  ];
  final List<_ManzanaForm> _manzanas = [_ManzanaForm(nombre: 'Manzana 1')];
  final _AgrupacionPisosForm _edificio = _AgrupacionPisosForm(
    nombre: 'Edificio',
  );

  bool get _esEdicion => widget.proyectoId != null;

  @override
  void initState() {
    super.initState();
    context.read<AdministradoresBloc>().add(const AdministradoresSolicitados());

    _superadminBloc = context.read<SuperadminBloc>();

    if (_esEdicion) {
      _superadminBloc.add(ProyectoEdicionSolicitada(widget.proyectoId!));
      _suscripcion = _superadminBloc.stream.listen(_onEstado);
    }
  }

  void _onEstado(SuperadminState state) {
    if (_prefillHecho) return;

    final detalle = state.proyectoEnEdicion;

    if (detalle == null || detalle.id != widget.proyectoId) return;

    _prefillHecho = true;

    if (!mounted) return;

    setState(() => _aplicarDetalle(detalle));
  }

  void _aplicarDetalle(ProyectoDetalle detalle) {
    _nombreController.text = detalle.nombre;
    _descripcionController.text = detalle.descripcion ?? '';
    _tipo = detalle.tipoCondominio;

    _modulos
      ..clear()
      ..addAll(detalle.modulos);

    _adminIds
      ..clear()
      ..addAll(detalle.adminIds);

    for (final instalacion in _instalaciones) {
      instalacion.dispose();
    }
    _instalaciones.clear();

    for (final instalacion in detalle.instalacionesExtra) {
      _instalaciones.add(_InstalacionForm.desde(instalacion));
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    if (_esEdicion) {
      _superadminBloc.add(const ProyectoEdicionFinalizada());
    }
    _nombreController.dispose();
    _descripcionController.dispose();
    for (final instalacion in _instalaciones) {
      instalacion.dispose();
    }
    for (final torre in _torres) {
      torre.dispose();
    }
    for (final manzana in _manzanas) {
      manzana.dispose();
    }
    _edificio.dispose();
    super.dispose();
  }

  void _agregarInstalacion() {
    setState(() => _instalaciones.add(_InstalacionForm()));
  }

  void _quitarInstalacion(int index) {
    setState(() => _instalaciones.removeAt(index).dispose());
  }

  void _agregarTorre() {
    setState(
      () => _torres.add(
        _AgrupacionPisosForm(nombre: 'Torre ${_torres.length + 1}'),
      ),
    );
  }

  void _agregarManzana() {
    setState(
      () => _manzanas.add(
        _ManzanaForm(nombre: 'Manzana ${_manzanas.length + 1}'),
      ),
    );
  }

  List<DefinicionAgrupacion> _construirAgrupaciones() {
    final agrupaciones = <DefinicionAgrupacion>[];

    if (_tipo == TipoCondominio.torres || _tipo == TipoCondominio.mixto) {
      for (final torre in _torres) {
        agrupaciones.add(torre.toDefinicion(TipoAgrupacion.torre));
      }
    }

    if (_tipo == TipoCondominio.casas || _tipo == TipoCondominio.mixto) {
      for (final manzana in _manzanas) {
        agrupaciones.add(manzana.toDefinicion());
      }
    }

    if (_tipo == TipoCondominio.edificio) {
      agrupaciones.add(_edificio.toDefinicion(TipoAgrupacion.edificio));
    }

    return agrupaciones;
  }

  List<InstalacionExtra> _construirInstalaciones() {
    return _instalaciones
        .where((form) => form.nombre.text.trim().isNotEmpty)
        .map(
          (form) => InstalacionExtra(
            nombre: form.nombre.text.trim(),
            tipo: form.tipo.text.trim().isEmpty ? null : form.tipo.text.trim(),
            atributos: form.atributos,
          ),
        )
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_modulos.isEmpty) {
      _snack('Debes habilitar al menos un módulo.', error: true);
      return;
    }
    if (_adminIds.isEmpty) {
      _snack('Debes asignar al menos un administrador.', error: true);
      return;
    }

    final descripcion = _descripcionController.text.trim().isEmpty
        ? null
        : _descripcionController.text;
    final instalaciones = _construirInstalaciones();

    if (_esEdicion) {
      _superadminBloc.add(
        ProyectoActualizado(
          id: widget.proyectoId!,
          nombre: _nombreController.text,
          descripcion: descripcion,
          modulos: _modulos.toList(),
          instalaciones: instalaciones,
          adminIds: _adminIds.toList(),
        ),
      );

      return;
    }

    final agrupaciones = _construirAgrupaciones();
    if (agrupaciones.isEmpty) {
      _snack('Debes definir al menos una agrupación.', error: true);
      return;
    }

    _superadminBloc.add(
      ProyectoCreado(
        nombre: _nombreController.text,
        descripcion: descripcion,
        tipoCondominio: _tipo,
        modulos: _modulos.toList(),
        agrupaciones: agrupaciones,
        instalaciones: instalaciones,
        adminIds: _adminIds.toList(),
      ),
    );

    Navigator.of(context).pop();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titulo = _esEdicion ? 'Editar proyecto' : 'Nuevo proyecto';

    return BlocListener<SuperadminBloc, SuperadminState>(
      listenWhen: (previous, current) =>
          _esEdicion && current.exito && current.mensaje != null,
      listener: (context, state) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: BlocBuilder<SuperadminBloc, SuperadminState>(
          builder: (context, superadminState) {
            if (_esEdicion && superadminState.proyectoEnEdicion == null) {
              if (superadminState.cargandoDetalle) {
                return const Center(child: CircularProgressIndicator());
              }

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudo cargar el proyecto.'),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => _superadminBloc.add(
                        ProyectoEdicionSolicitada(widget.proyectoId!),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<AdministradoresBloc, AdministradoresState>(
              builder: (context, adminsState) {
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del proyecto',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Ingresa un nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._seccionTipoCondominio(theme),
                      const Divider(height: 32),
                      ..._seccionEstructura(theme),
                      Text(
                        'Módulos habilitados',
                        style: theme.textTheme.titleMedium,
                      ),
                      ...ModuloSistema.values.map(
                        (modulo) => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(modulo.etiqueta),
                          value: _modulos.contains(modulo),
                          onChanged: (value) => setState(() {
                            if (value) {
                              _modulos.add(modulo);
                            } else {
                              _modulos.remove(modulo);
                            }
                          }),
                        ),
                      ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Text(
                            'Instalaciones extra',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _agregarInstalacion,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Añadir'),
                          ),
                        ],
                      ),
                      ...List.generate(_instalaciones.length, (index) {
                        final form = _instalaciones[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: form.nombre,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre (ej. Quincho)',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: form.tipo,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _quitarInstalacion(index),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 32),
                      Text(
                        'Administradores con acceso',
                        style: theme.textTheme.titleMedium,
                      ),
                      if (adminsState.cargando)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator(),
                        ),
                      if (!adminsState.cargando &&
                          adminsState.administradores.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'No hay administradores. Crea al menos uno en el '
                            'módulo "Administradores".',
                          ),
                        ),
                      ...adminsState.administradores.map(
                        (administrador) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _adminIds.contains(administrador.id),
                          title: Text(administrador.nombre),
                          subtitle: Text(administrador.correo),
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              _adminIds.add(administrador.id);
                            } else {
                              _adminIds.remove(administrador.id);
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: superadminState.guardando ? null : _submit,
                          child: superadminState.guardando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _esEdicion
                                      ? 'Guardar cambios'
                                      : 'Crear proyecto',
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _seccionTipoCondominio(ThemeData theme) {
    if (_esEdicion) {
      return [
        Text('Tipo de condominio', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: Text(_tipo.etiqueta),
        ),
        const SizedBox(height: 4),
        Text(
          'El tipo de condominio no se puede cambiar una vez creada '
          'la estructura del recinto.',
          style: theme.textTheme.bodySmall,
        ),
      ];
    }

    return [
      Text('Tipo de condominio', style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      RadioGroup<TipoCondominio>(
        groupValue: _tipo,
        onChanged: (value) => setState(() => _tipo = value ?? _tipo),
        child: Column(
          children: TipoCondominio.values
              .map(
                (tipo) => RadioListTile<TipoCondominio>(
                  contentPadding: EdgeInsets.zero,
                  value: tipo,
                  title: Text(tipo.etiqueta),
                  subtitle: Text(tipo.descripcion),
                ),
              )
              .toList(),
        ),
      ),
    ];
  }

  List<Widget> _seccionEstructura(ThemeData theme) {
    if (_esEdicion) {
      return [
        Text('Estructura del recinto', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'La estructura (agrupaciones, pisos y unidades) se administra desde '
          'el módulo Infraestructura.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
      ];
    }

    return [
      Text('Estructura del recinto', style: theme.textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        'La estructura se crea junto con el proyecto.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      ..._construirSeccionesEstructura(),
      const Divider(height: 32),
    ];
  }

  List<Widget> _construirSeccionesEstructura() {
    switch (_tipo) {
      case TipoCondominio.torres:
        return _seccionPisos(
          titulo: 'Torres / bloques',
          formularios: _torres,
          onAgregar: _agregarTorre,
          onQuitar: (index) =>
              setState(() => _torres.removeAt(index).dispose()),
        );
      case TipoCondominio.casas:
        return _seccionManzanas();
      case TipoCondominio.edificio:
        return [_cardPisos('Edificio (sin torres)', _edificio, onQuitar: null)];
      case TipoCondominio.mixto:
        return [
          ..._seccionPisos(
            titulo: 'Torres / bloques',
            formularios: _torres,
            onAgregar: _agregarTorre,
            onQuitar: (index) =>
                setState(() => _torres.removeAt(index).dispose()),
          ),
          const SizedBox(height: 8),
          ..._seccionManzanas(),
        ];
    }
  }

  List<Widget> _seccionPisos({
    required String titulo,
    required List<_AgrupacionPisosForm> formularios,
    required VoidCallback onAgregar,
    required void Function(int) onQuitar,
  }) {
    return [
      Row(
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar'),
          ),
        ],
      ),
      ...List.generate(
        formularios.length,
        (index) => _cardPisos(
          null,
          formularios[index],
          onQuitar: formularios.length > 1 ? () => onQuitar(index) : null,
        ),
      ),
    ];
  }

  List<Widget> _seccionManzanas() {
    return [
      Row(
        children: [
          const Text(
            'Manzanas (casas)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _agregarManzana,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar'),
          ),
        ],
      ),
      ...List.generate(
        _manzanas.length,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _manzanas[index].nombre,
                        decoration: const InputDecoration(
                          labelText: 'Nombre (ej. Manzana 1)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Requerido'
                            : null,
                      ),
                    ),
                    if (_manzanas.length > 1)
                      IconButton(
                        onPressed: () =>
                            setState(() => _manzanas.removeAt(index).dispose()),
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _manzanas[index].cantidad,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de casas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) =>
                      (int.tryParse(value ?? '') ?? 0) < 1 ? 'Mínimo 1' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _cardPisos(
    String? titulo,
    _AgrupacionPisosForm form, {
    VoidCallback? onQuitar,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titulo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre (ej. Torre A)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Requerido' : null,
                  ),
                ),
                if (onQuitar != null)
                  IconButton(
                    onPressed: onQuitar,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.pisoDesde,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Piso desde',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) =>
                        int.tryParse(value ?? '') == null ? 'Inválido' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: form.pisoHasta,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Piso hasta',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) =>
                        int.tryParse(value ?? '') == null ? 'Inválido' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: form.unidadesPorPiso,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Unid./piso',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) =>
                        (int.tryParse(value ?? '') ?? 0) < 1 ? 'Mín. 1' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InstalacionForm {
  _InstalacionForm({
    String nombre = '',
    String tipo = '',
    this.atributos = const {},
  }) : nombre = TextEditingController(text: nombre),
       tipo = TextEditingController(text: tipo);

  factory _InstalacionForm.desde(InstalacionExtra instalacion) {
    return _InstalacionForm(
      nombre: instalacion.nombre,
      tipo: instalacion.tipo ?? '',
      atributos: instalacion.atributos,
    );
  }

  final TextEditingController nombre;
  final TextEditingController tipo;
  final Map<String, dynamic> atributos;

  void dispose() {
    nombre.dispose();
    tipo.dispose();
  }
}

class _AgrupacionPisosForm {
  _AgrupacionPisosForm({
    required String nombre,
    String pisoDesde = '1',
    String pisoHasta = '1',
    String unidadesPorPiso = '4',
  }) : nombre = TextEditingController(text: nombre),
       pisoDesde = TextEditingController(text: pisoDesde),
       pisoHasta = TextEditingController(text: pisoHasta),
       unidadesPorPiso = TextEditingController(text: unidadesPorPiso);

  final TextEditingController nombre;
  final TextEditingController pisoDesde;
  final TextEditingController pisoHasta;
  final TextEditingController unidadesPorPiso;

  DefinicionAgrupacion toDefinicion(TipoAgrupacion tipo) {
    return DefinicionAgrupacion(
      nombre: nombre.text.trim(),
      tipo: tipo,
      pisoDesde: int.tryParse(pisoDesde.text) ?? 1,
      pisoHasta: int.tryParse(pisoHasta.text) ?? 1,
      unidadesPorPiso: int.tryParse(unidadesPorPiso.text) ?? 1,
    );
  }

  void dispose() {
    nombre.dispose();
    pisoDesde.dispose();
    pisoHasta.dispose();
    unidadesPorPiso.dispose();
  }
}

class _ManzanaForm {
  _ManzanaForm({required String nombre, String cantidad = '6'})
    : nombre = TextEditingController(text: nombre),
      cantidad = TextEditingController(text: cantidad);

  final TextEditingController nombre;
  final TextEditingController cantidad;

  DefinicionAgrupacion toDefinicion() {
    return DefinicionAgrupacion(
      nombre: nombre.text.trim(),
      tipo: TipoAgrupacion.manzana,
      cantidad: int.tryParse(cantidad.text) ?? 0,
    );
  }

  void dispose() {
    nombre.dispose();
    cantidad.dispose();
  }
}
