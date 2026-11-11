import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/respuesta_asistente.dart';
import '../../domain/repositories/asistente_repository.dart';
import '../datasources/asistente_remote_data_source.dart';

class AsistenteRepositoryImpl implements AsistenteRepositoryInterface {
  const AsistenteRepositoryImpl(this._remoteDataSource);

  final AsistenteRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, RespuestaAsistente>> consultar(String pregunta) async {
    try {
      final dto = await _remoteDataSource.consultar(pregunta);
      return Right(dto.toEntity());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final mensaje = data is Map<String, dynamic> && data['message'] is String
          ? data['message'] as String
          : null;

      if (statusCode == 404) {
        return Left(
          ServerFailure(
            mensaje ??
                'La administración aún no ha cargado un documento para este proyecto.',
          ),
        );
      }
      if (statusCode == 503) {
        return Left(
          ServerFailure(
            mensaje ?? 'El modelo de IA no está disponible en este momento.',
          ),
        );
      }
      if (statusCode == 422) {
        return Left(ValidationFailure(mensaje ?? 'Revisa el texto de tu consulta.'));
      }
      if (statusCode == 403) {
        return const Left(ServerFailure('No tienes permisos para esta acción.'));
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
