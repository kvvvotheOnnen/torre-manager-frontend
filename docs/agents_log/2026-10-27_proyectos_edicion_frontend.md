# Bitácora — Edición de proyectos (Frontend)

- **Fecha:** 2026-10-27
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** El listado de "Gestión de Proyectos" solo permitía crear. Se agregó la edición de proyectos (nombre, descripción, módulos, instalaciones extra y administradores).

## Cambios realizados

- `AppConfig.superadminProyectoPath(id)` para el recurso individual.
- DataSource: `obtenerProyecto` (GET) y `actualizarProyecto` (PUT) → `ProyectoDetalleDTO`.
- Repositorio (interfaz e implementación) con `_guard`: `obtenerProyecto` y `actualizarProyecto`.
- Casos de uso: `ObtenerProyectoUseCase` y `ActualizarProyectoUseCase` (validaciones locales de nombre, módulos y administradores).
- `SuperadminBloc`: eventos `ProyectoEdicionSolicitada`, `ProyectoEdicionFinalizada` y `ProyectoActualizado`; estado `cargandoDetalle` y `proyectoEnEdicion`.
- `ProyectosScreen`: tarjeta con acción de edición (icono y tap) que abre el formulario en modo edición.
- Formulario unificado (crear/editar): precarga de datos, tipo de condominio deshabilitado con nota, sección de estructura oculta con referencia al módulo Infraestructura, botón "Guardar cambios".
- `main.dart`: inyección de los casos de uso nuevos en `SuperadminBloc`.

## Decisiones de diseño

- El formulario se reutiliza en ambos modos para no duplicar la UI; en edición no envía `tipo_condominio` ni estructura.
- La precarga se hace escuchando el stream del bloc y aplicando el detalle una sola vez (flag), para evitar reinicios de controladores en rebuilds.
- Al guardar con éxito, el formulario se cierra al recibir el estado de éxito; los errores se muestran como SnackBar y el formulario permanece abierto.
- Los atributos de las instalaciones existentes se conservan y se reenvían en el PUT (permite renombrar sin perderlos).
- Si no se puede cargar el detalle, se muestra un mensaje con acción "Reintentar".

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 11 passed (3 nuevos en `superadmin_bloc_edicion_test.dart`: carga de detalle, actualización exitosa y validación de nombre vacío).

## Pendientes

- Edición de la estructura del recinto (agrupaciones y unidades) desde la app.
