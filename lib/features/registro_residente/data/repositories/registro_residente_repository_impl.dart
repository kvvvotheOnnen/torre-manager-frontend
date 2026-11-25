import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/registro_residente.dart';
import '../../domain/repositories/registro_residente_repository.dart';
import '../datasources/registro_residente_remote_data_source.dart';
import '../models/registro_residente_dto.dart';

class RegistroResidenteRepositoryImpl implements RegistroResidenteRepository {
  const RegistroResidenteRepositoryImpl(this._remoteDataSource);

  final RegistroResidenteRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ProyectoRegistro>>> listarProyectos() async {
    try {
      final dtos = await _remoteDataSource.listarProyectos();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ApiException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<UnidadRegistro>>> listarUnidades(
    String proyectoId,
  ) async {
    try {
      final dtos = await _remoteDataSource.listarUnidades(proyectoId);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ApiException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, String>> registrar(
    SolicitudRegistro solicitud,
  ) async {
    try {
      final mensaje = await _remoteDataSource.registrar(
        SolicitudRegistroDTO.fromEntity(solicitud),
      );
      return Right(mensaje);
    } on ApiException catch (error) {
      return Left(_failure(error));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  Failure _failure(ApiException error) {
    final statusCode = error.statusCode;
    final data = error.data;
    final mensaje = data is Map<String, dynamic> && data['message'] is String
        ? data['message'] as String
        : null;

    if (statusCode == 401) return const AuthenticationFailure();
    if (statusCode == 403) {
      return const ServerFailure('No tienes permisos para esta acción.');
    }
    if (statusCode == 404 || statusCode == 409 || statusCode == 422) {
      return ServerFailure(mensaje ?? 'No fue posible procesar el registro.');
    }
    return const ServerFailure();
  }
}
