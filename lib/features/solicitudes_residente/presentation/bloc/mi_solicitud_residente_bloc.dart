import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/solicitud_residente.dart';
import '../../domain/usecases/listar_mis_solicitudes_usecase.dart';

enum MiSolicitudStatus { inicial, cargando, cargada, error }

sealed class MiSolicitudEvent extends Equatable {
  const MiSolicitudEvent();

  @override
  List<Object?> get props => [];
}

class MiSolicitudCargada extends MiSolicitudEvent {
  const MiSolicitudCargada();
}

class MiSolicitudState extends Equatable {
  const MiSolicitudState({
    this.status = MiSolicitudStatus.inicial,
    this.solicitudes = const [],
    this.mensaje,
  });

  final MiSolicitudStatus status;
  final List<SolicitudResidente> solicitudes;
  final String? mensaje;

  SolicitudResidente? get ultima =>
      solicitudes.isEmpty ? null : solicitudes.first;

  @override
  List<Object?> get props => [status, solicitudes, mensaje];
}

class MiSolicitudResidenteBloc
    extends Bloc<MiSolicitudEvent, MiSolicitudState> {
  MiSolicitudResidenteBloc(this._listarMisSolicitudesUseCase)
    : super(const MiSolicitudState()) {
    on<MiSolicitudCargada>(_onCargar);
  }

  final ListarMisSolicitudesUseCase _listarMisSolicitudesUseCase;

  Future<void> _onCargar(
    MiSolicitudCargada event,
    Emitter<MiSolicitudState> emit,
  ) async {
    emit(
      MiSolicitudState(
        status: MiSolicitudStatus.cargando,
        solicitudes: state.solicitudes,
      ),
    );

    final result = await _listarMisSolicitudesUseCase();

    result.fold(
      (failure) => emit(
        MiSolicitudState(
          status: MiSolicitudStatus.error,
          solicitudes: state.solicitudes,
          mensaje: failure.message,
        ),
      ),
      (solicitudes) => emit(
        MiSolicitudState(
          status: MiSolicitudStatus.cargada,
          solicitudes: solicitudes,
        ),
      ),
    );
  }
}
