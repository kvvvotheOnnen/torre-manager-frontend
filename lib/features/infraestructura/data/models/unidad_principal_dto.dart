import '../../domain/entities/unidad_principal.dart';

class UnidadPrincipalDTO {
  const UnidadPrincipalDTO({
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

  factory UnidadPrincipalDTO.fromJson(Map<String, dynamic> json) {
    return UnidadPrincipalDTO(
      id: '${json['id']}',
      agrupacionId: '${json['agrupacion_id']}',
      identificador: (json['identificador'] ?? '') as String,
      propietarioId: json['propietario_id'] != null ? '${json['propietario_id']}' : null,
      propietarioNombre: json['propietario_nombre'] as String?,
      ocupanteId: json['ocupante_id'] != null ? '${json['ocupante_id']}' : null,
      ocupanteNombre: json['ocupante_nombre'] as String?,
      ocupanteTipo: json['ocupante_tipo'] as String?,
    );
  }

  UnidadPrincipal toEntity() {
    return UnidadPrincipal(
      id: id,
      agrupacionId: agrupacionId,
      identificador: identificador,
      propietarioId: propietarioId,
      propietarioNombre: propietarioNombre,
      ocupanteId: ocupanteId,
      ocupanteNombre: ocupanteNombre,
      ocupanteTipo: ocupanteTipo,
    );
  }
}
