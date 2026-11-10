import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/paquete.dart';
import '../../domain/entities/paquete_foto.dart';
import '../../domain/usecases/actualizar_paquete_usecase.dart';
import '../../domain/usecases/listar_paquetes_usecase.dart';
import '../../domain/usecases/marcar_paquete_retirado_usecase.dart';
import '../../domain/usecases/registrar_paquete_usecase.dart';
import '../../data/datasources/paqueteria_remote_data_source.dart';

sealed class PaqueteriaEvent extends Equatable {
  const PaqueteriaEvent();

  @override
  List<Object?> get props => [];
}

class PaqueteriaSolicitada extends PaqueteriaEvent {
  const PaqueteriaSolicitada();
}

class PaqueteriaLimpiada extends PaqueteriaEvent {
  const PaqueteriaLimpiada();
}

class PaqueteriaUnidadesSolicitadas extends PaqueteriaEvent {
  const PaqueteriaUnidadesSolicitadas();
}

class PaqueteRegistrado extends PaqueteriaEvent {
  const PaqueteRegistrado({
    required this.proyectoId,
    required this.descripcion,
    this.remitente,
    this.residenteId,
    this.unidadPrincipalId,
    this.foto,
  });

  final int proyectoId;
  final String descripcion;
  final String? remitente;
  final int? residenteId;
  final int? unidadPrincipalId;
  final PaqueteFoto? foto;

  @override
  List<Object?> get props => [proyectoId, descripcion];
}

class PaqueteRetirado extends PaqueteriaEvent {
  const PaqueteRetirado(this.id, this.retiradoPorNombre);

  final String id;
  final String retiradoPorNombre;

  @override
  List<Object?> get props => [id, retiradoPorNombre];
}

class PaqueteActualizado extends PaqueteriaEvent {
  const PaqueteActualizado({
    required this.id,
    this.descripcion,
    this.remitente,
    this.residenteId,
    this.unidadPrincipalId,
    this.foto,
  });

  final String id;
  final String? descripcion;
  final String? remitente;
  final int? residenteId;
  final int? unidadPrincipalId;
  final PaqueteFoto? foto;

  @override
  List<Object?> get props => [id];
}

enum PaqueteriaStatus { inicial, cargando, cargado, error, registrando }

class PaqueteriaState extends Equatable {
  const PaqueteriaState({
    this.status = PaqueteriaStatus.inicial,
    this.paquetes = const [],
    this.unidades = const [],
    this.mensaje,
    this.errorUnidades,
  });

  final PaqueteriaStatus status;
  final List<Paquete> paquetes;
  final List<Map<String, dynamic>> unidades;
  final String? mensaje;
  final String? errorUnidades;

  List<Paquete> get pendientes =>
      paquetes.where((p) => p.estaPendiente).toList();

  List<Paquete> get retirados =>
      paquetes.where((p) => !p.estaPendiente).toList();

  @override
  List<Object?> get props => [
    status,
    paquetes,
    unidades,
    mensaje,
    errorUnidades,
  ];
}

class PaqueteriaBloc extends Bloc<PaqueteriaEvent, PaqueteriaState> {
  PaqueteriaBloc({
    required this.listarUseCase,
    required this.registrarUseCase,
    required this.marcarRetiradoUseCase,
    required this.actualizarUseCase,
    required this.remoteDataSource,
  }) : super(const PaqueteriaState()) {
    on<PaqueteriaSolicitada>(_onSolicitada);
    on<PaqueteriaLimpiada>(_onLimpiada);
    on<PaqueteriaUnidadesSolicitadas>(_onUnidadesSolicitadas);
    on<PaqueteRegistrado>(_onRegistrado);
    on<PaqueteRetirado>(_onRetirado);
    on<PaqueteActualizado>(_onActualizado);
  }

  final ListarPaquetesUseCase listarUseCase;
  final RegistrarPaqueteUseCase registrarUseCase;
  final MarcarPaqueteRetiradoUseCase marcarRetiradoUseCase;
  final ActualizarPaqueteUseCase actualizarUseCase;
  final PaqueteriaRemoteDataSource remoteDataSource;
  int _identityVersion = 0;

  void _onLimpiada(PaqueteriaLimpiada event, Emitter<PaqueteriaState> emit) {
    _identityVersion++;
    emit(const PaqueteriaState());
  }

  Future<void> _onSolicitada(
    PaqueteriaSolicitada event,
    Emitter<PaqueteriaState> emit,
  ) async {
    final identityVersion = _identityVersion;
    emit(
      PaqueteriaState(status: PaqueteriaStatus.cargando, paquetes: const []),
    );
    final result = await listarUseCase();
    if (identityVersion != _identityVersion) return;
    result.fold(
      (failure) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.error,
          paquetes: const [],
          unidades: state.unidades,
          mensaje: failure.message,
          errorUnidades: state.errorUnidades,
        ),
      ),
      (paquetes) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.cargado,
          paquetes: paquetes,
          unidades: state.unidades,
          errorUnidades: state.errorUnidades,
        ),
      ),
    );
  }

  Future<void> _onUnidadesSolicitadas(
    PaqueteriaUnidadesSolicitadas event,
    Emitter<PaqueteriaState> emit,
  ) async {
    final identityVersion = _identityVersion;
    try {
      final unidades = await remoteDataSource.unidades();
      if (identityVersion != _identityVersion) return;
      emit(
        PaqueteriaState(
          status: state.status,
          paquetes: state.paquetes,
          unidades: unidades,
          mensaje: state.mensaje,
          errorUnidades: null,
        ),
      );
    } catch (e) {
      if (identityVersion != _identityVersion) return;
      emit(
        PaqueteriaState(
          status: state.status,
          paquetes: state.paquetes,
          unidades: state.unidades,
          mensaje: state.mensaje,
          errorUnidades: 'Error: $e',
        ),
      );
    }
  }

  Future<void> _onRegistrado(
    PaqueteRegistrado event,
    Emitter<PaqueteriaState> emit,
  ) async {
    final identityVersion = _identityVersion;
    emit(
      PaqueteriaState(
        status: PaqueteriaStatus.registrando,
        paquetes: state.paquetes,
      ),
    );
    final result = await registrarUseCase(
      proyectoId: event.proyectoId,
      descripcion: event.descripcion,
      remitente: event.remitente,
      residenteId: event.residenteId,
      unidadPrincipalId: event.unidadPrincipalId,
      foto: event.foto,
    );
    if (identityVersion != _identityVersion) return;
    result.fold(
      (failure) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.error,
          paquetes: state.paquetes,
          unidades: state.unidades,
          mensaje: failure.message,
          errorUnidades: state.errorUnidades,
        ),
      ),
      (paquete) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.cargado,
          paquetes: [paquete, ...state.paquetes],
          unidades: state.unidades,
          errorUnidades: state.errorUnidades,
        ),
      ),
    );
  }

  Future<void> _onRetirado(
    PaqueteRetirado event,
    Emitter<PaqueteriaState> emit,
  ) async {
    final identityVersion = _identityVersion;
    final result = await marcarRetiradoUseCase(
      event.id,
      event.retiradoPorNombre,
    );
    if (identityVersion != _identityVersion) return;
    result.fold(
      (failure) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.error,
          paquetes: state.paquetes,
          unidades: state.unidades,
          mensaje: failure.message,
          errorUnidades: state.errorUnidades,
        ),
      ),
      (paquete) {
        final actualizados = state.paquetes.map((p) {
          if (p.id == paquete.id) return paquete;
          return p;
        }).toList();
        emit(
          PaqueteriaState(
            status: PaqueteriaStatus.cargado,
            paquetes: actualizados,
            unidades: state.unidades,
            errorUnidades: state.errorUnidades,
          ),
        );
      },
    );
  }

  Future<void> _onActualizado(
    PaqueteActualizado event,
    Emitter<PaqueteriaState> emit,
  ) async {
    final identityVersion = _identityVersion;
    final result = await actualizarUseCase(
      id: event.id,
      descripcion: event.descripcion,
      remitente: event.remitente,
      residenteId: event.residenteId,
      unidadPrincipalId: event.unidadPrincipalId,
      foto: event.foto,
    );
    if (identityVersion != _identityVersion) return;
    result.fold(
      (failure) => emit(
        PaqueteriaState(
          status: PaqueteriaStatus.error,
          paquetes: state.paquetes,
          unidades: state.unidades,
          mensaje: failure.message,
          errorUnidades: state.errorUnidades,
        ),
      ),
      (paquete) {
        final actualizados = state.paquetes.map((p) {
          if (p.id == paquete.id) return paquete;
          return p;
        }).toList();
        emit(
          PaqueteriaState(
            status: PaqueteriaStatus.cargado,
            paquetes: actualizados,
            unidades: state.unidades,
            errorUnidades: state.errorUnidades,
          ),
        );
      },
    );
  }
}
