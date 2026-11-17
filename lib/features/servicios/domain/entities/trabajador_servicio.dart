import 'package:equatable/equatable.dart';

import 'tipo_servicio.dart';

class TrabajadorServicio extends Equatable {
  const TrabajadorServicio({
    required this.id,
    required this.nombre,
    required this.nombreEmpresa,
    required this.telefono,
    required this.tipo,
    required this.descripcion,
    required this.fotoUrl,
  });

  final String id;
  final String nombre;
  final String? nombreEmpresa;
  final String telefono;
  final TipoServicio tipo;
  final String? descripcion;
  final String? fotoUrl;

  bool get tieneFoto => fotoUrl != null && fotoUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    nombre,
    nombreEmpresa,
    telefono,
    tipo,
    descripcion,
    fotoUrl,
  ];
}
