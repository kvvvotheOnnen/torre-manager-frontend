import '../../domain/entities/instalacion_extra.dart';
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
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final String tipoCondominio;
  final List<String> modulos;
  final List<InstalacionExtraDTO> instalacionesExtra;
  final List<String> adminIds;

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
    );
  }

  ProyectoDetalle toEntity() {
    return ProyectoDetalle(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipoCondominio: tipoCondominioFromString(tipoCondominio),
      modulos: modulos.map(moduloSistemaFromString).toList(),
      instalacionesExtra: instalacionesExtra
          .map((instalacion) => instalacion.toEntity())
          .toList(),
      adminIds: adminIds,
    );
  }
}

class InstalacionExtraDTO {
  const InstalacionExtraDTO({
    required this.nombre,
    this.tipo,
    this.atributos = const {},
  });

  final String nombre;
  final String? tipo;
  final Map<String, dynamic> atributos;

  factory InstalacionExtraDTO.fromJson(Map<String, dynamic> json) {
    return InstalacionExtraDTO(
      nombre: (json['nombre'] ?? '') as String,
      tipo: json['tipo'] as String?,
      atributos: (json['atributos'] as Map<String, dynamic>?) ?? const {},
    );
  }

  InstalacionExtra toEntity() {
    return InstalacionExtra(nombre: nombre, tipo: tipo, atributos: atributos);
  }
}
