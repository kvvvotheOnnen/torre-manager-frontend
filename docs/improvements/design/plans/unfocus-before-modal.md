# Fix: Keyboard reappears after closing a modal

- Link: https://flutterpro.design/details/md/unfocus-before-modal
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

Si un campo tiene foco al abrir un modal, el teclado vuelve al cerrarlo aunque
el usuario ya haya terminado de escribir.

## Fix

Llamar `FocusManager.instance.primaryFocus?.unfocus();` antes de abrir el modal
(no `FocusScope.of(context).unfocus()`).

- `marketplace_screen.dart`: `_abrirFormulario`, `_abrirDetalle`.
- `servicios_screen.dart`: `_abrirFormulario`.
- `gestion_residentes_screen.dart`: `_abrirDetalle`, `_confirmarAceptacion`.
- `paqueteria_gestion_screen.dart`: `_solicitarRetiro`, `_abrirFormulario`,
  `_mostrarEdicion` y el `onTap` de la tarjeta que abre el detalle.

## Check

Enfocar el buscador, abrir y cerrar un modal: el teclado no debe reaparecer.
