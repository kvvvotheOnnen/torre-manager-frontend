import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/paquete.dart';
import '../../domain/entities/paquete_foto.dart';
import '../../domain/entities/unidad_gestionable.dart';
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
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        return const Left(ServerFailure('No autenticado.'));
      }
      return Left(ServerFailure(_mensaje(error)));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<UnidadGestionable>>> listarUnidades() async {
    try {
      final dtos = await _remoteDataSource.unidades();
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        return const Left(ServerFailure('No autenticado.'));
      }
      return Left(ServerFailure(_mensaje(error)));
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
    } on ApiException catch (error) {
      if (error.statusCode == 403) {
        return Left(ServerFailure(_mensaje(error)));
      }
      return Left(ServerFailure(_mensaje(error)));
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
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return const Left(ServerFailure('Paquete no encontrado.'));
      }
      return Left(ServerFailure(_mensaje(error)));
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
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return const Left(ServerFailure('Paquete no encontrado.'));
      }
      return Left(ServerFailure(_mensaje(error)));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  String _mensaje(ApiException error) {
    final data = error.data;
    if (data is Map && data['message'] is String) {
      final mensaje = data['message'] as String;
      if (mensaje.isNotEmpty) return mensaje;
    }
    return 'Ocurrió un error en el servidor.';
  }
}
