import 'package:equatable/equatable.dart';

/// Unidad que el superadmin puede clasificar dentro del proyecto.
class UnidadClasificable extends Equatable {
  const UnidadClasificable({
    required this.agrupacion,
    required this.identificador,
  });

  final String agrupacion;
  final String identificador;

  /// Clave estable para distinguir unidades de distintas agrupaciones.
  String get clave => '$agrupacion|$identificador';

  @override
  List<Object?> get props => [agrupacion, identificador];
}

/// Clasificación creada por el superadmin (nombre libre) con sus unidades.
///
/// Una unidad sin clasificación pertenece implícitamente a "Estándar".
class ClasificacionUnidad extends Equatable {
  const ClasificacionUnidad({
    required this.nombre,
    this.unidades = const [],
  });

  final String nombre;
  final List<UnidadClasificable> unidades;

  @override
  List<Object?> get props => [nombre, unidades];
}
