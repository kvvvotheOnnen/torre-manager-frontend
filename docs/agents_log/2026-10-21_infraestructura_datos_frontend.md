# Bitácora — Tarea 4: Capa de Datos (Frontend Flutter)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** HU-04, consumo de los endpoints `/api/infraestructura/*` (rol Administrador).

## Cambios realizados

- **DTOs** (`lib/features/infraestructura/data/models/`): `ProyectoDTO`, `AgrupacionDTO`, `UnidadPrincipalDTO`, `UnidadAccesoriaDTO` y `ArbolInfraestructuraDTO` (+ clases anidadas del árbol). Únicos con `fromJson`/`toEntity`; parsean los enums por nombre (`data/models/tipo_*` del dominio).
- **DataSource** (`data/datasources/infraestructura_remote_data_source.dart`): única clase con `dio`; consume `GET /api/infraestructura/proyecto|arbol`, `POST proyectos|agrupaciones|unidades-accesorias|vista-previa-identificaciones`, `PATCH unidades-accesorias/{id}/asignacion`. Rutas centralizadas en `AppConfig`.
- **Repositorio** (`data/repositories/infraestructura_repository_impl.dart`): implementa la interfaz de dominio; mapea `DioException` a `Failure` (422/409 → `ValidationFailure` con mensaje del backend, 404/403/401 → `ServerFailure`) y retorna **entidades puras**.

## Decisiones de diseño

- El `proyecto_id` no se envía desde el cliente en agrupaciones/unidades accesorias: el backend lo resuelve del usuario autenticado (scoping multi-tenant server-side).
- El mapeo DTO→Entidad ocurre íntegramente en el repositorio (barrera anticorrupción); el dominio no ve JSON.

## Verificación

- `flutter analyze`: sin issues.

## Pendientes

- BLoC, pantallas y guards de `go_router` (Tarea 5).
