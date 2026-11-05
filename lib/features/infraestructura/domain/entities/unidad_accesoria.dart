import 'package:equatable/equatable.dart';

import 'tipo_asignacion.dart';
import 'tipo_unidad_accesoria.dart';

class UnidadAccesoria extends Equatable {
  const UnidadAccesoria({
    required this.id,
    required this.proyectoId,
    required this.identificador,
    required this.tipo,
    required this.asignacion,
    required this.unidadPrincipalId,
  });

  final String id;
  final String proyectoId;
  final String identificador;
  final TipoUnidadAccesoria tipo;
  final TipoAsignacion? asignacion;
  final String? unidadPrincipalId;

  @override
  List<Object?> get props => [
    id,
    proyectoId,
    identificador,
    tipo,
    asignacion,
    unidadPrincipalId,
  ];
}
