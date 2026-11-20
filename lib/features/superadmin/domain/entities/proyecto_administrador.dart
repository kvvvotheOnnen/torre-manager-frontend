import 'package:equatable/equatable.dart';

/// Proyecto al que un administrador está anexado.
class ProyectoAdministrador extends Equatable {
  const ProyectoAdministrador({required this.id, required this.nombre});

  final String id;
  final String nombre;

  @override
  List<Object?> get props => [id, nombre];
}
