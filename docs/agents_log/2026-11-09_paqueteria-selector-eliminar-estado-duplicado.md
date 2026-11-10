# 2026-11-09 — Paquetería: quitar estado duplicado de departamentos

- **Módulo:** Frontend / Paquetería
- **Rama:** `test-martin`

## Contexto

El formulario de registro mostraba debajo del selector de departamento un
mensaje de estado fijo (por ejemplo, "Cargando departamentos..." o
"304 departamentos cargados"). El dropdown también muestra estado cuando
corresponde, por lo que el mensaje fijo se duplicaba visualmente.

## Cambios realizados

- Se quitó el mensaje fijo de carga/conteo ubicado debajo del campo en
  `_FormularioRegistro`.
- Se conserva el estado contextual dentro de la lista desplegable cuando aún
  está cargando o no hay coincidencias.
- No se alteró la lógica de selección de departamentos ni el endpoint.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.

## Pendientes

- Confirmación visual manual del selector en el navegador.
