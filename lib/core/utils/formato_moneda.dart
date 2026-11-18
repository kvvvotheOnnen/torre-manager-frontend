String formatearPrecio(int valor) {
  final digitos = valor.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digitos[i]);
  }

  return '\$${valor < 0 ? '-' : ''}$buffer';
}

String formatearFecha(DateTime? fecha) {
  if (fecha == null) {
    return '';
  }

  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}
