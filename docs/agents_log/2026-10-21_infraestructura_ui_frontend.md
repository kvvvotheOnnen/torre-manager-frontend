# Bitácora — Tarea 5: Presentación y UI Funcional (Frontend Flutter)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** HU-04. Objetivo: flujo end-to-end funcional con RBAC en `go_router`.

## Cambios realizados

- **Sesión mínima para guards:** `AuthRemoteDataSource.me()` (`GET /api/user`), `AuthRepositoryInterface.obtenerUsuarioAutenticado()`/`cerrarSesion()`, eventos `AuthCheckRequested` y `LogoutRequested`, y estado `AuthUnauthenticated` en `AuthBloc`. Al arrancar se verifica el token guardado.
- **Router con RBAC** (`core/router/app_router.dart`): `refreshListenable` sobre el stream del `AuthBloc`; splash `/` mientras se verifica sesión; redirect global que envía a `/login` sin sesión, al home por rol con sesión, y bloquea `/admin_panel` y `/admin/infraestructura` para cualquier rol distinto de `administrador` (protege deep-links). Pantalla nueva `AdminPanelScreen` con acceso al módulo y logout.
- **InfraestructuraBloc** (`presentation/bloc/`): eventos `InfraestructuraIniciado` (resuelve proyecto del usuario y carga el árbol), `ArbolSolicitado`, `AgrupacionRegistrada` (cascada), `UnidadAccesoriaCreada`, `AccesoriaAsignada`, `MensajeConsumido`; estado con `status`/`arbol`/`mensaje`.
- **UI** (`presentation/screens/infraestructura_screen.dart`): árbol jerárquico Proyecto → Agrupación → Unidad → Accesorias con ExpansionTiles, diálogo de registro de agrupación en cascada (nombre, tipo Torre/Bloque/Manzana, prefijo, piso desde/hasta, unidades por piso), diálogo de unidad accesoria (identificador, tipo, asignación opcional a la unidad actual) y diálogo de liberación de accesoria. SnackBars de éxito/error, pull-to-refresh.
- **DI** en `main.dart`: BLoCs globales, use cases de infraestructura inyectados manualmente.
- Se actualizaron los tests de Auth (fakes con los nuevos métodos del repositorio).

## Decisiones de diseño

- El `proyecto_id` nunca viaja en la URL: la pantalla dispara `InfraestructuraIniciado` y el BLoC resuelve el proyecto server-side.
- RBAC defensivo en dos capas: guard de `go_router` (frontend) + middleware `role:administrador` (backend, Tarea 3).

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 4 passed.
- End-to-end manual pendiente de ejecución en dispositivo/emulador (guía abajo).

## Guía de prueba manual end-to-end

1. Backend: `docker compose up -d` y `php artisan migrate:fresh --seed` (crea usuarios demo del proyecto).
2. App: `flutter run --dart-define=API_BASE_URL=http://<ip-host>:8000` (emulador Android usa `http://10.0.2.2:8000`).
3. Login con el usuario Administrador demo → cae en Panel de Administración.
4. Entrar a "Infraestructura": se muestra el proyecto y el árbol sembrado (Torre A, Manzana 1).
5. Botón "Agrupación": registrar "Torre B", tipo Torre, pisos 1-2, 3 unidades por piso → aparece en el árbol con 6 unidades.
6. Expandir una unidad → "Unidad accesoria": crear E-901 estacionamiento asignado → visible como "Asignada".
7. "Cambiar" sobre una accesoria → liberarla → pasa a "Libre disposición".
8. Verificación RBAC: iniciar sesión como residente/conserje demo → nunca se accede a rutas `/admin/*` (redirect al home propio); en API responden 403.

## Pendientes

- Navegación de logout en pantallas placeholder de residente/conserje (no bloquea la HU-04).
