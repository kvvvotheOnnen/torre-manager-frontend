# 2026-11-09 — Paquetería: corregir selección de departamento

- **Módulo:** Paquetería / registro de paquetes
- **Rama:** `test-martin` (frontend)

## Contexto

Al registrar un paquete, el selector podía mostrar el departamento elegido pero
el formulario lo validaba como si no hubiera selección.

## Cambios realizados

- El selector ahora conserva su selección en estado local y la usa para su
  indicador visual y validación.
- Al elegir una unidad, actualiza el estado local y notifica al formulario
  contenedor; el formulario conserva el identificador para registrar el paquete.
- El estado local se sincroniza cuando cambia la selección externa y se limpia
  al borrar la selección o modificar el texto.

## Decisiones de diseño

- Se mantuvo el flujo existente de diálogo y callback; el cambio evita que la
  validación dependa de una reconstrucción del diálogo por el estado de la
  pantalla que lo abrió.
- No se cambió el contrato del API ni el modelo de datos.

## Verificación

- `dart format`: sin cambios pendientes.
- `flutter analyze`: sin observaciones.
- `flutter test`: 40 pruebas aprobadas.
- `flutter build web --dart-define=API_BASE_URL=http://localhost:8000`: aprobado.

## Pendientes

- Confirmar manualmente en navegador el flujo de seleccionar departamento y
  registrar un paquete.
