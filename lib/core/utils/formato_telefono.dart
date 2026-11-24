import 'package:flutter/services.dart';

/// Formatea un teléfono chileno para leerlo con facilidad:
/// `+56 9 1234 5678`, `9 1234 5678` o agrupado de cuatro en cuatro.
String formatearTelefono(String? telefono, {String marcador = '-'}) {
  final crudo = telefono?.trim() ?? '';
  if (crudo.isEmpty || crudo.toLowerCase() == 'null') return marcador;

  final soloDigitos = crudo.replaceAll(RegExp(r'\D'), '');
  if (soloDigitos.isEmpty) return marcador;

  final tienePrefijo = crudo.startsWith('+');

  if (soloDigitos.length == 11 && soloDigitos.startsWith('56')) {
    final cuerpo = soloDigitos.substring(2);
    return '+56 ${cuerpo[0]} ${cuerpo.substring(1, 5)} '
        '${cuerpo.substring(5)}';
  }
  if (soloDigitos.length == 9) {
    return '${tienePrefijo ? '+' : ''}${soloDigitos[0]} '
        '${soloDigitos.substring(1, 5)} ${soloDigitos.substring(5)}';
  }

  final grupos = <String>[];
  for (var i = 0; i < soloDigitos.length; i += 4) {
    grupos.add(
      soloDigitos.substring(
        i,
        i + 4 > soloDigitos.length ? soloDigitos.length : i + 4,
      ),
    );
  }
  return '${tienePrefijo ? '+' : ''}${grupos.join(' ')}';
}

/// Da formato al teléfono mientras el usuario escribe y elimina el código de
/// país duplicado cuando el portapapeles o el autocompletado lo incluyen.
class FormateadorTelefono extends TextInputFormatter {
  const FormateadorTelefono();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final tienePrefijo = newValue.text.startsWith('+');
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return newValue.copyWith(text: '');

    if (digitos.length > 9 && digitos.startsWith('56')) {
      digitos = digitos.substring(2);
    }
    if (digitos.length > 9) {
      digitos = digitos.substring(0, 9);
    }

    final formateado = tienePrefijo || digitos.length == 9
        ? formatearTelefono('${tienePrefijo ? '+' : ''}$digitos')
        : formatearTelefono(digitos);

    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}
