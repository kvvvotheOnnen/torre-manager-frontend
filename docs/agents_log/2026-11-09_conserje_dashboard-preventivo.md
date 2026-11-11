# 2026-11-09 — Dashboard preventivo del conserje

- **Módulo:** Frontend / Dashboard
- **Rama:** `test-martin` (frontend)

## Contexto

El conserje podía iniciar sesión pero su dashboard estaba vacío ("Aún no tienes
módulos asignados"). Se creó un dashboard preventivo que espeja el diseño del
admin/residente.

## Cambios realizados

- Nuevo `conserje_dashboard_screen.dart`: espeja el diseño del residente
  (sidebar desktop, drawer móvil, panel superior, grid responsive).
  - Panel superior: solo "Bienvenido, {nombre}" + logout (sin notificaciones).
  - 4 módulos preventivos: Paquetería, Control de acceso, Alertas y noticias,
    Reserva de espacios comunes.
  - Al presionar un módulo se abre la vista "Próximamente".
- `dashboard_screen.dart`: `Rol.conserje` → `ConserjeDashboardScreen`.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK.

## Pendientes

- Implementar lógica real de cada módulo en backend + frontend.
- Conectar botones a endpoints cuando existan.
