// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../infraestructura/domain/entities/arbol_infraestructura.dart';
import '../../../infraestructura/domain/entities/asignacion_accesoria.dart';
import '../../../infraestructura/domain/entities/tipo_asignacion.dart';
import '../../../infraestructura/domain/entities/tipo_unidad_accesoria.dart';
import '../../../infraestructura/domain/usecases/asignar_unidad_accesoria_usecase.dart';
import '../../../infraestructura/domain/usecases/crear_unidades_accesorias_en_lote_usecase.dart';
import '../../../infraestructura/domain/usecases/obtener_arbol_infraestructura_usecase.dart';
import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/proyecto_detalle.dart';
import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/entities/tipo_condominio.dart';
import '../../domain/usecases/actualizar_proyecto_usecase.dart';
import '../../domain/usecases/crear_proyecto_usecase.dart';
import '../../domain/usecases/obtener_proyecto_usecase.dart';
import '../../domain/usecases/listar_proyectos_usecase.dart';

sealed class SuperadminEvent extends Equatable {
  const SuperadminEvent();

  @override
  List<Object?> get props => [];
}

class ProyectosSolicitados extends SuperadminEvent {
  const ProyectosSolicitados();
}

class ProyectoCreado extends SuperadminEvent {
  const ProyectoCreado({
    required this.nombre,
    required this.descripcion,
    required this.tipoCondominio,
    required this.modulos,
    required this.agrupaciones,
    required this.instalaciones,
    required this.adminIds,
    this.estacionamientos = 0,
    this.bodegas = 0,
  });

  final String nombre;
  final String? descripcion;
  final TipoCondominio tipoCondominio;
  final List<ModuloSistema> modulos;
  final List<DefinicionAgrupacion> agrupaciones;
  final List<InstalacionExtra> instalaciones;
  final List<String> adminIds;
  final int estacionamientos;
  final int bodegas;

  @override
  List<Object?> get props => [
    nombre,
    descripcion,
    tipoCondominio,
    modulos,
    agrupaciones,
    instalaciones,
    adminIds,
    estacionamientos,
    bodegas,
  ];
}

class AccesoriasLoteSolicitadas extends SuperadminEvent {
  const AccesoriasLoteSolicitadas({
    required this.proyectoId,
    required this.tipo,
    required this.cantidad,
    this.asignacion,
  });

  final String proyectoId;
  final TipoUnidadAccesoria tipo;
  final int cantidad;
  final TipoAsignacion? asignacion;

  @override
  List<Object?> get props => [proyectoId, tipo, cantidad, asignacion];
}

class AsignacionAccesoriaSolicitada extends SuperadminEvent {
  const AsignacionAccesoriaSolicitada({
    required this.proyectoId,
    required this.asignacion,
  });

  final String proyectoId;
  final AsignacionAccesoria asignacion;

  @override
  List<Object?> get props => [proyectoId, asignacion];
}

class AsignacionesAccesoriasSolicitadas extends SuperadminEvent {
  const AsignacionesAccesoriasSolicitadas({
    required this.proyectoId,
    required this.asignaciones,
  });

  final String proyectoId;
  final List<AsignacionAccesoria> asignaciones;

  @override
  List<Object?> get props => [proyectoId, asignaciones];
}

class ProyectoEdicionSolicitada extends SuperadminEvent {
  const ProyectoEdicionSolicitada(this.proyectoId);

  final String proyectoId;

  @override
  List<Object?> get props => [proyectoId];
}

class ProyectoEdicionFinalizada extends SuperadminEvent {
  const ProyectoEdicionFinalizada();
}

class EstructuraProyectoSolicitada extends SuperadminEvent {
  const EstructuraProyectoSolicitada(this.proyectoId);

  final String proyectoId;

  @override
  List<Object?> get props => [proyectoId];
}

class ProyectoActualizado extends SuperadminEvent {
  const ProyectoActualizado({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.modulos,
    required this.instalaciones,
    required this.adminIds,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final List<ModuloSistema> modulos;
  final List<InstalacionExtra> instalaciones;
  final List<String> adminIds;

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    modulos,
    instalaciones,
    adminIds,
  ];
}

class SuperadminMensajeConsumido extends SuperadminEvent {
  const SuperadminMensajeConsumido();
}

class UltimoProyectoCreadoConsumido extends SuperadminEvent {
  const UltimoProyectoCreadoConsumido();
}

class SuperadminState extends Equatable {
  const SuperadminState({
    this.cargando = false,
    this.guardando = false,
    this.proyectos = const [],
    this.mensaje,
    this.exito = false,
    this.ultimoProyectoCreado,
    this.cargandoDetalle = false,
    this.proyectoEnEdicion,
    this.cargandoEstructura = false,
    this.estructura,
    this.errorEstructura,
  });

  final bool cargando;
  final bool guardando;
  final List<ResumenProyecto> proyectos;
  final String? mensaje;
  final bool exito;
  final ProyectoDetalle? ultimoProyectoCreado;
  final bool cargandoDetalle;
  final ProyectoDetalle? proyectoEnEdicion;
  final bool cargandoEstructura;
  final ArbolInfraestructura? estructura;
  final String? errorEstructura;

  SuperadminState copyWith({
    bool? cargando,
    bool? guardando,
    List<ResumenProyecto>? proyectos,
    String? mensaje,
    bool? exito,
    ProyectoDetalle? ultimoProyectoCreado,
    bool? cargandoDetalle,
    ProyectoDetalle? proyectoEnEdicion,
    bool? cargandoEstructura,
    ArbolInfraestructura? estructura,
    String? errorEstructura,
    bool limpiarMensaje = false,
    bool limpiarUltimoProyectoCreado = false,
    bool limpiarDetalle = false,
    bool limpiarEstructura = false,
    bool limpiarErrorEstructura = false,
  }) {
    return SuperadminState(
      cargando: cargando ?? this.cargando,
      guardando: guardando ?? this.guardando,
      proyectos: proyectos ?? this.proyectos,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      exito: limpiarMensaje ? false : (exito ?? this.exito),
      ultimoProyectoCreado: limpiarUltimoProyectoCreado
          ? null
          : (ultimoProyectoCreado ?? this.ultimoProyectoCreado),
      cargandoDetalle: cargandoDetalle ?? this.cargandoDetalle,
      proyectoEnEdicion: limpiarDetalle
          ? null
          : (proyectoEnEdicion ?? this.proyectoEnEdicion),
      cargandoEstructura: cargandoEstructura ?? this.cargandoEstructura,
      estructura: limpiarEstructura ? null : (estructura ?? this.estructura),
      errorEstructura: limpiarErrorEstructura
          ? null
          : (errorEstructura ?? this.errorEstructura),
    );
  }

  @override
  List<Object?> get props => [
    cargando,
    guardando,
    proyectos,
    mensaje,
    exito,
    ultimoProyectoCreado,
    cargandoDetalle,
    proyectoEnEdicion,
    cargandoEstructura,
    estructura,
    errorEstructura,
  ];
}

class SuperadminBloc extends Bloc<SuperadminEvent, SuperadminState> {
  SuperadminBloc({
    required ListarProyectosUseCase listarProyectosUseCase,
    required CrearProyectoUseCase crearProyectoUseCase,
    required ObtenerProyectoUseCase obtenerProyectoUseCase,
    required ActualizarProyectoUseCase actualizarProyectoUseCase,
    required ObtenerArbolInfraestructuraUseCase obtenerEstructuraUseCase,
    required CrearUnidadesAccesoriasEnLoteUseCase
    crearUnidadesAccesoriasEnLoteUseCase,
    required AsignarUnidadAccesoriaUseCase asignarUnidadAccesoriaUseCase,
  }) : _listarProyectosUseCase = listarProyectosUseCase,
       _crearProyectoUseCase = crearProyectoUseCase,
       _obtenerProyectoUseCase = obtenerProyectoUseCase,
       _actualizarProyectoUseCase = actualizarProyectoUseCase,
       _obtenerEstructuraUseCase = obtenerEstructuraUseCase,
       _crearUnidadesAccesoriasEnLoteUseCase =
           crearUnidadesAccesoriasEnLoteUseCase,
       _asignarUnidadAccesoriaUseCase = asignarUnidadAccesoriaUseCase,
       super(const SuperadminState()) {
    on<ProyectosSolicitados>(_onProyectosSolicitados);
    on<ProyectoCreado>(_onProyectoCreado);
    on<ProyectoEdicionSolicitada>(_onEdicionSolicitada);
    on<ProyectoEdicionFinalizada>(_onEdicionFinalizada);
    on<EstructuraProyectoSolicitada>(_onEstructuraSolicitada);
    on<ProyectoActualizado>(_onProyectoActualizado);
    on<AccesoriasLoteSolicitadas>(_onAccesoriasLoteSolicitadas);
    on<AsignacionAccesoriaSolicitada>(_onAsignacionAccesoriaSolicitada);
    on<AsignacionesAccesoriasSolicitadas>(_onAsignacionesAccesoriasSolicitadas);
    on<SuperadminMensajeConsumido>(_onMensajeConsumido);
    on<UltimoProyectoCreadoConsumido>(_onUltimoProyectoCreadoConsumido);
  }

  final ListarProyectosUseCase _listarProyectosUseCase;
  final CrearProyectoUseCase _crearProyectoUseCase;
  final ObtenerProyectoUseCase _obtenerProyectoUseCase;
  final ActualizarProyectoUseCase _actualizarProyectoUseCase;
  final ObtenerArbolInfraestructuraUseCase _obtenerEstructuraUseCase;
  final CrearUnidadesAccesoriasEnLoteUseCase
  _crearUnidadesAccesoriasEnLoteUseCase;
  final AsignarUnidadAccesoriaUseCase _asignarUnidadAccesoriaUseCase;

  Future<void> _onProyectosSolicitados(
    ProyectosSolicitados event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(state.copyWith(cargando: true, limpiarMensaje: true));

    final result = await _listarProyectosUseCase();

    result.fold(
      (failure) =>
          emit(state.copyWith(cargando: false, mensaje: failure.message)),
      (proyectos) => emit(
        state.copyWith(
          cargando: false,
          proyectos: proyectos,
          limpiarMensaje: true,
        ),
      ),
    );
  }

  Future<void> _onProyectoCreado(
    ProyectoCreado event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _crearProyectoUseCase(
      nombre: event.nombre,
      descripcion: event.descripcion,
      tipoCondominio: event.tipoCondominio,
      modulos: event.modulos,
      agrupaciones: event.agrupaciones,
      instalaciones: event.instalaciones,
      adminIds: event.adminIds,
      estacionamientos: event.estacionamientos,
      bodegas: event.bodegas,
    );

    await result.fold(
      (failure) async =>
          emit(state.copyWith(guardando: false, mensaje: failure.message)),
      (proyecto) async {
        emit(
          state.copyWith(
            guardando: false,
            mensaje: 'Proyecto "${proyecto.nombre}" creado.',
            exito: true,
            ultimoProyectoCreado: proyecto,
          ),
        );
        add(const ProyectosSolicitados());
      },
    );
  }

  Future<void> _onEdicionSolicitada(
    ProyectoEdicionSolicitada event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(
      state.copyWith(
        cargandoDetalle: true,
        limpiarDetalle: true,
        limpiarMensaje: true,
        limpiarEstructura: true,
        limpiarErrorEstructura: true,
      ),
    );

    final result = await _obtenerProyectoUseCase(event.proyectoId);

    result.fold(
      (failure) => emit(
        state.copyWith(cargandoDetalle: false, mensaje: failure.message),
      ),
      (proyecto) => emit(
        state.copyWith(cargandoDetalle: false, proyectoEnEdicion: proyecto),
      ),
    );
  }

  void _onEdicionFinalizada(
    ProyectoEdicionFinalizada event,
    Emitter<SuperadminState> emit,
  ) {
    emit(
      state.copyWith(
        limpiarDetalle: true,
        cargandoDetalle: false,
        limpiarEstructura: true,
        limpiarErrorEstructura: true,
        cargandoEstructura: false,
      ),
    );
  }

  Future<void> _onEstructuraSolicitada(
    EstructuraProyectoSolicitada event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(
      state.copyWith(
        cargandoEstructura: true,
        limpiarEstructura: true,
        limpiarErrorEstructura: true,
      ),
    );

    final result = await _obtenerEstructuraUseCase(
      proyectoId: event.proyectoId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          cargandoEstructura: false,
          errorEstructura: failure.message,
        ),
      ),
      (arbol) =>
          emit(state.copyWith(cargandoEstructura: false, estructura: arbol)),
    );
  }

  Future<void> _onProyectoActualizado(
    ProyectoActualizado event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _actualizarProyectoUseCase(
      id: event.id,
      nombre: event.nombre,
      descripcion: event.descripcion,
      modulos: event.modulos,
      instalaciones: event.instalaciones,
      adminIds: event.adminIds,
    );

    await result.fold(
      (failure) async {
        emit(state.copyWith(guardando: false, mensaje: failure.message));
      },
      (proyecto) async {
        emit(
          state.copyWith(
            guardando: false,
            mensaje: 'Proyecto "${proyecto.nombre}" actualizado.',
            exito: true,
            limpiarDetalle: true,
          ),
        );
        add(const ProyectosSolicitados());
      },
    );
  }

  Future<void> _onAccesoriasLoteSolicitadas(
    AccesoriasLoteSolicitadas event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _crearUnidadesAccesoriasEnLoteUseCase(
      proyectoId: event.proyectoId,
      tipo: event.tipo,
      cantidad: event.cantidad,
      asignacion: event.asignacion,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(guardando: false, mensaje: failure.message)),
      (unidades) {
        emit(
          state.copyWith(
            guardando: false,
            exito: true,
            mensaje:
                'Se crearon ${unidades.length} '
                '${_nombreTipo(event.tipo)}.',
          ),
        );
        add(EstructuraProyectoSolicitada(event.proyectoId));
      },
    );
  }

  Future<void> _onAsignacionAccesoriaSolicitada(
    AsignacionAccesoriaSolicitada event,
    Emitter<SuperadminState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _asignarUnidadAccesoriaUseCase(
      unidadAccesoriaId: event.asignacion.unidadAccesoriaId,
      asignacion: event.asignacion.asignacion,
      unidadPrincipalId: event.asignacion.unidadPrincipalId,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(guardando: false, mensaje: failure.message)),
      (unidad) {
        emit(
          state.copyWith(
            guardando: false,
            exito: true,
            mensaje: 'Asignación de ${unidad.identificador} actualizada.',
          ),
        );
        add(EstructuraProyectoSolicitada(event.proyectoId));
      },
    );
  }

  Future<void> _onAsignacionesAccesoriasSolicitadas(
    AsignacionesAccesoriasSolicitadas event,
    Emitter<SuperadminState> emit,
  ) async {
    if (event.asignaciones.isEmpty) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final fallas = <String>[];
    var actualizadas = 0;

    for (final asignacion in event.asignaciones) {
      final result = await _asignarUnidadAccesoriaUseCase(
        unidadAccesoriaId: asignacion.unidadAccesoriaId,
        asignacion: asignacion.asignacion,
        unidadPrincipalId: asignacion.unidadPrincipalId,
      );

      result.fold(
        (failure) => fallas.add(failure.message),
        (_) => actualizadas++,
      );
    }

    if (actualizadas > 0) {
      add(EstructuraProyectoSolicitada(event.proyectoId));
    }

    if (fallas.isEmpty) {
      emit(
        state.copyWith(
          guardando: false,
          exito: true,
          mensaje: 'Se actualizaron $actualizadas asignaciones.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        guardando: false,
        exito: actualizadas > 0,
        mensaje: actualizadas > 0
            ? 'Se actualizaron $actualizadas asignaciones. '
                  '${fallas.length} no se pudieron guardar.'
            : fallas.first,
      ),
    );
  }

  void _onMensajeConsumido(
    SuperadminMensajeConsumido event,
    Emitter<SuperadminState> emit,
  ) {
    emit(state.copyWith(limpiarMensaje: true));
  }

  void _onUltimoProyectoCreadoConsumido(
    UltimoProyectoCreadoConsumido event,
    Emitter<SuperadminState> emit,
  ) {
    emit(state.copyWith(limpiarUltimoProyectoCreado: true));
  }

  String _nombreTipo(TipoUnidadAccesoria tipo) {
    return switch (tipo) {
      TipoUnidadAccesoria.estacionamiento => 'estacionamientos',
      TipoUnidadAccesoria.bodega => 'bodegas',
    };
  }
}
