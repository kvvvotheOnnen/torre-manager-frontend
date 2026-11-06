import 'package:equatable/equatable.dart';

enum TipoModuloDashboard {
  general,
  proyecto;

  String get valor => switch (this) {
    TipoModuloDashboard.general => 'general',
    TipoModuloDashboard.proyecto => 'proyecto',
  };
}

TipoModuloDashboard tipoModuloDashboardFromString(String value) {
  return TipoModuloDashboard.values.firstWhere(
    (tipo) => tipo.valor == value,
    orElse: () => TipoModuloDashboard.proyecto,
  );
}

class ModuloDashboard extends Equatable {
  const ModuloDashboard({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.habilitado,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final TipoModuloDashboard tipo;
  final bool habilitado;

  bool get esGeneral => tipo == TipoModuloDashboard.general;

  @override
  List<Object?> get props => [id, nombre, descripcion, tipo, habilitado];
}
