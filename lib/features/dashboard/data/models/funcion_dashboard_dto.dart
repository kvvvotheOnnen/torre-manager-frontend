import '../../domain/entities/funcion_dashboard.dart';

/// Representa exactamente el JSON de `GET /api/dashboard/funciones`.
class FuncionDashboardDto {
  const FuncionDashboardDto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.capacidades,
    required this.ambito,
    required this.ruta,
    this.acciones = const <String, bool>{},
  });

  factory FuncionDashboardDto.fromJson(Map<String, dynamic> json) {
    final capacidadesJson = json['capacidades'];

    return FuncionDashboardDto(
      id: '${json['id'] ?? ''}',
      titulo: '${json['titulo'] ?? ''}',
      descripcion: '${json['descripcion'] ?? ''}',
      icono: '${json['icono'] ?? ''}',
      capacidades: capacidadesJson is List
          ? capacidadesJson.map((capacidad) => '$capacidad').toList()
          : const <String>[],
      ambito: '${json['ambito'] ?? ''}',
      ruta: '${json['ruta'] ?? ''}',
      acciones: _acciones(json['acciones']),
    );
  }

  /// Normaliza el mapa de acciones: cualquier valor distinto de `true`
  /// se interpreta como permiso denegado.
  static Map<String, bool> _acciones(dynamic valor) {
    if (valor is! Map) {
      return const <String, bool>{};
    }

    return <String, bool>{
      for (final entrada in valor.entries) '${entrada.key}': entrada.value == true,
    };
  }

  final String id;
  final String titulo;
  final String descripcion;
  final String icono;
  final List<String> capacidades;
  final String ambito;
  final String ruta;
  final Map<String, bool> acciones;

  FuncionDashboard toEntity() {
    return FuncionDashboard(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      icono: icono,
      capacidades: capacidades,
      ambito: ambitoFuncionDesde(ambito),
      ruta: ruta,
      acciones: acciones,
    );
  }
}
