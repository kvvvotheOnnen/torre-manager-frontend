import 'package:equatable/equatable.dart';

class InstalacionExtra extends Equatable {
  const InstalacionExtra({
    required this.nombre,
    required this.capacidad,
    this.descripcion,
  });

  final String nombre;
  final int capacidad;
  final String? descripcion;

  @override
  List<Object?> get props => [nombre, capacidad, descripcion];
}
