# Pisos con excepción en estructura de edificio (frontend)

- **Fecha:** 2026-11-04
- **Branch:** `feature/koke/pisos-excepcion-edificio/2026-11-04`
- **Módulo:** Superadmin / Wizard de proyectos

## Contexto

Durante la creación de un edificio se debía permitir marcar pisos con
excepción, eliminar sus unidades automáticas y definirlas manualmente. Cada
unidad manual puede ser una unidad simple (departamento) o una instalación
extra con capacidad y descripción.

## Cambios realizados

- Entidades de dominio:
  - `TipoUnidadExcepcion`, `UnidadExcepcion`, `PisoExcepcion`.
  - `DefinicionAgrupacion` incorpora `pisosExcepcion`.
  - Helper `instalacionesDePisosExcepcion()`.
- El datasource envía `pisos_excepcion` al guardar estructura.
- Wizard de estructura (solo edificio):
  - Selector de pisos disponibles dentro del rango configurado.
  - Tarjetas por piso con unidades manuales.
  - Checkboxes mutuamente excluyentes “Unidad simple” / “Instalación extra”.
  - Capacidad (1-500) y descripción (máx. 100) para instalaciones extra.
  - Validaciones de rango, tipo obligatorio, identificadores únicos y
    capacidades.
- Paso de instalaciones:
  - Las instalaciones extra de pisos con excepción se listan en modo solo
    lectura.
  - Se combinan con las instalaciones manuales al guardar el paso.
  - Validación de nombres duplicados antes de enviar.
- Test nuevo de extracción de instalaciones desde pisos con excepción.

## Decisiones de diseño

- Las instalaciones extra creadas en pisos con excepción se materializan al
  guardar el paso 5, no en el guardado de estructura. Esto evita duplicar el
  origen de las instalaciones y reutiliza el endpoint existente.
- Las unidades simples se crean como unidades principales normales, por lo que
  participan del autocompletado de accesorias.
- El editor de excepciones se muestra solo para tipo Edificio.

## Verificación

- `flutter analyze` — sin issues.
- `flutter test` — 29 tests en verde.

## Pendientes

- Ninguno para esta tarea.

## Ajuste posterior: piso sin unidades y numeración automática

- Se agregó la casilla “Piso sin unidades” a nivel de piso; al marcarla se
  ocultan las unidades y no se exige identificador.
- Las unidades simples de un piso con excepción muestran el identificador
  calculado automáticamente (`201`, `202`, ...) y ya no se editan manualmente.
- La numeración respeta el número de piso y salta los pisos sin unidades.
- Verificación: `flutter analyze` sin issues; `flutter test` 30 tests en verde.
