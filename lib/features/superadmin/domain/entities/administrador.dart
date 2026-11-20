import 'package:equatable/equatable.dart';

import 'proyecto_administrador.dart';

class Administrador extends Equatable {
  const Administrador({
    required this.id,
    required this.nombre,
    required this.correo,
    this.proyectos = const [],
  });

  final String id;
  final String nombre;
  final String correo;
  final List<ProyectoAdministrador> proyectos;

  @override
  List<Object?> get props => [id, nombre, correo, proyectos];
}
