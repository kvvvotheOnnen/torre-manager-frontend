import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/arbol_infraestructura.dart';
import '../repositories/infraestructura_repository.dart';

class ObtenerArbolInfraestructuraUseCase {
  final InfraestructuraRepositoryInterface _repository;

  ObtenerArbolInfraestructuraUseCase(this._repository);

  Future<Either<Failure, ArbolInfraestructura>> call({required String proyectoId}) {
    return _repository.obtenerArbol(proyectoId: proyectoId);
  }
}
