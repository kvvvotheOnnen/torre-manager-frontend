import '../../domain/entities/administrador.dart';

class AdministradorDTO {
  const AdministradorDTO({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  final String id;
  final String nombre;
  final String correo;

  factory AdministradorDTO.fromJson(Map<String, dynamic> json) {
    return AdministradorDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
      correo: (json['email'] ?? json['correo'] ?? '') as String,
    );
  }

  Administrador toEntity() {
    return Administrador(id: id, nombre: nombre, correo: correo);
  }
}
