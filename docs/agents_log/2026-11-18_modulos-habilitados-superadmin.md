# 2026-11-18 — Edición de proyecto con todos los módulos y switches

## Datos de la sesión

- **Fecha:** 2026-11-18
- **Branch:** `feature/koke/correcion-modulos-habilitados/18-11-2026`
- **Base:** `merge-test-marketplace-nuevodiseño`
- **Alcance:** pantalla "Editar proyecto" del superadmin

## Contexto

La pantalla de edición solo mostraba los módulos configurables
(`infraestructura`). El superadmin necesita ver y alternar todos los módulos de
la plataforma, incluidos los globales, con un switch por módulo.

El backend incorpora `modulos_deshabilitados` (IDs de módulos globales apagados
para el proyecto). El cliente debe leerlo, precargar los switches y enviarlo al
actualizar.

## Cambios realizados

### 1. Dominio

- Nuevo enum `ModuloGeneral` con los 13 módulos globales, su valor de API y su
  etiqueta, más el helper `moduloGeneralFromString`.
- `ProyectoDetalle` agrega `modulosDeshabilitados` (`List<ModuloGeneral>`).

### 2. Datos

- `ProyectoDetalleDTO` parsea `modulos_deshabilitados` y descarta IDs
  desconocidos al mapear a entidad.
- `SuperadminRemoteDataSource.actualizarProyecto` envía
  `modulos_deshabilitados` en el `PUT`.
- `SuperadminRepositoryInterface` y su implementación incorporan el parámetro.

### 3. Aplicación y presentación

- `ActualizarProyectoUseCase` y el evento `ProyectoActualizado` transportan la
  lista.
- La pantalla de edición (`proyectos_screen.dart`) precarga los
  deshabilitados y muestra, bajo "Módulos globales", un `SwitchListTile` por
  cada `ModuloGeneral`: activo significa habilitado, apagado agrega el ID a la
  lista enviada.
- El switch de `infraestructura` conserva la regla de al menos un módulo
  configurable.

## Decisiones de diseño

1. **Switch semánticamente positivo**: la UI muestra "habilitado"; el payload
   envía la lista de deshabilitados, alineado con la columna del backend.
2. **Enum local espejo del catálogo backend**: sin hardcodear roles ni listas
   por rol; solo valores de API y etiquetas.
3. **DTO con tolerancia**: IDs desconocidos en `modulos_deshabilitados` se
   ignoran para no romper con respuestas antiguas o futuras.

## Verificación

- `flutter analyze`: sin problemas.
- `flutter test`: 104 pruebas, todas en verde.
- Nuevas pruebas de DTO para `modulos_deshabilitados` (parseo y ausencia).

## Pendientes

- Los endpoints operativos de módulos globales aún no validan el estado del
  módulo; deshabilitar solo oculta la tarjeta/función en el dashboard.
- Sincronizar el `AGENTS.md` maestro con ambos repositorios (realizado).
