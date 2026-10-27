import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/administrador.dart';
import '../entities/definicion_agrupacion.dart';
import '../entities/instalacion_extra.dart';
import '../entities/modulo_sistema.dart';
import '../entities/proyecto_detalle.dart';
import '../entities/resumen_proyecto.dart';
import '../entities/tipo_condominio.dart';

abstract interface class SuperadminRepositoryInterface {
  Future<Either<Failure, List<ResumenProyecto>>> listarProyectos();

  Future<Either<Failure, List<Administrador>>> listarAdministradores();

  Future<Either<Failure, Administrador>> crearAdministrador({
    required String nombre,
    required String correo,
    required String password,
  });

  Future<Either<Failure, ProyectoDetalle>> crearProyecto({
    required String nombre,
    String? descripcion,
    required TipoCondominio tipoCondominio,
    required List<ModuloSistema> modulos,
    required List<DefinicionAgrupacion> agrupaciones,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  });

  Future<Either<Failure, ProyectoDetalle>> obtenerProyecto(String id);

  Future<Either<Failure, ProyectoDetalle>> actualizarProyecto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<ModuloSistema> modulos,
    required List<InstalacionExtra> instalaciones,
    required List<String> adminIds,
  });

  Future<Either<Failure, List<ProyectoDetalle>>> listarMisProyectos();
}
