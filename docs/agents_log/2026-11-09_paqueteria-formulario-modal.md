# 2026-11-09 — Paquetería: formulario de registro modal

- **Módulo:** Frontend / Paquetería
- **Rama:** `test-martin`

## Contexto

El formulario para registrar paquetes se desplegaba dentro de la página,
debajo de la búsqueda. Se solicitó que aparezca como ventana centrada encima
de la pantalla.

## Cambios realizados

- El botón "Registrar paquete" ahora abre un `Dialog` centrado, con ancho y
  alto máximos adaptados al viewport y contenido desplazable en pantallas
  pequeñas.
- Se retiró el formulario inline de la página.
- El diálogo conserva departamento, remitente, descripción, foto opcional,
  validación, registro y cancelación.
- El diálogo observa el BLoC para mostrar las unidades cuando termine su carga.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.

## Pendientes

- Verificación manual del modal y su selector en navegador y móvil.
