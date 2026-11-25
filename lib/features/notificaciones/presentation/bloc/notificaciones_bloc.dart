// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notificacion.dart';
import '../../domain/usecases/contar_notificaciones_no_leidas_usecase.dart';
import '../../domain/usecases/listar_notificaciones_usecase.dart';
import '../../domain/usecases/marcar_notificacion_leida_usecase.dart';
import '../../domain/usecases/marcar_todas_notificaciones_leidas_usecase.dart';

sealed class NotificacionesEvent {
  const NotificacionesEvent();
}

final class NotificacionesSolicitadas extends NotificacionesEvent {
  const NotificacionesSolicitadas();
}

final class NotificacionesRefrescadas extends NotificacionesEvent {
  const NotificacionesRefrescadas();
}

final class NotificacionLeidaSolicitada extends NotificacionesEvent {
  const NotificacionLeidaSolicitada(this.id);

  final String id;
}

final class TodasNotificacionesLeidasSolicitadas extends NotificacionesEvent {
  const TodasNotificacionesLeidasSolicitadas();
}

final class NotificacionesLimpiadas extends NotificacionesEvent {
  const NotificacionesLimpiadas();
}

final class MensajeNotificacionesConsumido extends NotificacionesEvent {
  const MensajeNotificacionesConsumido();
}

enum NotificacionesStatus { inicial, cargando, cargado, error }

class NotificacionesState extends Equatable {
  const NotificacionesState({
    this.status = NotificacionesStatus.inicial,
    this.notificaciones = const [],
    this.noLeidas = 0,
    this.mensaje,
  });

  final NotificacionesStatus status;
  final List<Notificacion> notificaciones;
  final int noLeidas;
  final String? mensaje;

  bool get cargando => status == NotificacionesStatus.cargando;

  bool get tieneError => status == NotificacionesStatus.error;

  NotificacionesState copyWith({
    NotificacionesStatus? status,
    List<Notificacion>? notificaciones,
    int? noLeidas,
    String? mensaje,
    bool limpiarMensaje = false,
  }) {
    return NotificacionesState(
      status: status ?? this.status,
      notificaciones: notificaciones ?? this.notificaciones,
      noLeidas: noLeidas ?? this.noLeidas,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
    );
  }

  @override
  List<Object?> get props => [status, notificaciones, noLeidas, mensaje];
}

class NotificacionesBloc
    extends Bloc<NotificacionesEvent, NotificacionesState> {
  NotificacionesBloc({
    required ListarNotificacionesUseCase listar,
    required ContarNotificacionesNoLeidasUseCase contarNoLeidas,
    required MarcarNotificacionLeidaUseCase marcarLeida,
    required MarcarTodasNotificacionesLeidasUseCase marcarTodas,
  })  : _listar = listar,
        _contarNoLeidas = contarNoLeidas,
        _marcarLeida = marcarLeida,
        _marcarTodas = marcarTodas,
        super(const NotificacionesState()) {
    on<NotificacionesSolicitadas>(_onSolicitadas);
    on<NotificacionesRefrescadas>(_onRefrescadas);
    on<NotificacionLeidaSolicitada>(_onLeida);
    on<TodasNotificacionesLeidasSolicitadas>(_onTodasLeidas);
    on<NotificacionesLimpiadas>(_onLimpiadas);
    on<MensajeNotificacionesConsumido>(
      (_, emit) => emit(state.copyWith(limpiarMensaje: true)),
    );
  }

  final ListarNotificacionesUseCase _listar;
  final ContarNotificacionesNoLeidasUseCase _contarNoLeidas;
  final MarcarNotificacionLeidaUseCase _marcarLeida;
  final MarcarTodasNotificacionesLeidasUseCase _marcarTodas;

  Timer? _timer;

  Future<void> _onSolicitadas(
    NotificacionesSolicitadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    _iniciarPolling();
    await _cargar(emit, mostrarCargando: state.notificaciones.isEmpty);
  }

  Future<void> _onRefrescadas(
    NotificacionesRefrescadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    await _cargar(emit, mostrarCargando: false);
  }

  Future<void> _cargar(
    Emitter<NotificacionesState> emit, {
    required bool mostrarCargando,
  }) async {
    if (mostrarCargando) {
      emit(
        state.copyWith(
          status: NotificacionesStatus.cargando,
          limpiarMensaje: true,
        ),
      );
    }

    final resultado = await _listar();

    await resultado.fold(
      (failure) async {
        if (mostrarCargando) {
          emit(
            state.copyWith(
              status: NotificacionesStatus.error,
              mensaje: failure.message,
            ),
          );
        }
      },
      (notificaciones) async {
        final conteo = await _contarNoLeidas();
        final noLeidas = conteo.fold(
          (_) => notificaciones.where((item) => !item.leida).length,
          (total) => total,
        );
        emit(
          state.copyWith(
            status: NotificacionesStatus.cargado,
            notificaciones: notificaciones,
            noLeidas: noLeidas,
            limpiarMensaje: true,
          ),
        );
      },
    );
  }

  Future<void> _onLeida(
    NotificacionLeidaSolicitada event,
    Emitter<NotificacionesState> emit,
  ) async {
    final indice =
        state.notificaciones.indexWhere((item) => item.id == event.id);
    if (indice < 0 || state.notificaciones[indice].leida) {
      return;
    }

    final resultado = await _marcarLeida(event.id);

    resultado.fold(
      (failure) => emit(state.copyWith(mensaje: failure.message)),
      (actualizada) {
        final notificaciones = [...state.notificaciones];
        notificaciones[indice] = actualizada;
        emit(
          state.copyWith(
            notificaciones: notificaciones,
            noLeidas: state.noLeidas > 0 ? state.noLeidas - 1 : 0,
            limpiarMensaje: true,
          ),
        );
      },
    );
  }

  Future<void> _onTodasLeidas(
    TodasNotificacionesLeidasSolicitadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    final resultado = await _marcarTodas();

    resultado.fold(
      (failure) => emit(state.copyWith(mensaje: failure.message)),
      (_) {
        emit(
          state.copyWith(
            notificaciones: state.notificaciones
                .map((item) => item.copyWith(leida: true))
                .toList(),
            noLeidas: 0,
            limpiarMensaje: true,
          ),
        );
      },
    );
  }

  Future<void> _onLimpiadas(
    NotificacionesLimpiadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    _detenerPolling();
    emit(const NotificacionesState());
  }

  void _iniciarPolling() {
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) {
        add(const NotificacionesRefrescadas());
      }
    });
  }

  void _detenerPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _detenerPolling();
    return super.close();
  }
}
