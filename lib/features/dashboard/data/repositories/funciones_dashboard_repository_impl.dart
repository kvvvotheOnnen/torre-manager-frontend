import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/funcion_dashboard.dart';
import '../../domain/repositories/funciones_dashboard_repository.dart';
import '../datasources/funciones_dashboard_remote_data_source.dart';

/// Barrera anticorrupción: convierte DTOs en entidades y errores de red en
/// `Failure` de dominio.
class FuncionesDashboardRepositoryImpl implements FuncionesDashboardRepository {
  const FuncionesDashboardRepositoryImpl(this._dataSource);

  final FuncionesDashboardRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<FuncionDashboard>>> listarFunciones() async {
    try {
      final dtos = await _dataSource.listar();

      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if ((statusCode == 404 || statusCode == 422) &&
          data is Map<String, dynamic> &&
          data['message'] is String) {
        return Left(ServerFailure(data['message'] as String));
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
      return const Left(
        ServerFailure('Respuesta inesperada del servidor.'),
      );
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
