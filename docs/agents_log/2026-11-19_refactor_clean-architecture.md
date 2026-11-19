# 2026-11-19 — Refactor de Clean Architecture (frontend)

## Contexto

- **Branch:** `feature/koke/refactor-clean-architecture/19-11-2026`
- Auditoría previa de ambos repos contra `AGENTS.md`. Este paso corrige las
  discrepancias de severidad alta y media del cliente Flutter.

## Cambios realizados

### Paquetería

- Nueva entidad pura `UnidadGestionable` y DTO `UnidadDto`.
- El DataSource `unidades()` devuelve DTOs; el repositorio mapea a entidad.
- Nuevo `ListarUnidadesUseCase`. El `PaqueteriaBloc` ya no recibe el DataSource:
  depende solo de casos de uso.
- `PaqueteriaState.unidades` pasa de `List<Map<String, dynamic>>` a
  `List<UnidadGestionable>`; la pantalla de gestión usa campos tipados.

### Dashboards desde el catálogo

- `ResidentDashboardScreen` y `ConserjeDashboardScreen` ya no mantienen listas
  de módulos hardcodeadas. Componen tarjetas y navegación exclusivamente desde
  `GET /api/dashboard/funciones`.
- `abrirFuncionDashboard` resuelve las rutas del catálogo: mi información,
  asistente, paquetería (gestión vs. consulta según la acción resuelta),
  solicitudes, servicios, marketplace y módulos aún no implementados.
- `icono_funcion.dart` incorpora los íconos nuevos del catálogo.

### Red y errores

- Nuevo `core/network/api_client.dart`: envuelve `dio` y traduce
  `DioException` a `ApiException` (`core/errors/api_exception.dart`).
- Los DataSources usan `ApiClient`; los repositorios ya no importan `dio` ni
  leen `error.response`, solo traducen `ApiException` a `Failure`.

### Entidades y tenant

- `InstalacionExtra` dejó de exponer `Map<String, dynamic> atributos`; la
  entidad es pura y el DTO es la única capa que toca JSON.
- `ListarMisProyectosUseCase` se movió de la feature `superadmin` al dominio de
  `tenant`, quitando la dependencia Presentation → Superadmin.

## Verificación

- `dart analyze lib` y `dart analyze test`: sin issues.
- `flutter test`: **101 tests OK**.

## Pendientes / deuda documentada

- `Tenant` aún depende de `ProyectoDetalle` y `SuperadminRepositoryInterface`
  (dependencia entre features; conviene un repositorio propio de tenant).
- El dashboard de superadmin conserva sus dos accesos de gobierno de plataforma
  (proyectos/administradores), que no forman parte del catálogo de módulos.
- Las funciones aún no implementadas (gastos, control de acceso, reservas,
  alertas) navegan a rutas `/admin/modulos/...` que muestran "próximamente";
  sus pantallas reales quedan para las siguientes tareas.
- `setState` en formularios y diálogos se mantiene como estado local de UI.
