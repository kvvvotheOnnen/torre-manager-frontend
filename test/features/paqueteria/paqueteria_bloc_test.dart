import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:torre_manager_frontend/core/errors/failures.dart';
import 'package:torre_manager_frontend/features/paqueteria/data/datasources/paqueteria_remote_data_source.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/entities/paquete.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/entities/paquete_foto.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/repositories/paqueteria_repository.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/usecases/actualizar_paquete_usecase.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/usecases/listar_paquetes_usecase.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/usecases/marcar_paquete_retirado_usecase.dart';
import 'package:torre_manager_frontend/features/paqueteria/domain/usecases/registrar_paquete_usecase.dart';
import 'package:torre_manager_frontend/features/paqueteria/presentation/bloc/paqueteria_bloc.dart';

void main() {
  test(
    'una respuesta tardía no restaura paquetes tras limpiar la identidad',
    () async {
      final repo = _RepositorioConRespuestaTardia();
      final bloc = PaqueteriaBloc(
        listarUseCase: ListarPaquetesUseCase(repo),
        registrarUseCase: RegistrarPaqueteUseCase(repo),
        marcarRetiradoUseCase: MarcarPaqueteRetiradoUseCase(repo),
        actualizarUseCase: ActualizarPaqueteUseCase(repo),
        remoteDataSource: PaqueteriaRemoteDataSource(Dio()),
      );
      addTearDown(bloc.close);

      bloc.add(const PaqueteriaSolicitada());
      await bloc.stream.firstWhere(
        (state) => state.status == PaqueteriaStatus.cargado,
      );
      expect(bloc.state.paquetes.single.id, 'viejo');

      bloc.add(const PaqueteriaSolicitada());
      await bloc.stream.firstWhere(
        (state) => state.status == PaqueteriaStatus.cargando,
      );
      expect(bloc.state.paquetes, isEmpty);

      bloc.add(const PaqueteriaLimpiada());
      await bloc.stream.firstWhere(
        (state) => state.status == PaqueteriaStatus.inicial,
      );
      repo.respuestaTardia.complete(Right([_paquete('viejo')]));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.paquetes, isEmpty);
      expect(bloc.state.status, PaqueteriaStatus.inicial);
    },
  );
}

class _RepositorioConRespuestaTardia implements PaqueteriaRepositoryInterface {
  int _llamadas = 0;
  final Completer<Either<Failure, List<Paquete>>> respuestaTardia =
      Completer<Either<Failure, List<Paquete>>>();

  @override
  Future<Either<Failure, List<Paquete>>> listar() {
    _llamadas++;
    if (_llamadas == 1) return Future.value(Right([_paquete('viejo')]));
    return respuestaTardia.future;
  }

  @override
  Future<Either<Failure, Paquete>> registrar({
    required int proyectoId,
    required String descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Paquete>> marcarRetirado(
    String id,
    String retiradoPorNombre,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Paquete>> actualizar({
    required String id,
    String? descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) => throw UnimplementedError();
}

Paquete _paquete(String id) => Paquete(
  id: id,
  descripcion: 'Paquete de prueba',
  estado: 'pendiente',
  fechaRecepcion: '2026-11-10',
);
