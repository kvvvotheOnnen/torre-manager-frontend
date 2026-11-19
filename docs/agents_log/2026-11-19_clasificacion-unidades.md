# 2026-11-19 — Clasificación de unidades (task 13)

## Contexto

- **Branch:** `feature/koke/clasificacion-unidades/19-11-2026`
- Task 13 en el cliente: el paso de Estructura del wizard incorpora la sección
  "Clasificación de unidades", habilitada cuando hay unidades definidas por
  piso. También se refuerza el gating de "pisos con excepción".

## Cambios realizados

- Entidades puras `ClasificacionUnidad` y `UnidadClasificable`.
- Servicio de dominio `GeneradorUnidadesClasificables`: replica la generación
  de identificadores del backend (pisos, excepciones simples, manzanas) para
  listar las unidades que se crearán antes de persistir el paso.
- Wizard de Estructura:
  - nueva sección "Clasificación de unidades" en el mismo slide;
  - permite crear clasificaciones con nombre libre y asignar unidades;
  - el selector solo ofrece unidades sin clasificar (una unidad no puede estar
    en dos categorías);
  - tarjeta "Estándar" fija con las unidades sin clasificar;
  - eliminar una clasificación devuelve sus unidades a "Estándar".
  - "Pisos con excepción" solo muestra su contenido cuando piso desde/hasta y
    unidades por piso son válidos.
- El paso envía `clasificaciones` junto con `agrupaciones` mediante
  `WizardEstructuraGuardada`, el caso de uso, el repositorio y el DataSource.

## Decisiones de diseño

- La sección vive en el mismo slide de Estructura (indicación del usuario),
  por lo que las unidades se calculan en el dominio a partir de los formularios.
- "Estándar" es informativa y de solo lectura; el backend la representa con
  `clasificacion_id = NULL`.
- Sin precarga adicional: el wizard ya no reanuda pasos desde el borrador y el
  estado local mantiene las clasificaciones al retroceder dentro del asistente.

## Verificación

- `dart analyze lib test`: sin issues.
- `flutter test`: **105 tests OK**, incluidos los nuevos tests del generador de
  unidades y la verificación de que el BLoC propaga las clasificaciones.

## Corrección posterior: nomenclatura de unidades del edificio

- `GeneradorUnidadesClasificables` usa `Unidad-` como base para el tipo
  edificio (paridad con backend); torres/bloques mantienen su nombre.
- El identificador sugerido en pisos con excepción del edificio ahora es
  `Unidad-<piso><n>`.
- Tests del generador actualizados a `Unidad-101` / `Unidad-201`.
- Verificación: `dart analyze` limpio y **105 tests OK**.

## Corrección UI: excepciones colapsables y diálogo de asignación

- Los pisos con excepción ahora se expanden y contraen desde su cabecera
  (`Piso N` + resumen de unidades + chevron). Los nuevos se agregan contraídos
  para que varios pisos en edición no se estorben.
- Clasificación de unidades:
  - se eliminó el listado de unidades "Estándar"; queda solo un contador
    discreto bajo la sección;
  - cada clasificación muestra nombre y número de unidades asignadas;
  - "Asignar unidades" abre un diálogo con buscador y cuadrícula de unidades
    seleccionables, permitiendo agregar y quitar en lote;
  - "Guardar cambios" aplica al estado del wizard y "Salir sin guardar"
    descarta; la persistencia real sigue ocurriendo al avanzar el paso.
- Verificación: `dart analyze` limpio y **105 tests OK**.
