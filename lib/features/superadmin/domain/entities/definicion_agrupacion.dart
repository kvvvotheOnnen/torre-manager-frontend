import 'package:equatable/equatable.dart';

import '../../../infraestructura/domain/entities/tipo_agrupacion.dart';
import 'instalacion_extra.dart';

enum TipoUnidadExcepcion { simple, instalacionExtra }

/// Unidad definida manualmente dentro de un piso con excepción.
///
/// Si [tipo] es [TipoUnidadExcepcion.simple] se crea como unidad principal.
/// Si es [TipoUnidadExcepcion.instalacionExtra] se crea como instalación extra
/// y requiere [capacidad].
class UnidadExcepcion extends Equatable {
  const UnidadExcepcion({
    required this.identificador,
    required this.tipo,
    this.capacidad,
    this.descripcion,
  });

  final String identificador;
  final TipoUnidadExcepcion tipo;
  final int? capacidad;
  final String? descripcion;

  @override
  List<Object?> get props => [identificador, tipo, capacidad, descripcion];
}

/// Piso que reemplaza la generación automática de unidades por unidades
/// creadas manualmente.
class PisoExcepcion extends Equatable {
  const PisoExcepcion({required this.piso, required this.unidades});

  final int piso;
  final List<UnidadExcepcion> unidades;

  @override
  List<Object?> get props => [piso, unidades];
}

/// Extrae las instalaciones extra definidas en los pisos con excepción.
List<InstalacionExtra> instalacionesDePisosExcepcion(
  List<PisoExcepcion> pisos,
) {
  return pisos
      .expand((piso) => piso.unidades)
      .where((unidad) => unidad.tipo == TipoUnidadExcepcion.instalacionExtra)
      .map(
        (unidad) => InstalacionExtra(
          nombre: unidad.identificador,
          capacidad: unidad.capacidad ?? 0,
          descripcion: unidad.descripcion,
        ),
      )
      .toList();
}

/// Definición de una agrupación (y sus unidades) al crear un proyecto.
///
/// - Para `edificio`, `torre` o `bloque`: usa [pisoDesde], [pisoHasta] y
///   [unidadesPorPiso], más [pisosExcepcion] si aplica.
/// - Para `manzana`: usa [cantidad] (número de casas).
class DefinicionAgrupacion extends Equatable {
  const DefinicionAgrupacion({
    required this.nombre,
    required this.tipo,
    this.prefijo,
    this.pisoDesde,
    this.pisoHasta,
    this.unidadesPorPiso,
    this.cantidad,
    this.pisosExcepcion = const [],
  });

  final String nombre;
  final TipoAgrupacion tipo;
  final String? prefijo;
  final int? pisoDesde;
  final int? pisoHasta;
  final int? unidadesPorPiso;
  final int? cantidad;
  final List<PisoExcepcion> pisosExcepcion;

  @override
  List<Object?> get props => [
    nombre,
    tipo,
    prefijo,
    pisoDesde,
    pisoHasta,
    unidadesPorPiso,
    cantidad,
    pisosExcepcion,
  ];
}
