import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/solicitud_residente.dart';
import '../../domain/repositories/solicitudes_residente_repository.dart';
import '../datasources/solicitudes_residente_remote_data_source.dart';
import '../models/solicitud_residente_dto.dart';

class SolicitudesResidenteRepositoryImpl
    implements SolicitudesResidenteRepository {
  const SolicitudesResidenteRepositoryImpl(this._remoteDataSource);

  final SolicitudesResidenteRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarPendientes() {
    return _listar(_remoteDataSource.listarPendientes);
  }

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarHistorial() {
    return _listar(_remoteDataSource.listarHistorial);
  }

  @override
  Future<Either<Failure, List<SolicitudResidente>>> listarMias() {
    return _listar(_remoteDataSource.listarMias);
  }

  @override
  Future<Either<Failure, SolicitudResidente>> aprobar(String id) async {
    try {
      final dto = await _remoteDataSource.aprobar(id);
      return Right(dto.toEntity());
    } on DioException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, SolicitudResidente>> rechazar(
    String id,
    String motivo,
  ) async {
    try {
      final dto = await _remoteDataSource.rechazar(id, motivo);
      return Right(dto.toEntity());
    } on DioException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  Future<Either<Failure, List<SolicitudResidente>>> _listar(
    Future<List<SolicitudResidenteDTO>> Function() accion,
  ) async {
    try {
      final dtos = await accion();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  Failure _failure(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final mensaje = data is Map<String, dynamic> && data['message'] is String
        ? data['message'] as String
        : null;

    if (statusCode == 401) return const AuthenticationFailure();
    if (statusCode == 403) {
      return const ServerFailure('No tienes permisos para esta acción.');
    }
    if (statusCode == 404 || statusCode == 409 || statusCode == 422) {
      return ServerFailure(mensaje ?? 'No fue posible procesar la solicitud.');
    }
    return const ServerFailure();
  }
}
