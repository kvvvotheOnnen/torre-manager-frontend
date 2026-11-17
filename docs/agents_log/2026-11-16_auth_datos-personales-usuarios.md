# Datos personales del usuario en la app

- **Fecha:** 2026-11-16
- **Branch:** `feature/koke/rut-usuarios/2026-11-16`
- **Módulo:** Auth / Residente

## Contexto

El backend agregó RUT, teléfono y contacto de emergencia a `usuarios`. En Flutter se
incorporaron al modelo de usuario y se muestran en la pantalla "Mi información" para
residentes y propietarios.

## Cambios realizados

- `Usuario` y `UsuarioDTO` incluyen `rut`, `telefono`, `telefonoEmergencia` y
  `nombreEmergencia` como campos opcionales; el DTO parsea `telefono_emergencia` y
  `nombre_emergencia`.
- Nuevo widget `DatosPersonalesCard` con RUT, teléfono y contacto de emergencia, usando
  "No registrado" cuando falta información.
- `MiInformacionScreen` muestra la card de datos personales sobre las unidades.
- Tests nuevos para el parseo del DTO y para el render del widget con y sin datos.

## Decisiones de diseño

- La pantalla usa el usuario autenticado (`AuthBloc` → `/api/user`), sin modificar el
  endpoint de información de residente.
- Los campos son nullable para mantener compatibilidad con usuarios sin datos.
- Los administradores y conserjes verán estos datos cuando exista una pantalla de perfil;
  por ahora solo se visualizan en "Mi información".

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 56 pruebas, todas pasan.
- Integración manual: el login devuelve los nuevos campos y la card los muestra.

## Pendientes

- Formulario de registro de residentes (Task 12) y validación de RUT en Flutter.
- Perfil de usuario para roles administrador y conserje.
