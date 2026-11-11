import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/documento_asistente.dart';
import '../../domain/repositories/asistente_admin_repository.dart';
import '../datasources/asistente_admin_remote_data_source.dart';

class AsistenteAdminRepositoryImpl implements AsistenteAdminRepositoryInterface {
  const AsistenteAdminRepositoryImpl(this._remoteDataSource);

  final AsistenteAdminRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DocumentoAsistente?>> obtenerDocumento() {
    return _guard(
      () => _remoteDataSource.obtenerDocumento().then((dto) => dto?.toEntity()),
    );
  }

  @override
  Future<Either<Failure, DocumentoAsistente>> subirDocumento({
    required List<int> bytes,
    required String nombre,
  }) {
    return _guard(
      () => _remoteDataSource
          .subirDocumento(bytes: bytes, nombre: nombre)
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> eliminarDocumento() {
    return _guard(() => _remoteDataSource.eliminarDocumento());
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final mensaje = data is Map<String, dynamic> && data['message'] is String
          ? data['message'] as String
          : null;

      if (statusCode == 409 || statusCode == 422) {
        return Left(ValidationFailure(mensaje ?? 'No fue posible procesar la solicitud.'));
      }
      if (statusCode == 403) {
        return const Left(ServerFailure('No tienes permisos para esta acción.'));
      }
      if (statusCode == 404) {
        return Left(ServerFailure(mensaje ?? 'No se encontró el documento.'));
      }
      if (statusCode == 401) {
        return const Left(AuthenticationFailure());
      }
      return Left(ServerFailure(mensaje ?? 'Ocurrió un error en el servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
