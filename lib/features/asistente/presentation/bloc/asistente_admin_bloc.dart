import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/documento_asistente.dart';
import '../../domain/usecases/eliminar_documento_use_case.dart';
import '../../domain/usecases/obtener_documento_use_case.dart';
import '../../domain/usecases/subir_documento_use_case.dart';

sealed class AsistenteAdminEvent extends Equatable {
  const AsistenteAdminEvent();

  @override
  List<Object?> get props => [];
}

class AsistenteAdminDocumentoSolicitado extends AsistenteAdminEvent {
  const AsistenteAdminDocumentoSolicitado();
}

class AsistenteAdminDocumentoSubido extends AsistenteAdminEvent {
  const AsistenteAdminDocumentoSubido({
    required this.bytes,
    required this.nombre,
  });

  final List<int> bytes;
  final String nombre;

  @override
  List<Object?> get props => [nombre, bytes.length];
}

class AsistenteAdminDocumentoEliminado extends AsistenteAdminEvent {
  const AsistenteAdminDocumentoEliminado();
}

enum AsistenteAdminStatus {
  inicial,
  cargando,
  subiendo,
  eliminando,
  cargado,
  error,
}

class AsistenteAdminState extends Equatable {
  const AsistenteAdminState({
    this.status = AsistenteAdminStatus.inicial,
    this.documento,
    this.mensaje,
  });

  final AsistenteAdminStatus status;
  final DocumentoAsistente? documento;
  final String? mensaje;

  bool get ocupado =>
      status == AsistenteAdminStatus.cargando ||
      status == AsistenteAdminStatus.subiendo ||
      status == AsistenteAdminStatus.eliminando;

  @override
  List<Object?> get props => [status, documento, mensaje];
}

class AsistenteAdminBloc
    extends Bloc<AsistenteAdminEvent, AsistenteAdminState> {
  AsistenteAdminBloc({
    required this._obtenerDocumentoUseCase,
    required this._subirDocumentoUseCase,
    required this._eliminarDocumentoUseCase,
  }) : super(const AsistenteAdminState()) {
    on<AsistenteAdminDocumentoSolicitado>(_onSolicitado);
    on<AsistenteAdminDocumentoSubido>(_onSubido);
    on<AsistenteAdminDocumentoEliminado>(_onEliminado);
  }

  final ObtenerDocumentoUseCase _obtenerDocumentoUseCase;
  final SubirDocumentoUseCase _subirDocumentoUseCase;
  final EliminarDocumentoUseCase _eliminarDocumentoUseCase;

  Future<void> _onSolicitado(
    AsistenteAdminDocumentoSolicitado event,
    Emitter<AsistenteAdminState> emit,
  ) async {
    emit(
      AsistenteAdminState(
        status: AsistenteAdminStatus.cargando,
        documento: state.documento,
      ),
    );

    final result = await _obtenerDocumentoUseCase();

    result.fold(
      (failure) => emit(
        AsistenteAdminState(
          status: AsistenteAdminStatus.error,
          documento: state.documento,
          mensaje: failure.message,
        ),
      ),
      (documento) => emit(
        AsistenteAdminState(
          status: AsistenteAdminStatus.cargado,
          documento: documento,
        ),
      ),
    );
  }

  Future<void> _onSubido(
    AsistenteAdminDocumentoSubido event,
    Emitter<AsistenteAdminState> emit,
  ) async {
    emit(
      AsistenteAdminState(
        status: AsistenteAdminStatus.subiendo,
        documento: state.documento,
      ),
    );

    final result = await _subirDocumentoUseCase(
      bytes: event.bytes,
      nombre: event.nombre,
    );

    result.fold(
      (failure) => emit(
        AsistenteAdminState(
          status: AsistenteAdminStatus.cargado,
          documento: state.documento,
          mensaje: failure.message,
        ),
      ),
      (documento) => emit(
        AsistenteAdminState(
          status: AsistenteAdminStatus.cargado,
          documento: documento,
        ),
      ),
    );
  }

  Future<void> _onEliminado(
    AsistenteAdminDocumentoEliminado event,
    Emitter<AsistenteAdminState> emit,
  ) async {
    emit(
      AsistenteAdminState(
        status: AsistenteAdminStatus.eliminando,
        documento: state.documento,
      ),
    );

    final result = await _eliminarDocumentoUseCase();

    result.fold(
      (failure) => emit(
        AsistenteAdminState(
          status: AsistenteAdminStatus.cargado,
          documento: state.documento,
          mensaje: failure.message,
        ),
      ),
      (_) => emit(const AsistenteAdminState(
        status: AsistenteAdminStatus.cargado,
      )),
    );
  }
}
