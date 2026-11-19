import 'package:equatable/equatable.dart';

class UnidadGestionable extends Equatable {
  const UnidadGestionable({
    required this.id,
    required this.identificador,
    required this.proyectoId,
    this.agrupacion,
    this.residenteId,
    this.propietarioId,
    this.propietarioNombre,
    this.ocupanteId,
    this.ocupanteNombre,
  });

  final int id;
  final String identificador;
  final int proyectoId;
  final String? agrupacion;
  final int? residenteId;
  final int? propietarioId;
  final String? propietarioNombre;
  final int? ocupanteId;
  final String? ocupanteNombre;

  @override
  List<Object?> get props => [id, identificador, proyectoId];
}
