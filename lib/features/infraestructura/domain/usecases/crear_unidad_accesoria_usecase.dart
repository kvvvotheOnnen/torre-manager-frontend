import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_asignacion.dart';
import '../entities/tipo_unidad_accesoria.dart';
import '../entities/unidad_accesoria.dart';
import '../repositories/infraestructura_repository.dart';

class CrearUnidadAccesoriaUseCase {
  final InfraestructuraRepositoryInterface _repository;

  CrearUnidadAccesoriaUseCase(this._repository);

  Future<Either<Failure, UnidadAccesoria>> call({
    required String proyectoId,
    required String identificador,
    required TipoUnidadAccesoria tipo,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  }) {
    final trimmed = identificador.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        Left(
          ValidationFailure(
            'El identificador de la unidad accesoria es obligatorio.',
          ),
        ),
      );
    }
    if (asignacion == TipoAsignacion.departamento &&
        (unidadPrincipalId == null || unidadPrincipalId.isEmpty)) {
      return Future.value(
        Left(ValidationFailure('Debes seleccionar un departamento.')),
      );
    }
    return _repository.crearUnidadAccesoria(
      proyectoId: proyectoId,
      identificador: trimmed,
      tipo: tipo,
      asignacion: asignacion,
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
