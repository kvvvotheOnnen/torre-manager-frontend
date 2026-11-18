# Pantalla de gestión de residentes y espera de aprobación

- **Fecha:** 2026-11-16
- **Branch:** `feature/koke/gestion-residentes/2026-11-16`
- **Módulo:** Solicitudes de residente

## Contexto

El backend incorporó el módulo de solicitudes de residentes. La aprobación anexa a un
usuario existente a una unidad y le otorga acceso al dashboard. La creación de cuentas
no forma parte de esta task.

## Cambios realizados

- Feature `solicitudes_residente` con entidades, repositorio, casos de uso, DTOs,
  datasource, repositorio de datos y BLoC.
- Pantalla responsive de gestión para administrador y conserje:
  - Buscador que filtra por nombre, RUT, correo, teléfono, emergencia, unidad,
    agrupación, tipo, estado, origen, motivo, decisores, fechas e instalaciones.
  - Búsqueda por múltiples términos y sin distinguir mayúsculas ni acentos.
  - Sidebar de pendientes/historial en escritorio y selector segmentado en móvil.
  - Lista de cards con persona principal, RUT, unidad, tipo y estado.
  - Detalle con personas, contacto de emergencia e instalaciones de la unidad.
  - Aceptar con confirmación y rechazar con motivo obligatorio.
  - Historial con estado y motivo de rechazo.
- Pantalla “Mi solicitud” para usuarios sin acceso al dashboard:
  - Muestra “Estamos revisando su solicitud” cuando está pendiente.
  - Muestra el motivo cuando fue rechazada.
  - Permite refrescar y cerrar sesión.
  - Avisa cuando la solicitud fue aprobada para recargar el acceso.
- BLoC y caso de uso para consultar `GET /api/mis-solicitudes-residentes`.
- Router:
  - Acceso a gestión solo para administrador, conserje y superadmin.
  - Si un residente/propietario no tiene proyectos aprobados, se redirige a
    `/solicitud-pendiente` y no puede entrar al dashboard.
  - Cuando la aprobación crea el proyecto, el dashboard queda disponible.
- Dashboard de administrador abre la pantalla real del módulo.
- Dashboard de conserje incluye la entrada al módulo.
- Inyección de datasource, repositorio, casos de uso y BLoCs en `main.dart`.

## Decisiones de diseño

- La lista de pendientes ya incluye personas e instalaciones; el detalle no requiere una
  llamada adicional.
- Tras aprobar o rechazar, la solicitud se mueve al historial local y se muestra un
  mensaje de confirmación.
- El residente pendiente conserva su sesión y ve su estado, sin acceso al dashboard.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 62 pruebas, todas pasan.
- Tests nuevos de DTO, BLoC de gestión, BLoC de solicitud propia y utilidad de búsqueda.

## Pendientes

- Flujo de registro y creación de cuentas en otra task.
- Mostrar el motivo del rechazo también en otras pantallas del residente.
