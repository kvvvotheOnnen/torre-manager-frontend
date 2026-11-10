import '../../domain/entities/paquete.dart';

class PaqueteDto {
  const PaqueteDto({
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

  factory PaqueteDto.fromJson(Map<String, dynamic> json) {
    return PaqueteDto(
      id: '${json['id']}',
      descripcion: (json['descripcion'] ?? '') as String,
      estado: (json['estado'] ?? 'pendiente') as String,
      fechaRecepcion: (json['fecha_recepcion'] ?? '') as String,
      remitente: json['remitente'] as String?,
      fotoUrl: json['foto_url'] as String?,
      fechaRetiro: json['fecha_retiro'] as String?,
      retiradoPorNombre: json['retirado_por_nombre'] as String?,
      unidadIdentificador: json['unidad'] as String?,
      residenteId: json['residente_id'] != null
          ? '${json['residente_id']}'
          : null,
      proyectoId: json['proyecto_id'] != null ? '${json['proyecto_id']}' : null,
      unidadPrincipalId: json['unidad_principal_id'] != null
          ? '${json['unidad_principal_id']}'
          : null,
    );
  }

  Paquete toEntity() {
    return Paquete(
      id: id,
      descripcion: descripcion,
      estado: estado,
      fechaRecepcion: fechaRecepcion,
      remitente: remitente,
      fotoUrl: fotoUrl,
      fechaRetiro: fechaRetiro,
      retiradoPorNombre: retiradoPorNombre,
      unidadIdentificador: unidadIdentificador,
      residenteId: residenteId,
      proyectoId: proyectoId,
      unidadPrincipalId: unidadPrincipalId,
    );
  }
}
