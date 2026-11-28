# Notificaciones in-app — Fase 0 (campanita y bandeja, frontend)

- **Fecha:** 2026-11-25
- **Branch:** `feature/martin/control-acceso-notificaciones/2026-11-24`
- **Repositorio:** `torre_manager_frontend`

## Contexto

Con la base de notificaciones ya disponible en el backend, se implementa en el
cliente la campanita con contador de no leídas y la bandeja con historial. Las
notificaciones son solo in-app: el envío por correo se incorporará más adelante,
cuando exista la infraestructura.

## Cambios realizados

- Feature `notificaciones` completa siguiendo la arquitectura del proyecto:
  - Dominio: entidad `Notificacion`, contrato del repositorio y casos de uso para
    listar, contar no leídas, marcar una y marcar todas.
  - Datos: DTO, fuente de datos remota sobre `ApiClient` y repositorio con el
    manejo de errores habitual.
  - Presentación: `NotificacionesBloc` y pantalla de bandeja.
- Bloc con refresco silencioso cada 30 segundos y limpieza al cerrar sesión.
- Pantalla `NotificacionesScreen`: historial con las no leídas resaltadas, toque
  para marcar como leída, acción "Marcar todas" y estados vacío/error.
- Rutas y constantes: `AppRoutes.notificaciones` (`/notificaciones`) y los paths
  de API correspondientes en `AppConfig`.
- `main.dart`: construcción del datasource, repositorio y bloc; carga al iniciar
  sesión (salvo superadmin) y limpieza al salir.
- Dashboards de administrador, conserje y residente: la campanita abre la
  bandeja y muestra el contador real de no leídas; se elimina el acceso al estado
  "próximamente".
- Prueba del dashboard de administrador actualizada con un repositorio falso y el
  proveedor del nuevo bloc.

## Decisiones de diseño

- El contador sale del estado del bloc, por lo que el badge se actualiza al
  entrar y mientras se navega sin recargar la pantalla.
- El refresco periódico es silencioso: no muestra indicadores de carga ni
  mensajes de error para no interrumpir la navegación.
- Marcar como leída actualiza el elemento y descuenta el contador en memoria, sin
  recargar la lista completa.
- Se reutiliza el botón de notificaciones existente del `AppTopBar`; no se
  modificó el componente compartido.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 110 pruebas aprobadas.

## Ajuste posterior: carga tras resolver el tenant

- `NotificacionesSolicitadas` ya no se dispara en `AuthSuccess`: se dispara
  cuando `TenantBloc` queda en estado `listo` con `proyectoActivoId`, de modo que
  el interceptor de `dio` ya envía `X-Proyecto-Id`.
- También recarga la bandeja al cambiar de proyecto.

## Ajuste posterior: navegación al módulo desde la notificación

- Al tocar una notificación se marca como leída y se abre el módulo de origen:
  paquetería y recordatorios van a `/paqueteria` o `/paqueteria/gestion` según
  el rol; marketplace a `/marketplace`; servicios a `/servicios`.
- Verificación: `flutter analyze` sin issues; `flutter test` 110/110.

## Ajuste posterior: bandeja como ventana emergente

- La campanita ya no navega a una pantalla completa: abre `NotificacionesDialog`,
  un diálogo centrado con ancho máximo de 560 px y alto máximo del 80% de la
  pantalla, borde redondeado y lista con scroll para cuando hay muchas
  notificaciones.
- El diálogo reutiliza `NotificacionesLista` con la misma tarjeta de la pantalla
  completa; al tocar una notificación se marca leída, se cierra el diálogo y se
  abre el módulo de origen.
- El encabezado del diálogo concentra "Marcar todas" y el botón de cierre; la
  ruta `/notificaciones` se conserva por si se necesita enlazar la pantalla.
- Los tres dashboards (administrador, conserje y residente) invocan
  `NotificacionesDialog.mostrar(context)` desde el ícono de campanita.
- Verificación: `flutter analyze` sin issues; `flutter test` 110/110.

## Ajuste posterior: notificaciones de servicios, solicitudes y acceso

- `_rutaPara` reconoce el tipo `solicitudes`: si el usuario es residente o
  propietario abre `/solicitud-pendiente`; para el staff no hay pantalla y la
  notificación solo se marca como leída.
- Los tipos `servicios` y `marketplace` ya abrían su módulo; `acceso` no tiene
  pantalla propia por ahora.
- Verificación: `flutter analyze` sin issues; `flutter test` 110/110.

## Pendientes

- Listeners por módulo en el backend para que lleguen avisos reales.
- Prueba manual en la app con cambio de usuario y refresco del badge.
- Push/FCM para actualización en tiempo real (hoy polling cada 30 segundos) y
  correo cuando la infraestructura esté lista.
