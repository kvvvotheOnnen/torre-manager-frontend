# Restricción de infraestructura en dashboard de administrador

- **Fecha:** 2026-11-06
- **Branch:** `feature/koke/dashboard-admin/2026-11-06`
- **Contexto:** Corrección de seguridad: el dashboard de administrador mostraba y permitía navegar a Infraestructura.

## Cambios realizados

- Se renombró la ruta de `/admin/infraestructura` a `/superadmin/infraestructura`.
- La ruta quedó protegida por la validación de rutas `/superadmin`, accesible solo para superadmin.
- Se eliminó Infraestructura del mapa de rutas e iconos del dashboard de administrador.
- Se eliminó el código legado que declaraba Infraestructura como módulo del administrador.
- `ModulosDashboardBloc` filtra defensivamente cualquier módulo `infraestructura` recibido desde backend.
- Se ajustaron las pruebas:
  - el dashboard admin no muestra Infraestructura aun si el backend la envía;
  - el BLoC descarta Infraestructura;
  - se mantiene la cobertura de módulos generales y bloqueados.

## Decisiones de diseño

- El dashboard de superadmin no se modifica.
- La pantalla de infraestructura conserva su ruta directa bajo `/superadmin`, pero no se enlaza desde el dashboard de administrador.
- Los módulos generales y configurables siguen viniendo del catálogo backend.

## Verificación

- `flutter analyze`: sin problemas.
- `flutter test`: 37 tests aprobados.

## Pendientes

- Implementación futura de las pantallas reales de los módulos generales.
