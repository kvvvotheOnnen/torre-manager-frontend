# Frontend - Creación y asignación de accesorias

- **Fecha:** 2026-10-27
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** Task 3 de creación de estacionamientos y bodegas desde la creación/edición de proyectos, con pantalla dedicada para asignarlas a departamentos, visita u otro.

## Cambios realizados

- Entidades y DTOs actualizados con `asignacion` nullable y lista completa de accesorias en el árbol de infraestructura.
- Casos de uso:
  - creación de unidades accesorias en lote;
  - creación y asignación individual con validación de departamento.
- `SuperadminBloc` ampliado con eventos y estado para lote, asignación individual y actualización múltiple.
- Formulario de proyecto:
  - sección de estacionamientos y bodegas;
  - definición de cantidades con validación 1..999 y doble confirmación;
  - creación inicial de accesorias junto con el proyecto;
  - redirección al modo edición y apertura de la gestión de accesorias recién creadas.
- Pantalla dedicada `AccesoriasProyectoScreen`:
  - listado por tipo con identificador y asignación actual;
  - opciones mutuamente excluyentes: `Visita`, `Otro` y búsqueda de departamento por autocompletado;
  - validación de que el departamento elegido sea una sugerencia existente;
  - botón `Actualizar` por fila habilitado solo con una selección válida;
  - botón `Actualizar todo` visible, habilitado desde dos cambios válidos;
  - icono de edición para desplegar opciones y salir sin guardar.
- Se mantiene compatibilidad con `InfraestructuraScreen` para creación y liberación de accesorias; crear o liberar sin asignación envía `null`.
- Las accesorias nuevas inician sin ninguna opción marcada. `Otro` solo se marca y persiste cuando el usuario lo selecciona explícitamente.

## Decisiones de diseño

- El autocompletado usa las unidades principales existentes del proyecto y exige seleccionar una sugerencia para evitar identificadores incompletos.
- Las selecciones se consideran cambios solo cuando difieren de la asignación actual.
- `null` representa “sin asignar”; `otro` es una elección explícita que bloquea las demás opciones.
- La actualización múltiple reutiliza el caso de uso individual y reporta éxitos y fallos parciales.
- La navegación posterior a la creación usa un estado explícito para no depender del orden de mensajes del bloc.

## Verificación

- `flutter analyze`: sin observaciones.
- `flutter test`: 17 tests aprobados, incluyendo DTO sin asignación, `otro` explícito, creación en lote sin asignación y actualización múltiple.

## Pendientes

- Prueba manual del flujo completo en dispositivo/emulador.
- Revisar comportamiento visual del autocompletado en pantallas pequeñas.
