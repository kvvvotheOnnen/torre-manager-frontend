# Bitácora — Fix: parseo defensivo de `atributos` en instalaciones extra

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** "Ocurrió un error inesperado" al crear un proyecto con instalaciones extra (el backend respondía 201).

## Diagnóstico

- `InstalacionExtraDTO.fromJson` hacía `json['atributos'] as Map<String, dynamic>?`. Cuando el backend enviaba `[]` (array vacío), el cast lanzaba `TypeError`, que `SuperadminRepositoryImpl._guard` capturaba en el `catch (_)` genérico → `UnexpectedFailure` ("Ocurrió un error inesperado").

## Cambios realizados

- `InstalacionExtraDTO.fromJson`: se acepta el valor solo si es `Map<String, dynamic>`; en cualquier otro caso (lista vacía, null, ausente) se usa `const {}`.
- Nuevo test `test/features/superadmin/proyecto_detalle_dto_test.dart`: cubre atributos como mapa, como lista vacía `[]`, ausentes/null y el tipo de condominio `edificio`.

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 8 passed (4 nuevos).

## Pendientes

- Ninguno.
