# 2026-11-04 — Proyectos: asistente de creación por pasos

- **Branch:** `feature/koke/ajustes-creacion-infraestructura/2026-11-04`
- **Módulo:** Superadmin / Proyectos

## Contexto

La creación de proyectos se realizaba en un único formulario. Al crear
estacionamientos y bodegas no era posible asociarlos a departamentos porque la
estructura del recinto aún no se había guardado. Se reemplaza el alta por un
asistente de 7 pasos con guardado incremental. La edición se mantiene igual.

## Cambios realizados

- Nueva capa de dominio/datos para borradores:
  - `IniciarProyectoBorradorUseCase`
  - `GuardarPasoProyectoUseCase`
  - `DescartarProyectoBorradorUseCase`
  - métodos nuevos en `SuperadminRepositoryInterface`, datasource y repositorio.
- Nuevo `ProyectoWizardBloc` (event/state) que orquesta los guardados por paso.
- Nueva pantalla `ProyectoWizardScreen` con 7 pasos y mapa de nodos
  (`WizardStepMap`).
- Todos los pasos tienen botones “Atrás” y “Siguiente”. “Siguiente” queda
  deshabilitado hasta cumplir la validación del paso actual.
- Paso 4 con pestañas embebidas “Estacionamientos” y “Bodegas”
  (`WizardAccesoriasPanel`), reutilizando los eventos de `SuperadminBloc`.
- Diálogo de salida con doble confirmación y descarte del borrador.
- Se elimina el creador anterior de `proyectos_screen.dart`; el formulario queda
  solo para edición.
- Wiring del nuevo BLoC en `main.dart`.
- Tests del `ProyectoWizardBloc`.

## Decisiones de diseño

- El borrador se elimina al salir del asistente.
- Al cambiar el tipo de condominio se reinicia la estructura tanto en la UI como
  en el backend.
- El paso de accesorias e instalaciones es opcional; nombre/tipo/estructura,
  administradores y módulos son obligatorios para finalizar.

## Verificación

- `flutter analyze` — sin issues.
- `flutter test` — 26 tests, todos en verde.

## Pendientes

- Limpieza de borradores huérfanos ante cierres abruptos del cliente.

## Corrección de bugs (2026-11-04)

- `ProyectoWizardState` incorpora `descartado` para garantizar una transición de
  estado al salir, incluso cuando no existe borrador creado.
- `WizardDescartado` emite `descartado: true` sin llamar al backend cuando no
  hay borrador, y reinicia el estado al descartar uno existente.
- `ProyectoWizardScreen` cierra el asistente al recibir `descartado`; se elimina
  la bandera local `_salidaSolicitada`.
- El botón/gesto atrás del sistema retrocede de paso cuando `pasoActual > 0` y
  solo pide confirmación en el paso inicial.
- Test de regresión: descartar sin borrador en el paso inicial.
- Verificación: `flutter analyze` sin issues; `flutter test` 27 tests en verde.
