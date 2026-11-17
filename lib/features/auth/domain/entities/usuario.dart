import 'package:equatable/equatable.dart';

enum Rol { superadmin, administrador, residente, conserje, propietario }

class Usuario extends Equatable {
  const Usuario({
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
  final Rol rol;
  final String? rut;
  final String? telefono;
  final String? telefonoEmergencia;
  final String? nombreEmergencia;

  @override
  List<Object?> get props => [
    id,
    nombre,
    correo,
    rol,
    rut,
    telefono,
    telefonoEmergencia,
    nombreEmergencia,
  ];
}
