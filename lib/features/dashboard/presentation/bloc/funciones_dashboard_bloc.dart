// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/funcion_dashboard.dart';
import '../../domain/usecases/obtener_funciones_dashboard_usecase.dart';

sealed class FuncionesDashboardEvent {
  const FuncionesDashboardEvent();
}

final class FuncionesSolicitadas extends FuncionesDashboardEvent {
  const FuncionesSolicitadas();
}

final class FuncionesRefrescadas extends FuncionesDashboardEvent {
  const FuncionesRefrescadas();
}

enum FuncionesDashboardStatus { inicial, cargando, cargado, error }

class FuncionesDashboardState {
  const FuncionesDashboardState({
    this.status = FuncionesDashboardStatus.inicial,
    this.funciones = const [],
    this.mensaje,
  });

  final FuncionesDashboardStatus status;
  final List<FuncionDashboard> funciones;
  final String? mensaje;

  bool get cargando => status == FuncionesDashboardStatus.cargando;
  bool get tieneFunciones => funciones.isNotEmpty;
  bool get tieneError => status == FuncionesDashboardStatus.error;

  FuncionesDashboardState copyWith({
    FuncionesDashboardStatus? status,
    List<FuncionDashboard>? funciones,
    String? mensaje,
    bool limpiarMensaje = false,
  }) {
    return FuncionesDashboardState(
      status: status ?? this.status,
      funciones: funciones ?? this.funciones,
      mensaje: limpiarMensaje ? null : (mensaje ?? this.mensaje),
    );
  }
}

class FuncionesDashboardBloc
    extends Bloc<FuncionesDashboardEvent, FuncionesDashboardState> {
  FuncionesDashboardBloc({
    required ObtenerFuncionesDashboardUseCase obtenerFunciones,
  }) : _obtenerFunciones = obtenerFunciones,
       super(const FuncionesDashboardState()) {
    on<FuncionesSolicitadas>(_onSolicitadas);
    on<FuncionesRefrescadas>(_onSolicitadas);
  }

  final ObtenerFuncionesDashboardUseCase _obtenerFunciones;

  Future<void> _onSolicitadas(
    FuncionesDashboardEvent event,
    Emitter<FuncionesDashboardState> emit,
  ) async {
    emit(state.copyWith(status: FuncionesDashboardStatus.cargando, limpiarMensaje: true));

    final resultado = await _obtenerFunciones();

    resultado.fold(
      (failure) => emit(
        state.copyWith(
          status: FuncionesDashboardStatus.error,
          mensaje: failure.message,
        ),
      ),
      (funciones) => emit(
        state.copyWith(
          status: FuncionesDashboardStatus.cargado,
          funciones: funciones,
        ),
      ),
    );
  }
}
