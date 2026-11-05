# Log de Agentes — Torre Manager Frontend (Flutter)

Bitácora de los cambios realizados por el agente de IA en este repositorio.

> **Privacidad:** este repositorio es público. En todos los logs queda
> estrictamente prohibido incluir datos sensibles: credenciales, tokens,
> API keys, correos o nombres reales, cadenas de conexión, rutas absolutas
> del entorno local o contenido de archivos `.env`.

---

## 2026-10-19 — Módulo Auth, Paso 3: Presentación (BLoC y UI)

**Branch:** `feature/login/koke/19-10-2026`

### Contexto

Cierre del frontend del módulo Auth. Se ajustó el contrato de red según la
decisión de producto (una sola petición en el login) y se construyó la capa de
presentación con `flutter_bloc`, `go_router` y Material 3.

### Ajuste del contrato con el backend

- `POST /api/login` ahora retorna en una sola respuesta:
  `{"access_token": "...", "token_type": "Bearer", "user": {"id", "nombre", "correo", "rol"}}`.
- `AuthRemoteDataSource` fue simplificado: elimina la segunda llamada de
  fallback a `GET /api/user` y construye `AuthResponseDTO` directamente desde
  la respuesta del login.
- Se removió `AppConfig.currentUserPath` (ya no se usa). El DTO ya toleraba
  esta estructura sin cambios.

### Gestión de Estado (BLoC)

- `lib/features/auth/presentation/bloc/auth_event.dart`
  - `AuthEvent` (sellado) y `LoginRequested(email, password)`.
- `lib/features/auth/presentation/bloc/auth_state.dart`
  - `AuthState` (sellado) con `AuthInitial`, `AuthLoading`,
    `AuthSuccess(Usuario)` y `AuthError(String message)`.
  - Igualdad de valor con `equatable`.
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
  - `AuthBloc` inyecta `LoginUseCase`.
  - `LoginRequested` → emite `AuthLoading` → ejecuta el caso de uso →
    `AuthError(failure.message)` o `AuthSuccess(usuario)` según el `Either`.

### Interfaz Gráfica (UI)

- `lib/features/auth/presentation/screens/login_screen.dart`
  - `Form` con validación de email (regex) y contraseña obligatoria.
  - `BlocConsumer<AuthBloc, AuthState>`:
    - *listener*: `AuthError` → `SnackBar`; `AuthSuccess` → navegación según rol.
    - *builder*: `AuthLoading` muestra `CircularProgressIndicator` dentro del
      botón y deshabilita el formulario.
  - `TextEditingController` liberados en `dispose`.

### Enrutamiento y RBAC

- `lib/core/router/app_router.dart`
  - `GoRouter` con `initialLocation: /login`.
  - Rutas: `/login`, `/admin_panel`, `/residente_home`, `/conserjeria`
    (las tres últimas son pantallas temporales `_RolePlaceholder`).
  - `AppRoutes.homeForRol(Rol)` mapea el rol de la entidad `Usuario` a su ruta
    (RBAC). El rol se obtiene de `AuthSuccess.usuario.rol`.

### Composición de dependencias

- `lib/main.dart` (`TorreManagerApp`, `StatefulWidget`):
  - Construye el grafo: `SecureTokenStorage` → `DioClient` →
    `AuthRemoteDataSource` → `AuthRepositoryImpl` → `LoginUseCase` → `AuthBloc`.
  - `BlocProvider.value` sobre `MaterialApp.router` y cierre del bloc en
    `dispose`.

### Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 4 pruebas pasan:
  - `LoginUseCase` (camino feliz y error).
  - `AuthBloc` (emisión `AuthLoading` → `AuthSuccess` / `AuthError`).

### Estado del módulo Auth (frontend)

Completo: Dominio, Datos (con token en almacenamiento seguro) y Presentación
(BLoC, UI y enrutamiento por rol). Pendiente natural: pantallas reales por rol,
persistencia de sesión al reabrir la app y protección de rutas en el router.
