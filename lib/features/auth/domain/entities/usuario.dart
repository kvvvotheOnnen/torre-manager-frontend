import 'package:equatable/equatable.dart';

enum Rol { superadmin, administrador, residente, conserje }

class Usuario extends Equatable {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String correo;
  final Rol rol;

  @override
  List<Object?> get props => [id, nombre, correo, rol];
}
