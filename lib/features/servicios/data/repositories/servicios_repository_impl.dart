import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/tipo_servicio.dart';
import '../../domain/entities/trabajador_servicio.dart';
import '../../domain/entities/trabajador_servicio_foto.dart';
import '../../domain/repositories/servicios_repository.dart';
import '../datasources/servicios_remote_data_source.dart';

class ServiciosRepositoryImpl implements ServiciosRepositoryInterface {
  const ServiciosRepositoryImpl(this._remoteDataSource);

  final ServiciosRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<TrabajadorServicio>>> listar({
    TipoServicio? tipo,
    String? buscar,
  }) async {
    try {
      final dtos = await _remoteDataSource.listar(tipo: tipo, buscar: buscar);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on DioException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, TrabajadorServicio>> crear({
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.crear(
        nombre: nombre,
        nombreEmpresa: nombreEmpresa,
        telefono: telefono,
        tipo: tipo,
        descripcion: descripcion,
        foto: foto,
      );
      return Right(dto.toEntity());
    } on DioException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, TrabajadorServicio>> actualizar({
    required String id,
    required String nombre,
    String? nombreEmpresa,
    required String telefono,
    required TipoServicio tipo,
    String? descripcion,
    TrabajadorServicioFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.actualizar(
        id: id,
        nombre: nombre,
        nombreEmpresa: nombreEmpresa,
        telefono: telefono,
        tipo: tipo,
        descripcion: descripcion,
        foto: foto,
      );
      return Right(dto.toEntity());
    } on DioException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> eliminar(String id) async {
    try {
      await _remoteDataSource.eliminar(id);
      return const Right(true);
    } on DioException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  Failure _failureDesde(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 401) {
      return const AuthenticationFailure();
    }

    if (statusCode == 403) {
      return const ServerFailure('No tienes permisos para realizar esta acción.');
    }

    if ((statusCode == 404 || statusCode == 422) && data is Map) {
      final mensaje = data['message'];
      if (mensaje is String && mensaje.isNotEmpty) {
        return ServerFailure(mensaje);
      }
    }

    return const ServerFailure();
  }
}
