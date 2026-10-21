enum TipoCondominio {
  torres,
  casas,
  mixto;

  String get etiqueta => switch (this) {
    TipoCondominio.torres => 'Torres',
    TipoCondominio.casas => 'Casas',
    TipoCondominio.mixto => 'Mixto',
  };
}

TipoCondominio tipoCondominioFromString(String value) {
  switch (value) {
    case 'torres':
      return TipoCondominio.torres;
    case 'casas':
      return TipoCondominio.casas;
    case 'mixto':
      return TipoCondominio.mixto;
    default:
      throw ArgumentError('Tipo de condominio desconocido: $value');
  }
}
