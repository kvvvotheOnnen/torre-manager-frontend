enum ModuloSistema {
  infraestructura,
  paqueteria,
  quincho,
  gastosComunes,
  controlAcceso;

  /// Valor de API (snake_case).
  String get valor => switch (this) {
    ModuloSistema.infraestructura => 'infraestructura',
    ModuloSistema.paqueteria => 'paqueteria',
    ModuloSistema.quincho => 'quincho',
    ModuloSistema.gastosComunes => 'gastos_comunes',
    ModuloSistema.controlAcceso => 'control_acceso',
  };

  String get etiqueta => switch (this) {
    ModuloSistema.infraestructura => 'Infraestructura',
    ModuloSistema.paqueteria => 'Paquetería',
    ModuloSistema.quincho => 'Quincho',
    ModuloSistema.gastosComunes => 'Gastos comunes',
    ModuloSistema.controlAcceso => 'Control de acceso',
  };
}

ModuloSistema moduloSistemaFromString(String value) {
  return ModuloSistema.values.firstWhere(
    (modulo) => modulo.valor == value,
    orElse: () => throw ArgumentError('Módulo desconocido: $value'),
  );
}
