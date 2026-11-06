import '../../domain/entities/modulo_dashboard.dart';

class ModuloDashboardDTO {
  const ModuloDashboardDTO({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.habilitado,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String tipo;
  final bool habilitado;

  factory ModuloDashboardDTO.fromJson(Map<String, dynamic> json) {
    return ModuloDashboardDTO(
      id: '${json['id'] ?? ''}',
      nombre: '${json['nombre'] ?? ''}',
      descripcion: '${json['descripcion'] ?? ''}',
      tipo: '${json['tipo'] ?? TipoModuloDashboard.proyecto.valor}',
      habilitado: json['habilitado'] == true,
    );
  }

  ModuloDashboard toEntity() {
    return ModuloDashboard(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipo: tipoModuloDashboardFromString(tipo),
      habilitado: habilitado,
    );
  }
}
