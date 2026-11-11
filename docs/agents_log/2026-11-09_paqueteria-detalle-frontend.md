# 2026-11-09 — Paquetería: detalle con foto (frontend)

- **Módulo:** Frontend / Paquetería

## Cambios realizados

- Nuevo `paquete_detalle_dialog.dart`: muestra la foto del paquete (o "No hay imagen"
  si no tiene) y los datos (descripción, remitente, unidad, fechas, estado).
- En `mis_paquetes_screen.dart` y `paqueteria_gestion_screen.dart`, al tocar
  una tarjeta se abre el diálogo de detalle. En la gestión, el diálogo incluye
  el botón "Marcar retirado".

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK.
