import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mi_informacion.dart';
import '../../domain/usecases/obtener_mi_informacion_usecase.dart';

sealed class ResidenteMiInformacionEvent extends Equatable {
  const ResidenteMiInformacionEvent();

  @override
  List<Object?> get props => [];
}

class ResidenteMiInformacionSolicitada extends ResidenteMiInformacionEvent {
  const ResidenteMiInformacionSolicitada();
}

enum ResidenteMiInformacionStatus { inicial, cargando, cargado, error }

class ResidenteMiInformacionState extends Equatable {
  const ResidenteMiInformacionState({
    this.status = ResidenteMiInformacionStatus.inicial,
    this.informacion,
    this.mensaje,
  });

  final ResidenteMiInformacionStatus status;
  final MiInformacion? informacion;
  final String? mensaje;

  @override
  List<Object?> get props => [status, informacion, mensaje];
}

class ResidenteMiInformacionBloc
    extends Bloc<ResidenteMiInformacionEvent, ResidenteMiInformacionState> {
  ResidenteMiInformacionBloc({
    required this._obtenerMiInformacionUseCase,
  }) : super(const ResidenteMiInformacionState()) {
    on<ResidenteMiInformacionSolicitada>(_onSolicitada);
  }

  final ObtenerMiInformacionUseCase _obtenerMiInformacionUseCase;

  Future<void> _onSolicitada(
    ResidenteMiInformacionSolicitada event,
    Emitter<ResidenteMiInformacionState> emit,
  ) async {
    emit(
      ResidenteMiInformacionState(
        status: ResidenteMiInformacionStatus.cargando,
        informacion: state.informacion,
      ),
    );

    final result = await _obtenerMiInformacionUseCase();

    result.fold(
      (failure) => emit(
        ResidenteMiInformacionState(
          status: ResidenteMiInformacionStatus.error,
          informacion: state.informacion,
          mensaje: failure.message,
        ),
      ),
      (informacion) => emit(
        ResidenteMiInformacionState(
          status: ResidenteMiInformacionStatus.cargado,
          informacion: informacion,
        ),
      ),
    );
  }
}
