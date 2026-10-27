// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  });

  final String nombre;
  final String? descripcion;
  final TipoCondominio tipoCondominio;
  final List<ModuloSistema> modulos;
  final List<DefinicionAgrupacion> agrupaciones;
  final List<InstalacionExtra> instalaciones;
  final List<String> adminIds;

  @override
  List<Object?> get props => [
    nombre,
    descripcion,
    tipoCondominio,
    modulos,
    agrupaciones,
    instalaciones,
    adminIds,
  ];
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
  });

  final bool cargando;
  final bool guardando;
  final List<ResumenProyecto> proyectos;
  final String? mensaje;
  final bool exito;
  final ProyectoDetalle? ultimoProyectoCreado;
  final bool cargandoDetalle;
  final ProyectoDetalle? proyectoEnEdicion;

  SuperadminState copyWith({
    bool? cargando,
    bool? guardando,
    List<ResumenProyecto>? proyectos,
    String? mensaje,
    bool? exito,
    ProyectoDetalle? ultimoProyectoCreado,
    bool? cargandoDetalle,
    ProyectoDetalle? proyectoEnEdicion,
    bool limpiarMensaje = false,
    bool limpiarDetalle = false,
  }) {
    return SuperadminState(
      cargando: cargando ?? this.cargando,
      guardando: guardando ?? this.guardando,
      proyectos: proyectos ?? this.proyectos,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
      exito: limpiarMensaje ? false : (exito ?? this.exito),
      ultimoProyectoCreado: limpiarMensaje
          ? null
          : (ultimoProyectoCreado ?? this.ultimoProyectoCreado),
      cargandoDetalle: cargandoDetalle ?? this.cargandoDetalle,
      proyectoEnEdicion: limpiarDetalle
          ? null
          : (proyectoEnEdicion ?? this.proyectoEnEdicion),
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
  ];
}

class SuperadminBloc extends Bloc<SuperadminEvent, SuperadminState> {
  SuperadminBloc({
    required ListarProyectosUseCase listarProyectosUseCase,
    required CrearProyectoUseCase crearProyectoUseCase,
    required ObtenerProyectoUseCase obtenerProyectoUseCase,
    required ActualizarProyectoUseCase actualizarProyectoUseCase,
  }) : _listarProyectosUseCase = listarProyectosUseCase,
       _crearProyectoUseCase = crearProyectoUseCase,
       _obtenerProyectoUseCase = obtenerProyectoUseCase,
       _actualizarProyectoUseCase = actualizarProyectoUseCase,
       super(const SuperadminState()) {
    on<ProyectosSolicitados>(_onProyectosSolicitados);
    on<ProyectoCreado>(_onProyectoCreado);
    on<ProyectoEdicionSolicitada>(_onEdicionSolicitada);
    on<ProyectoEdicionFinalizada>(_onEdicionFinalizada);
    on<ProyectoActualizado>(_onProyectoActualizado);
    on<SuperadminMensajeConsumido>(_onMensajeConsumido);
  }

  final ListarProyectosUseCase _listarProyectosUseCase;
  final CrearProyectoUseCase _crearProyectoUseCase;
  final ObtenerProyectoUseCase _obtenerProyectoUseCase;
  final ActualizarProyectoUseCase _actualizarProyectoUseCase;

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
    emit(state.copyWith(limpiarDetalle: true, cargandoDetalle: false));
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

  void _onMensajeConsumido(
    SuperadminMensajeConsumido event,
    Emitter<SuperadminState> emit,
  ) {
    emit(state.copyWith(limpiarMensaje: true));
  }
}
