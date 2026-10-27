import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/administrador.dart';
import '../../domain/entities/definicion_agrupacion.dart';
import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/proyecto_detalle.dart';
import '../../domain/entities/resumen_proyecto.dart';
import '../../domain/entities/tipo_condominio.dart';
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

  @override
  Future<Either<Failure, ProyectoDetalle>> crearProyecto({
    required String nombre,
    String? descripcion,
    required TipoCondominio tipoCondominio,
    required List<ModuloSistema> modulos,
    required List<DefinicionAgrupacion> agrupaciones,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  }) {
    return _guard(
      () => _remoteDataSource
          .crearProyecto(
            nombre: nombre,
            descripcion: descripcion,
            tipoCondominio: tipoCondominio,
            modulos: modulos,
            agrupaciones: agrupaciones,
            instalaciones: instalaciones,
            adminIds: adminIds,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> obtenerProyecto(String id) {
    return _guard(
      () => _remoteDataSource.obtenerProyecto(id).then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, ProyectoDetalle>> actualizarProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<ModuloSistema> modulos,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  }) {
    return _guard(
      () => _remoteDataSource
          .actualizarProyecto(
            id: id,
            nombre: nombre,
            descripcion: descripcion,
            modulos: modulos,
            instalaciones: instalaciones,
            adminIds: adminIds,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, List<ProyectoDetalle>>> listarMisProyectos() async {
    return _guard(
      () => _remoteDataSource.listarMisProyectos().then(
        (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
      ),
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
        if (statusCode == 404) {
          return Left(ServerFailure(message));
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
    } on ArgumentError catch (error) {
      return Left(ValidationFailure('Datos inesperados: ${error.message}'));
    } on FormatException {
      return const Left(ServerFailure('Respuesta inesperada del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
