import '../../domain/entities/solicitud_residente.dart';

class PersonaSolicitudDTO {
  const PersonaSolicitudDTO({
    required this.id,
    required this.nombre,
    required this.rut,
    required this.email,
    required this.telefono,
    required this.telefonoEmergencia,
    required this.nombreEmergencia,
    required this.tipoVinculo,
    required this.esPrincipal,
    this.usuarioId,
  });

  final String id;
  final String? usuarioId;
  final String nombre;
  final String rut;
  final String email;
  final String telefono;
  final String telefonoEmergencia;
  final String nombreEmergencia;
  final String tipoVinculo;
  final bool esPrincipal;

  factory PersonaSolicitudDTO.fromJson(Map<String, dynamic> json) {
    return PersonaSolicitudDTO(
      id: '${json['id']}',
      usuarioId: json['usuario_id'] != null ? '${json['usuario_id']}' : null,
      nombre: (json['nombre'] ?? '') as String,
      rut: (json['rut'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      telefono: (json['telefono'] ?? '') as String,
      telefonoEmergencia: (json['telefono_emergencia'] ?? '') as String,
      nombreEmergencia: (json['nombre_emergencia'] ?? '') as String,
      tipoVinculo: (json['tipo_vinculo'] ?? 'residente') as String,
      esPrincipal: (json['es_principal'] ?? false) as bool,
    );
  }

  PersonaSolicitud toEntity() {
    return PersonaSolicitud(
      id: id,
      usuarioId: usuarioId,
      nombre: nombre,
      rut: rut,
      email: email,
      telefono: telefono,
      telefonoEmergencia: telefonoEmergencia,
      nombreEmergencia: nombreEmergencia,
      tipoVinculo: tipoVinculo,
      esPrincipal: esPrincipal,
    );
  }
}

class InstalacionUnidadDTO {
  const InstalacionUnidadDTO({
    required this.id,
    required this.identificador,
    required this.tipo,
    this.asignacion,
  });

  final String id;
  final String identificador;
  final String tipo;
  final String? asignacion;

  factory InstalacionUnidadDTO.fromJson(Map<String, dynamic> json) {
    return InstalacionUnidadDTO(
      id: '${json['id']}',
      identificador: (json['identificador'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      asignacion: json['asignacion'] as String?,
    );
  }

  InstalacionUnidad toEntity() {
    return InstalacionUnidad(
      id: id,
      identificador: identificador,
      tipo: tipo,
      asignacion: asignacion,
    );
  }
}

class SolicitudResidenteDTO {
  const SolicitudResidenteDTO({
    required this.id,
    required this.proyectoId,
    required this.unidadPrincipalId,
    required this.unidad,
    required this.agrupacion,
    required this.tipoSolicitud,
    required this.origen,
    required this.estado,
    required this.createdAt,
    required this.personas,
    required this.instalaciones,
    this.motivoRechazo,
    this.solicitadoPorNombre,
    this.decididoPorNombre,
    this.decididoAt,
  });

  final String id;
  final String proyectoId;
  final String unidadPrincipalId;
  final String unidad;
  final String agrupacion;
  final String tipoSolicitud;
  final String origen;
  final String estado;
  final String? motivoRechazo;
  final String? solicitadoPorNombre;
  final String? decididoPorNombre;
  final String? decididoAt;
  final String createdAt;
  final List<PersonaSolicitudDTO> personas;
  final List<InstalacionUnidadDTO> instalaciones;

  factory SolicitudResidenteDTO.fromJson(Map<String, dynamic> json) {
    final personas = (json['personas'] as List<dynamic>? ?? const [])
        .map((e) => PersonaSolicitudDTO.fromJson(e as Map<String, dynamic>))
        .toList();
    final instalaciones = (json['instalaciones'] as List<dynamic>? ?? const [])
        .map((e) => InstalacionUnidadDTO.fromJson(e as Map<String, dynamic>))
        .toList();

    return SolicitudResidenteDTO(
      id: '${json['id']}',
      proyectoId: '${json['proyecto_id']}',
      unidadPrincipalId: '${json['unidad_principal_id']}',
      unidad: (json['unidad'] ?? '') as String,
      agrupacion: (json['agrupacion'] ?? '') as String,
      tipoSolicitud: (json['tipo_solicitud'] ?? 'propietario') as String,
      origen: (json['origen'] ?? 'autoregistro') as String,
      estado: (json['estado'] ?? 'pendiente') as String,
      motivoRechazo: json['motivo_rechazo'] as String?,
      solicitadoPorNombre: json['solicitado_por_nombre'] as String?,
      decididoPorNombre: json['decidido_por_nombre'] as String?,
      decididoAt: json['decidido_at'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
      personas: personas,
      instalaciones: instalaciones,
    );
  }

  SolicitudResidente toEntity() {
    return SolicitudResidente(
      id: id,
      proyectoId: proyectoId,
      unidadPrincipalId: unidadPrincipalId,
      unidad: unidad,
      agrupacion: agrupacion,
      tipoSolicitud: _tipoSolicitud(tipoSolicitud),
      origen: _origen(origen),
      estado: _estado(estado),
      motivoRechazo: motivoRechazo,
      solicitadoPorNombre: solicitadoPorNombre,
      decididoPorNombre: decididoPorNombre,
      decididoAt: decididoAt,
      createdAt: createdAt,
      personas: personas.map((p) => p.toEntity()).toList(),
      instalaciones: instalaciones.map((i) => i.toEntity()).toList(),
    );
  }

  static TipoSolicitud _tipoSolicitud(String value) {
    return TipoSolicitud.values.firstWhere(
      (tipo) => tipo.name == value,
      orElse: () => TipoSolicitud.propietario,
    );
  }

  static OrigenSolicitud _origen(String value) {
    return OrigenSolicitud.values.firstWhere(
      (origen) => origen.name == value,
      orElse: () => OrigenSolicitud.autoregistro,
    );
  }

  static EstadoSolicitud _estado(String value) {
    return EstadoSolicitud.values.firstWhere(
      (estado) => estado.name == value,
      orElse: () => EstadoSolicitud.pendiente,
    );
  }
}
