import 'package:equatable/equatable.dart';

import 'tipo_agrupacion.dart';

class Agrupacion extends Equatable {
  const Agrupacion({
    required this.id,
    required this.proyectoId,
    required this.nombre,
    required this.tipo,
  });

  final String id;
  final String proyectoId;
  final String nombre;
  final TipoAgrupacion tipo;

  @override
  List<Object?> get props => [id, proyectoId, nombre, tipo];
}
