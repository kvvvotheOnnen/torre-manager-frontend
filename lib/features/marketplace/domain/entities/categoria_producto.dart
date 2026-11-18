enum CategoriaProducto {
  electrodomesticos('electrodomesticos', 'Electrodomésticos'),
  muebles('muebles', 'Muebles'),
  electronica('electronica', 'Electrónica'),
  ropa('ropa', 'Ropa'),
  accesorios('accesorios', 'Accesorios'),
  otros('otros', 'Otros');

  const CategoriaProducto(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;
}

CategoriaProducto categoriaProductoDesde(String valor) {
  for (final categoria in CategoriaProducto.values) {
    if (categoria.valor == valor) {
      return categoria;
    }
  }

  return CategoriaProducto.otros;
}
