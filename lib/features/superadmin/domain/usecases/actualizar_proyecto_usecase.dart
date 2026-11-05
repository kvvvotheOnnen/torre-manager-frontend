import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/instalacion_extra.dart';
import '../entities/modulo_sistema.dart';
import '../entities/proyecto_detalle.dart';
import '../repositories/superadmin_repository.dart';

class ActualizarProyectoUseCase {
  final SuperadminRepositoryInterface _repository;

  ActualizarProyectoUseCase(this._repository);

  Future<Either<Failure, ProyectoDetalle>> call({
    required String id,
    required String nombre,
    String? descripcion,
    required List<ModuloSistema> modulos,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  }) {
    final nombreTrim = nombre.trim();

    if (nombreTrim.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El nombre del proyecto es obligatorio.')),
      );
    }
    if (modulos.isEmpty) {
      return Future.value(
        Left(ValidationFailure('Debes habilitar al menos un módulo.')),
      );
    }
    if (adminIds.isEmpty) {
      return Future.value(
        Left(ValidationFailure('Debes asignar al menos un administrador.')),
      );
    }

    return _repository.actualizarProyecto(
      id: id,
      nombre: nombreTrim,
      descripcion: descripcion?.trim(),
      modulos: modulos,
      instalaciones: instalaciones,
      adminIds: adminIds,
    );
  }
}
