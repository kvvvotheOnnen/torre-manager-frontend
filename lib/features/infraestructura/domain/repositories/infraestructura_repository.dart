import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/agrupacion.dart';
import '../entities/arbol_infraestructura.dart';
import '../entities/proyecto.dart';
import '../entities/tipo_agrupacion.dart';
import '../entities/tipo_asignacion.dart';
import '../entities/tipo_unidad_accesoria.dart';
import '../entities/unidad_accesoria.dart';

abstract interface class InfraestructuraRepositoryInterface {
  Future<Either<Failure, Proyecto>> obtenerProyectoDelUsuario();

  Future<Either<Failure, List<Proyecto>>> listarProyectos();

  Future<Either<Failure, Proyecto>> crearProyecto({
    required String nombre,
    String? descripcion,
  });

  Future<Either<Failure, Agrupacion>> registrarAgrupacionEnCascada({
    required String proyectoId,
    required String nombre,
    required TipoAgrupacion tipo,
    String? prefijo,
    required int pisoDesde,
    required int pisoHasta,
    required int unidadesPorPiso,
  });

  Future<Either<Failure, UnidadAccesoria>> crearUnidadAccesoria({
    required String proyectoId,
    required String identificador,
    required TipoUnidadAccesoria tipo,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  });

  Future<Either<Failure, List<UnidadAccesoria>>> crearUnidadesAccesoriasEnLote({
    required String proyectoId,
    required TipoUnidadAccesoria tipo,
    required int cantidad,
    TipoAsignacion? asignacion,
  });

  Future<Either<Failure, UnidadAccesoria>> asignarUnidadAccesoria({
    required String unidadAccesoriaId,
    required TipoAsignacion? asignacion,
    String? unidadPrincipalId,
  });

  Future<Either<Failure, ArbolInfraestructura>> obtenerArbol({
    required String proyectoId,
  });
}
