import 'package:equatable/equatable.dart';

class InstalacionExtra extends Equatable {
  const InstalacionExtra({
    required this.nombre,
    required this.capacidad,
    this.descripcion,
    this.atributos = const {},
  });

  final String nombre;
  final int capacidad;
  final String? descripcion;
  final Map<String, dynamic> atributos;

  @override
  List<Object?> get props => [nombre, capacidad, descripcion, atributos];
}
