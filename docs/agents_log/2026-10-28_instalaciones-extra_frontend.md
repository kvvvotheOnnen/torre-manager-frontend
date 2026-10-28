# Frontend - Instalaciones extra con capacidad y descripcion

- **Fecha:** 2026-10-28
- **Branch:** `feature/koke/instalaciones-extra-capacidad/28-10-2026`
- **Contexto:** Task 5 para actualizar el formulario y datos de proyectos al nuevo enfoque de instalaciones extra con capacidad y descripcion.

## Cambios realizados

- Entidad `InstalacionExtra`: `capacidad` obligatoria y `descripcion` opcional.
- DTO `InstalacionExtraDTO`: parseo de `capacidad` y `descripcion`, sin `tipo`.
- Datasource de crear/actualizar proyecto envia `capacidad` y `descripcion`.
- Formulario de instalaciones en `proyectos_screen.dart` actualizado a Nombre / Capacidad / Descripcion.
- Se elimina el campo Tipo de instalaciones extra.
- Validacion y parsing del DTO incluyendo el nuevo campo.

## Decisiones de diseno

- La validacion final de rango y longitud se respalda en backend.
- `atributos` se mantiene para compatibilidad.
- No se expone tipo de instalacion en el flujo nuevo.

## Verificacion

- `flutter analyze`: sin observaciones.
- `flutter test`: 17 tests aprobados.

## Pendientes

- Prueba manual del flujo completo desde el formulario.
