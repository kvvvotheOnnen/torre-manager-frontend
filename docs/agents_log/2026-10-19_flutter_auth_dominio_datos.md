# Log de Agentes — Torre Manager Frontend (Flutter)

Bitácora de los cambios realizados por el agente de IA en este repositorio.

> **Privacidad:** este repositorio es público. En todos los logs queda
> estrictamente prohibido incluir datos sensibles: credenciales, tokens,
> API keys, correos o nombres reales, cadenas de conexión, rutas absolutas
> del entorno local o contenido de archivos `.env`.

---

## 2026-10-19 — Módulo Auth, Pasos 1 y 2: Dominio y Datos

**Branch:** `feature/login/koke/19-10-2026`

### Contexto

Cliente Flutter de Torre Manager siguiendo Clean Architecture + Feature-First
(AGENTS.md raíz del proyecto). Stack: `dio` (red), `flutter_bloc` (estado),
`go_router` (enrutamiento), `equatable` y `fpdart` (`Either` para errores).

Dependencias añadidas en este paso: `fpdart` y `flutter_secure_storage`.

### Paso 1 — Capa de Dominio (Core)

1. **Entidad `Usuario`** — `lib/features/auth/domain/entities/usuario.dart`
   - Clase pura de Dart con `id`, `nombre`, `correo` y el enum `Rol`
     (`administrador`, `residente`, `conserje`).
   - Igualdad de valor vía `equatable`. Sin dependencias de JSON, red o
     framework.

2. **`Failure`** — `lib/core/errors/failures.dart`
   - Clase base abstracta (hereda de `Equatable`) y subclases `ServerFailure`,
     `CacheFailure` y `UnexpectedFailure`.

3. **`AuthRepositoryInterface`** —
   `lib/features/auth/domain/repositories/auth_repository.dart`
   - Contrato: `Future<Either<Failure, Usuario>> login(String email, String password)`.

4. **`LoginUseCase`** — `lib/features/auth/domain/usecases/login_usecase.dart`
   - Inyecta el repositorio por constructor.
   - `call({email, password})` normaliza el email (`trim`) y delega en el
     repositorio.

### Paso 2 — Capa de Datos (Traductor y Red)

1. **DTOs** — `lib/features/auth/data/models/`
   - `usuario_dto.dart`: serialización (`fromJson`) y `toEntity()`. Tolerante a
     los nombres de campo del backend (`nombre`/`name`, `email`/`correo`) y al
     parseo del rol string → enum.
   - `auth_response_dto.dart`: agrupa `access_token` + usuario.

2. **Infraestructura de red y almacenamiento** — `lib/core/`
   - `config/app_config.dart`: URL base configurable en tiempo de compilación
     vía `--dart-define=API_BASE_URL=...`. Por defecto `http://10.0.2.2:8000`
     (host visto desde el emulador de Android). Rutas `/api/login` y `/api/user`.
   - `network/dio_client.dart`: `Dio` con `BaseOptions` e interceptor que
     inyecta `Authorization: Bearer <token>` cuando existe token guardado.
   - `storage/token_storage.dart`: contrato `TokenStorage` + implementación
     `SecureTokenStorage` con `flutter_secure_storage` (almacenamiento seguro
     del token, nunca en texto plano).

3. **`AuthRemoteDataSource`** —
   `lib/features/auth/data/datasources/auth_remote_data_source.dart`
   - `POST /api/login` con `email`/`password`; extrae `access_token`.
   - Si la respuesta incluye el objeto usuario, lo usa; en caso contrario
     consulta `GET /api/user` con el token recién emitido.

4. **`AuthRepositoryImpl`** —
   `lib/features/auth/data/repositories/auth_repository_impl.dart`
   - Llama al DataSource, guarda el token con `TokenStorage`, mapea el
     `UsuarioDTO` a la entidad pura y retorna `Right(Usuario)`.
   - Captura `DioException`: `401` → `Left(ServerFailure('Credenciales inválidas'))`;
     otros errores → `Left(ServerFailure())`; `FormatException` y errores
     inesperados → `Left(UnexpectedFailure())`.

### Nota de contrato con el backend

El endpoint `POST /api/login` del backend actual responde únicamente
`{"access_token": "...", "token_type": "Bearer"}` (sin el objeto usuario). Por
eso el DataSource obtiene el usuario con una segunda llamada a `GET /api/user`.
**Recomendación:** incluir el objeto `user` en la respuesta de login para
ahorrar una petición (el DTO ya lo soporta sin cambios).

### Verificación

- `flutter analyze`: sin issues.
- `flutter test`: prueba unitaria del `LoginUseCase` (camino feliz y error).

### Pendiente

- Paso 3 (BLoC y UI): estado (`AuthBloc`/`Cubit`), pantalla de login,
  validación de formulario, enrutamiento con `go_router` y composición de
  dependencias (inyección del repositorio/caso de uso).
