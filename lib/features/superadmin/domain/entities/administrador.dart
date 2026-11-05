import 'package:equatable/equatable.dart';

class Administrador extends Equatable {
  const Administrador({
    required this.id,
    required this.nombre,
    required this.correo,
  });

  final String id;
  final String nombre;
  final String correo;

  @override
  List<Object?> get props => [id, nombre, correo];
}
