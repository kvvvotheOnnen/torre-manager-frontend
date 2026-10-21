import '../../domain/entities/proyecto.dart';

class ProyectoDTO {
  const ProyectoDTO({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  final String id;
  final String nombre;
  final String? descripcion;

  factory ProyectoDTO.fromJson(Map<String, dynamic> json) {
    return ProyectoDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Proyecto toEntity() {
    return Proyecto(id: id, nombre: nombre, descripcion: descripcion);
  }
}
