import '../../domain/entities/unidad_gestionable.dart';

class UnidadDto {
  const UnidadDto({
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

  factory UnidadDto.fromJson(Map<String, dynamic> json) {
    return UnidadDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      identificador: (json['identificador'] ?? '').toString(),
      proyectoId: (json['proyecto_id'] as num?)?.toInt() ?? 0,
      agrupacion: json['agrupacion'] as String?,
      residenteId: (json['residente_id'] as num?)?.toInt(),
      propietarioId: (json['propietario_id'] as num?)?.toInt(),
      propietarioNombre: json['propietario_nombre'] as String?,
      ocupanteId: (json['ocupante_id'] as num?)?.toInt(),
      ocupanteNombre: json['ocupante_nombre'] as String?,
    );
  }

  UnidadGestionable toEntity() {
    return UnidadGestionable(
      id: id,
      identificador: identificador,
      proyectoId: proyectoId,
      agrupacion: agrupacion,
      residenteId: residenteId,
      propietarioId: propietarioId,
      propietarioNombre: propietarioNombre,
      ocupanteId: ocupanteId,
      ocupanteNombre: ocupanteNombre,
    );
  }
}
