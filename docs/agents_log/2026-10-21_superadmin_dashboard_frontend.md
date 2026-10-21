# Bitácora — Superadmin y Dashboard unificado (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** todos los roles llegan a un mismo dashboard cuyos módulos dependen del rol.

## Cambios realizados

- **Rol `superadmin`** agregado al enum `Rol` de la entidad `Usuario` (el parseo de `UsuarioDTO` ya era genérico).
- **Feature `superadmin`** (`lib/features/superadmin/`): entidad `ResumenProyecto`, repositorio/interfaz, DTO, DataSource `dio` (`GET /api/superadmin/proyectos`), `SuperadminBloc` y pantalla `ProyectosScreen` (listado con conteos de agrupaciones/unidades y pull-to-refresh).
- **Dashboard unificado** (`lib/features/dashboard/presentation/screens/dashboard_screen.dart`): única pantalla de aterrizaje para todos los roles. Un método `_modulosPara(Rol)` centraliza qué módulos ve cada perfil:
  - `superadmin` → "Gestión de Proyectos" + "Infraestructura" (herencia de administrador).
  - `administrador` → "Infraestructura".
  - `residente` / `conserje` → sin módulos ("Aún no tienes módulos asignados"), listos para definirse luego.
  - Incluye chip de rol y logout.
- **Router** (`core/router/app_router.dart`): ruta `/dashboard` para todos los roles (post-login y post-verificación); `/admin/infraestructura` protegida para `administrador` y `superadmin`; `/superadmin/*` exclusiva de `superadmin`. Se eliminaron las rutas `/admin_panel`, `/residente_home`, `/conserjeria` y sus placeholders, y la pantalla `AdminPanelScreen`.
- **DI** en `main.dart`: `SuperadminBloc` global inyectado junto a los demás.

## Decisiones de diseño

- El dashboard es único; la visibilidad de módulos es un mapeo declarativo por rol en un solo lugar, fácil de migrar a configuración servida por la API más adelante.
- La herencia de módulos del superadmin se refleja tanto en el dashboard como en los guards y en el backend (rutas `role:administrador,superadmin`).

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 4 passed.

## Guía de prueba manual

1. Backend: `docker compose up -d` + `php artisan migrate:fresh --seed`.
2. App (Chrome): `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`.
3. Login `superadmin@torremanager.test` / `password` → dashboard con módulos "Gestión de Proyectos" e "Infraestructura". "Gestión de Proyectos" lista el/los proyectos con conteos.
4. Login `admin@torremanager.test` / `password` → dashboard con solo "Infraestructura".
5. Login `residente@torremanager.test` o `conserje@torremanager.test` → dashboard sin módulos.
6. RBAC: como residente/conserje, deep-link a `/admin/infraestructura` o `/superadmin/proyectos` redirige al dashboard; como administrador, `/superadmin/proyectos` redirige al dashboard.

## Pendientes

- Definir los módulos de residente y conserje.
- CRUD de proyectos para el superadmin (vertical futura).
