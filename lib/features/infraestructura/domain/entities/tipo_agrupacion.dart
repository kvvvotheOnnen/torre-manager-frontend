enum TipoAgrupacion { torre, bloque, manzana }

TipoAgrupacion tipoAgrupacionFromString(String value) {
  switch (value) {
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
