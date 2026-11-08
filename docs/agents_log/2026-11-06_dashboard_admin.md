# Dashboard de administrador - UI responsive y módulos backend

- **Fecha:** 2026-11-06
- **Branch:** `feature/koke/dashboard-admin/2026-11-06`
- **Contexto:** Task 9, dashboard de administrador con selector de proyecto, sidebar de módulos y vistas móvil/desktop.

## Cambios realizados

- Se agregó la capa Data de `dashboard`: DataSource, DTO, repositorio.
- Se agregó la capa Domain de `dashboard`: entidad `ModuloDashboard`, repositorio y caso de uso.
- Se agregó `ModulosDashboardBloc` para cargar y recargar los módulos desde el backend.
- Se agregó `AdminDashboardScreen` con:
  - panel superior con nombre del usuario, selector de proyecto y cierre de sesión;
  - sidebar en desktop y drawer en móvil;
  - agrupación visual de módulos del proyecto y módulos generales;
  - módulos deshabilitados visibles, bloqueados y sin navegación;
  - carga de módulos al iniciar y al cambiar de proyecto activo;
  - manejo de estados de carga, error, reintento y ausencia de proyectos.
- Se mantuvo el dashboard de superadmin sin cambios funcionales; `DashboardScreen` deriva al administrador a la nueva pantalla.
- Se agregó la ruta `/admin/modulos/:id` y la pantalla genérica `ModuloProximamenteScreen`.
- Se agregó el endpoint de catálogo en `AppConfig`.
- Se registraron los nuevos repositorios, caso de uso y BLoC en `main.dart`.
- Se agregaron pruebas de DTO, BLoC y widget para desktop y móvil.

## Decisiones de diseño

- El catálogo de módulos se consume desde backend; el frontend solo aporta iconos y rutas de presentación.
- Los módulos desconocidos que lleguen desde backend se muestran con icono genérico y abren una vista de “Próximamente”, permitiendo agregar módulos globales sin romper la UI.
- Los módulos configurables bloqueados se muestran con candado y un mensaje de no habilitado.
- El cambio de proyecto usa el `TenantBloc` existente y dispara una recarga de módulos.

## Verificación

- `flutter analyze`: sin problemas.
- `flutter test`: 37 tests aprobados.

## Pendientes

- Implementar las pantallas reales de los módulos generales.
- Añadir la validación backend de módulo habilitado cuando esos módulos expongan endpoints.
