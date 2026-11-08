# Módulos operativos generales en dashboard

- **Fecha:** 2026-11-06
- **Branch:** `feature/koke/dashboard-admin/2026-11-06`
- **Contexto:** El dashboard de administrador mostraba bloqueados paquetería, instalaciones extra, gastos comunes y control de acceso.

## Cambios realizados

- `ModuloSistema` quedó reducido a `infraestructura`.
- `ProyectoDetalleDTO` ahora ignora IDs de módulos que ya no son configurables, como `paqueteria`, `quincho`, `gastos_comunes` y `control_acceso`.
- El dashboard admin consume desde backend los nuevos módulos globales habilitados:
  - Paquetería
  - Instalaciones extra
  - Gastos comunes
  - Control de acceso
- Se renombró visualmente `quincho` por `instalaciones_extra` en el mapa de iconos.
- Se ocultan las secciones vacías del sidebar para no mostrar “Módulos del proyecto” cuando no existen módulos configurables.
- Se actualizaron pruebas del dashboard, DTO y BLoC.

## Resultado

- El administrador ve Paquetería, Instalaciones extra, Gastos comunes y Control de acceso siempre habilitados.
- Infraestructura sigue sin aparecer en el dashboard de administrador.
- El wizard de proyectos conserva el paso de módulos con Infraestructura.

## Verificación

- `flutter analyze`: sin problemas.
- `flutter test`: 38 tests aprobados.

## Nota

Infraestructura permanece visible e interactuable solo para superadmin.
