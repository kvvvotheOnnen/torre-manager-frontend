# 2026-11-07 — Dashboard preventivo del residente

- **Módulo:** Frontend / Dashboard / Auth
- **Rama:** `feature/martin/residente-dashboard-2026-11-07` (fusionada a `main` vía PR #1)

## Contexto

El residente podía iniciar sesión pero su dashboard estaba vacío ("Aún no tienes
módulos asignados") y el login rebotaba al inicio de sesión por una doble
navegación entre el `LoginScreen` y el router.

## Cambios realizados

### Fix de rebote de login
- `lib/features/auth/presentation/screens/login_screen.dart`: se eliminó el
  `context.go(...)` manual en el listener de `AuthSuccess`. La navegación al
  dashboard la gestiona únicamente el router. Se mantuvo el snackbar de error.

### Dashboard preventivo del residente
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`:
  - `Rol.residente` deriva a `ResidentDashboardScreen`.
- Nuevo `resident_dashboard_screen.dart`: espeja el diseño del admin
  (sidebar en desktop, drawer en móvil, panel superior, grid responsive).
  - Sidebar: sección "Notificaciones" (icono campana arriba) + "Módulos".
  - 5 módulos preventivos: Mi información, Paquetería, Quincho, Gastos comunes,
    Control de acceso.
  - Icono de notificaciones en el panel superior (extremo derecho) con badge
    de cantidad (listo para conectar al backend).
  - Al presionar un módulo aparece su vista "Próximamente" en el panel central.
- `modulo_proximamente_screen.dart`: acepta `titulo` y `descripcion` opcionales
  vía `ProximamenteArgs` (extra de la ruta).
- `app_router.dart`: guardia de rutas permite a residente acceder a
  `/admin/modulos/*` (vista "Próximamente").

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK.

## Pendientes

- Conectar el botón "Mi información" al endpoint backend (implementado en
  `2026-11-09_residente_mi-informacion-backend.md`).
- Implementar la lógica real de cada módulo preventivo.
