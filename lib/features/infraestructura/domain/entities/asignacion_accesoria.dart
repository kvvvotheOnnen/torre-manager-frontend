import 'package:equatable/equatable.dart';

import 'tipo_asignacion.dart';

class AsignacionAccesoria extends Equatable {
  const AsignacionAccesoria({
    required this.unidadAccesoriaId,
    required this.asignacion,
    this.unidadPrincipalId,
  });

  final String unidadAccesoriaId;
  final TipoAsignacion asignacion;
  final String? unidadPrincipalId;

  @override
  List<Object?> get props => [unidadAccesoriaId, asignacion, unidadPrincipalId];
}
