import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/usecases/listar_proyectos_usecase.dart';

sealed class SuperadminEvent extends Equatable {
  const SuperadminEvent();

  @override
  List<Object?> get props => [];
}

class ProyectosSolicitados extends SuperadminEvent {
  const ProyectosSolicitados();
}

class SuperadminState extends Equatable {
  const SuperadminState({
    this.cargando = false,
    this.proyectos = const [],
    this.mensaje,
  });

  final bool cargando;
  final List<ResumenProyecto> proyectos;
  final String? mensaje;

  SuperadminState copyWith({
    bool? cargando,
    List<ResumenProyecto>? proyectos,
    String? mensaje,
    bool limpiarMensaje = false,
  }) {
    return SuperadminState(
      cargando: cargando ?? this.cargando,
      proyectos: proyectos ?? this.proyectos,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
    );
  }

  @override
  List<Object?> get props => [cargando, proyectos, mensaje];
}

class SuperadminBloc extends Bloc<SuperadminEvent, SuperadminState> {
  SuperadminBloc(this._listarProyectosUseCase)
    : super(const SuperadminState()) {
    on<ProyectosSolicitados>(_onProyectosSolicitados);
  }

  final ListarProyectosUseCase _listarProyectosUseCase;

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
}
