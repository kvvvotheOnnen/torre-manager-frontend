import '../../domain/entities/unidad_principal.dart';

class UnidadPrincipalDTO {
  const UnidadPrincipalDTO({
    required this.id,
    required this.agrupacionId,
    required this.identificador,
  });

  final String id;
  final String agrupacionId;
  final String identificador;

  factory UnidadPrincipalDTO.fromJson(Map<String, dynamic> json) {
    return UnidadPrincipalDTO(
      id: '${json['id']}',
      agrupacionId: '${json['agrupacion_id']}',
      identificador: (json['identificador'] ?? '') as String,
    );
  }

  UnidadPrincipal toEntity() {
    return UnidadPrincipal(
      id: id,
      agrupacionId: agrupacionId,
      identificador: identificador,
    );
  }
}
