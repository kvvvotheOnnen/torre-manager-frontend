enum EstadoPublicacion {
  disponible('disponible', 'Disponible'),
  vendida('vendida', 'Vendida'),
  retirada('retirada', 'Retirada'),
  eliminada('eliminada', 'Eliminada'),
  desconocido('desconocido', 'No disponible');

  const EstadoPublicacion(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  bool get estaDisponible => this == EstadoPublicacion.disponible;
  bool get estaVendida => this == EstadoPublicacion.vendida;
  bool get estaRetirada => this == EstadoPublicacion.retirada;
  bool get estaEliminada => this == EstadoPublicacion.eliminada;
}

EstadoPublicacion estadoPublicacionDesde(String valor) {
  for (final estado in EstadoPublicacion.values) {
    if (estado.valor == valor) {
      return estado;
    }
  }

  return EstadoPublicacion.desconocido;
}
