# Bitácora — Fase 3: Enrutamiento Multi-Tenant del Administrador (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** Fase 3, contexto de proyecto activo y enrutamiento post-login.

## Cambios realizados

- **`ProyectoActivoStore`** (`core/tenant/`): persiste el proyecto activo en `shared_preferences`. El interceptor de `DioClient` ahora inyecta la cabecera `X-Proyecto-Id` en todas las peticiones (junto al `Authorization`).
- **`TenantBloc`** (`features/tenant/`): al autenticarse un **administrador** consulta `GET /api/mis-proyectos` y decide:
  - 1 proyecto → lo fija como activo (`listo`).
  - varios → `seleccionPendiente` (o restaura uno válido guardado).
  - 0 → `sinProyectos` (dashboard con aviso).
  - Al cerrar sesión limpia el proyecto activo.
- **`ListarMisProyectosUseCase`** reutilizado desde la feature `superadmin`.
- **Router** (`go_router`): el `refreshListenable` escucha también al `TenantBloc`. Regla post-login del administrador: mientras resuelve → splash; con múltiples proyectos y ninguno elegido → fuerza `/selector-proyecto`; una vez listo → `/dashboard`. Se añadió la ruta `/selector-proyecto` y su pantalla `SelectorProyectoScreen`.
- **Dashboard**: para el administrador, los módulos se filtran además por los `ModuloSistema` habilitados del proyecto activo (los administradores heredan los módulos del recinto).
- Inyección de dependencias en `main.dart`; el store se comparte con `DioClient`.

## Decisiones de diseño

- El superadmin mantiene su flujo (no pasa por el selector; elige proyecto al operar en Infraestructura).
- La pertenencia y los módulos se resuelven server-side; el cliente solo refleja el proyecto elegido y envía el header de contexto.

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 4 passed.
- Backend (curl): un administrador con 3 proyectos → `mis-proyectos` devuelve 3; con `X-Proyecto-Id` válido → 200. Prueba manual: administrador de 1 proyecto entra directo; con varios, aparece el selector.

## Guía de prueba manual (multi-tenant completo)

1. Backend: `docker compose up -d` + `php artisan migrate:fresh --seed`.
2. App: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`.
3. Superadmin: crear 1–2 administradores (módulo "Administradores").
4. Superadmin: crear un proyecto (módulo "Gestión de Proyectos") asignando esos administradores; repetir para darle 2 proyectos a un mismo admin.
5. Login con un administrador asignado a **1** proyecto → entra directo al dashboard.
6. Login con un administrador asignado a **2+** proyectos → aparece el selector; al elegir, entra al dashboard con los módulos del recinto.
7. Dentro de Infraestructura, las operaciones se aplican al proyecto activo (header `X-Proyecto-Id`).

## Pendientes

- Definir módulos de residente/conserje y su contexto de proyecto.
