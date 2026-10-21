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
  static const String infraestructuraBasePath = '/api/infraestructura';
  static const String infraestructuraProyectoPath = '$infraestructuraBasePath/proyecto';
  static const String infraestructuraProyectosPath = '$infraestructuraBasePath/proyectos';
  static const String infraestructuraAgrupacionesPath = '$infraestructuraBasePath/agrupaciones';
  static const String infraestructuraUnidadesAccesoriasPath = '$infraestructuraBasePath/unidades-accesorias';
  static const String infraestructuraArbolPath = '$infraestructuraBasePath/arbol';
  static const String infraestructuraVistaPreviaPath = '$infraestructuraBasePath/vista-previa-identificaciones';
}
