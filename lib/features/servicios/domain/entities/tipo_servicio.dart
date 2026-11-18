enum TipoServicio {
  electricista('electricista', 'Electricista'),
  gasfiter('gasfiter', 'Gasfiter'),
  maestro('maestro', 'Maestro'),
  cerrajero('cerrajero', 'Cerrajero'),
  tecnicoInformatico('tecnico_informatico', 'Técnico informático'),
  otro('otro', 'Otro');

  const TipoServicio(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;
}

TipoServicio tipoServicioDesde(String valor) {
  for (final tipo in TipoServicio.values) {
    if (tipo.valor == valor) {
      return tipo;
    }
  }
  return TipoServicio.otro;
}
