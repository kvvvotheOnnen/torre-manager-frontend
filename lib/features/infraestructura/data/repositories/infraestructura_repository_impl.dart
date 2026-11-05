import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/agrupacion.dart';
import '../../domain/entities/arbol_infraestructura.dart';
import '../../domain/entities/proyecto.dart';
import '../../domain/entities/tipo_agrupacion.dart';
import '../../domain/entities/tipo_asignacion.dart';
import '../../domain/entities/tipo_unidad_accesoria.dart';
import '../../domain/entities/unidad_accesoria.dart';
import '../../domain/repositories/infraestructura_repository.dart';
import '../datasources/infraestructura_remote_data_source.dart';

class InfraestructuraRepositoryImpl
    implements InfraestructuraRepositoryInterface {
  const InfraestructuraRepositoryImpl(this._remoteDataSource);

  final InfraestructuraRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Proyecto>> obtenerProyectoDelUsuario() async {
    return _guard(
      () => _remoteDataSource.obtenerProyectoDelUsuario().then(
        (dto) => dto.toEntity(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Proyecto>>> listarProyectos() async {
    return _guard(
      () => _remoteDataSource.listarProyectos().then(
        (dtos) => dtos.map((dto) => dto.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, Proyecto>> crearProyecto({
    required String nombre,
    String? descripcion,
  }) {
    return _guard(
      () => _remoteDataSource
          .crearProyecto(nombre: nombre, descripcion: descripcion)
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Agrupacion>> registrarAgrupacionEnCascada({
    required String proyectoId,
    required String nombre,
    required TipoAgrupacion tipo,
    String? prefijo,
    required int pisoDesde,
    required int pisoHasta,
    required int unidadesPorPiso,
  }) {
    return _guard(
      () => _remoteDataSource
          .registrarAgrupacionEnCascada(
            nombre: nombre,
            tipo: tipo.name,
            prefijo: prefijo,
            pisoDesde: pisoDesde,
            pisoHasta: pisoHasta,
            unidadesPorPiso: unidadesPorPiso,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, UnidadAccesoria>> crearUnidadAccesoria({
    required String proyectoId,
    required String identificador,
    required TipoUnidadAccesoria tipo,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  }) {
    return _guard(
      () => _remoteDataSource
          .crearUnidadAccesoria(
            identificador: identificador,
            tipo: tipo.name,
            asignacion: asignacion?.name,
            unidadPrincipalId: unidadPrincipalId,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, List<UnidadAccesoria>>> crearUnidadesAccesoriasEnLote({
    required String proyectoId,
    required TipoUnidadAccesoria tipo,
    required int cantidad,
    TipoAsignacion? asignacion,
  }) {
    return _guard(
      () => _remoteDataSource
          .crearUnidadesAccesoriasEnLote(
            proyectoId: proyectoId,
            tipo: tipo.name,
            cantidad: cantidad,
            asignacion: asignacion?.name,
          )
          .then((dtos) => dtos.map((dto) => dto.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, UnidadAccesoria>> asignarUnidadAccesoria({
    required String unidadAccesoriaId,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  }) {
    return _guard(
      () => _remoteDataSource
          .asignarUnidadAccesoria(
            unidadAccesoriaId: unidadAccesoriaId,
            asignacion: asignacion?.name,
            unidadPrincipalId: unidadPrincipalId,
          )
          .then((dto) => dto.toEntity()),
    );
  }

  @override
  Future<Either<Failure, ArbolInfraestructura>> obtenerArbol({
    required String proyectoId,
  }) {
    return _guard(
      () => _remoteDataSource
          .obtenerArbol(proyectoId: proyectoId)
          .then((dto) => dto.toEntity()),
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 422 &&
          data is Map<String, dynamic> &&
          data['message'] is String) {
        return Left(ValidationFailure(data['message'] as String));
      }

      if (statusCode == 409 &&
          data is Map<String, dynamic> &&
          data['message'] is String) {
        return Left(ValidationFailure(data['message'] as String));
      }

      if (statusCode == 404 &&
          data is Map<String, dynamic> &&
          data['message'] is String) {
        return Left(ServerFailure(data['message'] as String));
      }

      if (statusCode == 403) {
        return const Left(
          ServerFailure('No tienes permisos para esta acción.'),
        );
      }

      if (statusCode == 401) {
        return const Left(
          ServerFailure('Sesión expirada. Inicia sesión nuevamente.'),
        );
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
