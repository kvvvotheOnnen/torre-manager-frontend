enum TipoAsignacion { departamento, visita, otro }

TipoAsignacion? tipoAsignacionFromStringOrNull(Object? value) {
  if (value == null || value == '') return null;
  return tipoAsignacionFromString(value as String);
}

TipoAsignacion tipoAsignacionFromString(String value) {
  switch (value) {
    case 'departamento':
      return TipoAsignacion.departamento;
    case 'visita':
      return TipoAsignacion.visita;
    case 'otro':
      return TipoAsignacion.otro;
    default:
      throw ArgumentError('Tipo de asignación desconocido: $value');
  }
}

extension TipoAsignacionEtiqueta on TipoAsignacion {
  String get etiqueta => switch (this) {
    TipoAsignacion.departamento => 'Departamento',
    TipoAsignacion.visita => 'Visita',
    TipoAsignacion.otro => 'Otro',
  };
}
