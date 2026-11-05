enum TipoCondominio {
  torres,
  casas,
  edificio,
  mixto;

  String get etiqueta => switch (this) {
    TipoCondominio.torres => 'Torres',
    TipoCondominio.casas => 'Casas',
    TipoCondominio.edificio => 'Edificio',
    TipoCondominio.mixto => 'Mixto',
  };

  String get descripcion => switch (this) {
    TipoCondominio.torres => 'Una o más torres/bloques con pisos y unidades',
    TipoCondominio.casas => 'Una o más manzanas con casas',
    TipoCondominio.edificio => 'Un edificio de pisos, sin torres',
    TipoCondominio.mixto => 'Combina torres y manzanas',
  };
}

TipoCondominio tipoCondominioFromString(String value) {
  switch (value) {
    case 'torres':
      return TipoCondominio.torres;
    case 'casas':
      return TipoCondominio.casas;
    case 'edificio':
      return TipoCondominio.edificio;
    case 'mixto':
      return TipoCondominio.mixto;
    default:
      throw ArgumentError('Tipo de condominio desconocido: $value');
  }
}
