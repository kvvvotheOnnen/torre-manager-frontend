import '../../domain/entities/usuario.dart';

/// DTO que traduce el JSON del backend hacia/desde el dominio.
///
/// Es el único punto que conoce los nombres de los campos de la API.
/// Soporta tanto los nombres en español (`nombre`, `correo`) como el
/// esquema por defecto de Eloquent (`name`, `email`).
class UsuarioDTO {
  const UsuarioDTO({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.rut,
    this.telefono,
    this.telefonoEmergencia,
    this.nombreEmergencia,
  });

  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final String? rut;
  final String? telefono;
  final String? telefonoEmergencia;
  final String? nombreEmergencia;

  factory UsuarioDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? json['name'] ?? '') as String,
      correo: (json['email'] ?? json['correo'] ?? '') as String,
      rol: (json['rol'] ?? '') as String,
      rut: json['rut'] as String?,
      telefono: json['telefono'] as String?,
      telefonoEmergencia: json['telefono_emergencia'] as String?,
      nombreEmergencia: json['nombre_emergencia'] as String?,
    );
  }

  Usuario toEntity() {
    return Usuario(
      id: id,
      nombre: nombre,
      correo: correo,
      rol: _parseRol(rol),
      rut: rut,
      telefono: telefono,
      telefonoEmergencia: telefonoEmergencia,
      nombreEmergencia: nombreEmergencia,
    );
  }

  static Rol _parseRol(String value) {
    return Rol.values.firstWhere(
      (rol) => rol.name == value.toLowerCase(),
      orElse: () => throw ArgumentError('Rol desconocido: $value'),
    );
  }
}
