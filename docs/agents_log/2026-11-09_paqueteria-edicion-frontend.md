# 2026-11-09 — Paquetería: edición de paquete (frontend)

- **Módulo:** Frontend / Paquetería

## Cambios realizados

- `paqueteria_gestion_screen.dart`: botón "Editar" (icono) en cada tarjeta que
  abre un diálogo con formulario pre-llenado (descripción, remitente, residente,
  foto). Al guardar despacha `PaqueteActualizado`.
- `paqueteria_bloc.dart`: evento `PaqueteActualizado` + handler que reemplaza
  el paquete en la lista.
- `paqueteria_repository.dart` / `paqueteria_repository_impl.dart`: método
  `actualizar` (PUT multipart, foto opcional).
- `paqueteria_remote_data_source.dart`: método `actualizar`.
- `paquete.dart` + `paquete_dto.dart`: campo `residenteId`.
- `modulo_proximamente` no modificado.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 38 passed.
- `flutter build web`: OK.
