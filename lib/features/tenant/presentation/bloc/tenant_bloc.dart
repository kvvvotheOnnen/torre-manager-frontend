// ignore_for_file: prefer_initializing_formals
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tenant/proyecto_activo_store.dart';
import '../../../superadmin/domain/entities/proyecto_detalle.dart';
import '../../../superadmin/domain/usecases/listar_mis_proyectos_usecase.dart';

sealed class TenantEvent extends Equatable {
  const TenantEvent();

  @override
  List<Object?> get props => [];
}

/// Resuelve los proyectos del administrador y define el contexto de tenant.
class TenantResuelto extends TenantEvent {
  const TenantResuelto();
}

class TenantProyectoSeleccionado extends TenantEvent {
  const TenantProyectoSeleccionado(this.proyectoId);

  final String proyectoId;

  @override
  List<Object?> get props => [proyectoId];
}

class TenantLimpiado extends TenantEvent {
  const TenantLimpiado();
}

enum TenantStatus { inicial, cargando, seleccionPendiente, listo, sinProyectos }

class TenantState extends Equatable {
  const TenantState({
    this.status = TenantStatus.inicial,
    this.proyectos = const [],
    this.proyectoActivoId,
    this.mensaje,
  });

  final TenantStatus status;
  final List<ProyectoDetalle> proyectos;
  final String? proyectoActivoId;
  final String? mensaje;

  ProyectoDetalle? get proyectoActivo {
    for (final proyecto in proyectos) {
      if (proyecto.id == proyectoActivoId) return proyecto;
    }
    return null;
  }

  @override
  List<Object?> get props => [status, proyectos, proyectoActivoId, mensaje];
}

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  TenantBloc({
    required ListarMisProyectosUseCase listarMisProyectosUseCase,
    required ProyectoActivoStore proyectoActivoStore,
  }) : _listarMisProyectosUseCase = listarMisProyectosUseCase,
       _proyectoActivoStore = proyectoActivoStore,
       super(const TenantState()) {
    on<TenantResuelto>(_onResuelto);
    on<TenantProyectoSeleccionado>(_onSeleccionado);
    on<TenantLimpiado>(_onLimpiado);
  }

  final ListarMisProyectosUseCase _listarMisProyectosUseCase;
  final ProyectoActivoStore _proyectoActivoStore;

  Future<void> _onResuelto(
    TenantResuelto event,
    Emitter<TenantState> emit,
  ) async {
    emit(const TenantState(status: TenantStatus.cargando));

    final result = await _listarMisProyectosUseCase();

    await result.fold(
      (failure) async => emit(
        TenantState(
          status: TenantStatus.sinProyectos,
          mensaje: failure.message,
        ),
      ),
      (proyectos) async {
        if (proyectos.isEmpty) {
          await _proyectoActivoStore.clear();
          emit(const TenantState(status: TenantStatus.sinProyectos));
          return;
        }

        if (proyectos.length == 1) {
          final proyecto = proyectos.first;
          await _proyectoActivoStore.saveProyectoId(proyecto.id);
          emit(
            TenantState(
              status: TenantStatus.listo,
              proyectos: proyectos,
              proyectoActivoId: proyecto.id,
            ),
          );
          return;
        }

        final guardado = await _proyectoActivoStore.readProyectoId();
        final esValido = proyectos.any((proyecto) => proyecto.id == guardado);

        if (esValido) {
          emit(
            TenantState(
              status: TenantStatus.listo,
              proyectos: proyectos,
              proyectoActivoId: guardado,
            ),
          );
          return;
        }

        await _proyectoActivoStore.clear();
        emit(
          TenantState(
            status: TenantStatus.seleccionPendiente,
            proyectos: proyectos,
          ),
        );
      },
    );
  }

  Future<void> _onSeleccionado(
    TenantProyectoSeleccionado event,
    Emitter<TenantState> emit,
  ) async {
    final esValido = state.proyectos.any(
      (proyecto) => proyecto.id == event.proyectoId,
    );
    if (!esValido) return;

    await _proyectoActivoStore.saveProyectoId(event.proyectoId);

    emit(
      TenantState(
        status: TenantStatus.listo,
        proyectos: state.proyectos,
        proyectoActivoId: event.proyectoId,
      ),
    );
  }

  Future<void> _onLimpiado(
    TenantLimpiado event,
    Emitter<TenantState> emit,
  ) async {
    await _proyectoActivoStore.clear();
    emit(const TenantState());
  }
}
