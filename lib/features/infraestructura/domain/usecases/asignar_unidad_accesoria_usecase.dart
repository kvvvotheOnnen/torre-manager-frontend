import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_asignacion.dart';
import '../entities/unidad_accesoria.dart';
import '../repositories/infraestructura_repository.dart';

class AsignarUnidadAccesoriaUseCase {
  final InfraestructuraRepositoryInterface _repository;

  AsignarUnidadAccesoriaUseCase(this._repository);

  Future<Either<Failure, UnidadAccesoria>> call({
    required String unidadAccesoriaId,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  }) {
    if (asignacion == TipoAsignacion.departamento &&
        (unidadPrincipalId == null || unidadPrincipalId.isEmpty)) {
      return Future.value(
        Left(ValidationFailure('Debes seleccionar un departamento.')),
      );
    }
    return _repository.asignarUnidadAccesoria(
      unidadAccesoriaId: unidadAccesoriaId,
      asignacion: asignacion,
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
