# Bitácora — Fase 2: Creación de Proyectos y Asignación (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** Fase 2 del modelo SaaS multi-tenant.

## Cambios realizados

- **Dominio** (`features/superadmin/domain`): enums `TipoCondominio` y `ModuloSistema` (con valor de API y etiqueta), entidades `InstalacionExtra` y `ProyectoDetalle`; método `crearProyecto(...)` en el repositorio y `CrearProyectoUseCase` (valida nombre, al menos un módulo y al menos un administrador).
- **Datos**: `ProyectoDetalleDTO`/`InstalacionExtraDTO`; DataSource `crearProyecto` (`POST /api/superadmin/proyectos`) y `listarMisProyectos` (`GET /api/mis-proyectos`, para la Fase 3); repositorio con `_guard` (409/422 → `ValidationFailure`, 404 → mensaje del backend).
- **Presentación**: `SuperadminBloc` extendido con el evento `ProyectoCreado`; `ProyectosScreen` ahora tiene FAB "Proyecto" que abre una pantalla de formulario con: nombre, descripción, `SegmentedButton` de tipo de condominio, switches de módulos, lista dinámica de instalaciones extra (nombre + tipo) y checklist de administradores existentes (cargados vía `AdministradoresBloc`). Botón "Crear proyecto" con estado de guardado.
- DI en `main.dart`.

## Decisiones de diseño

- El formulario usa los administradores reales (`GET /api/superadmin/administradores`) para el selector, evitando IDs manuales.
- La lista dinámica de instalaciones extra envía solo las que tienen nombre, con tipo opcional.

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 4 passed.
- Prueba manual: login superadmin → "Gestión de Proyectos" → FAB → completar formulario (tipo Casas, módulos, instalación "Quincho", 1 administrador) → el proyecto aparece en el listado y en la API.

## Pendientes

- Fase 3 (enrutamiento multi-tenant del administrador).
