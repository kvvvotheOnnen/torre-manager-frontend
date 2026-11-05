import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/definicion_agrupacion.dart';
import '../entities/instalacion_extra.dart';
import '../entities/modulo_sistema.dart';
import '../entities/proyecto_detalle.dart';
import '../entities/tipo_condominio.dart';
import '../repositories/superadmin_repository.dart';

class GuardarPasoProyectoUseCase {
  const GuardarPasoProyectoUseCase(this._repository);

  final SuperadminRepositoryInterface _repository;

  Future<Either<Failure, ProyectoDetalle>> call({
    required String id,
    required String nombre,
    String? descripcion,
    TipoCondominio? tipoCondominio,
    List<DefinicionAgrupacion>? agrupaciones,
    List<InstalacionExtra>? instalaciones,
    List<ModuloSistema>? modulos,
    List<String>? adminIds,
    bool resetEstructura = false,
    bool finalizar = false,
  }) {
    final nombreTrim = nombre.trim();

    if (nombreTrim.isEmpty) {
      return Future.value(
        Left(ValidationFailure('El nombre del proyecto es obligatorio.')),
      );
    }

    if (finalizar && (modulos == null || modulos.isEmpty)) {
      return Future.value(
        Left(ValidationFailure('Debes habilitar al menos un módulo.')),
      );
    }

    if (finalizar && (adminIds == null || adminIds.isEmpty)) {
      return Future.value(
        Left(ValidationFailure('Debes asignar al menos un administrador.')),
      );
    }

    return _repository.guardarPasoProyecto(
      id: id,
      nombre: nombreTrim,
      descripcion: descripcion?.trim(),
      tipoCondominio: tipoCondominio,
      agrupaciones: agrupaciones,
      instalaciones: instalaciones,
      modulos: modulos,
      adminIds: adminIds,
      resetEstructura: resetEstructura,
      finalizar: finalizar,
    );
  }
}
