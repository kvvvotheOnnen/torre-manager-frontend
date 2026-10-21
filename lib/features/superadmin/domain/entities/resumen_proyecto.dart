import 'package:equatable/equatable.dart';

class ResumenProyecto extends Equatable {
  const ResumenProyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.agrupaciones,
    required this.unidadesPrincipales,
    required this.unidadesAccesorias,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final int agrupaciones;
  final int unidadesPrincipales;
  final int unidadesAccesorias;

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    agrupaciones,
    unidadesPrincipales,
    unidadesAccesorias,
  ];
}
