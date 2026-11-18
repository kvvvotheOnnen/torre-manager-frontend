import '../../domain/entities/solicitud_residente.dart';

const _acentos = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
  'Á': 'a',
  'É': 'e',
  'Í': 'i',
  'Ó': 'o',
  'Ú': 'u',
  'Ü': 'u',
  'Ñ': 'n',
};

String normalizarTextoBusqueda(String value) {
  var texto = value.toLowerCase();

  for (final entry in _acentos.entries) {
    texto = texto.replaceAll(entry.key, entry.value);
  }

  return texto.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool solicitudCoincide(SolicitudResidente solicitud, String busqueda) {
  final terminos = normalizarTextoBusqueda(busqueda)
      .split(' ')
      .where((termino) => termino.isNotEmpty)
      .toList();

  if (terminos.isEmpty) return true;

  final campos = <String?>[
    solicitud.unidad,
    solicitud.agrupacion,
    solicitud.tipoSolicitud.name,
    solicitud.estado.name,
    solicitud.origen.name,
    solicitud.motivoRechazo,
    solicitud.solicitadoPorNombre,
    solicitud.decididoPorNombre,
    solicitud.createdAt,
    solicitud.decididoAt,
    ...solicitud.personas.expand(
      (persona) => [
        persona.nombre,
        persona.rut,
        persona.email,
        persona.telefono,
        persona.telefonoEmergencia,
        persona.nombreEmergencia,
        persona.tipoVinculo,
      ],
    ),
    ...solicitud.instalaciones.expand(
      (instalacion) => [
        instalacion.identificador,
        instalacion.tipo,
        instalacion.asignacion,
      ],
    ),
  ];

  final valores = campos
      .whereType<String>()
      .map(normalizarTextoBusqueda)
      .where((valor) => valor.isNotEmpty)
      .toList();

  return terminos.every(
    (termino) => valores.any((valor) => valor.contains(termino)),
  );
}
