# Flujo de aprobación de publicaciones del marketplace (frontend)

- **Fecha:** 2026-11-25
- **Branch:** `feature/martin/control-acceso-notificaciones/2026-11-24`
- **Repositorio:** `torre_manager_frontend`
- **Módulo:** Marketplace / Solicitudes de publicación

## Contexto

El backend pasó a crear las publicaciones de residentes en estado pendiente, con
un espacio de solicitudes para conserje y administrador. El cliente debía mostrar
esa bandeja con el número de pendientes, permitir aprobar o rechazar con motivo,
y que el dueño vea el estado y el motivo del rechazo.

## Cambios realizados

### Dominio

- `EstadoPublicacion`: nuevos valores `pendiente` y `rechazada`, con getters
  `esPendiente` y `esRechazada`.
- `PublicacionMarketplace`: campos `motivoRechazo` y `rechazadoEn`, getter
  `esPendiente`.
- Nueva entidad `SolicitudesMarketplace` (pendientes + solicitudes).
- Nuevos casos de uso: `ListarSolicitudesUseCase`,
  `AprobarSolicitudMarketplaceUseCase`, `RechazarSolicitudMarketplaceUseCase`.

### Datos

- `PublicacionMarketplaceDto`: lee `motivo_rechazo` y `rechazado_en`.
- Nuevo `SolicitudesMarketplaceDto` con `fromJson` y `toEntity`.
- `MarketplaceRemoteDataSource`: métodos `solicitudes`, `aprobar` y `rechazar`.
- `MarketplaceRepositoryInterface` e implementación: `solicitudes`,
  `aprobarSolicitud`, `rechazarSolicitud`, con el manejo de errores habitual.

### Presentación

- `MarketplaceBloc`: vista `solicitudes`, eventos `SolicitudAprobadaSolicitada` y
  `SolicitudRechazadaSolicitada`, campo `pendientes` en el estado, carga
  específica de la bandeja y actualización del contador al aprobar o rechazar.
- `MarketplaceScreen`: pestaña "Solicitudes" con badge de pendientes para quien
  tiene `aprobar`; acciones aprobar/rechazar en las tarjetas; estados vacíos
  propios de la bandeja; mensaje "Publicación enviada a revisión." al crear una
  publicación que nace pendiente.
- `PublicacionCard`: acciones opcionales Aprobar/Rechazar y colores de estado
  para pendiente y rechazada.
- `PublicacionDetalleDialog`: muestra el motivo del rechazo y la fecha.
- Nuevo `RechazarSolicitudDialog` con motivo obligatorio (5 a 500 caracteres).

### Ajustes

- Se agregó la acción `aprobar` al catálogo de funciones en backend
  (`config/funciones.php`) para que la pestaña se muestre por capacidad.
- `main.dart`: se conectan los tres casos de uso nuevos al `MarketplaceBloc`.

## Decisiones de diseño

- La pestaña de solicitudes se muestra por la capacidad `aprobar`, no por rol:
  conserje y administrador la ven, el residente no.
- El badge usa `Badge.count` sobre el icono, igual que la campanita.
- El residente conserva la publicación rechazada en Mis publicaciones con su
  motivo; no se reabre la edición, debe publicar una nueva.
- Se mantuvo el patrón de datos del feature (DTO y datasource) sin tocar la
  entidad existente más allá de los dos campos nuevos.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 110 pruebas aprobadas.
- Backend asociado: 192 pruebas aprobadas.

## Ajuste posterior: reposición tras pérdida del working tree

- Se detectó que la capa de presentación y datos del flujo no estaba en disco:
  el bloc, la pantalla, la tarjeta, el detalle, el datasource, el repositorio y
  el wiring de `main.dart` habían desaparecido del árbol de trabajo, junto con
  esta bitácora. El backend y sus pruebas no se vieron afectados.
- Se reescribieron los archivos faltantes, incluido el nuevo
  `SolicitudesMarketplaceDto`, y se restituyeron los cuatro tests del bloc.
- Se resolvió una colisión de nombres: los casos de uso de marketplace se
  llaman `AprobarSolicitudMarketplaceUseCase` y
  `RechazarSolicitudMarketplaceUseCase` para no chocar con los de solicitudes
  de residente.
- Verificación tras la reposición: `flutter analyze` sin issues y
  `flutter test` con 110 pruebas aprobadas.

## Ajuste posterior: contador visible al entrar y navegación de conserje

- El badge de pendientes solo se cargaba al abrir la pestaña Solicitudes. Se
  agregó el evento `ContadorSolicitudesSolicitado`, que consulta el conteo de
  forma silenciosa al entrar al módulo cuando el usuario tiene la acción
  `aprobar` (en `initState` y al resolverse las funciones del dashboard).
- La pestaña "Catálogo" ahora se muestra a todo usuario sin gestión de admin,
  para que el conserje pueda volver desde Solicitudes.
- Verificación: `flutter analyze` sin issues y `flutter test` con 110 pruebas
  aprobadas.

## Pendientes

- Prueba manual en la app (reinicio completo, no hot reload) del flujo completo:
  residente publica, conserje ve el badge, aprueba o rechaza con motivo, el
  residente ve el estado.
- Notificar al dueño cuando el módulo de notificaciones vuelva a implementarse.
- Evaluar un flujo de reenvío para publicaciones rechazadas.
