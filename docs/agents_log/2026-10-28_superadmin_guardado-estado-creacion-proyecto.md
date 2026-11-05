# Frontend - Guardado de estado en creacion de proyecto

- **Fecha:** 2026-10-28
- **Branch:** `feature/koke/guardado-estado-creacion-proyecto/28-10-2026`
- **Contexto:** Task 6 de `task.md`. Al fallar la creacion de un proyecto, el usuario quedaba sin feedback propio del formulario y sin garantias de no perder el avance. Se busca corregir en pantalla y reintentar sin perder datos.

## Cambios realizados

- `superadmin_bloc.dart`: los fallos de crear y actualizar proyecto ahora emiten `exito: false` de forma explicita, para que los listeners puedan distinguir el error de un estado previo exitoso.
- `proyectos_screen.dart` (listado): el `BlocConsumer` del listado omite mostrar snackbars de error cuando un formulario del superadmin esta en primer plano (`ModalRoute.isCurrent`), evitando duplicados; los mensajes de exito siguen mostrandose via ScaffoldMessenger.
- `proyectos_screen.dart` (formulario):
  - El `BlocListener` maneja el fallo de creacion: muestra el error dentro del formulario, consume el mensaje y se mantiene en pantalla sin hacer pop (los datos de los `TextEditingController` se conservan).
  - Fallo de edicion tambien muestra el error dentro del formulario.
  - Validadores inline para instalaciones extra: `capacidad` requiere entero 1-500 cuando la fila tiene nombre, `descripcion` valida el maximo de 100 caracteres.

## Decisiones de diseno

- El formulario es dueno del feedback de sus propios errores; el listado queda como fallback para mensajes globales de exito.
- Ninguna navegacion se dispara a partir de un fallo: solo el exito navega (pop en edicion, pushReplacement en creacion).
- El boton "Crear proyecto" ya estaba deshabilitado mientras `guardando`; no se cambio.

## Verificacion

- `flutter analyze`: sin issues.
- `flutter test`: 19 tests aprobados, incluidos 2 nuevos: fallo de creacion (emite mensaje, exito false, guardando false, ultimoProyectoCreado null) y reintento exitoso tras un fallo.

## Pendientes

- Verificacion manual del flujo visual en dispositivo/emulador.
