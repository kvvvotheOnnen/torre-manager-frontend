import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/mi_informacion.dart';
import '../../domain/repositories/residente_repository.dart';
import '../datasources/residente_remote_data_source.dart';

class ResidenteRepositoryImpl implements ResidenteRepositoryInterface {
  const ResidenteRepositoryImpl(this._remoteDataSource);

  final ResidenteRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, MiInformacion>> obtenerMiInformacion() async {
    try {
      final dto = await _remoteDataSource.miInformacion();
      return Right(dto.toEntity());
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const Left(ServerFailure('No tienes una unidad asignada.'));
      }
      if (error.response?.statusCode == 403) {
        return const Left(ServerFailure('No tienes permisos.'));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
