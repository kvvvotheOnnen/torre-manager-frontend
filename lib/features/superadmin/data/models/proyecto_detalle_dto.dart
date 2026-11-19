import '../../domain/entities/instalacion_extra.dart';
import '../../domain/entities/modulo_general.dart';
import '../../domain/entities/modulo_sistema.dart';
import '../../domain/entities/proyecto_detalle.dart';
import '../../domain/entities/tipo_condominio.dart';

class ProyectoDetalleDTO {
  const ProyectoDetalleDTO({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipoCondominio,
    required this.modulos,
    required this.instalacionesExtra,
    required this.adminIds,
    this.modulosDeshabilitados = const [],
    this.rol,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final String tipoCondominio;
  final List<String> modulos;
  final List<InstalacionExtraDTO> instalacionesExtra;
  final List<String> adminIds;
  final List<String> modulosDeshabilitados;
  final String? rol;

  factory ProyectoDetalleDTO.fromJson(Map<String, dynamic> json) {
    return ProyectoDetalleDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
      descripcion: json['descripcion'] as String?,
      tipoCondominio: (json['tipo_condominio'] ?? 'torres') as String,
      modulos: ((json['modulos'] ?? const []) as List)
          .map((item) => '$item')
          .toList(),
      instalacionesExtra: ((json['instalaciones_extra'] ?? const []) as List)
          .map(
            (item) =>
                InstalacionExtraDTO.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      adminIds: ((json['admin_ids'] ?? const []) as List)
          .map((item) => '$item')
          .toList(),
      modulosDeshabilitados:
          ((json['modulos_deshabilitados'] ?? const []) as List)
              .map((item) => '$item')
              .toList(),
      rol: json['rol'] as String?,
    );
  }

  ProyectoDetalle toEntity() {
    return ProyectoDetalle(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipoCondominio: tipoCondominioFromString(tipoCondominio),
      modulos: modulos
          .map(moduloSistemaFromString)
          .whereType<ModuloSistema>()
          .toList(),
      instalacionesExtra: instalacionesExtra
          .map((instalacion) => instalacion.toEntity())
          .toList(),
      adminIds: adminIds,
      modulosDeshabilitados: modulosDeshabilitados
          .map(moduloGeneralFromString)
          .whereType<ModuloGeneral>()
          .toList(),
      rol: rol,
    );
  }
}

class InstalacionExtraDTO {
  const InstalacionExtraDTO({
    required this.nombre,
    required this.capacidad,
    this.descripcion,
  });

  final String nombre;
  final int capacidad;
  final String? descripcion;

  factory InstalacionExtraDTO.fromJson(Map<String, dynamic> json) {
    return InstalacionExtraDTO(
      nombre: (json['nombre'] ?? '') as String,
      capacidad: (json['capacidad'] ?? 0) as int,
      descripcion: json['descripcion'] as String?,
    );
  }

  InstalacionExtra toEntity() {
    return InstalacionExtra(
      nombre: nombre,
      capacidad: capacidad,
      descripcion: descripcion,
    );
  }
}
