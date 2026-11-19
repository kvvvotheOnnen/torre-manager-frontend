/// Error de transporte producido por la capa de red.
///
/// La construyen los DataSources (o el cliente HTTP compartido) al capturar
/// respuestas 4xx/5xx. Los repositorios solo traducen esta excepción a un
/// `Failure` de dominio; nunca conocen `dio`.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.data);

  final int? statusCode;
  final Object? data;
}
