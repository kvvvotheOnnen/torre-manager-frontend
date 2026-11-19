import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../infraestructura/domain/entities/tipo_agrupacion.dart';
import '../../domain/entities/clasificacion_unidad.dart';
import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/tipo_condominio.dart';
import '../../domain/services/generador_unidades_clasificables.dart';
import '../bloc/administradores_bloc.dart';
import '../bloc/proyecto_wizard_bloc.dart';
import '../bloc/proyecto_wizard_event.dart';
import '../bloc/proyecto_wizard_state.dart';
import '../widgets/wizard_accesorias_panel.dart';
import '../widgets/wizard_step_map.dart';

class ProyectoWizardScreen extends StatefulWidget {
  const ProyectoWizardScreen({super.key});

  @override
  State<ProyectoWizardScreen> createState() => _ProyectoWizardScreenState();
}

class _ProyectoWizardScreenState extends State<ProyectoWizardScreen> {
  static const _pasos = [
    'Datos',
    'Tipo',
    'Estructura',
    'Accesorias',
    'Instalaciones',
    'Administradores',
    'Módulos',
  ];

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formEstructuraKey = GlobalKey<FormState>();
  final _formInstalacionesKey = GlobalKey<FormState>();

  TipoCondominio? _tipo;
  final List<_AgrupacionPisosForm> _torres = [
    _AgrupacionPisosForm(nombre: 'Torre A'),
  ];
  final List<_ManzanaForm> _manzanas = [_ManzanaForm(nombre: 'Manzana 1')];
  final _AgrupacionPisosForm _edificio = _AgrupacionPisosForm(
    nombre: 'Edificio',
  );
  final List<_InstalacionForm> _instalaciones = [];
  final Set<String> _adminIds = {};
  final Set<ModuloSistema> _modulos = {ModuloSistema.infraestructura};
  final _nuevaClasificacionController = TextEditingController();
  final List<_ClasificacionForm> _clasificaciones = [];
  static const _generadorUnidades = GeneradorUnidadesClasificables();

  late final ProyectoWizardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProyectoWizardBloc>();
    _bloc.add(const WizardReiniciado());
    context.read<AdministradoresBloc>().add(const AdministradoresSolicitados());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _nuevaClasificacionController.dispose();
    for (final clasificacion in _clasificaciones) {
      clasificacion.dispose();
    }
    for (final torre in _torres) {
      torre.dispose();
    }
    for (final manzana in _manzanas) {
      manzana.dispose();
    }
    _edificio.dispose();
    for (final instalacion in _instalaciones) {
      instalacion.dispose();
    }
    super.dispose();
  }

  void _snack(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  void _reiniciarEstructura() {
    for (final torre in _torres) {
      torre.dispose();
    }
    for (final manzana in _manzanas) {
      manzana.dispose();
    }
    _torres
      ..clear()
      ..add(_AgrupacionPisosForm(nombre: 'Torre A'));
    _manzanas
      ..clear()
      ..add(_ManzanaForm(nombre: 'Manzana 1'));
    _edificio
      ..nombre.text = 'Edificio'
      ..pisoDesde.text = '1'
      ..pisoHasta.text = '1'
      ..unidadesPorPiso.text = '4'
      ..limpiarExcepciones();
    for (final clasificacion in _clasificaciones) {
      clasificacion.dispose();
    }
    _clasificaciones.clear();
  }

  void _seleccionarTipo(TipoCondominio? tipo) {
    if (tipo == null || tipo == _tipo) return;

    setState(() {
      _tipo = tipo;
      _reiniciarEstructura();
    });
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

  void _agregarInstalacion() {
    setState(() => _instalaciones.add(_InstalacionForm()));
  }

  void _quitarInstalacion(int index) {
    setState(() => _instalaciones.removeAt(index).dispose());
  }

  List<DefinicionAgrupacion> _construirAgrupaciones() {
    final agrupaciones = <DefinicionAgrupacion>[];
    final tipo = _tipo;

    if (tipo == null) return agrupaciones;

    if (tipo == TipoCondominio.torres || tipo == TipoCondominio.mixto) {
      for (final torre in _torres) {
        agrupaciones.add(torre.toDefinicion(TipoAgrupacion.torre));
      }
    }

    if (tipo == TipoCondominio.casas || tipo == TipoCondominio.mixto) {
      for (final manzana in _manzanas) {
        agrupaciones.add(manzana.toDefinicion());
      }
    }

    if (tipo == TipoCondominio.edificio) {
      agrupaciones.add(_edificio.toDefinicion(TipoAgrupacion.edificio));
    }

    return agrupaciones;
  }

  List<InstalacionExtra> _construirInstalaciones() {
    final manuales = _instalaciones
        .where((form) => form.nombre.text.trim().isNotEmpty)
        .map(
          (form) => InstalacionExtra(
            nombre: form.nombre.text.trim(),
            capacidad: int.tryParse(form.capacidad.text.trim()) ?? 0,
            descripcion: form.descripcion.text.trim().isEmpty
                ? null
                : form.descripcion.text.trim(),
          ),
        )
        .toList();

    return [...manuales, ..._instalacionesDeExcepciones()];
  }

  List<InstalacionExtra> _instalacionesDeExcepciones() {
    if (_tipo != TipoCondominio.edificio) return const [];

    return instalacionesDePisosExcepcion(_edificio.toPisosExcepcion());
  }

  String _identificadorUnidad(String prefijo, int piso, int numero) {
    final base = prefijo.isEmpty ? '' : '$prefijo-';
    return '$base$piso${numero.toString().padLeft(2, '0')}';
  }

  String? _validarExcepcionesEdificio() {
    if (_tipo != TipoCondominio.edificio) return null;

    final desde = int.tryParse(_edificio.pisoDesde.text.trim());
    final hasta = int.tryParse(_edificio.pisoHasta.text.trim());
    if (desde == null || hasta == null || hasta < desde) return null;

    final pisos = <int>{};

    for (final excepcion in _edificio.excepciones) {
      if (excepcion.piso < desde || excepcion.piso > hasta) {
        return 'El piso ${excepcion.piso} está fuera del rango configurado.';
      }

      if (!pisos.add(excepcion.piso)) {
        return 'El piso ${excepcion.piso} está repetido en las excepciones.';
      }

      for (final unidad in excepcion.unidades) {
        if (unidad.tipo == null) {
          return 'Selecciona unidad simple o instalación extra en el piso ${excepcion.piso}.';
        }

        if (unidad.tipo == TipoUnidadExcepcion.simple) continue;

        final nombre = unidad.identificador.text.trim();
        if (nombre.isEmpty) {
          return 'Completa el nombre de la instalación del piso ${excepcion.piso}.';
        }

        final capacidad = int.tryParse(unidad.capacidad.text.trim());
        if (capacidad == null || capacidad < 1 || capacidad > 500) {
          return 'La capacidad de "$nombre" debe estar entre 1 y 500.';
        }

        if (unidad.descripcion.text.trim().length > 100) {
          return 'La descripción de "$nombre" no puede superar 100 caracteres.';
        }
      }
    }

    return null;
  }

  List<UnidadClasificable> _unidadesActuales() {
    return _generadorUnidades.paraDefiniciones(_construirAgrupaciones());
  }

  void _agregarClasificacion() {
    final nombre = _nuevaClasificacionController.text.trim();

    if (nombre.isEmpty) {
      _snack('Ingresa un nombre para la clasificación.');
      return;
    }

    if (nombre.length > 100) {
      _snack('El nombre no puede superar 100 caracteres.');
      return;
    }

    final existe = _clasificaciones.any(
      (clasificacion) =>
          clasificacion.nombre.text.trim().toLowerCase() ==
          nombre.toLowerCase(),
    );

    if (existe) {
      _snack('Ya existe una clasificación con ese nombre.');
      return;
    }

    setState(() {
      _clasificaciones.add(_ClasificacionForm(nombre: nombre));
      _nuevaClasificacionController.clear();
    });
  }

  List<ClasificacionUnidad> _construirClasificaciones() {
    final clavesValidas = _unidadesActuales().map((u) => u.clave).toSet();

    return _clasificaciones
        .where((clasificacion) => clasificacion.nombre.text.trim().isNotEmpty)
        .map(
          (clasificacion) => ClasificacionUnidad(
            nombre: clasificacion.nombre.text.trim(),
            unidades: clasificacion.unidades
                .where((unidad) => clavesValidas.contains(unidad.clave))
                .toList(),
          ),
        )
        .toList();
  }

  bool _formPisosListo(_AgrupacionPisosForm form) {
    final desde = int.tryParse(form.pisoDesde.text.trim());
    final hasta = int.tryParse(form.pisoHasta.text.trim());
    final unidades = int.tryParse(form.unidadesPorPiso.text.trim());

    return desde != null &&
        hasta != null &&
        unidades != null &&
        hasta >= desde &&
        unidades >= 1;
  }

  void _siguiente(ProyectoWizardState state) {
    switch (state.pasoActual) {
      case 0:
        if (_nombreController.text.trim().isEmpty) {
          _snack('Ingresa el nombre del proyecto.');
          return;
        }
        _bloc.add(
          WizardIniciado(
            nombre: _nombreController.text,
            descripcion: _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text,
          ),
        );
        return;
      case 1:
        if (_tipo == null) {
          _snack('Selecciona el tipo de condominio.');
          return;
        }
        _bloc.add(WizardTipoGuardado(_tipo!));
        return;
      case 2:
        if (!(_formEstructuraKey.currentState?.validate() ?? false)) return;
        final errorExcepciones = _validarExcepcionesEdificio();
        if (errorExcepciones != null) {
          _snack(errorExcepciones);
          return;
        }
        final agrupaciones = _construirAgrupaciones();
        if (agrupaciones.isEmpty) {
          _snack('Debes definir al menos una agrupación.');
          return;
        }
        _bloc.add(
          WizardEstructuraGuardada(
            agrupaciones,
            clasificaciones: _construirClasificaciones(),
          ),
        );
        return;
      case 3:
        _bloc.add(const WizardPasoAvanzado());
        return;
      case 4:
        if (!(_formInstalacionesKey.currentState?.validate() ?? false)) return;
        final instalaciones = _construirInstalaciones();
        final nombres = <String>{};
        for (final instalacion in instalaciones) {
          if (!nombres.add(instalacion.nombre.toLowerCase())) {
            _snack('Hay instalaciones con nombres duplicados.');
            return;
          }
        }
        _bloc.add(WizardInstalacionesGuardadas(instalaciones));
        return;
      case 5:
        if (_adminIds.isEmpty) {
          _snack('Asigna al menos un administrador.');
          return;
        }
        _bloc.add(WizardAdministradoresGuardados(_adminIds.toList()));
        return;
      case 6:
        if (_modulos.isEmpty) {
          _snack('Habilita al menos un módulo.');
          return;
        }
        _bloc.add(WizardFinalizado(_modulos.toList(), _adminIds.toList()));
        return;
    }
  }

  void _atras() {
    _bloc.add(const WizardPasoRetrocedido());
  }

  Future<void> _confirmarSalida() async {
    final primerPaso = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salir de la creación'),
        content: const Text(
          'Se perderá todo el progreso guardado del proyecto en creación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuar creando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (primerPaso != true || !mounted) return;

    final segundoPaso = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar salida'),
        content: const Text(
          '¿Seguro que deseas salir sin guardar el progreso? Esta acción '
          'eliminará el proyecto en creación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Salir sin guardar'),
          ),
        ],
      ),
    );

    if (segundoPaso != true || !mounted) return;

    _bloc.add(const WizardDescartado());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProyectoWizardBloc, ProyectoWizardState>(
      listenWhen: (previous, current) =>
          previous.pasoActual != current.pasoActual ||
          previous.guardando != current.guardando ||
          previous.descartando != current.descartando ||
          previous.descartado != current.descartado ||
          previous.finalizado != current.finalizado ||
          previous.proyectoId != current.proyectoId ||
          previous.mensaje != current.mensaje,
      listener: (context, state) {
        if (state.finalizado) {
          Navigator.of(context).pop(true);
          return;
        }

        if (state.descartado) {
          Navigator.of(context).pop(false);
          return;
        }

        if (state.mensaje != null) {
          _snack(state.mensaje!);
          _bloc.add(const WizardMensajeConsumido());
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_bloc.state.guardando || _bloc.state.descartando) return;
            if (_bloc.state.pasoActual > 0) {
              _bloc.add(const WizardPasoRetrocedido());
              return;
            }
            _confirmarSalida();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Nuevo proyecto'),
              actions: [
                TextButton.icon(
                  onPressed: state.guardando || state.descartando
                      ? null
                      : _confirmarSalida,
                  icon: const Icon(Icons.logout),
                  label: const Text('Salir'),
                ),
              ],
            ),
            body: Column(
              children: [
                WizardStepMap(pasos: _pasos, pasoActual: state.pasoActual),
                const Divider(height: 1),
                Expanded(child: _construirPaso(state)),
                if (state.guardando) const LinearProgressIndicator(),
                _barraNavegacion(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirPaso(ProyectoWizardState state) {
    switch (state.pasoActual) {
      case 0:
        return _pasoDatos();
      case 1:
        return _pasoTipo();
      case 2:
        return _pasoEstructura();
      case 3:
        final proyectoId = state.proyectoId;
        if (proyectoId == null) return const SizedBox.shrink();
        return WizardAccesoriasPanel(proyectoId: proyectoId);
      case 4:
        return _pasoInstalaciones();
      case 5:
        return _pasoAdministradores();
      case 6:
        return _pasoModulos();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _barraNavegacion(ProyectoWizardState state) {
    final esUltimo = state.pasoActual == 6;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: state.pasoActual == 0 || state.guardando
                  ? null
                  : _atras,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Atrás'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: state.guardando || state.descartando
                  ? null
                  : () => _siguiente(state),
              icon: Icon(esUltimo ? Icons.check : Icons.arrow_forward),
              label: Text(esUltimo ? 'Finalizar' : 'Siguiente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pasoDatos() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Datos del proyecto',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre del proyecto',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _pasoTipo() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tipo de condominio', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<TipoCondominio>(
          groupValue: _tipo,
          onChanged: _seleccionarTipo,
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
        if (_tipo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Si cambias el tipo, la estructura ya guardada se reiniciará.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _pasoEstructura() {
    return Form(
      key: _formEstructuraKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Estructura del recinto',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'La estructura se guarda al continuar al siguiente paso.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ..._construirSeccionesEstructura(),
          if (_tipo != null) _seccionClasificaciones(),
        ],
      ),
    );
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
        return [
          _cardPisos(
            'Edificio (sin torres)',
            _edificio,
            onQuitar: null,
            permiteExcepciones: true,
          ),
        ];
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
      case null:
        return const [Text('Selecciona primero el tipo de condominio.')];
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

  Widget _seccionClasificaciones() {
    final theme = Theme.of(context);
    final unidades = _unidadesActuales();
    final clavesValidas = unidades.map((unidad) => unidad.clave).toSet();
    final asignadas = <String>{
      for (final clasificacion in _clasificaciones)
        for (final unidad in clasificacion.unidades)
          if (clavesValidas.contains(unidad.clave)) unidad.clave,
    };
    final sinClasificar = unidades
        .where((unidad) => !asignadas.contains(unidad.clave))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Clasificación de unidades',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${unidades.length} unidades',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Text(
          'Crea clasificaciones con el nombre que decidas y asigna unidades. '
          'Las unidades sin clasificar quedan en "Estándar" y una unidad solo '
          'puede pertenecer a una clasificación.',
          style: theme.textTheme.bodySmall,
        ),
        if (unidades.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Registra unidades por piso para habilitar la clasificación.',
            ),
          )
        else ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nuevaClasificacionController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva clasificación',
                    hintText: 'Ej. Unidad grande',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _agregarClasificacion(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _agregarClasificacion,
                child: const Text('Crear'),
              ),
            ],
          ),
          ..._clasificaciones.map(
            (clasificacion) => _cardClasificacion(clasificacion, clavesValidas),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              sinClasificar == 1
                  ? '1 unidad quedará como Estándar.'
                  : '$sinClasificar unidades quedarán como Estándar.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _cardClasificacion(
    _ClasificacionForm clasificacion,
    Set<String> clavesValidas,
  ) {
    final visibles = clasificacion.unidades
        .where((unidad) => clavesValidas.contains(unidad.clave))
        .length;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        title: Text(
          clasificacion.nombre.text.trim(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          visibles == 1 ? '1 unidad asignada' : '$visibles unidades asignadas',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => _abrirDialogoAsignacion(clasificacion),
              icon: const Icon(Icons.playlist_add_check, size: 18),
              label: const Text('Asignar unidades'),
            ),
            IconButton(
              tooltip: 'Eliminar clasificación',
              onPressed: () => setState(() {
                _clasificaciones.remove(clasificacion);
                clasificacion.dispose();
              }),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirDialogoAsignacion(
    _ClasificacionForm clasificacion,
  ) async {
    final unidades = _unidadesActuales();
    final clavesValidas = unidades.map((unidad) => unidad.clave).toSet();
    final clavesOtras = <String>{
      for (final otra in _clasificaciones)
        if (!identical(otra, clasificacion))
          for (final unidad in otra.unidades)
            if (clavesValidas.contains(unidad.clave)) unidad.clave,
    };
    final disponibles = unidades
        .where((unidad) => !clavesOtras.contains(unidad.clave))
        .toList();
    final seleccionadas = clasificacion.unidades
        .where((unidad) => clavesValidas.contains(unidad.clave))
        .toList();
    final mostrarAgrupacion =
        disponibles.map((unidad) => unidad.agrupacion).toSet().length > 1;

    final resultado = await showDialog<List<UnidadClasificable>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoAsignarUnidades(
        titulo: clasificacion.nombre.text.trim(),
        unidades: disponibles,
        seleccionadas: seleccionadas,
        mostrarAgrupacion: mostrarAgrupacion,
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      clasificacion.unidades
        ..clear()
        ..addAll(resultado);
    });
  }

  Widget _cardPisos(
    String? titulo,
    _AgrupacionPisosForm form, {
    VoidCallback? onQuitar,
    bool permiteExcepciones = false,
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
                    onChanged: (_) => setState(() {}),
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
                    onChanged: (_) => setState(() {}),
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
            if (permiteExcepciones) _seccionExcepciones(form),
          ],
        ),
      ),
    );
  }

  Widget _seccionExcepciones(_AgrupacionPisosForm form) {
    if (!_formPisosListo(form)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          const Text(
            'Pisos con excepción',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Completa piso desde, piso hasta y unidades por piso para '
              'habilitar esta sección.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    final desde = int.tryParse(form.pisoDesde.text.trim());
    final hasta = int.tryParse(form.pisoHasta.text.trim());
    final disponibles = <int>[];

    if (desde != null && hasta != null && hasta >= desde) {
      for (var piso = desde; piso <= hasta; piso++) {
        if (!form.excepciones.any((excepcion) => excepcion.piso == piso)) {
          disponibles.add(piso);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pisos con excepción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButton<int>(
              value: null,
              hint: const Text('Añadir piso'),
              items: disponibles
                  .map(
                    (piso) => DropdownMenuItem<int>(
                      value: piso,
                      child: Text('Piso $piso'),
                    ),
                  )
                  .toList(),
              onChanged: disponibles.isEmpty
                  ? null
                  : (piso) {
                      if (piso == null) return;
                      setState(
                        () => form.excepciones.add(_PisoExcepcionForm(piso)),
                      );
                    },
            ),
          ],
        ),
        Text(
          'Las unidades de estos pisos se crean manualmente y respetan la '
          'numeración del piso. Un piso con excepción puede quedar vacío: '
          'nace sin unidades y salta la generación automática.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (form.excepciones.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Sin pisos con excepción.'),
          ),
        ...form.excepciones.map(
          (excepcion) => _cardPisoExcepcion(form, excepcion),
        ),
      ],
    );
  }

  Widget _cardPisoExcepcion(
    _AgrupacionPisosForm form,
    _PisoExcepcionForm excepcion,
  ) {
    return Card(
      key: ObjectKey(excepcion),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(
              () => excepcion.expandido = !excepcion.expandido,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Icon(
                    excepcion.expandido
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Piso ${excepcion.piso}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          excepcion.resumen,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Quitar piso con excepción',
                    onPressed: () => setState(() {
                      form.excepciones.remove(excepcion);
                      excepcion.dispose();
                    }),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
          if (excepcion.expandido)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            if (excepcion.unidades.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'Piso vacío: sin unidades ni instalaciones. Agrega una '
                  'unidad si quieres usar este piso.',
                ),
              ),
            ..._cardsUnidadesExcepcion(excepcion),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(
                  () => excepcion.unidades.add(_UnidadExcepcionForm()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar unidad'),
              ),
            ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _cardsUnidadesExcepcion(_PisoExcepcionForm excepcion) {
    var secuenciaSimple = 0;
    final cards = <Widget>[];

    for (var index = 0; index < excepcion.unidades.length; index++) {
      final unidad = excepcion.unidades[index];

      if (unidad.tipo == TipoUnidadExcepcion.simple) {
        secuenciaSimple++;
      }

      cards.add(_cardUnidadExcepcion(excepcion, index, secuenciaSimple));
    }

    return cards;
  }

  Widget _cardUnidadExcepcion(
    _PisoExcepcionForm excepcion,
    int index,
    int secuenciaSimple,
  ) {
    final unidad = excepcion.unidades[index];
    final esInstalacion = unidad.tipo == TipoUnidadExcepcion.instalacionExtra;
    final esSimple = unidad.tipo == TipoUnidadExcepcion.simple;
    // Las excepciones solo existen para el edificio; sus unidades se
    // identifican como "Unidad-<piso><n>".
    final identificadorSugerido = _identificadorUnidad(
      'Unidad',
      excepcion.piso,
      secuenciaSimple,
    );

    return Card(
      key: ObjectKey(unidad),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    esInstalacion
                        ? 'Instalación extra'
                        : esSimple
                        ? 'Unidad simple'
                        : 'Unidad ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar unidad',
                  onPressed: () => setState(
                    () => excepcion.unidades.removeAt(index).dispose(),
                  ),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FormField<TipoUnidadExcepcion>(
              initialValue: unidad.tipo,
              validator: (value) =>
                  value == null ? 'Selecciona una opción' : null,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Unidad simple'),
                      value: esSimple,
                      onChanged: (value) => setState(() {
                        unidad.tipo = (value ?? false)
                            ? TipoUnidadExcepcion.simple
                            : null;
                        field.didChange(unidad.tipo);
                      }),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Instalación extra'),
                      value: esInstalacion,
                      onChanged: (value) => setState(() {
                        unidad.tipo = (value ?? false)
                            ? TipoUnidadExcepcion.instalacionExtra
                            : null;
                        field.didChange(unidad.tipo);
                      }),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (esSimple)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Identificador asignado',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(identificadorSugerido),
              ),
            if (esInstalacion) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: unidad.identificador,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la instalación',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: unidad.capacidad,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (1-500)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.isEmpty) return 'Ingresa la capacidad';
                  final capacidad = int.tryParse(texto);
                  if (capacidad == null) return 'Debe ser un número';
                  if (capacidad < 1 || capacidad > 500) return 'Entre 1 y 500';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: unidad.descripcion,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  counterText: '',
                ),
                validator: (value) => (value?.trim().length ?? 0) > 100
                    ? 'Máximo 100 caracteres'
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pasoInstalaciones() {
    final theme = Theme.of(context);
    final excepciones = _instalacionesDeExcepciones();

    return Form(
      key: _formInstalacionesKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Instalaciones extra', style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _agregarInstalacion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Paso opcional. Ejemplos: quincho, piscina, gimnasio.',
            style: theme.textTheme.bodySmall,
          ),
          if (excepciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Instalaciones desde pisos con excepción',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Se guardan automáticamente al continuar. Para modificarlas, '
              'vuelve al paso de estructura.',
              style: theme.textTheme.bodySmall,
            ),
            ...excepciones.map(
              (instalacion) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.lock_outline, size: 18),
                  title: Text(instalacion.nombre),
                  subtitle: Text(
                    'Capacidad ${instalacion.capacidad}'
                    '${instalacion.descripcion != null ? ' · ${instalacion.descripcion}' : ''}',
                  ),
                ),
              ),
            ),
          ],
          ...List.generate(_instalaciones.length, (index) {
            final form = _instalaciones[index];
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
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
                          controller: form.capacidad,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacidad (1-500)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            final texto = value?.trim() ?? '';
                            if (texto.isEmpty) {
                              return form.nombre.text.trim().isNotEmpty
                                  ? 'Ingresa la capacidad'
                                  : null;
                            }
                            final capacidad = int.tryParse(texto);
                            if (capacidad == null) return 'Debe ser un número';
                            if (capacidad < 1 || capacidad > 500) {
                              return 'Entre 1 y 500';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _quitarInstalacion(index),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: form.descripcion,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      counterText: '',
                    ),
                    validator: (value) => (value?.trim().length ?? 0) > 100
                        ? 'Máximo 100 caracteres'
                        : null,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pasoAdministradores() {
    final theme = Theme.of(context);

    return BlocBuilder<AdministradoresBloc, AdministradoresState>(
      builder: (context, adminsState) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Administradores con acceso',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Debes asignar al menos un administrador.',
              style: theme.textTheme.bodySmall,
            ),
            if (adminsState.cargando)
              const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              ),
            if (!adminsState.cargando && adminsState.administradores.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No hay administradores. Crea al menos uno en el módulo '
                  '"Administradores".',
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
          ],
        );
      },
    );
  }

  Widget _pasoModulos() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Módulos habilitados', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Habilita al menos un módulo para finalizar.',
          style: theme.textTheme.bodySmall,
        ),
        ...ModuloSistema.values.map(
          (modulo) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(modulo.etiqueta),
            subtitle: const Text('Siempre habilitado para el proyecto'),
            value: true,
            onChanged: null,
          ),
        ),
      ],
    );
  }
}

class _InstalacionForm {
  _InstalacionForm() : nombre = TextEditingController();

  final TextEditingController nombre;
  final TextEditingController capacidad = TextEditingController();
  final TextEditingController descripcion = TextEditingController();

  void dispose() {
    nombre.dispose();
    capacidad.dispose();
    descripcion.dispose();
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
  final List<_PisoExcepcionForm> excepciones = [];

  DefinicionAgrupacion toDefinicion(TipoAgrupacion tipo) {
    return DefinicionAgrupacion(
      nombre: nombre.text.trim(),
      tipo: tipo,
      pisoDesde: int.tryParse(pisoDesde.text) ?? 1,
      pisoHasta: int.tryParse(pisoHasta.text) ?? 1,
      unidadesPorPiso: int.tryParse(unidadesPorPiso.text) ?? 1,
      pisosExcepcion: toPisosExcepcion(),
    );
  }

  List<PisoExcepcion> toPisosExcepcion() {
    return excepciones
        .map(
          (excepcion) => PisoExcepcion(
            piso: excepcion.piso,
            unidades: excepcion.unidades
                      .map(
                        (unidad) => UnidadExcepcion(
                          identificador:
                              unidad.tipo ==
                                  TipoUnidadExcepcion.instalacionExtra
                              ? unidad.identificador.text.trim()
                              : '',
                          tipo: unidad.tipo ?? TipoUnidadExcepcion.simple,
                          capacidad: int.tryParse(unidad.capacidad.text.trim()),
                          descripcion: unidad.descripcion.text.trim().isEmpty
                              ? null
                              : unidad.descripcion.text.trim(),
                        ),
                      )
                      .toList(),
          ),
        )
        .toList();
  }

  void limpiarExcepciones() {
    for (final excepcion in excepciones) {
      excepcion.dispose();
    }
    excepciones.clear();
  }

  void dispose() {
    nombre.dispose();
    pisoDesde.dispose();
    pisoHasta.dispose();
    unidadesPorPiso.dispose();
    limpiarExcepciones();
  }
}

class _DialogoAsignarUnidades extends StatefulWidget {
  const _DialogoAsignarUnidades({
    required this.titulo,
    required this.unidades,
    required this.seleccionadas,
    required this.mostrarAgrupacion,
  });

  final String titulo;
  final List<UnidadClasificable> unidades;
  final List<UnidadClasificable> seleccionadas;
  final bool mostrarAgrupacion;

  @override
  State<_DialogoAsignarUnidades> createState() =>
      _DialogoAsignarUnidadesState();
}

class _DialogoAsignarUnidadesState extends State<_DialogoAsignarUnidades> {
  final TextEditingController _busqueda = TextEditingController();
  late final Set<String> _seleccionadas = widget.seleccionadas
      .map((unidad) => unidad.clave)
      .toSet();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  List<UnidadClasificable> get _filtradas {
    final query = _busqueda.text.trim().toLowerCase();
    if (query.isEmpty) return widget.unidades;

    return widget.unidades
        .where(
          (unidad) =>
              unidad.identificador.toLowerCase().contains(query) ||
              unidad.agrupacion.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtradas = _filtradas;

    return AlertDialog(
      title: Text('Asignar unidades · ${widget.titulo}'),
      content: SizedBox(
        width: 520,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _busqueda,
              decoration: const InputDecoration(
                hintText: 'Buscar unidad',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtradas.isEmpty
                  ? const Center(
                      child: Text('No hay unidades disponibles.'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 54,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: filtradas.length,
                      itemBuilder: (context, index) {
                        final unidad = filtradas[index];
                        final seleccionada = _seleccionadas.contains(
                          unidad.clave,
                        );

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() {
                            if (seleccionada) {
                              _seleccionadas.remove(unidad.clave);
                            } else {
                              _seleccionadas.add(unidad.clave);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: seleccionada
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                width: seleccionada ? 2 : 1,
                              ),
                              color: seleccionada
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  unidad.identificador,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.mostrarAgrupacion)
                                  Text(
                                    unidad.agrupacion,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_seleccionadas.length} seleccionadas',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Salir sin guardar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    widget.unidades
                        .where(
                          (unidad) => _seleccionadas.contains(unidad.clave),
                        )
                        .toList(),
                  ),
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClasificacionForm {
  _ClasificacionForm({String nombre = ''})
    : nombre = TextEditingController(text: nombre);

  final TextEditingController nombre;
  final List<UnidadClasificable> unidades = [];

  void dispose() {
    nombre.dispose();
  }
}

class _PisoExcepcionForm {
  _PisoExcepcionForm(this.piso);

  final int piso;
  final List<_UnidadExcepcionForm> unidades = [];
  bool expandido = false;

  String get resumen {
    if (unidades.isEmpty) return 'Piso vacío';
    if (unidades.length == 1) return '1 unidad';
    return '${unidades.length} unidades';
  }

  void dispose() {
    for (final unidad in unidades) {
      unidad.dispose();
    }
    unidades.clear();
  }
}

class _UnidadExcepcionForm {
  final TextEditingController identificador = TextEditingController();
  final TextEditingController capacidad = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  TipoUnidadExcepcion? tipo;

  void dispose() {
    identificador.dispose();
    capacidad.dispose();
    descripcion.dispose();
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
