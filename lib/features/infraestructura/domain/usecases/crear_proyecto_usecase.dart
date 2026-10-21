import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/proyecto.dart';
import '../repositories/infraestructura_repository.dart';

class CrearProyectoUseCase {
  final InfraestructuraRepositoryInterface _repository;

  CrearProyectoUseCase(this._repository);

  Future<Either<Failure, Proyecto>> call({
    required String nombre,
    String? descripcion,
  }) {
    final trimmed = nombre.trim();
    if (trimmed.isEmpty) {
      return Future.value(Left(ValidationFailure('El nombre del proyecto es obligatorio.')));
    }
    return _repository.crearProyecto(nombre: trimmed, descripcion: descripcion?.trim());
  }
}
