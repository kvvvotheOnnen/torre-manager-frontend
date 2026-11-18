import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/categoria_producto.dart';
import '../../domain/entities/condicion_producto.dart';
import '../../domain/entities/estado_publicacion.dart';
import '../../domain/entities/publicacion_foto.dart';
import '../../domain/entities/publicacion_marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_data_source.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepositoryInterface {
  const MarketplaceRepositoryImpl(this._remoteDataSource);

  final MarketplaceRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<PublicacionMarketplace>>> listar({
    bool todas = false,
    EstadoPublicacion? estado,
  }) async {
    try {
      final dtos = await _remoteDataSource.listar(todas: todas, estado: estado);
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
  Future<Either<Failure, List<PublicacionMarketplace>>>
  misPublicaciones() async {
    try {
      final dtos = await _remoteDataSource.misPublicaciones();
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
  Future<Either<Failure, List<PublicacionMarketplace>>> historial() async {
    try {
      final dtos = await _remoteDataSource.historial();
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
  Future<Either<Failure, List<PublicacionMarketplace>>> favoritos() async {
    try {
      final dtos = await _remoteDataSource.favoritos();
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
  Future<Either<Failure, PublicacionMarketplace>> crear({
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.crear(
        titulo: titulo,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        condicion: condicion,
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
  Future<Either<Failure, PublicacionMarketplace>> actualizar({
    required String id,
    required String titulo,
    required String descripcion,
    required int precio,
    required CategoriaProducto categoria,
    required CondicionProducto condicion,
    PublicacionFoto? foto,
  }) async {
    try {
      final dto = await _remoteDataSource.actualizar(
        id: id,
        titulo: titulo,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        condicion: condicion,
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
  Future<Either<Failure, PublicacionMarketplace>> retirar(String id) async {
    try {
      final dto = await _remoteDataSource.retirar(id);
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
  Future<Either<Failure, PublicacionMarketplace>> vender(String id) async {
    try {
      final dto = await _remoteDataSource.vender(id);
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
  Future<Either<Failure, bool>> eliminar({
    required String id,
    required String motivo,
  }) async {
    try {
      await _remoteDataSource.eliminar(id: id, motivo: motivo);
      return const Right(true);
    } on DioException catch (error) {
      return Left(_failureDesde(error));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> alternarFavorito({
    required String id,
    required bool favorito,
  }) async {
    try {
      final esFavorita = await _remoteDataSource.alternarFavorito(
        id: id,
        favorito: favorito,
      );
      return Right(esFavorita);
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
      return const ServerFailure(
        'No tienes permisos para realizar esta acción.',
      );
    }

    if ((statusCode == 404 || statusCode == 409 || statusCode == 422) &&
        data is Map) {
      final mensaje = data['message'];
      if (mensaje is String && mensaje.isNotEmpty) {
        return ServerFailure(mensaje);
      }
    }

    return const ServerFailure();
  }
}
