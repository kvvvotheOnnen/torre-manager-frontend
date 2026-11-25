/// Utilidades para validar y normalizar RUT chilenos (módulo 11).
class RutValidator {
  const RutValidator._();

  static String limpiar(String valor) {
    return valor.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
  }

  static String? validar(String? valor) {
    final rut = valor?.trim() ?? '';

    if (rut.isEmpty) return 'Ingresa el RUT';

    final limpio = limpiar(rut);

    if (limpio.length < 2) return 'RUT inválido';

    final cuerpo = limpio.substring(0, limpio.length - 1);
    final dv = limpio.substring(limpio.length - 1);

    if (cuerpo.isEmpty || cuerpo.length > 8 || int.tryParse(cuerpo) == null) {
      return 'RUT inválido';
    }

    if (int.parse(cuerpo) == 0) return 'RUT inválido';

    if (dv != _calcularDv(cuerpo)) return 'Dígito verificador inválido';

    return null;
  }

  static bool esValido(String valor) => validar(valor) == null;

  static String formatear(String valor) {
    final limpio = limpiar(valor);
    if (limpio.length < 2) return limpio;

    final cuerpo = limpio.substring(0, limpio.length - 1);
    final dv = limpio.substring(limpio.length - 1);

    final buffer = StringBuffer();
    for (var i = 0; i < cuerpo.length; i++) {
      if (i > 0 && (cuerpo.length - i) % 3 == 0) buffer.write('.');
      buffer.write(cuerpo[i]);
    }

    return '${buffer.toString()}-$dv';
  }

  static String _calcularDv(String cuerpo) {
    var suma = 0;
    var multiplicador = 2;

    for (var i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * multiplicador;
      multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
    }

    final resto = 11 - (suma % 11);

    return switch (resto) {
      11 => '0',
      10 => 'K',
      _ => '$resto',
    };
  }
}
