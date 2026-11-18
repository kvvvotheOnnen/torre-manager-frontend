/// Módulos globales de la plataforma.
///
/// Están disponibles por defecto para cualquier proyecto, pero el superadmin
/// puede deshabilitarlos por proyecto desde la edición del proyecto.
enum ModuloGeneral {
  paqueteria,
  instalacionesExtra,
  gastosComunes,
  controlAcceso,
  registroConserjes,
  cambioUnidadResidente,
  solicitudesResidente,
  registroEmpleados,
  personasExternasOficios,
  alertasNoticias,
  asistenteIaAdmin,
  serviciosRecomendados,
  marketplace;

  /// Valor de API (snake_case).
  String get valor => switch (this) {
    ModuloGeneral.paqueteria => 'paqueteria',
    ModuloGeneral.instalacionesExtra => 'instalaciones_extra',
    ModuloGeneral.gastosComunes => 'gastos_comunes',
    ModuloGeneral.controlAcceso => 'control_acceso',
    ModuloGeneral.registroConserjes => 'registro_conserjes',
    ModuloGeneral.cambioUnidadResidente => 'cambio_unidad_residente',
    ModuloGeneral.solicitudesResidente => 'solicitudes_residente',
    ModuloGeneral.registroEmpleados => 'registro_empleados',
    ModuloGeneral.personasExternasOficios => 'personas_externas_oficios',
    ModuloGeneral.alertasNoticias => 'alertas_noticias',
    ModuloGeneral.asistenteIaAdmin => 'asistente_ia_admin',
    ModuloGeneral.serviciosRecomendados => 'servicios_recomendados',
    ModuloGeneral.marketplace => 'marketplace',
  };

  String get etiqueta => switch (this) {
    ModuloGeneral.paqueteria => 'Paquetería',
    ModuloGeneral.instalacionesExtra => 'Instalaciones extra',
    ModuloGeneral.gastosComunes => 'Gastos comunes',
    ModuloGeneral.controlAcceso => 'Control de acceso',
    ModuloGeneral.registroConserjes => 'Registro de conserjes',
    ModuloGeneral.cambioUnidadResidente => 'Cambio de unidad de residente',
    ModuloGeneral.solicitudesResidente => 'Solicitudes de nuevo residente',
    ModuloGeneral.registroEmpleados => 'Registro de otros empleados',
    ModuloGeneral.personasExternasOficios => 'Personas externas para oficios',
    ModuloGeneral.alertasNoticias => 'Alertas y noticias',
    ModuloGeneral.asistenteIaAdmin => 'IA admin',
    ModuloGeneral.serviciosRecomendados => 'Servicios recomendados',
    ModuloGeneral.marketplace => 'Marketplace',
  };
}

/// Retorna `null` para IDs que no correspondan a un módulo global.
ModuloGeneral? moduloGeneralFromString(String value) {
  for (final modulo in ModuloGeneral.values) {
    if (modulo.valor == value) return modulo;
  }
  return null;
}
