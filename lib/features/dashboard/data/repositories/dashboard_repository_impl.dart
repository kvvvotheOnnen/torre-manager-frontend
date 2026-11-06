import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/modulo_dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ModuloDashboard>>> listarModulos() async {
    try {
      final modulos = await _remoteDataSource.listarModulos();
      return Right(modulos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic> && data['message'] is String) {
        final message = data['message'] as String;
        if (statusCode == 404 || statusCode == 422) {
          return Left(ServerFailure(message));
        }
      }

      if (statusCode == 401) {
        return const Left(AuthenticationFailure());
      }
      if (statusCode == 403) {
        return const Left(
          ServerFailure('No tienes permisos para esta acción.'),
        );
      }

      return const Left(ServerFailure());
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
