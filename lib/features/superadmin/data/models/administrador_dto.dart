import '../../domain/entities/administrador.dart';
import '../../domain/entities/proyecto_administrador.dart';

class AdministradorDTO {
  const AdministradorDTO({
    required this.id,
    required this.nombre,
    required this.correo,
    this.proyectos = const [],
  });

  final String id;
  final String nombre;
  final String correo;
  final List<ProyectoAdministrador> proyectos;

  factory AdministradorDTO.fromJson(Map<String, dynamic> json) {
    final proyectos = json['proyectos'];

    return AdministradorDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
      correo: (json['email'] ?? json['correo'] ?? '') as String,
      proyectos: proyectos is List
          ? proyectos
                .whereType<Map>()
                .map(
                  (item) => ProyectoAdministrador(
                    id: '${item['id']}',
                    nombre: (item['nombre'] ?? '') as String,
                  ),
                )
                .toList()
          : const [],
    );
  }

  Administrador toEntity() {
    return Administrador(
      id: id,
      nombre: nombre,
      correo: correo,
      proyectos: proyectos,
    );
  }
}
