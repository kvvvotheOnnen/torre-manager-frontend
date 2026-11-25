import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_remote_data_source.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepositoryInterface {
  const NotificacionesRepositoryImpl(this._remoteDataSource);

  final NotificacionesRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Notificacion>>> listar() async {
    try {
      final items = await _remoteDataSource.listar();
      return Right(items.map((item) => item.toEntity()).toList());
    } on ApiException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> contarNoLeidas() async {
    try {
      return Right(await _remoteDataSource.contarNoLeidas());
    } on ApiException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Notificacion>> marcarLeida(String id) async {
    try {
      final item = await _remoteDataSource.marcarLeida(id);
      return Right(item.toEntity());
    } on ApiException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> marcarTodasLeidas() async {
    try {
      return Right(await _remoteDataSource.marcarTodasLeidas());
    } on ApiException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  Failure _failureDesde(ApiException error) {
    if (error.statusCode == 401) {
      return const AuthenticationFailure();
    }
    if (error.statusCode == 403) {
      return const ServerFailure('No tienes permisos para realizar esta acción.');
    }
    if (error.statusCode == 404 || error.statusCode == 422) {
      final data = error.data;
      if (data is Map && data['message'] is String) {
        final mensaje = data['message'] as String;
        if (mensaje.isNotEmpty) {
          return ServerFailure(mensaje);
        }
      }
    }
    return const ServerFailure();
  }
}
