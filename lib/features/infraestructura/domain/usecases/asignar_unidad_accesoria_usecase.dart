import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/unidad_accesoria.dart';
import '../repositories/infraestructura_repository.dart';

class AsignarUnidadAccesoriaUseCase {
  final InfraestructuraRepositoryInterface _repository;

  AsignarUnidadAccesoriaUseCase(this._repository);

  Future<Either<Failure, UnidadAccesoria>> call({
    required String unidadAccesoriaId,
    String? unidadPrincipalId,
  }) {
    return _repository.asignarUnidadAccesoria(
      unidadAccesoriaId: unidadAccesoriaId,
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
