enum TipoUnidadAccesoria { estacionamiento, bodega }

TipoUnidadAccesoria tipoUnidadAccesoriaFromString(String value) {
  switch (value) {
    case 'estacionamiento':
      return TipoUnidadAccesoria.estacionamiento;
    case 'bodega':
      return TipoUnidadAccesoria.bodega;
    default:
      throw ArgumentError('Tipo de unidad accesoria desconocido: $value');
  }
}
