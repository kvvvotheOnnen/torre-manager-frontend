import '../../domain/entities/agrupacion.dart';
import '../../domain/entities/tipo_agrupacion.dart';

class AgrupacionDTO {
  const AgrupacionDTO({
    required this.id,
    required this.proyectoId,
    required this.nombre,
    required this.tipo,
  });

  final String id;
  final String proyectoId;
  final String nombre;
  final String tipo;

  factory AgrupacionDTO.fromJson(Map<String, dynamic> json) {
    return AgrupacionDTO(
      id: '${json['id']}',
      proyectoId: '${json['proyecto_id']}',
      nombre: (json['nombre'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
    );
  }

  Agrupacion toEntity() {
    return Agrupacion(
      id: id,
      proyectoId: proyectoId,
      nombre: nombre,
      tipo: tipoAgrupacionFromString(tipo),
    );
  }
}
