import 'package:equatable/equatable.dart';

enum TipoVinculoRegistro { propietario, arrendatario }

enum EspecieMascota {
  canino,
  felino,
  pequenoMamifero,
  aveDomestica,
  otro,
}

extension EspecieMascotaApi on EspecieMascota {
  String get apiValue => switch (this) {
    EspecieMascota.canino => 'canino',
    EspecieMascota.felino => 'felino',
    EspecieMascota.pequenoMamifero => 'pequeno_mamifero',
    EspecieMascota.aveDomestica => 'ave_domestica',
    EspecieMascota.otro => 'otro',
  };

  String get etiqueta => switch (this) {
    EspecieMascota.canino => 'Canino',
    EspecieMascota.felino => 'Felino',
    EspecieMascota.pequenoMamifero => 'Pequeño mamífero',
    EspecieMascota.aveDomestica => 'Ave doméstica',
    EspecieMascota.otro => 'Otro',
  };
}

class ProyectoRegistro extends Equatable {
  const ProyectoRegistro({required this.id, required this.nombre});

  final String id;
  final String nombre;

  @override
  List<Object?> get props => [id, nombre];
}

class UnidadRegistro extends Equatable {
  const UnidadRegistro({
    required this.id,
    required this.identificador,
    required this.agrupacion,
    required this.etiqueta,
  });

  final String id;
  final String identificador;
  final String agrupacion;
  final String etiqueta;

  @override
  List<Object?> get props => [id, identificador, agrupacion, etiqueta];
}

class PersonaRegistro extends Equatable {
  const PersonaRegistro({
    required this.nombre,
    required this.rut,
    required this.email,
    required this.telefono,
    required this.telefonoEmergencia,
    required this.nombreEmergencia,
  });

  final String nombre;
  final String rut;
  final String email;
  final String telefono;
  final String telefonoEmergencia;
  final String nombreEmergencia;

  @override
  List<Object?> get props => [
    nombre,
    rut,
    email,
    telefono,
    telefonoEmergencia,
    nombreEmergencia,
  ];
}

class MascotaRegistro extends Equatable {
  const MascotaRegistro({
    required this.nombre,
    required this.especie,
    required this.raza,
    this.microchip,
  });

  final String nombre;
  final EspecieMascota especie;
  final String raza;
  final String? microchip;

  @override
  List<Object?> get props => [nombre, especie, raza, microchip];
}

class SolicitudRegistro extends Equatable {
  const SolicitudRegistro({
    required this.proyectoId,
    required this.unidadPrincipalId,
    required this.tipoVinculo,
    required this.password,
    required this.personas,
    required this.mascotas,
  });

  final String proyectoId;
  final String unidadPrincipalId;
  final TipoVinculoRegistro tipoVinculo;
  final String password;
  final List<PersonaRegistro> personas;
  final List<MascotaRegistro> mascotas;

  @override
  List<Object?> get props => [
    proyectoId,
    unidadPrincipalId,
    tipoVinculo,
    password,
    personas,
    mascotas,
  ];
}
