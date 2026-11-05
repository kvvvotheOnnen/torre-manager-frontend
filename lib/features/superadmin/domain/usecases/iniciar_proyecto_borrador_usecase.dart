import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/proyecto_detalle.dart';
import '../repositories/superadmin_repository.dart';

class IniciarProyectoBorradorUseCase {
  const IniciarProyectoBorradorUseCase(this._repository);

  final SuperadminRepositoryInterface _repository;

  Future<Either<Failure, ProyectoDetalle>> call({
    required String nombre,
    String? descripcion,
  }) {
    final nombreTrim = nombre.trim();

    if (nombreTrim.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El nombre del proyecto es obligatorio.')),
      );
    }

    return _repository.iniciarProyectoBorrador(
      nombre: nombreTrim,
      descripcion: descripcion?.trim(),
    );
  }
}
