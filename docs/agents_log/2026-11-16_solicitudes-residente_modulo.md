# Pantalla de gestión de residentes

- **Fecha:** 2026-11-16
- **Branch:** `feature/koke/gestion-residentes/2026-11-16`
- **Módulo:** Solicitudes de residente

## Contexto

El backend incorporó el módulo de solicitudes de residentes. En Flutter se agregó la
pantalla para que administradores y conserjes aprueben o rechacen solicitudes y consulten
el historial de las últimas 100 decisiones.

## Cambios realizados

- Feature `solicitudes_residente` con entidades, repositorio, casos de uso, DTOs,
  datasource, repositorio de datos y BLoC.
- Pantalla responsive de gestión:
  - Sidebar de pendientes/historial en escritorio y selector segmentado en móvil.
  - Lista de cards con persona principal, RUT, unidad, tipo y estado.
  - Detalle con personas, contacto de emergencia e instalaciones de la unidad.
  - Aceptar con confirmación “¿Verificaste la información?”.
  - Rechazar con motivo obligatorio y opción de cancelar.
  - Historial con estado y motivo de rechazo.
- Rutas y guardas: acceso solo para administrador, conserje y superadmin.
- El dashboard de administrador abre la pantalla real para `solicitudes_residente`.
- El dashboard de conserje incluye la entrada al módulo.
- Inyección del datasource, repositorio, casos de uso y BLoC en `main.dart`.

## Decisiones de diseño

- La lista de pendientes ya incluye personas e instalaciones, por lo que el detalle se
  muestra sin una llamada adicional.
- Tras aprobar o rechazar, la solicitud se mueve al historial local y se muestra un
  mensaje de confirmación.
- Se reutiliza el patrón de BLoC con estados de carga, guardado y error del resto de la app.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 61 pruebas, todas pasan.
- Pruebas nuevas de DTO y BLoC para carga, aprobación y rechazo.

## Pendientes

- Wizard de registro de residente (Task 12).
- Mostrar el motivo del rechazo al residente en su pantalla de espera.
