enum ModuloSistema {
  infraestructura;

  /// Valor de API (snake_case).
  String get valor => switch (this) {
    ModuloSistema.infraestructura => 'infraestructura',
  };

  String get etiqueta => switch (this) {
    ModuloSistema.infraestructura => 'Infraestructura',
  };
}

/// Retorna `null` para IDs que ya no son módulos configurables por proyecto,
/// permitiendo seguir leyendo respuestas antiguas de la API.
ModuloSistema? moduloSistemaFromString(String value) {
  for (final modulo in ModuloSistema.values) {
    if (modulo.valor == value) return modulo;
  }
  return null;
}
