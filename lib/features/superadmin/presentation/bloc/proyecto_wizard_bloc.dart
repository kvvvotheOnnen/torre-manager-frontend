// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/descartar_proyecto_borrador_usecase.dart';
import '../../domain/usecases/guardar_paso_proyecto_usecase.dart';
import '../../domain/usecases/iniciar_proyecto_borrador_usecase.dart';
import 'proyecto_wizard_event.dart';
import 'proyecto_wizard_state.dart';

class ProyectoWizardBloc
    extends Bloc<ProyectoWizardEvent, ProyectoWizardState> {
  ProyectoWizardBloc({
    required IniciarProyectoBorradorUseCase iniciarProyectoBorradorUseCase,
    required GuardarPasoProyectoUseCase guardarPasoProyectoUseCase,
    required DescartarProyectoBorradorUseCase descartarProyectoBorradorUseCase,
  }) : _iniciarProyectoBorradorUseCase = iniciarProyectoBorradorUseCase,
       _guardarPasoProyectoUseCase = guardarPasoProyectoUseCase,
       _descartarProyectoBorradorUseCase = descartarProyectoBorradorUseCase,
       super(const ProyectoWizardState()) {
    on<WizardIniciado>(_onIniciado);
    on<WizardTipoGuardado>(_onTipoGuardado);
    on<WizardEstructuraGuardada>(_onEstructuraGuardada);
    on<WizardInstalacionesGuardadas>(_onInstalacionesGuardadas);
    on<WizardAdministradoresGuardados>(_onAdministradoresGuardados);
    on<WizardFinalizado>(_onFinalizado);
    on<WizardPasoAvanzado>(_onPasoAvanzado);
    on<WizardPasoRetrocedido>(_onPasoRetrocedido);
    on<WizardDescartado>(_onDescartado);
    on<WizardMensajeConsumido>(_onMensajeConsumido);
    on<WizardReiniciado>(_onReiniciado);
  }

  final IniciarProyectoBorradorUseCase _iniciarProyectoBorradorUseCase;
  final GuardarPasoProyectoUseCase _guardarPasoProyectoUseCase;
  final DescartarProyectoBorradorUseCase _descartarProyectoBorradorUseCase;

  Future<void> _onIniciado(
    WizardIniciado event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final proyectoId = state.proyectoId;
    final descripcion = event.descripcion?.trim();

    if (proyectoId == null) {
      final result = await _iniciarProyectoBorradorUseCase(
        nombre: event.nombre,
        descripcion: descripcion,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            guardando: false,
            mensaje: failure.message,
            mensajeEsError: true,
          ),
        ),
        (proyecto) => emit(
          state.copyWith(
            proyectoId: proyecto.id,
            nombre: event.nombre.trim(),
            descripcion: descripcion,
            pasoActual: 1,
            guardando: false,
            limpiarMensaje: true,
          ),
        ),
      );
      return;
    }

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: event.nombre,
      descripcion: descripcion ?? '',
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          nombre: event.nombre.trim(),
          descripcion: descripcion,
          pasoActual: 1,
          guardando: false,
          limpiarMensaje: true,
        ),
      ),
    );
  }

  Future<void> _onTipoGuardado(
    WizardTipoGuardado event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;
    if (proyectoId == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: state.nombre,
      descripcion: state.descripcion ?? '',
      tipoCondominio: event.tipo,
      resetEstructura:
          state.tipoConfirmado != null && state.tipoConfirmado != event.tipo,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          pasoActual: 2,
          guardando: false,
          tipoConfirmado: event.tipo,
          limpiarMensaje: true,
        ),
      ),
    );
  }

  Future<void> _onEstructuraGuardada(
    WizardEstructuraGuardada event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;
    if (proyectoId == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: state.nombre,
      descripcion: state.descripcion ?? '',
      agrupaciones: event.agrupaciones,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(pasoActual: 3, guardando: false, limpiarMensaje: true),
      ),
    );
  }

  Future<void> _onInstalacionesGuardadas(
    WizardInstalacionesGuardadas event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;
    if (proyectoId == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: state.nombre,
      descripcion: state.descripcion ?? '',
      instalaciones: event.instalaciones,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(pasoActual: 5, guardando: false, limpiarMensaje: true),
      ),
    );
  }

  Future<void> _onAdministradoresGuardados(
    WizardAdministradoresGuardados event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;
    if (proyectoId == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: state.nombre,
      descripcion: state.descripcion ?? '',
      adminIds: event.adminIds,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(pasoActual: 6, guardando: false, limpiarMensaje: true),
      ),
    );
  }

  Future<void> _onFinalizado(
    WizardFinalizado event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;
    if (proyectoId == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true));

    final result = await _guardarPasoProyectoUseCase(
      id: proyectoId,
      nombre: state.nombre,
      descripcion: state.descripcion ?? '',
      modulos: event.modulos,
      adminIds: event.adminIds,
      finalizar: true,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          guardando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          guardando: false,
          finalizado: true,
          limpiarMensaje: true,
        ),
      ),
    );
  }

  void _onPasoAvanzado(
    WizardPasoAvanzado event,
    Emitter<ProyectoWizardState> emit,
  ) {
    if (state.pasoActual >= 6) return;
    emit(state.copyWith(pasoActual: state.pasoActual + 1));
  }

  void _onPasoRetrocedido(
    WizardPasoRetrocedido event,
    Emitter<ProyectoWizardState> emit,
  ) {
    if (state.pasoActual <= 0) return;
    emit(state.copyWith(pasoActual: state.pasoActual - 1));
  }

  Future<void> _onDescartado(
    WizardDescartado event,
    Emitter<ProyectoWizardState> emit,
  ) async {
    final proyectoId = state.proyectoId;

    if (proyectoId == null) {
      emit(const ProyectoWizardState());
      return;
    }

    emit(state.copyWith(descartando: true));

    final result = await _descartarProyectoBorradorUseCase(proyectoId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          descartando: false,
          mensaje: failure.message,
          mensajeEsError: true,
        ),
      ),
      (_) => emit(const ProyectoWizardState()),
    );
  }

  void _onMensajeConsumido(
    WizardMensajeConsumido event,
    Emitter<ProyectoWizardState> emit,
  ) {
    emit(state.copyWith(limpiarMensaje: true));
  }

  void _onReiniciado(
    WizardReiniciado event,
    Emitter<ProyectoWizardState> emit,
  ) {
    emit(const ProyectoWizardState());
  }
}
