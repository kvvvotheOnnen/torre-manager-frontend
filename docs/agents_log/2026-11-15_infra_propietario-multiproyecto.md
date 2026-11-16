# Rol propietario y selección de proyecto multirol

- **Fecha:** 2026-11-15
- **Branch:** newInfra/koke/15-11-2026
- **Contexto:** adaptar el cliente al modelo de membresías por proyecto y vínculos propietario/arrendatario.

## Cambios realizados

- Se agregó el rol `propietario` al enum de dominio.
- El selector de proyecto se habilita para todos los roles con más de un proyecto, no solo administradores.
- El dashboard de propietario reutiliza el panel del residente y muestra el título correspondiente.
- `MiInformacion` pasó de una unidad a una lista de unidades con tipo de vínculo e historial.
- El DTO de `MiInformacion` conserva compatibilidad con la respuesta antigua.
- El DTO y la entidad de unidad principal incluyen propietario y ocupante actual.
- La pantalla de infraestructura muestra propietario y ocupante por unidad.
- Se agregaron pruebas de parsing para `MiInformacionDTO` y `UnidadPrincipalDTO`.

- Se agregó la sección 2.4 de `AGENTS.md` con las reglas de propiedad, ocupación y autorización multi-proyecto, sincronizada en los tres archivos.

## Verificación

- `flutter analyze`: sin errores.
- `flutter test`: suite completa en verde, incluyendo nuevas pruebas de DTOs.

## Pendientes

- Pantalla de administración para asignar y cerrar vínculos.
- Mostrar el rol por proyecto en el selector y en el panel.
- Pruebas de integración de la selección de proyecto para propietario y residente.
