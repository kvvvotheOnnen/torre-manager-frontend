# 2026-11-19 — Enforcement de módulos a nivel API (cliente)

## Contexto

- **Branch:** `feature/koke/refactor-clean-architecture/19-11-2026`
- Acompaña el cambio de backend que valida el estado del módulo para el
  proyecto activo en cada endpoint.

## Cambios realizados

- Paquetería: el repositorio ahora propaga el mensaje del servidor cuando el
  backend responde `403` por módulo deshabilitado ("El módulo no está
  habilitado para este proyecto."), en lugar de un texto genérico.
- Wizard de creación y edición de proyecto: el módulo configurable
  `infraestructura` se muestra como **siempre habilitado** (switch fijo), en
  línea con la validación del backend que exige al menos un módulo.
- Edición de proyecto: al prefill, se garantiza que `infraestructura` esté en
  el conjunto de módulos enviados.

## Decisiones de diseño

- La seguridad no se replica en el cliente: el backend es la fuente de verdad.
  El frontend solo muestra el mensaje de error que devuelve la API.
- No se agregan guards de router por módulo; los dashboards siguen componiendo
  desde `GET /api/dashboard/funciones`.

## Verificación

- `dart analyze lib`: sin issues.
- `flutter test`: **101 tests OK**.

## Pendientes

- Replicar el manejo amable del `403` de módulo en las pantallas de servicios,
  marketplace, asistente administrativo y solicitudes cuando sus flujos de error
  se estandaricen.
- Las demás features ya extraían el mensaje del servidor para `403`; revisar
  que mantengan ese comportamiento al añadir nuevas pantallas.
