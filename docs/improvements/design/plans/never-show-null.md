# Fix: Never show "null" or a blank spot

- Link: https://flutterpro.design/details/md/never-show-null
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

Cuando la API devuelve `null`, la cadena `"null"` o vacío, el usuario ve la
palabra "null" o un hueco en pantalla.

## Fix

Nuevo `lib/core/utils/formato_texto.dart` con la extensión
`String?.orPlaceholder([String marcador = '-'])`, que cubre los tres casos.

Aplicado en `gestion_residentes_screen.dart` (RUT, correo, contacto de
emergencia) y `datos_personales_card.dart` (RUT, teléfono con marcador
"No registrado").

## Check

`flutter analyze` sin issues; revisar una solicitud con campos vacíos y ver "-".
