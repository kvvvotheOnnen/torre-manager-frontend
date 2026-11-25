# Fix: Las tarjetas del wizard se ven planas frente al login

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: N/A — petición directa del desarrollador (no proviene del catálogo).
- **Needs new dependency**: none

## Why

The login uses the app's signature surface: a soft glass card with depth and
glow. The resident-registration wizard, which is the first screen a future
resident sees, renders its step content directly on the background and draws
its inner cards (residents, pets, options) as flat boxes with ad-hoc radii
(`BorderRadius.circular(18)`) and no shadow. The result reads functional but
cheap next to the login. Putting the step content on a glass surface and giving
the inner cards the same radius and soft shadow ties the wizard to the app's
visual language.

## Where

Step content is rendered bare inside the scroll area:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:304 — current
                            child: _contenidoPaso(state),
```

(If the plan `wizard-navigation-placement` already ran, this same
`child: _contenidoPaso(state),` sits inside a `Column` inside the
`SingleChildScrollView`; the line to replace is identical.)

The resident summary card uses an ad-hoc 18px radius and no shadow:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:809 — current
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.14 : 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
```

The active resident form card:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:888 — current
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
```

The pet card uses the same decoration:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:1129 — current
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
```

The selectable option card (project, vínculo, pets yes/no) uses 18px radius in
two places and no shadow when selected:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:1328 — current
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: seleccionado
                ? p.accent.withValues(alpha: 0.12)
                : p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado ? p.accent : p.border,
              width: seleccionado ? 2 : 1,
            ),
          ),
```

## The fix

- Wrap the step content in the app's existing `GlassCard`, so the wizard shares
  the login's surface (glass background, soft border, shadow/glow).
- Replace every `BorderRadius.circular(18)` in the wizard with the shared
  `AppRadii.lgAll` (20) and give the inner cards `AppShadows.soft(p.isDark)`.
- Give a selected option card the same soft shadow, so selection reads as a
  lifted surface.

All three helpers (`GlassCard`, `AppRadii`, `AppShadows`) already exist; no new
dependencies.

## Steps

1. Add the import next to the other `core` imports at the top of
   `lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart`:

```dart
import '../../../../core/widgets/glass_card.dart';
```

2. Wrap the step content. Replace
   `child: _contenidoPaso(state),` with:

```dart
                            child: GlassCard(
                              glowColor: p.primary,
                              child: _contenidoPaso(state),
                            ),
```

   `p` is already defined at the top of the `build` method
   (`final p = context.palette;`), so it is in scope here.

3. Update the resident summary card decoration (first quoted decoration) to:

```dart
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.14 : 0.6),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: p.border),
        boxShadow: AppShadows.soft(p.isDark),
      ),
```

4. Update **both** the active resident form card and the pet card decorations
   (they are identical — apply to each of the two occurrences) to:

```dart
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: p.border),
        boxShadow: AppShadows.soft(p.isDark),
      ),
```

5. Update the option card: replace `borderRadius: BorderRadius.circular(18),`
   on the `InkWell` with `borderRadius: AppRadii.lgAll,`, and replace the
   `Container` decoration with:

```dart
          decoration: BoxDecoration(
            color: seleccionado
                ? p.accent.withValues(alpha: 0.12)
                : p.surface.withValues(alpha: p.isDark ? 0.18 : 0.8),
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: seleccionado ? p.accent : p.border,
              width: seleccionado ? 2 : 1,
            ),
            boxShadow: seleccionado ? AppShadows.soft(p.isDark) : null,
          ),
```

   Do **not** add an alpha to `p.surface` here; keep the existing color logic.

## Check it

- `grep -c "BorderRadius.circular(18)" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `0`.
- `grep -c "AppRadii.lgAll" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `5` (summary card, resident card, pet card, option `InkWell`, option `Container`).
- `grep -c "GlassCard(" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `1`.
- `grep -c "boxShadow: AppShadows.soft(p.isDark)" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `3` (three inner cards) plus the conditional one on the option card is a different string, so exactly `3`.
- `dart analyze lib/features/registro_residente` exits clean.

## Don't touch

- `GlassCard`, `AppRadii`, `AppShadows`, or the theme; use them as-is.
- The wizard's layout, navigation, validation, or step widgets' internals.
- Any other `BorderRadius.circular(...)` in the file that is not `18` (e.g.
  the image/status pills, if any).
- No new dependencies.

## STOP if

- Any quoted decoration or the `_contenidoPaso(state)` line no longer matches
  the file.
- `GlassCard` is not exported from
  `lib/core/widgets/glass_card.dart` (it is a public class; if it were
  private, stop rather than inventing a replacement).
- A check fails twice.

## When you're done

Open the resident registration: the step content now sits on the same glass
surface as the login, and the resident, pet and option cards have matching
rounded corners with a soft shadow, so the wizard feels like part of the same
product.
