import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
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
    String? unidadPrincipalId,
  }) {
    final trimmed = identificador.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El identificador de la unidad accesoria es obligatorio.')),
      );
    }
    return _repository.crearUnidadAccesoria(
      proyectoId: proyectoId,
      identificador: trimmed,
      tipo: tipo,
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
