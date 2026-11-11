import 'package:equatable/equatable.dart';

class Paquete extends Equatable {
  const Paquete({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.fechaRecepcion,
    this.remitente,
    this.fotoUrl,
    this.fechaRetiro,
    this.retiradoPorNombre,
    this.unidadIdentificador,
    this.residenteId,
    this.proyectoId,
    this.unidadPrincipalId,
  });

  final String id;
  final String descripcion;
  final String estado;
  final String fechaRecepcion;
  final String? remitente;
  final String? fotoUrl;
  final String? fechaRetiro;
  final String? retiradoPorNombre;
  final String? unidadIdentificador;
  final String? residenteId;
  final String? proyectoId;
  final String? unidadPrincipalId;

  bool get estaPendiente => estado == 'pendiente';

  @override
  List<Object?> get props => [
    id,
    descripcion,
    estado,
    fechaRecepcion,
    retiradoPorNombre,
    proyectoId,
    unidadPrincipalId,
  ];
}
