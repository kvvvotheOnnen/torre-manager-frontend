class AppConfig {
  const AppConfig._();

  /// URL base de la API.
  ///
  /// Puede sobreescribirse en tiempo de compilación:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
  ///
  /// El valor por defecto `10.0.2.2` apunta al host desde el emulador de
  /// Android. En iOS/Web usar `http://localhost:8000`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String loginPath = '/api/login';
  static const String userPath = '/api/user';
  static const String infraestructuraBasePath = '/api/infraestructura';
  static const String infraestructuraProyectoPath =
      '$infraestructuraBasePath/proyecto';
  static const String infraestructuraProyectosPath =
      '$infraestructuraBasePath/proyectos';
  static const String infraestructuraAgrupacionesPath =
      '$infraestructuraBasePath/agrupaciones';
  static const String infraestructuraUnidadesAccesoriasPath =
      '$infraestructuraBasePath/unidades-accesorias';
  static const String infraestructuraUnidadesAccesoriasLotePath =
      '$infraestructuraBasePath/unidades-accesorias/lote';
  static const String infraestructuraArbolPath =
      '$infraestructuraBasePath/arbol';
  static const String infraestructuraVistaPreviaPath =
      '$infraestructuraBasePath/vista-previa-identificaciones';
  static const String superadminProyectosPath = '/api/superadmin/proyectos';
  static const String superadminProyectosBorradorPath =
      '$superadminProyectosPath/borrador';
  static String superadminProyectoPath(String id) =>
      '$superadminProyectosPath/${Uri.encodeComponent(id)}';
  static String superadminProyectoBorradorPath(String id) =>
      '${superadminProyectoPath(id)}/borrador';
  static const String superadminAdministradoresPath =
      '/api/superadmin/administradores';
  static const String misProyectosPath = '/api/mis-proyectos';
  static const String dashboardModulosPath = '/api/dashboard/modulos';
  static const String dashboardFuncionesPath = '/api/dashboard/funciones';
  static const String notificacionesPath = '/api/notificaciones';
  static const String notificacionesNoLeidasPath =
      '$notificacionesPath/no-leidas';
  static const String notificacionesLeerTodasPath =
      '$notificacionesPath/leer-todas';
  static String notificacionLeerPath(String id) =>
      '$notificacionesPath/${Uri.encodeComponent(id)}/leer';
  static const String serviciosPath = '/api/servicios';
  static String servicioPath(String id) =>
      '$serviciosPath/${Uri.encodeComponent(id)}';
  static const String marketplaceBasePath = '/api/marketplace';
  static const String marketplacePublicacionesPath =
      '$marketplaceBasePath/publicaciones';
  static const String marketplaceMisPublicacionesPath =
      '$marketplaceBasePath/mis-publicaciones';
  static const String marketplaceHistorialPath =
      '$marketplaceBasePath/historial';
  static const String marketplaceFavoritosPath =
      '$marketplaceBasePath/favoritos';
  static String marketplacePublicacionPath(String id) =>
      '$marketplacePublicacionesPath/${Uri.encodeComponent(id)}';
  static String marketplaceRetirarPath(String id) =>
      '${marketplacePublicacionPath(id)}/retirar';
  static String marketplaceVenderPath(String id) =>
      '${marketplacePublicacionPath(id)}/vender';
  static String marketplaceFavoritoPath(String id) =>
      '${marketplacePublicacionPath(id)}/favorito';
  static const String marketplaceSolicitudesPath =
      '$marketplaceBasePath/solicitudes';
  static String marketplaceAprobarPath(String id) =>
      '${marketplacePublicacionPath(id)}/aprobar';
  static String marketplaceRechazarPath(String id) =>
      '${marketplacePublicacionPath(id)}/rechazar';
  static const String residenteMiInformacionPath =
      '/api/residente/mi-informacion';
  static const String residenteAsistenteConsultasPath =
      '/api/residente/asistente/consultas';
  static const String asistenteAdminDocumentoPath =
      '/api/admin/asistente/documento';
  static const String solicitudesResidentesPath =
      '/api/admin/solicitudes-residentes';
  static const String solicitudesResidentesHistorialPath =
      '$solicitudesResidentesPath/historial';
  static String solicitudResidentePath(String id) =>
      '$solicitudesResidentesPath/${Uri.encodeComponent(id)}';
  static String solicitudResidenteAprobarPath(String id) =>
      '${solicitudResidentePath(id)}/aprobar';
  static String solicitudResidenteRechazarPath(String id) =>
      '${solicitudResidentePath(id)}/rechazar';
  static const String misSolicitudesResidentesPath =
      '/api/mis-solicitudes-residentes';
}
