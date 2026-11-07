// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/modulo_dashboard.dart';
import '../../domain/usecases/obtener_modulos_dashboard_usecase.dart';

sealed class ModulosDashboardEvent extends Equatable {
  const ModulosDashboardEvent();

  @override
  List<Object?> get props => [];
}

class ModulosDashboardSolicitados extends ModulosDashboardEvent {
  const ModulosDashboardSolicitados();
}

enum ModulosDashboardStatus { inicial, cargando, cargado, error }

class ModulosDashboardState extends Equatable {
  const ModulosDashboardState({
    this.status = ModulosDashboardStatus.inicial,
    this.modulos = const [],
    this.mensaje,
  });

  final ModulosDashboardStatus status;
  final List<ModuloDashboard> modulos;
  final String? mensaje;

  List<ModuloDashboard> get modulosProyecto =>
      modulos.where((modulo) => !modulo.esGeneral).toList();

  List<ModuloDashboard> get modulosGenerales =>
      modulos.where((modulo) => modulo.esGeneral).toList();

  @override
  List<Object?> get props => [status, modulos, mensaje];
}

class ModulosDashboardBloc
    extends Bloc<ModulosDashboardEvent, ModulosDashboardState> {
  ModulosDashboardBloc({
    required ObtenerModulosDashboardUseCase obtenerModulosUseCase,
  }) : _obtenerModulosUseCase = obtenerModulosUseCase,
       super(const ModulosDashboardState()) {
    on<ModulosDashboardSolicitados>(_onSolicitados);
  }

  final ObtenerModulosDashboardUseCase _obtenerModulosUseCase;

  Future<void> _onSolicitados(
    ModulosDashboardSolicitados event,
    Emitter<ModulosDashboardState> emit,
  ) async {
    emit(
      ModulosDashboardState(
        status: ModulosDashboardStatus.cargando,
        modulos: state.modulos,
      ),
    );

    final result = await _obtenerModulosUseCase();

    result.fold(
      (failure) => emit(
        ModulosDashboardState(
          status: ModulosDashboardStatus.error,
          modulos: state.modulos,
          mensaje: failure.message,
        ),
      ),
      (modulos) => emit(
        ModulosDashboardState(
          status: ModulosDashboardStatus.cargado,
          modulos: modulos
              .where((modulo) => modulo.id != 'infraestructura')
              .toList(),
        ),
      ),
    );
  }
}
