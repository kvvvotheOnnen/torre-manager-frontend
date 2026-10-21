import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/administrador.dart';
import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/repositories/superadmin_repository.dart';
import '../datasources/superadmin_remote_data_source.dart';

class SuperadminRepositoryImpl implements SuperadminRepositoryInterface {
  const SuperadminRepositoryImpl(this._remoteDataSource);

  final SuperadminRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos() async {
    return _guard(
      () => _remoteDataSource.listarProyectos().then(
        (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Administrador>>> listarAdministradores() async {
    return _guard(
      () => _remoteDataSource.listarAdministradores().then(
        (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, Administrador>> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
  }) {
    return _guard(
      () => _remoteDataSource
          .crearAdministrador(
            nombre: nombre,
            correo: correo,
            password: password,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic> && data['message'] is String) {
        final message = data['message'] as String;
        if (statusCode == 409 || statusCode == 422) {
          return Left(ValidationFailure(message));
        }
      }

      if (statusCode == 403) {
        return const Left(
          ServerFailure('No tienes permisos para esta acción.'),
        );
      }
      if (statusCode == 401) {
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
