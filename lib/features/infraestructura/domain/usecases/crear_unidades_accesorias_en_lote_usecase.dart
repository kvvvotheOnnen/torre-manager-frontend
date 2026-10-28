import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/tipo_asignacion.dart';
import '../entities/tipo_unidad_accesoria.dart';
import '../entities/unidad_accesoria.dart';
import '../repositories/infraestructura_repository.dart';

class CrearUnidadesAccesoriasEnLoteUseCase {
  final InfraestructuraRepositoryInterface _repository;

  CrearUnidadesAccesoriasEnLoteUseCase(this._repository);

  Future<Either<Failure, List<UnidadAccesoria>>> call({
    required String proyectoId,
    required TipoUnidadAccesoria tipo,
    required int cantidad,
    TipoAsignacion? asignacion,
  }) {
    if (cantidad < 1 || cantidad > 999) {
      return Future.value(
        Left(ValidationFailure('La cantidad debe estar entre 1 y 999.')),
      );
    }
    return _repository.crearUnidadesAccesoriasEnLote(
      proyectoId: proyectoId,
      tipo: tipo,
      cantidad: cantidad,
      asignacion: asignacion,
    );
  }
}
