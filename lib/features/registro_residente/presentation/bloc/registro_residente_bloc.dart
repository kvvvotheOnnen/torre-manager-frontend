import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/registro_residente.dart';
import '../../domain/usecases/listar_proyectos_registro_usecase.dart';
import '../../domain/usecases/listar_unidades_registro_usecase.dart';
import '../../domain/usecases/registrar_solicitud_residente_usecase.dart';

sealed class RegistroResidenteEvent extends Equatable {
  const RegistroResidenteEvent();

  @override
  List<Object?> get props => [];
}

class RegistroProyectosSolicitados extends RegistroResidenteEvent {
  const RegistroProyectosSolicitados();
}

class RegistroUnidadesSolicitadas extends RegistroResidenteEvent {
  const RegistroUnidadesSolicitadas(this.proyectoId);

  final String proyectoId;

  @override
  List<Object?> get props => [proyectoId];
}

class RegistroSolicitudEnviada extends RegistroResidenteEvent {
  const RegistroSolicitudEnviada(this.solicitud);

  final SolicitudRegistro solicitud;

  @override
  List<Object?> get props => [solicitud];
}

class RegistroReiniciado extends RegistroResidenteEvent {
  const RegistroReiniciado();
}

class RegistroErrorLimpiado extends RegistroResidenteEvent {
  const RegistroErrorLimpiado();
}

class RegistroResidenteState extends Equatable {
  const RegistroResidenteState({
    this.cargandoProyectos = false,
    this.cargandoUnidades = false,
    this.enviando = false,
    this.enviado = false,
    this.proyectos = const [],
    this.unidades = const [],
    this.mensajeExito,
    this.error,
  });

  final bool cargandoProyectos;
  final bool cargandoUnidades;
  final bool enviando;
  final bool enviado;
  final List<ProyectoRegistro> proyectos;
  final List<UnidadRegistro> unidades;
  final String? mensajeExito;
  final String? error;

  RegistroResidenteState copyWith({
    bool? cargandoProyectos,
    bool? cargandoUnidades,
    bool? enviando,
    bool? enviado,
    List<ProyectoRegistro>? proyectos,
    List<UnidadRegistro>? unidades,
    String? mensajeExito,
    String? error,
    bool limpiarError = false,
  }) {
    return RegistroResidenteState(
      cargandoProyectos: cargandoProyectos ?? this.cargandoProyectos,
      cargandoUnidades: cargandoUnidades ?? this.cargandoUnidades,
      enviando: enviando ?? this.enviando,
      enviado: enviado ?? this.enviado,
      proyectos: proyectos ?? this.proyectos,
      unidades: unidades ?? this.unidades,
      mensajeExito: mensajeExito ?? this.mensajeExito,
      error: limpiarError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    cargandoProyectos,
    cargandoUnidades,
    enviando,
    enviado,
    proyectos,
    unidades,
    mensajeExito,
    error,
  ];
}

class RegistroResidenteBloc
    extends Bloc<RegistroResidenteEvent, RegistroResidenteState> {
  RegistroResidenteBloc({
    required ListarProyectosRegistroUseCase listarProyectosUseCase,
    required ListarUnidadesRegistroUseCase listarUnidadesUseCase,
    required RegistrarSolicitudResidenteUseCase registrarUseCase,
  }) : _listarProyectos = listarProyectosUseCase,
       _listarUnidades = listarUnidadesUseCase,
       _registrar = registrarUseCase,
       super(const RegistroResidenteState()) {
    on<RegistroProyectosSolicitados>(_onProyectos);
    on<RegistroUnidadesSolicitadas>(_onUnidades);
    on<RegistroSolicitudEnviada>(_onEnviar);
    on<RegistroReiniciado>((_, emit) => emit(const RegistroResidenteState()));
    on<RegistroErrorLimpiado>(
      (_, emit) => emit(state.copyWith(limpiarError: true)),
    );
  }

  final ListarProyectosRegistroUseCase _listarProyectos;
  final ListarUnidadesRegistroUseCase _listarUnidades;
  final RegistrarSolicitudResidenteUseCase _registrar;

  Future<void> _onProyectos(
    RegistroProyectosSolicitados event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    emit(state.copyWith(cargandoProyectos: true, limpiarError: true));

    final result = await _listarProyectos();

    result.fold(
      (failure) => emit(
        state.copyWith(cargandoProyectos: false, error: failure.message),
      ),
      (proyectos) => emit(
        state.copyWith(cargandoProyectos: false, proyectos: proyectos),
      ),
    );
  }

  Future<void> _onUnidades(
    RegistroUnidadesSolicitadas event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    emit(
      state.copyWith(
        cargandoUnidades: true,
        unidades: const [],
        limpiarError: true,
      ),
    );

    final result = await _listarUnidades(event.proyectoId);

    result.fold(
      (failure) => emit(
        state.copyWith(cargandoUnidades: false, error: failure.message),
      ),
      (unidades) =>
          emit(state.copyWith(cargandoUnidades: false, unidades: unidades)),
    );
  }

  Future<void> _onEnviar(
    RegistroSolicitudEnviada event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    emit(state.copyWith(enviando: true, limpiarError: true));

    final result = await _registrar(event.solicitud);

    result.fold(
      (failure) => emit(state.copyWith(enviando: false, error: failure.message)),
      (mensaje) => emit(
        state.copyWith(
          enviando: false,
          enviado: true,
          mensajeExito: mensaje,
        ),
      ),
    );
  }
}
