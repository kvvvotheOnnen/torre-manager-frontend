import 'package:equatable/equatable.dart';

class UnidadPrincipal extends Equatable {
  const UnidadPrincipal({
    required this.id,
    required this.agrupacionId,
    required this.identificador,
    this.propietarioId,
    this.propietarioNombre,
    this.ocupanteId,
    this.ocupanteNombre,
    this.ocupanteTipo,
  });

  final String id;
  final String agrupacionId;
  final String identificador;
  final String? propietarioId;
  final String? propietarioNombre;
  final String? ocupanteId;
  final String? ocupanteNombre;
  final String? ocupanteTipo;

  @override
  List<Object?> get props => [
    id,
    agrupacionId,
    identificador,
    propietarioId,
    propietarioNombre,
    ocupanteId,
    ocupanteNombre,
    ocupanteTipo,
  ];
}
