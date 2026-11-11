# Merge de Asistente IA y Paquetería en `main` (frontend)

- **Fecha:** 2026-11-10
- **Branch:** `main`
- **Contexto:** `main` local estaba desactualizado respecto a `origin/main` (que ya contenía Paquetería, commit `cd2fd6e`) mientras el trabajo de Asistente IA se encontraba en `feature/koke/asistente-ia/2026-11-10` (commit `1ec17dd`, ya pusheado). Se requería que `main` contuviera ambos features fusionados.

## Cambios realizados

- Merge de `origin/main` dentro de `feature/koke/asistente-ia/2026-11-10` (commit de merge `8792da8`).
- Resolución de conflictos combinando ambos lados:
  - `lib/core/router/app_router.dart`: consts y rutas de Asistente y Paquetería.
  - `lib/main.dart`: `AsistenteAdminBloc`, `AsistenteBloc` y `PaqueteriaBloc` en campos, inicialización, `dispose` y `BlocProvider`; se conservó el listener de `PaqueteriaLimpiada`.
  - `pubspec.yaml`: `file_picker` e `image_picker`.
  - `macos/Flutter/GeneratedPluginRegistrant.swift`: registros de ambos plugins.
  - `pubspec.lock`: regenerado con `flutter pub get` (no resuelto a mano).
- `main` actualizado con `--ff-only` a `origin/main` y luego merge `--no-ff` de la feature branch (commit `3b0a5bc`).

## Decisiones de diseño

- Se usó merge (no rebase) para preservar los commits ya publicados de la feature branch.
- `pubspec.lock` se regeneró con la herramienta oficial en lugar de resolverlo manualmente.

## Verificación

- `flutter pub get` completado.
- `flutter analyze`: sin observaciones.
- `flutter test`: 49 pruebas aprobadas (incluye suites de Asistente y Paquetería).
- Estado de `main`: contiene Asistente IA + Paquetería, sin conflictos pendientes.

## Pendientes

- `git push` de `main` y de la feature branch (merge commit `8792da8`) queda a cargo del usuario (push manual).
