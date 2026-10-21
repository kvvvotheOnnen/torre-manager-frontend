import 'package:equatable/equatable.dart';

import '../../../infraestructura/domain/entities/tipo_agrupacion.dart';

/// Definición de una agrupación (y sus unidades) al crear un proyecto.
///
/// - Para `edificio`, `torre` o `bloque`: usa [pisoDesde], [pisoHasta] y
///   [unidadesPorPiso].
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
  });

  final String nombre;
  final TipoAgrupacion tipo;
  final String? prefijo;
  final int? pisoDesde;
  final int? pisoHasta;
  final int? unidadesPorPiso;
  final int? cantidad;

  @override
  List<Object?> get props => [
    nombre,
    tipo,
    prefijo,
    pisoDesde,
    pisoHasta,
    unidadesPorPiso,
    cantidad,
  ];
}
