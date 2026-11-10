# 2026-11-09 — Paquetería: frontend (residente + conserje/admin)

- **Módulo:** Frontend / Paquetería
- **Rama:** `test-martin` (frontend)

## Contexto

El módulo Paquetería del backend quedó implementado (registro, listado, retiro,
foto opcional). Se conectó el frontend para que el botón "Paquetería" deje de
ser preventivo.

## Cambios realizados

- Nueva feature `paqueteria` (Clean Architecture):
  - `domain/entities/paquete.dart`
  - `domain/repositories/paqueteria_repository.dart`
  - `domain/usecases/` (listar, registrar, marcar retirado)
  - `data/models/paquete_dto.dart`
  - `data/datasources/paqueteria_remote_data_source.dart` (multipart con foto)
  - `data/repositories/paqueteria_repository_impl.dart`
  - `presentation/bloc/paqueteria_bloc.dart`
  - `presentation/screens/mis_paquetes_screen.dart` (residente)
  - `presentation/screens/paqueteria_gestion_screen.dart` (conserje/admin)
- `core/config/app_config.dart`: sin cambios (usa `/api/paqueteria` directo).
- `core/router/app_router.dart`: rutas `/paqueteria` y `/paqueteria/gestion`.
- `main.dart`: registro de data source, repo, use cases, bloc.
- `resident_dashboard_screen.dart`: botón "Paquetería" → `MisPaquetesScreen`.
- `conserje_dashboard_screen.dart`: botón "Paquetería" → `PaqueteriaGestionScreen`.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK ("Mis paquetes" presente en el build).

## Pendientes

- Implementar los demás módulos (Quincho, Gastos comunes, Control de acceso,
  Alertas y noticias, Notificaciones) en backend + frontend.
- Agregar tests de widget/bloc para paquetería (opcional).
