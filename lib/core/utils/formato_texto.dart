// Utilidades para presentar texto que viene de la API.

/// Devuelve el texto listo para mostrar: nunca `null`, vacío ni la cadena
/// literal "null". En su lugar usa un marcador como "-".
extension TextoParaMostrar on String? {
  String orPlaceholder([String marcador = '-']) {
    final valor = this?.trim();
    if (valor == null || valor.isEmpty || valor.toLowerCase() == 'null') {
      return marcador;
    }
    return valor;
  }
}
