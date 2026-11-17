# 2026-11-17 — Pantalla de servicios recomendados y sección de funciones

## Datos de la sesión

- **Fecha:** 2026-11-17
- **Branch:** `feature/martin/modulos-dashboard-residente-conserje/2026-11-17`
- **Base:** commits de gestión de residentes (no se modificó `dev`)
- **Alcance:** solo módulos nuevos; los módulos existentes conservan su autorización actual

## Contexto

El backend ya expone el catálogo de funciones con sus acciones resueltas y el módulo de servicios
recomendados. Falta que el cliente consuma el catálogo, muestre la nueva función en los dashboards
de residente y conserje, y permita al administrador gestionar los trabajadores.

## Cambios realizados

### 1. Modelo de funciones con acciones

- `FuncionDashboard` incorpora `Map<String, bool> acciones` y el método `puede(String)`.
- El DTO normaliza el mapa y tolera respuestas sin acciones o mal formadas.
- Pruebas nuevas de mapeo y de tolerancia.

### 2. Feature `servicios`

- Dominio: `TrabajadorServicio`, `TipoServicio` (seis tipos con etiqueta) y `TrabajadorServicioFoto`.
- Datos: DTO, datasource con multipart para la imagen y repositorio con el mismo mapeo de errores que paquetería.
- Casos de uso: listar, crear, actualizar y eliminar.
- BLoC con filtros por tipo y búsqueda, estado de guardado, mensajes y recarga tras cada cambio.
- Pantalla `/servicios`: buscador, chips de filtro, grilla responsiva y tarjetas con imagen 16:9 o recuadro "Sin imagen".
- El botón de agregar y las acciones de editar/eliminar solo aparecen si la función informa `acciones.gestionar`.
- Formulario en diálogo con validaciones, selector de tipo y carga de imagen desde la galería.

### 3. Integración con los dashboards

- `SeccionFuncionesDashboard` montada al final de los dashboards de residente y conserje; las tarjetas existentes no se modificaron.
- `abrirFuncionDashboard` traduce la ruta de la función a su pantalla y avisa "próximamente" si aún no existe.
- `FuncionesDashboardBloc` y `ServiciosBloc` instanciados en `main.dart`, con su cierre en `dispose`.
- Nuevos valores en `AppRoutes`, `AppConfig` y el mapa de iconos (`handyman`).
- La tarjeta del dashboard de administración abre la misma pantalla mediante `/admin/modulos/servicios_recomendados`.

## Decisiones de diseño

1. **El cliente no conoce roles:** la visibilidad de acciones viene resuelta desde el catálogo.
2. **Sección al final del dashboard** en lugar de reescribir las tarjetas existentes: las funciones futuras aparecen sin volver a tocar esos archivos.
3. **Una sola pantalla con filtros locales al servidor** para mantener el listado pequeño y consistente con el aislamiento por proyecto.
4. **Imagen opcional con recuadro explícito** cuando no existe, tal como se pidió.
5. **Formulario en diálogo** siguiendo el patrón ya usado en paquetería.

## Verificación

- `flutter analyze` sobre los archivos tocados: sin observaciones.
- `flutter test test/features/servicios`: 8 pruebas en verde.
- `flutter test` completo: 76 pruebas en verde.

## Pendientes

- Prueba visual en dispositivo o emulador de la grilla y del formulario con imagen.
- Revisar el comportamiento del selector de imagen en web.
- Los módulos antiguos siguen con autorización por rol; migrarlos al contrato es una tarea aparte.
