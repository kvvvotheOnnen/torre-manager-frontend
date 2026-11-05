enum TipoAgrupacion { edificio, torre, bloque, manzana }

TipoAgrupacion tipoAgrupacionFromString(String value) {
  switch (value) {
    case 'edificio':
      return TipoAgrupacion.edificio;
    case 'torre':
      return TipoAgrupacion.torre;
    case 'bloque':
      return TipoAgrupacion.bloque;
    case 'manzana':
      return TipoAgrupacion.manzana;
    default:
      throw ArgumentError('Tipo de agrupación desconocido: $value');
  }
}

extension TipoAgrupacionEtiqueta on TipoAgrupacion {
  String get etiqueta => switch (this) {
    TipoAgrupacion.edificio => 'Edificio',
    TipoAgrupacion.torre => 'Torre',
    TipoAgrupacion.bloque => 'Bloque',
    TipoAgrupacion.manzana => 'Manzana',
  };
}
