import '../../domain/entities/resumen_proyecto.dart';

class ResumenProyectoDTO {
  const ResumenProyectoDTO({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.agrupaciones,
    required this.unidadesPrincipales,
    required this.unidadesAccesorias,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final int agrupaciones;
  final int unidadesPrincipales;
  final int unidadesAccesorias;

  factory ResumenProyectoDTO.fromJson(Map<String, dynamic> json) {
    return ResumenProyectoDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
      descripcion: json['descripcion'] as String?,
      agrupaciones: (json['agrupaciones'] ?? 0) as int,
      unidadesPrincipales: (json['unidades_principales'] ?? 0) as int,
      unidadesAccesorias: (json['unidades_accesorias'] ?? 0) as int,
    );
  }

  ResumenProyecto toEntity() {
    return ResumenProyecto(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      agrupaciones: agrupaciones,
      unidadesPrincipales: unidadesPrincipales,
      unidadesAccesorias: unidadesAccesorias,
    );
  }
}
