# Frontend — Eliminación de proyectos

- **Fecha:** 2026-11-04
- **Branch:** `dev`
- **Contexto:** El formulario de edición de proyectos del superadmin no permitía eliminar el proyecto. Se agregó un botón destructivo con confirmación reforzada.

## Cambios realizados

- Dominio:
  - `SuperadminRepositoryInterface`: nuevo método `eliminarProyecto(String id)`.
  - Nuevo `EliminarProyectoUseCase`.
- Datos:
  - `SuperadminRemoteDataSource.eliminarProyecto`: `DELETE` al endpoint del proyecto.
  - `SuperadminRepositoryImpl.eliminarProyecto`: envuelto en `_guard` para mapear fallos.
- BLoC:
  - Nuevo evento `ProyectoEliminado`.
  - Estado con `eliminando` y `proyectoEliminadoId`, incluidos en `copyWith` y `props`.
  - Handler que emite éxito/error y solicita recargar el listado.
  - Inyección del caso de uso en `main.dart` y en el fake de pruebas.
- UI (`proyectos_screen.dart`):
  - Botón `Eliminar proyecto` visible solo en modo edición, deshabilitado mientras se guarda o elimina.
  - Diálogo de confirmación que exige escribir el nombre exacto del proyecto para habilitar la acción.
  - Al completarse el borrado se cierra el formulario y se muestra el mensaje de éxito.
- Pruebas: casos de éxito y error de eliminación en el test del BLoC.

## Decisiones de diseño

- El borrado es irreversible y advierte en el diálogo que elimina estructura, accesorias, instalaciones extra y accesos de administradores.
- La confirmación por nombre exacto reduce el riesgo de eliminaciones accidentales.
- El formulario conserva el patrón existente: el BLoC centraliza la llamada y el listado se refresca con `ProyectosSolicitados`.
- No se requirió cambiar el enrutamiento ni `task.md`.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 21 tests aprobados, incluidos 2 nuevos de eliminación.

## Pendientes

- Verificación manual del flujo visual en dispositivo/emulador.
