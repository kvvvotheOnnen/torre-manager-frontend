// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/arbol_infraestructura.dart';
import '../../domain/entities/tipo_agrupacion.dart';
import '../../domain/entities/tipo_unidad_accesoria.dart';
import '../../domain/usecases/asignar_unidad_accesoria_usecase.dart';
import '../../domain/usecases/crear_unidad_accesoria_usecase.dart';
import '../../domain/usecases/obtener_arbol_infraestructura_usecase.dart';
import '../../domain/usecases/obtener_proyecto_del_usuario_usecase.dart';
import '../../domain/usecases/registrar_agrupacion_en_cascada_usecase.dart';

part 'infraestructura_event.dart';
part 'infraestructura_state.dart';

class InfraestructuraBloc extends Bloc<InfraestructuraEvent, InfraestructuraState> {
  InfraestructuraBloc({
    required ObtenerArbolInfraestructuraUseCase obtenerArbolUseCase,
    required RegistrarAgrupacionEnCascadaUseCase registrarAgrupacionUseCase,
    required CrearUnidadAccesoriaUseCase crearUnidadAccesoriaUseCase,
    required AsignarUnidadAccesoriaUseCase asignarUnidadAccesoriaUseCase,
    required ObtenerProyectoDelUsuarioUseCase obtenerProyectoUseCase,
  }) : _obtenerArbolUseCase = obtenerArbolUseCase,
       _registrarAgrupacionUseCase = registrarAgrupacionUseCase,
       _crearUnidadAccesoriaUseCase = crearUnidadAccesoriaUseCase,
       _asignarUnidadAccesoriaUseCase = asignarUnidadAccesoriaUseCase,
       _obtenerProyectoUseCase = obtenerProyectoUseCase,
       super(const InfraestructuraState()) {
    on<InfraestructuraIniciado>(_onIniciado);
    on<InfraestructuraArbolSolicitado>(_onArbolSolicitado);
    on<InfraestructuraAgrupacionRegistrada>(_onAgrupacionRegistrada);
    on<InfraestructuraUnidadAccesoriaCreada>(_onUnidadAccesoriaCreada);
    on<InfraestructuraAccesoriaAsignada>(_onAccesoriaAsignada);
    on<InfraestructuraMensajeConsumido>(_onMensajeConsumido);
  }

  final ObtenerArbolInfraestructuraUseCase _obtenerArbolUseCase;
  final RegistrarAgrupacionEnCascadaUseCase _registrarAgrupacionUseCase;
  final CrearUnidadAccesoriaUseCase _crearUnidadAccesoriaUseCase;
  final AsignarUnidadAccesoriaUseCase _asignarUnidadAccesoriaUseCase;
  final ObtenerProyectoDelUsuarioUseCase _obtenerProyectoUseCase;

  Future<void> _onIniciado(
    InfraestructuraIniciado event,
    Emitter<InfraestructuraState> emit,
  ) async {
    emit(state.copyWith(status: InfraestructuraStatus.cargando, limpiarMensaje: true));

    final result = await _obtenerProyectoUseCase();

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: InfraestructuraStatus.error,
          mensaje: failure.message,
          limpiarMensaje: false,
        ),
      ),
      (proyecto) async {
        final arbolResult =
            await _obtenerArbolUseCase(proyectoId: proyecto.id);

        arbolResult.fold(
          (failure) => emit(
            state.copyWith(
              status: InfraestructuraStatus.error,
              mensaje: failure.message,
              limpiarMensaje: false,
            ),
          ),
          (arbol) => emit(
            state.copyWith(
              status: InfraestructuraStatus.cargado,
              arbol: arbol,
              limpiarMensaje: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onArbolSolicitado(
    InfraestructuraArbolSolicitado event,
    Emitter<InfraestructuraState> emit,
  ) async {
    emit(state.copyWith(status: InfraestructuraStatus.cargando, limpiarMensaje: true));

    final result = await _obtenerArbolUseCase(proyectoId: event.proyectoId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: InfraestructuraStatus.error,
          mensaje: failure.message,
          limpiarMensaje: false,
        ),
      ),
      (arbol) => emit(
        state.copyWith(status: InfraestructuraStatus.cargado, arbol: arbol),
      ),
    );
  }

  Future<void> _onAgrupacionRegistrada(
    InfraestructuraAgrupacionRegistrada event,
    Emitter<InfraestructuraState> emit,
  ) async {
    emit(state.copyWith(status: InfraestructuraStatus.guardando, limpiarMensaje: true));

    final result = await _registrarAgrupacionUseCase(
      proyectoId: event.proyectoId,
      nombre: event.nombre,
      tipo: event.tipo,
      prefijo: event.prefijo,
      pisoDesde: event.pisoDesde,
      pisoHasta: event.pisoHasta,
      unidadesPorPiso: event.unidadesPorPiso,
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: InfraestructuraStatus.error,
          mensaje: failure.message,
          limpiarMensaje: false,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            status: InfraestructuraStatus.cargado,
            mensaje: 'Agrupación registrada con sus unidades.',
            limpiarMensaje: false,
          ),
        );
        add(InfraestructuraArbolSolicitado(proyectoId: event.proyectoId));
      },
    );
  }

  Future<void> _onUnidadAccesoriaCreada(
    InfraestructuraUnidadAccesoriaCreada event,
    Emitter<InfraestructuraState> emit,
  ) async {
    emit(state.copyWith(status: InfraestructuraStatus.guardando, limpiarMensaje: true));

    final result = await _crearUnidadAccesoriaUseCase(
      proyectoId: event.proyectoId,
      identificador: event.identificador,
      tipo: event.tipo,
      unidadPrincipalId: event.unidadPrincipalId,
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: InfraestructuraStatus.error,
          mensaje: failure.message,
          limpiarMensaje: false,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            status: InfraestructuraStatus.cargado,
            mensaje: 'Unidad accesoria registrada.',
            limpiarMensaje: false,
          ),
        );
        add(InfraestructuraArbolSolicitado(proyectoId: event.proyectoId));
      },
    );
  }

  Future<void> _onAccesoriaAsignada(
    InfraestructuraAccesoriaAsignada event,
    Emitter<InfraestructuraState> emit,
  ) async {
    emit(state.copyWith(status: InfraestructuraStatus.guardando, limpiarMensaje: true));

    final result = await _asignarUnidadAccesoriaUseCase(
      unidadAccesoriaId: event.unidadAccesoriaId,
      unidadPrincipalId: event.unidadPrincipalId,
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: InfraestructuraStatus.error,
          mensaje: failure.message,
          limpiarMensaje: false,
        ),
      ),
      (_) async {
        emit(
          state.copyWith(
            status: InfraestructuraStatus.cargado,
            mensaje: 'Asignación actualizada.',
            limpiarMensaje: false,
          ),
        );
        add(InfraestructuraArbolSolicitado(proyectoId: event.proyectoId));
      },
    );
  }

  void _onMensajeConsumido(
    InfraestructuraMensajeConsumido event,
    Emitter<InfraestructuraState> emit,
  ) {
    emit(state.copyWith(limpiarMensaje: true));
  }
}
