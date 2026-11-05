# Bitácora — Visor de estructura de proyecto (Frontend)

- **Fecha:** 2026-10-27
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** En el modo edición de "Gestión de Proyectos" la estructura del recinto solo mostraba una nota que remitía al módulo Infraestructura. Se agregó un visor inline de solo lectura con la estructura completa del proyecto.

## Cambios realizados

- `InfraestructuraRemoteDataSource.obtenerArbol`: recibe `proyectoId` y lo envía como query param `proyecto_id`.
- `InfraestructuraRepositoryImpl.obtenerArbol`: propaga `proyectoId` al datasource.
- `SuperadminBloc`: nueva dependencia `ObtenerArbolInfraestructuraUseCase`, evento `EstructuraProyectoSolicitada` y campos de estado `estructura`, `cargandoEstructura` y `errorEstructura`.
- `ProyectosScreen`: al abrir la edición solicita detalle y estructura; en la sección "Estructura del recinto" muestra resumen de conteos y un `ExpansionTile` por agrupación con sus unidades y accesorias asignadas.
- Estados del visor: carga, error con botón "Reintentar", estructura vacía y datos.
- `main.dart`: inyección del caso de uso de estructura reutilizando el repositorio de infraestructura existente.

## Decisiones de diseño

- Se reutiliza el endpoint existente `GET /api/infraestructura/arbol` con `proyecto_id`, soportado por el backend para superadmin.
- El visor es inline, dentro del formulario de edición, y permanece colapsado por agrupación para no saturar la pantalla.
- Las agrupaciones y unidades no son editables desde este apartado.
- El detalle y la estructura se cargan en eventos separados, de modo que un fallo de la estructura no bloquea el formulario ni la edición de los demás campos.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 13 passed, incluyendo carga y error de estructura en `superadmin_bloc_edicion_test.dart`.

## Pendientes

- Task 3: creación masiva de estacionamientos y bodegas desde la creación/edición de proyecto.
- El árbol muestra solo las unidades accesorias asignadas a una unidad principal; las no asignadas no aparecen en este visor.
