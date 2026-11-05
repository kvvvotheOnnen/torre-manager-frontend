# Frontend — Corrección de parpadeo en listados vacíos

- **Fecha:** 2026-11-04
- **Branch:** `dev`
- **Contexto:** Al quedarse sin proyectos, la pantalla de Gestión de Proyectos parpadeaba entre el aviso "No hay proyectos registrados" y el spinner. El mismo patrón existía en Administradores.

## Causa

El `builder` del `BlocConsumer` disparaba `ProyectosSolicitados` cada vez que encontraba la lista vacía y sin carga activa. Ese dispatch cambiaba el estado a `cargando`, luego el backend respondía con una lista vacía y la condición se cumplía de nuevo, generando un ciclo de peticiones y repintados por segundo.

## Cambios realizados

- `proyectos_screen.dart`: `ProyectosScreen` ahora es `StatefulWidget` y dispara la carga inicial una sola vez desde `initState`, únicamente si la lista está vacía y no hay carga en curso. Se eliminó el dispatch automático del `builder`.
- `administradores_screen.dart`: mismo ajuste para evitar el parpadeo latente con la lista de administradores vacía.
- Se conservan el pull-to-refresh y las recargas posteriores a crear, editar o eliminar.

## Decisiones de diseño

- La carga inicial es un efecto de ciclo de vida de la pantalla, no una consecuencia del render, por eso vive en `initState` y no en `build`.
- Las condiciones de `initState` evitan peticiones redundantes al volver a la pantalla si el BLoC ya tiene datos o una carga en curso.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 21 tests aprobados.

## Pendientes

- Verificación manual con la base de datos sin proyectos para confirmar que el aviso queda estable y se realiza una sola petición inicial.
