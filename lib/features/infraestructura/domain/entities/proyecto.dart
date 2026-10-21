import 'package:equatable/equatable.dart';

class Proyecto extends Equatable {
  const Proyecto({required this.id, required this.nombre, this.descripcion});

  final String id;
  final String nombre;
  final String? descripcion;

  @override
  List<Object?> get props => [id, nombre, descripcion];
}
