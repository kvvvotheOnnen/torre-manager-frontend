import '../../domain/entities/registro_residente.dart';

class ProyectoRegistroDTO {
  const ProyectoRegistroDTO({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory ProyectoRegistroDTO.fromJson(Map<String, dynamic> json) {
    return ProyectoRegistroDTO(
      id: '${json['id']}',
      nombre: (json['nombre'] ?? '') as String,
    );
  }

  ProyectoRegistro toEntity() {
    return ProyectoRegistro(id: id, nombre: nombre);
  }
}

class UnidadRegistroDTO {
  const UnidadRegistroDTO({
    required this.id,
    required this.identificador,
    required this.agrupacion,
    required this.etiqueta,
  });

  final String id;
  final String identificador;
  final String agrupacion;
  final String etiqueta;

  factory UnidadRegistroDTO.fromJson(Map<String, dynamic> json) {
    final identificador = (json['identificador'] ?? '') as String;
    final agrupacion = (json['agrupacion'] ?? '') as String;

    return UnidadRegistroDTO(
      id: '${json['id']}',
      identificador: identificador,
      agrupacion: agrupacion,
      etiqueta: (json['etiqueta'] ?? identificador) as String,
    );
  }

  UnidadRegistro toEntity() {
    return UnidadRegistro(
      id: id,
      identificador: identificador,
      agrupacion: agrupacion,
      etiqueta: etiqueta,
    );
  }
}

class SolicitudRegistroDTO {
  const SolicitudRegistroDTO({
    required this.proyectoId,
    required this.unidadPrincipalId,
    required this.password,
    required this.personas,
    required this.mascotas,
  });

  final String proyectoId;
  final String unidadPrincipalId;
  final String password;
  final List<Map<String, dynamic>> personas;
  final List<Map<String, dynamic>> mascotas;

  factory SolicitudRegistroDTO.fromEntity(SolicitudRegistro solicitud) {
    final personas = <Map<String, dynamic>>[];
    final total = solicitud.personas.length;

    for (var i = 0; i < total; i++) {
      final persona = solicitud.personas[i];
      final esPrincipal = i == 0;

      personas.add({
        'nombre': persona.nombre,
        'rut': persona.rut,
        'email': persona.email,
        'telefono': persona.telefono,
        'telefono_emergencia': persona.telefonoEmergencia,
        'nombre_emergencia': persona.nombreEmergencia,
        'tipo_vinculo': esPrincipal
            ? solicitud.tipoVinculo.name
            : 'residente',
        'es_principal': esPrincipal,
      });
    }

    final mascotas = solicitud.mascotas
        .map(
          (mascota) => {
            'nombre': mascota.nombre,
            'especie': mascota.especie.apiValue,
            'raza': mascota.raza,
            if (mascota.microchip != null && mascota.microchip!.isNotEmpty)
              'microchip': mascota.microchip,
          },
        )
        .toList();

    return SolicitudRegistroDTO(
      proyectoId: solicitud.proyectoId,
      unidadPrincipalId: solicitud.unidadPrincipalId,
      password: solicitud.password,
      personas: personas,
      mascotas: mascotas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proyecto_id': proyectoId,
      'unidad_principal_id': unidadPrincipalId,
      'password': password,
      'password_confirmation': password,
      'personas': personas,
      'mascotas': mascotas,
    };
  }
}
