# Registro de residente (task 12) — frontend

- **Fecha:** 2026-11-25
- **Rama:** feature/koke/registro-residente/25-11-2026

## Contexto

La task 12 agrega el autoregistro de residentes/propietarios desde el login,
como un wizard de pasos. El destino tras el registro ya existía: la pantalla de
solicitud pendiente y el panel de aprobación del administrador (task 11).

## Cambios realizados

- Nueva feature `registro_residente` con la cadena Clean Architecture
  (DataSource → DTO → RepositorioImpl → Casos de uso → Bloc → pantalla).
- `RegistroWizardScreen` con 6 pasos reutilizando `WizardStepMap`: proyecto,
  vínculo (propietario/arrendatario), unidad (autocompletado obligatorio),
  residentes (hasta 6, con contraseña en el formulario principal), mascotas y
  finalización.
- Aviso de uso y cifrado de datos antes de avanzar del paso de residentes.
- Botón de acceso desde el login (`Regístrate`) y ruta pública `/registro` con
  los redirects de go_router ajustados para permitir la vista sin sesión.
- Validador de RUT chileno (módulo 11) en `core/utils/rut_validator.dart`.
- Rutas de API de registro en `AppConfig`.
- Inyección de dependencias y provider del bloc en `main.dart`.

## Decisiones de diseño

- La contraseña se captura en el formulario de la persona principal y se envía
  junto con la solicitud; el resto de residentes no crea cuenta.
- La unidad se selecciona en el paso 3 y las mascotas quedan asociadas a esa
  misma unidad.
- El botón "Agregar otro residente" se habilita solo cuando el último formulario
  está completo y se deshabilita al llegar a 6.
- La foto de mascota se muestra como botón inerte (sin funcionalidad) según la
  task.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 126 pruebas en verde (incluye nuevos tests de bloc, DTO y
  validador de RUT).

## Pendientes

- Funcionalidad de subida de foto de mascota.
- Pruebas de widget específicas del wizard (no incluidas en esta entrega).

## Corrección posterior: mensaje engañoso en el paso de unidad

- **Síntoma:** un fallo al cargar unidades se mostraba como "este proyecto aún
  no tiene unidades".
- **Corrección:** el bloc ahora distingue `errorUnidades` de una lista vacía. El
  paso 3 muestra un estado de error con botón "Reintentar" cuando falla la
  carga, y conserva el mensaje de "sin unidades" solo cuando la carga fue
  exitosa y realmente no hay unidades.
- **Verificación:** nuevo test del bloc para el caso de error de unidades;
  `flutter test` y `flutter analyze` en verde.

## Mejora: residentes completados como resumen

- **Cambio:** al agregar otro residente, el formulario completado se colapsa a
  una tarjeta resumen (etiqueta, nombre, RUT y correo) y solo se muestra un
  formulario activo a la vez. El nuevo formulario reemplaza visualmente al
  anterior en lugar de apilarse debajo.
- **Reglas:**
  - El botón "Agregar otro residente" se habilita solo cuando el formulario
    activo está completo y con RUT, correo y contraseña válidos; al agregar se
    valida el formulario y, si es válido, se colapsa.
  - Los resúmenes de convivientes permiten eliminarse; el principal no.
  - Eliminar el formulario activo (cuando hay 2+) restaura al residente
    completado anterior como formulario activo.
  - La validación al avanzar valida solo el formulario activo; los colapsados
    ya fueron validados antes de colapsarse.
- **Verificación:** `flutter analyze` sin issues y suite `flutter test` en verde.

## Mejora: validación visible en vivo

- **Problema:** el botón "Agregar otro residente" se habilita solo con datos
  válidos (RUT módulo 11, correo, contraseña ≥ 8 y coincidente), pero esos
  errores solo se mostraban al validar el formulario, lo que nunca ocurría
  mientras el botón estaba deshabilitado. El usuario no sabía qué dato corregir.
- **Cambio:** los campos de residente y mascota ahora usan
  `AutovalidateMode.onUserInteraction`, de modo que cada campo muestra su error
  (formato de correo, dígito verificador, longitud/mismatch de contraseña,
  obligatorio) apenas se interactúa con él.
- **Verificación:** `flutter analyze` sin issues y suite `flutter test` en verde.


