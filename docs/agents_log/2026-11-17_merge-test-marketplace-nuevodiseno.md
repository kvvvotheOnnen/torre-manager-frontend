# Integración de marketplace y servicios al rediseño (rama de prueba)

- **Fecha:** 2026-11-17
- **Branch:** `merge-test-marketplace-nuevodiseño`
- **Repositorios:** `torre_manager_frontend` y `torre-manager-backend`

## Contexto

Se integra la rama `feature/martin/marketplace/2026-11-17` sobre
`feature/koke/propuesta-diseno/2026-11-17` en una rama aislada de prueba, para
validar la convivencia del marketplace y el directorio de servicios con el
rediseño visual y los cambios recientes de solicitudes y asistente.

## Cambios realizados

- Backend: merge sin conflictos de la rama de marketplace (funciones de
  dashboard, servicios, marketplace, archivos y capacidades). Se aplicaron las
  migraciones nuevas, los seeders de trabajadores y marketplace, y el enlace
  público de almacenamiento.
- Se adaptaron tres tests de la rama integrada para el modelo de usuario actual
  (sin columna `estado`).
- Frontend: merge con 14 conflictos resueltos conservando el rediseño:
  - `main.dart`: se agregaron `FuncionesDashboardBloc`, `ServiciosBloc` y
    `MarketplaceBloc` manteniendo tema, solicitudes y asistente.
  - Dashboards de administrador, conserje y residente: se mantuvo `AppShell` y
    `ModuleCard`; las funciones del backend se incorporaron como tarjetas e
    ítems de navegación.
  - Rutas nuevas envueltas en `AppTitle`.
- Marketplace y Servicios se adaptaron al estilo del rediseño con `AppShell`,
  `AppScrollView`, `SectionHeader`, `GlassCard`, `AppEmptyState`, `StatusPill`
  y `ModuleCard`. Las tarjetas de publicación y trabajador usan `GlassCard`.
- No se modificó la lógica de negocio de marketplace ni de servicios.

## Decisiones de diseño

- El rediseño es la base visual; la rama de marketplace se adapta a él y no al
  revés.
- La rama de prueba es desechable: las ramas originales permanecen intactas.
- Se priorizó reutilizar los widgets del tema en lugar de introducir variantes
  nuevas por pantalla.

## Verificación

- Frontend: `flutter analyze` sin issues y 102 tests aprobados.
- Backend: 160 tests aprobados. `pint` pasa en los archivos tocados por la
  integración; persisten avisos de formato previos en archivos de Superadmin
  ajenos a este cambio.
- Smoke de endpoints: `/api/dashboard/funciones`, `/api/servicios` y
  `/api/marketplace/publicaciones` responden 200 para administrador, residente
  y conserje.

## Pendientes

- Prueba visual manual en web y móvil (tema claro/oscuro y breakpoints).
- Validar la subida de imágenes en un entorno desplegado.
- Si la integración se aprueba, definir qué rama pasa a ser la base definitiva.
