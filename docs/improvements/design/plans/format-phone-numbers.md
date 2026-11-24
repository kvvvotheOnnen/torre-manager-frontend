# Fix: Show and type phone numbers in a readable format

- Link: https://flutterpro.design/details/md/format-phone-numbers
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

Un teléfono como una tira de dígitos es difícil de leer y de tipear sin errores.

## Fix

Nuevo `lib/core/utils/formato_telefono.dart`:

- `formatearTelefono(String?, {String marcador = '-'})` agrupa números chilenos
  como `+56 9 1234 5678`, `9 1234 5678` o en bloques de cuatro.
- `FormateadorTelefono` (`TextInputFormatter`) da formato mientras se escribe,
  elimina el 56 duplicado y limita a 9 dígitos.

Usado en `trabajador_servicio_form_dialog.dart` (`inputFormatters`),
`trabajador_servicio_card.dart`, `trabajador_servicio_detalle_dialog.dart`,
`gestion_residentes_screen.dart` y `datos_personales_card.dart`.

## Check

Escribir y pegar `+56912345678` en el formulario de servicios: debe quedar
`+56 9 1234 5678` y nunca duplicar el código.
