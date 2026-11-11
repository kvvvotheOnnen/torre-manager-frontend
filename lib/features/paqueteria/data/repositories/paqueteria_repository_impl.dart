import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/paquete.dart';
import '../../domain/entities/paquete_foto.dart';
import '../../domain/repositories/paqueteria_repository.dart';
import '../datasources/paqueteria_remote_data_source.dart';

class PaqueteriaRepositoryImpl implements PaqueteriaRepositoryInterface {
  const PaqueteriaRepositoryImpl(this._remoteDataSource);

  final PaqueteriaRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Paquete>>> listar() async {
    try {
      final dtos = await _remoteDataSource.listar();
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return const Left(ServerFailure('No autenticado.'));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Paquete>> registrar({
    required int proyectoId,
    required String descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.registrar(
        proyectoId: proyectoId,
        descripcion: descripcion,
        remitente: remitente,
        residenteId: residenteId,
        unidadPrincipalId: unidadPrincipalId,
        foto: foto,
      );
      return Right(dto.toEntity());
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        return const Left(
          ServerFailure('No tienes permisos para registrar paquetes.'),
        );
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Paquete>> actualizar({
    required String id,
    String? descripcion,
    String? remitente,
    int? residenteId,
    int? unidadPrincipalId,
    PaqueteFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.actualizar(
        id: id,
        descripcion: descripcion,
        remitente: remitente,
        residenteId: residenteId,
        unidadPrincipalId: unidadPrincipalId,
        foto: foto,
      );
      return Right(dto.toEntity());
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const Left(ServerFailure('Paquete no encontrado.'));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Paquete>> marcarRetirado(
    String id,
    String retiradoPorNombre,
  ) async {
    try {
      final dto = await _remoteDataSource.marcarRetirado(id, retiradoPorNombre);
      return Right(dto.toEntity());
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const Left(ServerFailure('Paquete no encontrado.'));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
