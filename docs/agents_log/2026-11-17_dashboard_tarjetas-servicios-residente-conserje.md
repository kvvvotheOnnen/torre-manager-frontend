# 2026-11-17 — Tarjeta de servicios y acceso desde residente y conserje

## Datos de la sesión

- **Fecha:** 2026-11-17
- **Branch:** `feature/martin/modulos-dashboard-residente-conserje/2026-11-17`
- **Alcance:** presentación del dashboard; sin cambios de contrato ni endpoints

## Contexto

La tarjeta de Servicios recomendados se veía distinta en residente y conserje que en el panel de
administración, y no aparecía en sus barras laterales. Además, la tarjeta del administrador usaba
el ícono genérico porque el mapa local no conocía el identificador del módulo.

## Cambios realizados

### 1. Tarjeta única

- Nuevo `TarjetaModuloDashboard` con la estructura de la tarjeta de administración: ícono de 32 px,
  título `titleMedium` en negrita y descripción de hasta tres líneas, con soporte para módulos no
  habilitados.
- `admin_dashboard_screen.dart` delega en la tarjeta común, por lo que su apariencia no cambió.
- Residente y conserje usan la misma tarjeta para las funciones del catálogo, sin ancho fijo.
- Se agrega `servicios_recomendados` al mapa de íconos del administrador (`handyman_outlined`).

### 2. Barra lateral

- Las barras laterales de residente y conserje leen `FuncionesDashboardBloc` y agregan las funciones
  dentro de la sección "Módulos" existente.
- Se evita duplicar una función si su identificador ya está en la lista fija de cada panel.
- El ítem cierra el drawer en móvil, marca la selección según la ruta actual y navega con
  `abrirFuncionDashboard`.

### 3. Limpieza

- Se elimina `seccion_funciones_dashboard.dart`, que había quedado sin uso al integrar las funciones
  en la grilla de cada dashboard.
- `iconoDeFuncion` se mueve a `icono_funcion.dart` para conservar el mapa de íconos del catálogo.

## Decisiones de diseño

1. **Una sola tarjeta para módulos y funciones:** evita que las dos vistas vuelvan a divergir.
2. **Barra lateral alimentada por el catálogo:** el cliente no hardcodea qué servicios existen; si
   el backend deja de devolver la función, el ítem desaparece.
3. **Sin cambios de autorización:** la visibilidad de crear, editar y eliminar sigue dependiendo de
   `acciones.gestionar`, que solo resuelve verdadero para administrador.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 77 pruebas existentes en verde (no se agregaron pruebas nuevas por indicación).
- `php -l config/funciones.php`: sin errores de sintaxis.

## Pendientes

- Prueba visual en dispositivo o navegador con las cuentas de residente y conserje.
- Migrar los módulos antiguos al contrato de funciones cuando corresponda.
