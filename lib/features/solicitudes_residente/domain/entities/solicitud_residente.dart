import 'package:equatable/equatable.dart';

enum EstadoSolicitud { pendiente, aprobada, rechazada }

enum TipoSolicitud { propietario, arrendatario }

enum OrigenSolicitud {
  autoregistro,
  conserje,
  administrador,
  importacion,
  seeder,
}

class PersonaSolicitud extends Equatable {
  const PersonaSolicitud({
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

  @override
  List<Object?> get props => [
    id,
    usuarioId,
    nombre,
    rut,
    email,
    telefono,
    telefonoEmergencia,
    nombreEmergencia,
    tipoVinculo,
    esPrincipal,
  ];
}

class InstalacionUnidad extends Equatable {
  const InstalacionUnidad({
    required this.id,
    required this.identificador,
    required this.tipo,
    this.asignacion,
  });

  final String id;
  final String identificador;
  final String tipo;
  final String? asignacion;

  @override
  List<Object?> get props => [id, identificador, tipo, asignacion];
}

class SolicitudResidente extends Equatable {
  const SolicitudResidente({
    required this.id,
    required this.proyectoId,
    required this.unidadPrincipalId,
    required this.unidad,
    required this.agrupacion,
    required this.tipoSolicitud,
    required this.origen,
    required this.estado,
    required this.personas,
    required this.instalaciones,
    required this.createdAt,
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
  final TipoSolicitud tipoSolicitud;
  final OrigenSolicitud origen;
  final EstadoSolicitud estado;
  final String? motivoRechazo;
  final String? solicitadoPorNombre;
  final String? decididoPorNombre;
  final String? decididoAt;
  final String createdAt;
  final List<PersonaSolicitud> personas;
  final List<InstalacionUnidad> instalaciones;

  PersonaSolicitud? get personaPrincipal {
    for (final persona in personas) {
      if (persona.esPrincipal) return persona;
    }
    return personas.isEmpty ? null : personas.first;
  }

  @override
  List<Object?> get props => [
    id,
    proyectoId,
    unidadPrincipalId,
    unidad,
    agrupacion,
    tipoSolicitud,
    origen,
    estado,
    motivoRechazo,
    solicitadoPorNombre,
    decididoPorNombre,
    decididoAt,
    createdAt,
    personas,
    instalaciones,
  ];
}
