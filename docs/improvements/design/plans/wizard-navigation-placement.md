# Fix: El botón "Siguiente" queda pegado al fondo de la pantalla

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: N/A — petición directa del desarrollador (no proviene del catálogo).
- **Needs new dependency**: none

## Why

In the resident-registration wizard, the "Atrás / Siguiente" bar is pinned to
the bottom of the screen, far away from the form the person just filled. On a
tall phone or a desktop window the eye and the thumb travel a long way between
the last field and the action, and the form looks disconnected from what to do
next. The navigation should sit right below the current step's content, with a
consistent gap, so the user reads and acts in one place.

## Where

The wizard builds a fixed column: header, step map, an `Expanded` scroll area,
and the navigation pinned at the very bottom after the scroll area.

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:282 — current
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Encabezado(onSalir: _confirmarSalida),
                        WizardStepMap(pasos: _pasos, pasoActual: pasoVisual),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: _contenidoPaso(state),
                          ),
                        ),
                        if (!state.enviado)
                          _Navegacion(
                            paso: _paso,
                            enviando: state.enviando,
                            habilitado: _puedeAvanzar(state),
                            onAtras: _atras,
                            onSiguiente: _siguiente,
                          ),
                      ],
                    ),
                  ),
                ),
              );
```

## The fix

Move `_Navegacion` inside the scrollable, directly after the step content, with
`AppSpacing.xl` (24) above it and `AppSpacing.xl` (24) below it for breathing
room. The header and the step map stay fixed at the top; only the content plus
its navigation scroll. Now the action appears right under what the user filled,
not at the bottom edge of the screen.

## Steps

1. In `lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart`,
   replace the quoted `return Center(...)` block with:

```dart
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Encabezado(onSalir: _confirmarSalida),
                        WizardStepMap(pasos: _pasos, pasoActual: pasoVisual),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Navegación junto al contenido
                                _contenidoPaso(state),
                                if (!state.enviado) ...[
                                  const SizedBox(height: AppSpacing.xl),
                                  _Navegacion(
                                    paso: _paso,
                                    enviando: state.enviando,
                                    habilitado: _puedeAvanzar(state),
                                    onAtras: _atras,
                                    onSiguiente: _siguiente,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
```

2. Do not change `_Navegacion` itself: it already lays out "Atrás" on the left
   and "Siguiente" on the right, inside the same 780px column.

## Check it

- `grep -c "Navegación junto al contenido" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `1`.
- `grep -n "_contenidoPaso(state)\|_Navegacion(" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → both lines listed, and the `_Navegacion(` line number is **greater** than the `_contenidoPaso(state)` line number (the nav now comes after the content).
- `grep -c "if (!state.enviado)" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `1`.
- `dart analyze lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` exits clean.

## Don't touch

- The step content widgets (`_PasoProyecto`, `_PasoVinculo`, `_PasoUnidad`,
  `_PasoResidentes`, `_PasoMascotas`, `_PasoFinalizado`).
- `_Encabezado`, `WizardStepMap`, the `BlocConsumer` listener/builder logic, and
  the `_puedeAvanzar` / `_siguiente` / `_atras` handlers.
- No new dependencies.

## STOP if

- The quoted `return Center(...)` block at line ~282 no longer matches the file
  (the codebase moved on).
- Moving the nav would require touching a `_Paso*` widget to make it fit.
- A check fails twice.

## When you're done

Open the resident registration on a tall screen and complete a step: the
"Atrás / Siguiente" buttons now sit right below the form you just filled instead
of dropping to the bottom edge of the window.
