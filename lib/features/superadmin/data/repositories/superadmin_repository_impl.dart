import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/repositories/superadmin_repository.dart';
import '../datasources/superadmin_remote_data_source.dart';

class SuperadminRepositoryImpl implements SuperadminRepositoryInterface {
  const SuperadminRepositoryImpl(this._remoteDataSource);

  final SuperadminRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos() async {
    try {
      final dtos = await _remoteDataSource.listarProyectos();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        return const Left(
          ServerFailure('No tienes permisos para esta acción.'),
        );
      }
      if (error.response?.statusCode == 401) {
        return const Left(AuthenticationFailure());
      }
      return const Left(ServerFailure());
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
