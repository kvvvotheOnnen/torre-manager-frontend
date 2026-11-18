enum CondicionProducto {
  nuevo('nuevo', 'Nuevo'),
  semiNuevo('semi_nuevo', 'Semi nuevo'),
  usado('usado', 'Usado');

  const CondicionProducto(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;
}

CondicionProducto condicionProductoDesde(String valor) {
  for (final condicion in CondicionProducto.values) {
    if (condicion.valor == valor) {
      return condicion;
    }
  }

  return CondicionProducto.usado;
}
