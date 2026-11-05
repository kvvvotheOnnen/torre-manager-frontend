# Bitácora — Tarea 1: Dominio de Infraestructura (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** HU-04, vertical de Infraestructura (lado Flutter).

## Cambios realizados

- `lib/features/infraestructura/domain/entities/`: `Proyecto`, `Agrupacion`, `UnidadPrincipal`, `UnidadAccesoria`, enums `TipoAgrupacion` y `TipoUnidadAccesoria` (con conversión desde string de API), y `ArbolInfraestructura`/`ArbolAgrupacion`/`ArbolUnidadPrincipal`. Entidades puras con `Equatable`, sin `fromJson`/`toJson`.
- `domain/repositories/infraestructura_repository.dart`: interfaz con `Either<Failure, T>` y `fpdart`.
- `domain/usecases/`: `CrearProyectoUseCase`, `RegistrarAgrupacionEnCascadaUseCase` (valida rango de pisos y máximo de 500 unidades), `CrearUnidadAccesoriaUseCase`, `AsignarUnidadAccesoriaUseCase`, `ObtenerArbolInfraestructuraUseCase`, `ObtenerProyectoDelUsuarioUseCase`.
- `core/errors/failures.dart`: se agregó `ValidationFailure` para errores de negocio validados en el cliente.

## Decisiones de diseño

- Espejo exacto del dominio backend; el enum se parsea en `data/` (Tarea 4), no en las entidades.
- La validación de reglas de negocio (rango pisos, límite de unidades) vive en el UseCase, no en el BLoC.

## Verificación

- `flutter analyze`: sin issues.

## Pendientes

- DTOs, DataSource con `dio` y repositorio (Tarea 4); BLoC y UI (Tarea 5).
