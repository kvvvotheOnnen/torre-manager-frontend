import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/solicitud_residente.dart';
import '../../domain/usecases/aprobar_solicitud_usecase.dart';
import '../../domain/usecases/listar_historial_usecase.dart';
import '../../domain/usecases/listar_pendientes_usecase.dart';
import '../../domain/usecases/rechazar_solicitud_usecase.dart';

enum VistaSolicitudes { pendientes, historial }

enum SolicitudesResidenteStatus { inicial, cargando, cargado, guardando, error }

sealed class SolicitudesResidenteEvent extends Equatable {
  const SolicitudesResidenteEvent();

  @override
  List<Object?> get props => [];
}

class SolicitudesResidenteIniciadas extends SolicitudesResidenteEvent {
  const SolicitudesResidenteIniciadas();
}

class SolicitudesPendientesSolicitadas extends SolicitudesResidenteEvent {
  const SolicitudesPendientesSolicitadas();
}

class HistorialSolicitudesSolicitado extends SolicitudesResidenteEvent {
  const HistorialSolicitudesSolicitado();
}

class VistaSolicitudesCambiada extends SolicitudesResidenteEvent {
  const VistaSolicitudesCambiada(this.vista);

  final VistaSolicitudes vista;

  @override
  List<Object?> get props => [vista];
}

class SolicitudAprobada extends SolicitudesResidenteEvent {
  const SolicitudAprobada(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class SolicitudRechazada extends SolicitudesResidenteEvent {
  const SolicitudRechazada(this.id, this.motivo);

  final String id;
  final String motivo;

  @override
  List<Object?> get props => [id, motivo];
}

class MensajeSolicitudesLimpiado extends SolicitudesResidenteEvent {
  const MensajeSolicitudesLimpiado();
}

class SolicitudesResidenteState extends Equatable {
  const SolicitudesResidenteState({
    this.status = SolicitudesResidenteStatus.inicial,
    this.vista = VistaSolicitudes.pendientes,
    this.pendientes = const [],
    this.historial = const [],
    this.mensaje,
  });

  final SolicitudesResidenteStatus status;
  final VistaSolicitudes vista;
  final List<SolicitudResidente> pendientes;
  final List<SolicitudResidente> historial;
  final String? mensaje;

  SolicitudesResidenteState copyWith({
    SolicitudesResidenteStatus? status,
    VistaSolicitudes? vista,
    List<SolicitudResidente>? pendientes,
    List<SolicitudResidente>? historial,
    String? mensaje,
    bool limpiarMensaje = false,
  }) {
    return SolicitudesResidenteState(
      status: status ?? this.status,
      vista: vista ?? this.vista,
      pendientes: pendientes ?? this.pendientes,
      historial: historial ?? this.historial,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
    );
  }

  @override
  List<Object?> get props => [status, vista, pendientes, historial, mensaje];
}

class SolicitudesResidenteBloc
    extends Bloc<SolicitudesResidenteEvent, SolicitudesResidenteState> {
  SolicitudesResidenteBloc(
    this._listarPendientesUseCase,
    this._listarHistorialUseCase,
    this._aprobarUseCase,
    this._rechazarUseCase,
  ) : super(const SolicitudesResidenteState()) {
    on<SolicitudesResidenteIniciadas>(_onIniciar);
    on<SolicitudesPendientesSolicitadas>(_onCargarPendientes);
    on<HistorialSolicitudesSolicitado>(_onCargarHistorial);
    on<VistaSolicitudesCambiada>(_onCambiarVista);
    on<SolicitudAprobada>(_onAprobar);
    on<SolicitudRechazada>(_onRechazar);
    on<MensajeSolicitudesLimpiado>(
      (event, emit) => emit(state.copyWith(limpiarMensaje: true)),
    );
  }

  final ListarSolicitudesPendientesUseCase _listarPendientesUseCase;
  final ListarHistorialSolicitudesUseCase _listarHistorialUseCase;
  final AprobarSolicitudUseCase _aprobarUseCase;
  final RechazarSolicitudUseCase _rechazarUseCase;

  Future<void> _onIniciar(
    SolicitudesResidenteIniciadas event,
    Emitter<SolicitudesResidenteState> emit,
  ) async {
    await _cargar(emit, incluirHistorial: false);
  }

  Future<void> _onCargarPendientes(
    SolicitudesPendientesSolicitadas event,
    Emitter<SolicitudesResidenteState> emit,
  ) async {
    await _cargar(emit, incluirHistorial: false);
  }

  Future<void> _onCargarHistorial(
    HistorialSolicitudesSolicitado event,
    Emitter<SolicitudesResidenteState> emit,
  ) async {
    await _cargar(emit, incluirHistorial: true);
  }

  void _onCambiarVista(
    VistaSolicitudesCambiada event,
    Emitter<SolicitudesResidenteState> emit,
  ) {
    emit(state.copyWith(vista: event.vista, limpiarMensaje: true));
    if (event.vista == VistaSolicitudes.historial) {
      add(const HistorialSolicitudesSolicitado());
    }
  }

  Future<void> _onAprobar(
    SolicitudAprobada event,
    Emitter<SolicitudesResidenteState> emit,
  ) async {
    emit(state.copyWith(status: SolicitudesResidenteStatus.guardando));

    final result = await _aprobarUseCase(event.id);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: SolicitudesResidenteStatus.error,
          mensaje: failure.message,
        ),
      ),
      (solicitud) async {
        final pendientes = state.pendientes
            .where((s) => s.id != solicitud.id)
            .toList();
        emit(
          state.copyWith(
            status: SolicitudesResidenteStatus.cargado,
            pendientes: pendientes,
            historial: [solicitud, ...state.historial],
            mensaje: 'Solicitud aprobada correctamente.',
          ),
        );
      },
    );
  }

  Future<void> _onRechazar(
    SolicitudRechazada event,
    Emitter<SolicitudesResidenteState> emit,
  ) async {
    emit(state.copyWith(status: SolicitudesResidenteStatus.guardando));

    final result = await _rechazarUseCase(event.id, event.motivo);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: SolicitudesResidenteStatus.error,
          mensaje: failure.message,
        ),
      ),
      (solicitud) async {
        final pendientes = state.pendientes
            .where((s) => s.id != solicitud.id)
            .toList();
        emit(
          state.copyWith(
            status: SolicitudesResidenteStatus.cargado,
            pendientes: pendientes,
            historial: [solicitud, ...state.historial],
            mensaje: 'Solicitud rechazada.',
          ),
        );
      },
    );
  }

  Future<void> _cargar(
    Emitter<SolicitudesResidenteState> emit, {
    required bool incluirHistorial,
  }) async {
    emit(
      state.copyWith(
        status: SolicitudesResidenteStatus.cargando,
        limpiarMensaje: true,
      ),
    );

    final pendientesResult = await _listarPendientesUseCase();
    final pendientesFailure = pendientesResult.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );

    if (pendientesFailure != null) {
      emit(
        state.copyWith(
          status: SolicitudesResidenteStatus.error,
          mensaje: pendientesFailure,
        ),
      );
      return;
    }

    final pendientes = pendientesResult.fold(
      (_) => <SolicitudResidente>[],
      (solicitudes) => solicitudes,
    );

    if (!incluirHistorial) {
      emit(
        state.copyWith(
          status: SolicitudesResidenteStatus.cargado,
          pendientes: pendientes,
        ),
      );
      return;
    }

    final historialResult = await _listarHistorialUseCase();
    final historialFailure = historialResult.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );

    if (historialFailure != null) {
      emit(
        state.copyWith(
          status: SolicitudesResidenteStatus.error,
          pendientes: pendientes,
          mensaje: historialFailure,
        ),
      );
      return;
    }

    final historial = historialResult.fold(
      (_) => <SolicitudResidente>[],
      (solicitudes) => solicitudes,
    );

    emit(
      state.copyWith(
        status: SolicitudesResidenteStatus.cargado,
        pendientes: pendientes,
        historial: historial,
      ),
    );
  }
}
