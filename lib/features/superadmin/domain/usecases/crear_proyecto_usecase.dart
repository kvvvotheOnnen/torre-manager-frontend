import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/definicion_agrupacion.dart';
import '../entities/instalacion_extra.dart';
import '../entities/modulo_sistema.dart';
import '../entities/proyecto_detalle.dart';
import '../entities/tipo_condominio.dart';
import '../repositories/superadmin_repository.dart';

class CrearProyectoUseCase {
  final SuperadminRepositoryInterface _repository;

  CrearProyectoUseCase(this._repository);

  Future<Either<Failure, ProyectoDetalle>> call({
    required String nombre,
    String? descripcion,
    required TipoCondominio tipoCondominio,
    required List<ModuloSistema> modulos,
    required List<DefinicionAgrupacion> agrupaciones,
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
    if (agrupaciones.isEmpty) {
      return Future.value(
        Left(
          ValidationFailure(
            'Debes definir al menos una agrupación con sus unidades.',
          ),
        ),
      );
    }
    if (adminIds.isEmpty) {
      return Future.value(
        Left(ValidationFailure('Debes asignar al menos un administrador.')),
      );
    }

    return _repository.crearProyecto(
      nombre: nombreTrim,
      descripcion: descripcion?.trim(),
      tipoCondominio: tipoCondominio,
      modulos: modulos,
      agrupaciones: agrupaciones,
      instalaciones: instalaciones,
      adminIds: adminIds,
    );
  }
}
