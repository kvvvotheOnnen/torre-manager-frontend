# Log de Agentes — Torre Manager Frontend (Flutter)

Bitácora de los cambios realizados por el agente de IA en este repositorio.

> **Privacidad:** este repositorio es público. En todos los logs queda
> estrictamente prohibido incluir datos sensibles: credenciales, tokens,
> API keys, correos o nombres reales, cadenas de conexión, rutas absolutas
> del entorno local o contenido de archivos `.env`.

---

## 2026-10-19 — Login de prueba, manejo de error y verificación RBAC por rol

**Branch:** `feature/login/koke/19-10-2026`

### Contexto

Preparar una prueba manual end-to-end del login: diseño más cuidado de la
pantalla, mensaje de error estándar y usuarios de prueba (uno por rol) para
comprobar la redirección RBAC a las pantallas temporales.

### Contrato con el backend (respuesta del login)

El endpoint `POST /api/login` debe responder en una sola petición:
`{"access_token": "...", "token_type": "Bearer", "user": {"id", "nombre", "correo", "rol"}}`.
En la revisión se detectó que el controlador del backend quedaba incompleto
(referenciaba una variable inexistente y el caso de uso solo devolvía el
token). Se corrigió en el repositorio backend introduciendo un value object de
dominio `Sesion` (token + `Usuario`) y mapeando la respuesta. Detalle en la
bitácora del repositorio backend.

### Cambios en el frontend

1. **Mensaje de error** — `AuthRepositoryImpl`: ante `401` ahora retorna
   `ServerFailure('Credenciales incorrectas')`, mostrado como `SnackBar`.
2. **Rediseño de `LoginScreen`** (solo estética, lógica intacta):
   - Fondo con degradado, `Card` elevada centrada con ancho máximo.
   - Icono, título y subtítulo.
   - Campos con iconos de prefijo; contraseña con toggle de visibilidad.
   - Botón full-width con `CircularProgressIndicator` en `AuthLoading`.
   - Se mantiene `BlocConsumer` (error → SnackBar; éxito → navegación por rol).
3. **Placeholders por rol** — `app_router.dart`: las rutas `/admin_panel`,
   `/residente_home` y `/conserjeria` reciben el `Usuario` vía `extra` y
   muestran "Bienvenido, {nombre}" y "Rol: {rol}". La navegación usa
   `context.go(homeForRol(rol), extra: usuario)`.

### Usuarios de prueba (verificación RBAC)

Se crearon tres usuarios locales (uno por rol) en la base de datos de Docker,
mediante `php artisan tinker` con `updateOrCreate`. **Las contraseñas no se
registran en este documento ni en el repositorio.**

| Correo (referencia)      | Rol            | Ruta destino      |
|--------------------------|----------------|-------------------|
| `admin@torre.test`       | administrador  | `/admin_panel`    |
| `residente@torre.test`   | residente      | `/residente_home` |
| `conserje@torre.test`    | conserje       | `/conserjeria`    |

### Prueba manual

Con los contenedores del backend levantados (`nginx` en `:8000`):

```sh
# Web/escritorio en el host
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
# Emulador de Android (usa la URL por defecto 10.0.2.2:8000)
flutter run
```

- Credenciales correctas → redirección a la pantalla del rol con saludo.
- Credenciales incorrectas → `SnackBar` "Credenciales incorrectas".

### Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 4 pruebas pasan.
- `flutter build web`: compila correctamente.
