import 'package:equatable/equatable.dart';

class UnidadVinculada extends Equatable {
  const UnidadVinculada({
    required this.unidad,
    required this.agrupacion,
    required this.proyectoId,
    required this.tipoVinculo,
    required this.esActual,
    this.fechaInicio,
    this.fechaFin,
  });

  final String unidad;
  final String agrupacion;
  final String proyectoId;
  final String tipoVinculo;
  final bool esActual;
  final String? fechaInicio;
  final String? fechaFin;

  @override
  List<Object?> get props => [
    unidad,
    agrupacion,
    proyectoId,
    tipoVinculo,
    esActual,
    fechaInicio,
    fechaFin,
  ];
}

class MiInformacion extends Equatable {
  const MiInformacion({required this.unidades});

  final List<UnidadVinculada> unidades;

  UnidadVinculada? get unidadPrincipal {
    for (final unidad in unidades) {
      if (unidad.esActual) return unidad;
    }
    return unidades.isEmpty ? null : unidades.first;
  }

  String get unidad => unidadPrincipal?.unidad ?? '';
  String get agrupacion => unidadPrincipal?.agrupacion ?? '';

  @override
  List<Object?> get props => [unidades];
}
