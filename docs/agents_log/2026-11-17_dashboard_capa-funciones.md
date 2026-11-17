# Capa de funciones del dashboard (Etapa 1)

- **Fecha:** 2026-11-17
- **Branch:** `feature/martin/modulos-dashboard-residente-conserje/2026-11-17`
- **Alcance:** A (lo nuevo nace con el contrato; dashboards existentes intactos)

## Contexto

Los dashboards de residente y conserje definen sus tarjetas en listas `_modulos...` dentro de cada pantalla. Cada módulo nuevo obliga a editar esas listas y sus guards. Se acordó que el dashboard pase a componerse desde un catálogo del backend, para que agregar una función no requiera tocar los dashboards.

Esta etapa entrega el consumo del catálogo y su presentación, sin montarlo todavía en ninguna pantalla.

## Cambios realizados

### Dominio

- `lib/features/dashboard/domain/entities/funcion_dashboard.dart`: entidad pura `FuncionDashboard` con `id`, `titulo`, `descripcion`, `icono`, `capacidades`, `ambito` y `ruta`; enum `AmbitoFuncion` con parser tolerante y getters `esDeProyecto`, `esDeUnidad`, `esPropia`.
- `lib/features/dashboard/domain/repositories/funciones_dashboard_repository.dart`: contrato `listarFunciones()`.
- `lib/features/dashboard/domain/usecases/obtener_funciones_dashboard_usecase.dart`.

### Datos

- `lib/features/dashboard/data/models/funcion_dashboard_dto.dart`: `fromJson` defensivo (`capacidades` puede no venir o no ser lista) y `toEntity()`.
- `lib/features/dashboard/data/datasources/funciones_dashboard_remote_data_source.dart`: único punto que usa `dio`, contra `AppConfig.dashboardFuncionesPath`.
- `lib/features/dashboard/data/repositories/funciones_dashboard_repository_impl.dart`: mismo mapeo de errores que el repositorio de módulos (404/422 con mensaje, 401, 403, formato inesperado).

### Presentación

- `lib/features/dashboard/presentation/bloc/funciones_dashboard_bloc.dart`: eventos `FuncionesSolicitadas` y `FuncionesRefrescadas`; estados `inicial`, `cargando`, `cargado`, `error`; en error conserva la lista previa para no vaciar la pantalla.
- `lib/features/dashboard/presentation/widgets/seccion_funciones_dashboard.dart`: widget reutilizable `SeccionFuncionesDashboard(bloc, onAbrir, titulo)`; dispara la carga en `initState`, no dibuja nada si no hay funciones, tarjetas de ancho acotado e iconografía por identificador.

### Configuración

- `lib/core/config/app_config.dart`: nueva constante `dashboardFuncionesPath`.

## Decisiones de diseño

1. **La sección se oculta cuando el catálogo está vacío.** Evita un bloque vacío en los dashboards actuales mientras no exista la primera función.
2. **El widget recibe el BLoC por parámetro** en vez de crearlo, para poder montarlo en dashboards distintos sin duplicar instancias ni estados.
3. **`onAbrir` es un callback de navegación.** La sección no conoce rutas ni el router; el dashboard decide qué hacer con cada función. Eso mantiene el widget libre de RBAC.
4. **Las capacidades no se evalúan en el cliente.** El backend ya filtró; el frontend solo muestra.

## Verificación

- `flutter analyze` sobre `lib/features/dashboard`, `test/features/dashboard` y `lib/core/config/app_config.dart`: sin issues.
- `flutter test` completo: **66 tests**, todos en verde.
- Tests nuevos: `funcion_dashboard_dto_test.dart` (3) y `funciones_dashboard_bloc_test.dart` (2).

## Pendientes

- Montar `SeccionFuncionesDashboard` en los dashboards de residente y conserje (Etapa 2), junto con el mapa función → ruta.
- El mapeo de iconos es una lista cerrada; si el catálogo crece, conviene moverlo a un mapa con fallback único.
- Falta el estado de "sin funciones" visible para administración: hoy solo se oculta.
