# 2026-11-20 — Crear administrador anexado a proyectos

## Contexto

- **Branch:** `feature/koke/cambios-en-creacion-de-administrador/20-11-2026`
- El diálogo "Nuevo administrador" solo pedía nombre, correo y contraseña.

## Cambios realizados

- Entidades `ProyectoAdministrador` y `Administrador` con `proyectos`.
- `AdministradorDTO` parsea la nueva lista `proyectos` (tolerante a ausencia).
- Cadena de creación: `AdministradorCreado.proyectoIds` → use case →
  repositorio → datasource (`proyecto_ids` en el payload).
- Diálogo "Nuevo administrador":
  - sección "Proyectos (opcional)" con checkboxes múltiples desde
    `SuperadminBloc.state.proyectos` (dispara `ProyectosSolicitados` al abrir);
  - sin selección la cuenta se crea como antes.
- Listado de administradores: muestra el correo y los proyectos asignados, o
  "Sin proyecto asignado".

## Verificación

- `dart analyze lib test`: sin issues.
- `flutter test`: **109 tests OK**.
- Tests nuevos: `administrador_dto_test.dart` (parseo de proyectos) y
  `administradores_bloc_test.dart` (propagación de `proyectoIds`).

## Pendientes

- Si se requiere editar la pertenencia del admin después, reutilizar la edición
  de proyecto o crear endpoints de membresía dedicados.
