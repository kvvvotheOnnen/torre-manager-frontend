# Integración del rediseño "Arquitectura Nocturna" con la rama de gestión de residentes

- **Fecha:** 2026-11-17
- **Branch:** `feature/koke/propuesta-diseno/2026-11-17`
- **Repositorio:** `torre_manager_frontend` (sin cambios en backend)

## Contexto

La rama `feature/newdesign/koke/14-11-2026` contenía un único commit con un rediseño visual completo
(tema, tipografía, widgets compartidos, shells, login y dashboards). Estaba basada en un punto anterior
del proyecto y no incluía los cambios funcionales posteriores (propietario, solicitudes de residente,
tenant por rol activo, RUT/datos personales).

El objetivo fue crear una rama nueva que combine el rediseño con el estado más reciente del frontend,
dejando el backend intacto por tratarse de una reestructuración de presentación.

## Cambios realizados

1. Se creó `feature/koke/propuesta-diseno/2026-11-17` desde el último commit de
   `feature/koke/gestion-residentes/2026-11-16`.
2. Se fusionó `feature/newdesign/koke/14-11-2026` (`a6ccaa2`).
3. Se resolvieron los conflictos tomando el rediseño como base visual y re-aplicando los cambios
   funcionales recientes:
   - `lib/main.dart`: se conservó el tema/`ThemeModeController`/precarga de tipografía del rediseño y se
     reincorporaron `SolicitudesResidenteBloc`, `MiSolicitudResidenteBloc`, el enrutamiento tenant para
     todos los roles con proyecto y el cierre de blocs en `dispose`.
   - `lib/core/router/app_router.dart`: se mantuvieron los `AppTitle` del rediseño junto con
     `rolActivo`, `Rol.propietario`, las rutas `solicitudesResidente` y `solicitudPendiente` y las
     reglas de tenant (`inicial`, `cargando`, `seleccionPendiente`, `sinProyectos`).
   - `dashboard_screen.dart`: se usa `rolActivo` desde `TenantBloc`, se agregó `Rol.propietario` al
     `switch` y el propietario se dirige al dashboard de residente.
   - `admin_dashboard_screen.dart`: `_rutaPara` conserva el caso especial de `solicitudes_residente`.
   - `conserje_dashboard_screen.dart`: se agregó la tarjeta "Gestión de residentes" al listado.
   - `resident_dashboard_screen.dart`: el título cambia a "Panel de propietario" cuando corresponde.
4. Se aplicó el stash con los cambios pendientes del módulo "mi solicitud" (endpoint
   `mis-solicitudes-residentes`, pantalla de solicitud pendiente, usecase, bloc y tests).

## Decisiones de diseño

- La integración es exclusivamente de frontend: no se modificaron endpoints, DTOs de red ni contratos
  con la API.
- Se priorizó el rediseño en los archivos puramente visuales (tema, widgets, login, selector de
  proyecto, assets web y `modulo_proximamente`) y se re-aplicó el comportamiento funcional encima.
- Se mantuvo el formato de rama exigido por `AGENTS.md` en lugar del nombre literal con tilde.

## Verificación

- `flutter pub get`: correcto (incluye la nueva dependencia `google_fonts`).
- `flutter analyze`: sin issues.
- `flutter test`: 67 pruebas aprobadas.

## Pendientes

- Validación visual manual en web y móvil (claro/oscuro, breakpoints de dashboards y selector de
  proyecto).
- Revisar el comportamiento de carga de `google_fonts` en entornos con red restringida.
- Push manual de la rama cuando el equipo lo autorice.
