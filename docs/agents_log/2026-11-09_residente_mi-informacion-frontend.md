# 2026-11-09 — Residente: conexión "Mi información" al backend

- **Módulo:** Frontend / Residente
- **Rama:** `test-martin` (frontend)

## Contexto

El botón "Mi información" del dashboard del residente era preventivo (vista
"Próximamente"). Se conectó al endpoint backend `GET /api/residente/mi-informacion`
implementado en `2026-11-09_residente_mi-informacion-backend.md`.

## Cambios realizados

- Nueva feature `residente` (Clean Architecture):
  - `domain/entities/mi_informacion.dart`
  - `domain/repositories/residente_repository.dart`
  - `domain/usecases/obtener_mi_informacion_usecase.dart`
  - `data/models/mi_informacion_dto.dart`
  - `data/datasources/residente_remote_data_source.dart`
  - `data/repositories/residente_repository_impl.dart`
  - `presentation/bloc/residente_mi_informacion_bloc.dart`
  - `presentation/screens/mi_informacion_screen.dart`
- `core/config/app_config.dart`: path `residenteMiInformacionPath`.
- `core/router/app_router.dart`: ruta `/residente/mi-informacion`.
- `main.dart`: registro del data source, repository, use case y BLoC.
- `resident_dashboard_screen.dart`: el botón "Mi información" navega a
  `/residente/mi-informacion` (en lugar de "Próximamente").

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK ("Mi información" presente en el build).

## Pendientes

- Implementar los demás módulos (Paquetería, Quincho, Gastos comunes,
  Control de acceso, Notificaciones) en backend + frontend.
