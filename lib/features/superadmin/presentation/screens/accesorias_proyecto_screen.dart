import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../infraestructura/domain/entities/arbol_infraestructura.dart';
import '../../../infraestructura/domain/entities/asignacion_accesoria.dart';
import '../../../infraestructura/domain/entities/tipo_asignacion.dart';
import '../../../infraestructura/domain/entities/tipo_unidad_accesoria.dart';
import '../../../infraestructura/domain/entities/unidad_accesoria.dart';
import '../bloc/superadmin_bloc.dart';
import '../widgets/cantidad_accesorias_dialog.dart';

class AccesoriasProyectoScreen extends StatefulWidget {
  const AccesoriasProyectoScreen({
    super.key,
    required this.proyectoId,
    required this.tipo,
    this.expandirOpciones = false,
  });

  final String proyectoId;
  final TipoUnidadAccesoria tipo;
  final bool expandirOpciones;

  @override
  State<AccesoriasProyectoScreen> createState() =>
      _AccesoriasProyectoScreenState();
}

class _AccesoriasProyectoScreenState extends State<AccesoriasProyectoScreen> {
  final Map<String, _BorradorAsignacion> _borradores = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Set<String> _expandidas = {};
  final Set<String> _colapsadas = {};

  late final SuperadminBloc _bloc;
  late bool _expandirTodas;

  String get _etiquetaPlural =>
      widget.tipo == TipoUnidadAccesoria.estacionamiento
      ? 'estacionamientos'
      : 'bodegas';

  @override
  void initState() {
    super.initState();
    _expandirTodas = widget.expandirOpciones;
    _bloc = context.read<SuperadminBloc>();

    final arbol = _bloc.state.estructura;
    if (arbol == null || arbol.proyecto.id != widget.proyectoId) {
      _bloc.add(EstructuraProyectoSolicitada(widget.proyectoId));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String id) {
    return _controllers.putIfAbsent(id, TextEditingController.new);
  }

  FocusNode _focusNode(String id) {
    return _focusNodes.putIfAbsent(id, FocusNode.new);
  }

  _BorradorAsignacion _borrador(String id) {
    return _borradores.putIfAbsent(id, _BorradorAsignacion.new);
  }

  bool _expandida(String id) {
    if (_expandidas.contains(id)) return true;
    if (_colapsadas.contains(id)) return false;
    return _expandirTodas;
  }

  void _alternarExpansion(String id) {
    setState(() {
      if (_expandida(id)) {
        _expandidas.remove(id);
        _colapsadas.add(id);
        _borradores.remove(id);
        _controllers[id]?.clear();
      } else {
        _expandidas.add(id);
        _colapsadas.remove(id);
      }
    });
  }

  bool _marcado(
    TipoAsignacion opcion,
    UnidadAccesoria accesoria,
    _BorradorAsignacion? borrador,
  ) {
    if (borrador != null) return borrador.asignacion == opcion;
    return accesoria.asignacion == opcion;
  }

  bool _cambio(UnidadAccesoria accesoria) {
    final borrador = _borradores[accesoria.id];
    if (borrador == null) return false;
    if (borrador.asignacion == null) return true;
    if (borrador.asignacion == TipoAsignacion.departamento) {
      return accesoria.asignacion != TipoAsignacion.departamento ||
          accesoria.unidadPrincipalId != borrador.unidadPrincipalId;
    }
    return accesoria.asignacion != borrador.asignacion ||
        accesoria.unidadPrincipalId != null;
  }

  bool _valido(_BorradorAsignacion? borrador) {
    if (borrador == null || borrador.asignacion == null) return false;
    if (borrador.asignacion == TipoAsignacion.departamento) {
      return borrador.unidadPrincipalId != null;
    }
    return true;
  }

  bool _puedeActualizar(UnidadAccesoria accesoria) {
    return _cambio(accesoria) && _valido(_borradores[accesoria.id]);
  }

  void _marcarOpcion(
    UnidadAccesoria accesoria,
    TipoAsignacion opcion,
    bool marcado,
  ) {
    final borrador = _borrador(accesoria.id);
    setState(() {
      borrador.textoDepartamento = '';
      borrador.errorDepartamento = false;
      _controller(accesoria.id).clear();
      if (marcado) {
        borrador.asignacion = opcion;
        borrador.unidadPrincipalId = null;
      } else {
        borrador.asignacion = null;
        borrador.unidadPrincipalId = null;
      }
    });
  }

  void _cambiarTextoDepartamento(
    UnidadAccesoria accesoria,
    String texto,
    List<_OpcionDepartamento> opciones,
  ) {
    final borrador = _borrador(accesoria.id);
    final coincidencias = opciones
        .where((opcion) => opcion.etiqueta == texto)
        .toList();

    setState(() {
      borrador.textoDepartamento = texto;
      if (coincidencias.isNotEmpty) {
        borrador.asignacion = TipoAsignacion.departamento;
        borrador.unidadPrincipalId = coincidencias.first.id;
        borrador.errorDepartamento = false;
      } else {
        borrador.asignacion = null;
        borrador.unidadPrincipalId = null;
        borrador.errorDepartamento = texto.trim().isNotEmpty;
      }
    });
  }

  AsignacionAccesoria _asignacion(UnidadAccesoria accesoria) {
    final borrador = _borrador(accesoria.id);
    return AsignacionAccesoria(
      unidadAccesoriaId: accesoria.id,
      asignacion: borrador.asignacion!,
      unidadPrincipalId: borrador.asignacion == TipoAsignacion.departamento
          ? borrador.unidadPrincipalId
          : null,
    );
  }

  void _actualizarUna(UnidadAccesoria accesoria) {
    _bloc.add(
      AsignacionAccesoriaSolicitada(
        proyectoId: widget.proyectoId,
        asignacion: _asignacion(accesoria),
      ),
    );
  }

  void _actualizarTodo(List<UnidadAccesoria> accesorias) {
    final pendientes = accesorias
        .where(_puedeActualizar)
        .map(_asignacion)
        .toList();

    if (pendientes.length < 2) return;

    _bloc.add(
      AsignacionesAccesoriasSolicitadas(
        proyectoId: widget.proyectoId,
        asignaciones: pendientes,
      ),
    );
  }

  Future<void> _agregarAccesorias() async {
    final cantidad = await solicitarCantidadAccesorias(
      context,
      etiqueta: _etiquetaPlural,
    );
    if (cantidad == null) return;

    _bloc.add(
      AccesoriasLoteSolicitadas(
        proyectoId: widget.proyectoId,
        tipo: widget.tipo,
        cantidad: cantidad,
      ),
    );

    if (!mounted) return;
    setState(() => _expandirTodas = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuperadminBloc, SuperadminState>(
      listenWhen: (previous, current) =>
          current.mensaje != null && current.mensaje != previous.mensaje,
      listener: (context, state) {
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
        _bloc.add(const SuperadminMensajeConsumido());
      },
      builder: (context, state) {
        final arbol = state.estructura;
        final cargando =
            state.cargandoEstructura ||
            (arbol == null && state.errorEstructura == null);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.tipo == TipoUnidadAccesoria.estacionamiento
                  ? 'Estacionamientos'
                  : 'Bodegas',
            ),
            actions: [
              IconButton(
                tooltip: 'Agregar $_etiquetaPlural',
                onPressed: state.guardando ? null : _agregarAccesorias,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _construirContenido(state, arbol, cargando),
          bottomNavigationBar: arbol == null
              ? null
              : _barraActualizarTodo(arbol, state.guardando),
        );
      },
    );
  }

  Widget _construirContenido(
    SuperadminState state,
    ArbolInfraestructura? arbol,
    bool cargando,
  ) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorEstructura != null && arbol == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorEstructura!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () =>
                    _bloc.add(EstructuraProyectoSolicitada(widget.proyectoId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (arbol == null) return const SizedBox.shrink();

    final accesorias =
        arbol.unidadesAccesorias
            .where((accesoria) => accesoria.tipo == widget.tipo)
            .toList()
          ..sort((a, b) => a.identificador.compareTo(b.identificador));
    final opciones = _opcionesDepartamento(arbol);

    if (accesorias.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.tipo == TipoUnidadAccesoria.estacionamiento
                    ? Icons.directions_car_outlined
                    : Icons.inventory_2_outlined,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text('No hay $_etiquetaPlural registrados.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: state.guardando ? null : _agregarAccesorias,
                icon: const Icon(Icons.add),
                label: Text('Agregar $_etiquetaPlural'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '${accesorias.length} $_etiquetaPlural',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...accesorias.map(
          (accesoria) => _fila(accesoria, opciones, state.guardando),
        ),
      ],
    );
  }

  Widget _fila(
    UnidadAccesoria accesoria,
    List<_OpcionDepartamento> opciones,
    bool guardando,
  ) {
    final borrador = _borradores[accesoria.id];
    final expandida = _expandida(accesoria.id);
    final mostrarError =
        borrador?.errorDepartamento == true ||
        (borrador?.asignacion == TipoAsignacion.departamento &&
            borrador?.unidadPrincipalId == null);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              widget.tipo == TipoUnidadAccesoria.estacionamiento
                  ? Icons.directions_car_outlined
                  : Icons.inventory_2_outlined,
            ),
            title: Text(
              accesoria.identificador,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Asignación actual: ${_resumenAsignacion(accesoria, opciones)}',
            ),
            trailing: IconButton(
              tooltip: expandida ? 'Salir sin guardar' : 'Editar asignación',
              onPressed: () => _alternarExpansion(accesoria.id),
              icon: Icon(expandida ? Icons.close : Icons.edit_outlined),
            ),
          ),
          if (expandida)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Visita'),
                    value: _marcado(TipoAsignacion.visita, accesoria, borrador),
                    onChanged: guardando
                        ? null
                        : (value) => _marcarOpcion(
                            accesoria,
                            TipoAsignacion.visita,
                            value ?? false,
                          ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Otro'),
                    value: _marcado(TipoAsignacion.otro, accesoria, borrador),
                    onChanged: guardando
                        ? null
                        : (value) => _marcarOpcion(
                            accesoria,
                            TipoAsignacion.otro,
                            value ?? false,
                          ),
                  ),
                  const SizedBox(height: 4),
                  RawAutocomplete<_OpcionDepartamento>(
                    textEditingController: _controller(accesoria.id),
                    focusNode: _focusNode(accesoria.id),
                    displayStringForOption: (opcion) => opcion.etiqueta,
                    optionsBuilder: (value) {
                      final texto = value.text.trim().toLowerCase();
                      if (texto.isEmpty) {
                        return const Iterable<_OpcionDepartamento>.empty();
                      }
                      return opciones.where(
                        (opcion) =>
                            opcion.etiqueta.toLowerCase().contains(texto),
                      );
                    },
                    onSelected: (opcion) {
                      final controller = _controller(accesoria.id);
                      controller.text = opcion.etiqueta;
                      controller.selection = TextSelection.collapsed(
                        offset: controller.text.length,
                      );
                      _cambiarTextoDepartamento(
                        accesoria,
                        opcion.etiqueta,
                        opciones,
                      );
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: !guardando,
                            decoration: InputDecoration(
                              labelText: 'Departamento',
                              hintText: 'Escribe para buscar',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              errorText: mostrarError
                                  ? 'Debes elegir un departamento sugerido.'
                                  : null,
                            ),
                            onChanged: (texto) => _cambiarTextoDepartamento(
                              accesoria,
                              texto,
                              opciones,
                            ),
                            onSubmitted: (_) => onFieldSubmitted(),
                          );
                        },
                    optionsViewBuilder:
                        (context, onSelected, opcionesFiltradas) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 220,
                                  maxWidth: 420,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  children: opcionesFiltradas
                                      .map(
                                        (opcion) => ListTile(
                                          dense: true,
                                          title: Text(opcion.etiqueta),
                                          onTap: () => onSelected(opcion),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: guardando || !_puedeActualizar(accesoria)
                          ? null
                          : () => _actualizarUna(accesoria),
                      child: const Text('Actualizar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _barraActualizarTodo(ArbolInfraestructura arbol, bool guardando) {
    final accesorias = arbol.unidadesAccesorias
        .where((accesoria) => accesoria.tipo == widget.tipo)
        .toList();
    final pendientes = accesorias.where(_puedeActualizar).length;
    final conError = accesorias.any((accesoria) {
      final borrador = _borradores[accesoria.id];
      return borrador != null && _cambio(accesoria) && !_valido(borrador);
    });
    final habilitado = !guardando && pendientes >= 2 && !conError;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: habilitado ? () => _actualizarTodo(accesorias) : null,
            icon: const Icon(Icons.done_all),
            label: Text(
              pendientes >= 2
                  ? 'Actualizar todo ($pendientes)'
                  : 'Actualizar todo',
            ),
          ),
        ),
      ),
    );
  }

  List<_OpcionDepartamento> _opcionesDepartamento(ArbolInfraestructura arbol) {
    return arbol.agrupaciones
        .expand(
          (agrupacion) => agrupacion.unidadesPrincipales.map(
            (unidad) => _OpcionDepartamento(
              id: unidad.unidadPrincipal.id,
              etiqueta:
                  '${agrupacion.agrupacion.nombre} · '
                  '${unidad.unidadPrincipal.identificador}',
            ),
          ),
        )
        .toList();
  }

  String _resumenAsignacion(
    UnidadAccesoria accesoria,
    List<_OpcionDepartamento> opciones,
  ) {
    switch (accesoria.asignacion) {
      case TipoAsignacion.departamento:
        final coincidencias = opciones
            .where((opcion) => opcion.id == accesoria.unidadPrincipalId)
            .toList();
        return coincidencias.isEmpty
            ? 'Departamento'
            : coincidencias.first.etiqueta;
      case TipoAsignacion.visita:
        return 'Visita';
      case TipoAsignacion.otro:
        return 'Otro';
      case null:
        return 'Sin asignar';
    }
  }
}

class _BorradorAsignacion {
  TipoAsignacion? asignacion;
  String? unidadPrincipalId;
  String textoDepartamento = '';
  bool errorDepartamento = false;
}

class _OpcionDepartamento {
  const _OpcionDepartamento({required this.id, required this.etiqueta});

  final String id;
  final String etiqueta;
}
