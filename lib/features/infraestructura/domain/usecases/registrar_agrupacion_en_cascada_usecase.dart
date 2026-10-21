import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/agrupacion.dart';
import '../entities/tipo_agrupacion.dart';
import '../repositories/infraestructura_repository.dart';

class RegistrarAgrupacionEnCascadaUseCase {
  static const int maxUnidades = 500;

  final InfraestructuraRepositoryInterface _repository;

  RegistrarAgrupacionEnCascadaUseCase(this._repository);

  Future<Either<Failure, Agrupacion>> call({
    required String proyectoId,
    required String nombre,
    required TipoAgrupacion tipo,
    String? prefijo,
    required int pisoDesde,
    required int pisoHasta,
    required int unidadesPorPiso,
  }) {
    final trimmed = nombre.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El nombre de la agrupación es obligatorio.')),
      );
    }
    if (pisoDesde < 0 || pisoHasta < pisoDesde) {
      return Future.value(Left(ValidationFailure('El rango de pisos es inválido.')));
    }
    if (unidadesPorPiso < 1) {
      return Future.value(
        Left(ValidationFailure('Debe existir al menos una unidad por piso.')),
      );
    }
    final total = (pisoHasta - pisoDesde + 1) * unidadesPorPiso;
    if (total > maxUnidades) {
      return Future.value(
        Left(ValidationFailure('La generación excede el máximo de $maxUnidades unidades.')),
      );
    }

    return _repository.registrarAgrupacionEnCascada(
      proyectoId: proyectoId,
      nombre: trimmed,
      tipo: tipo,
      prefijo: prefijo?.trim(),
      pisoDesde: pisoDesde,
      pisoHasta: pisoHasta,
      unidadesPorPiso: unidadesPorPiso,
    );
  }
}
