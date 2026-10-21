import '../../domain/entities/tipo_unidad_accesoria.dart';
import '../../domain/entities/unidad_accesoria.dart';

class UnidadAccesoriaDTO {
  const UnidadAccesoriaDTO({
    required this.id,
    required this.proyectoId,
    required this.identificador,
    required this.tipo,
    this.unidadPrincipalId,
  });

  final String id;
  final String proyectoId;
  final String identificador;
  final String tipo;
  final String? unidadPrincipalId;

  factory UnidadAccesoriaDTO.fromJson(Map<String, dynamic> json) {
    return UnidadAccesoriaDTO(
      id: '${json['id']}',
      proyectoId: '${json['proyecto_id']}',
      identificador: (json['identificador'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      unidadPrincipalId: json['unidad_principal_id'] == null
          ? null
          : '${json['unidad_principal_id']}',
    );
  }

  UnidadAccesoria toEntity() {
    return UnidadAccesoria(
      id: id,
      proyectoId: proyectoId,
      identificador: identificador,
      tipo: tipoUnidadAccesoriaFromString(tipo),
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
