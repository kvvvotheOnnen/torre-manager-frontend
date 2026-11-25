# Fix: Anchos inconsistentes y contenido no siempre centrado

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: N/A — petición directa del desarrollador (no proviene del catálogo).
- **Needs new dependency**: none

## Why

The main screens disagree on how wide their content can grow and whether it is
centered. Three dashboards cap the content at a literal `1280` and center it,
the admin dashboard doesn't cap or center at all (cards stretch edge to edge on
wide screens), the "coming soon" screen uses a one-off `500`, and the
registration wizard mixes spacing values. The project already defines
`AppLayout.maxContent` (1200) and an `AppContent` helper that centers and caps
width; using them everywhere makes every screen line up and gives the wizard a
consistent spacing rhythm.

## Where

```dart
// lib/features/dashboard/presentation/screens/dashboard_screen.dart:159 — current
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SingleChildScrollView(
```

```dart
// lib/features/dashboard/presentation/screens/resident_dashboard_screen.dart:129 — current
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
```

```dart
// lib/features/dashboard/presentation/screens/conserje_dashboard_screen.dart:125 — current
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
```

The admin dashboard has no centering/width cap at all:

```dart
// lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart:273 — current
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
```

and its builder closes with:

```dart
// lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart:336 — current
            ],
          ),
        );
      },
    );
  }
}
```

```dart
// lib/features/dashboard/presentation/screens/modulo_proximamente_screen.dart:59 — current
              constraints: const BoxConstraints(maxWidth: 500),
```

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:287 — current
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
```

The wizard also uses a smaller gap between the step map and the content:

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:296 — current
                        const SizedBox(height: AppSpacing.sm),
```

## The fix

- Every main screen centers its content and caps it at `AppLayout.maxContent`
  (1200) using the existing `AppContent` widget where wrapping is simplest, or
  by swapping the literal for the token where a `Center`/`ConstrainedBox`
  already exists.
- The admin dashboard gets the same centering/cap as the other dashboards.
- The "coming soon" screen uses `AppLayout.maxForm` (560) instead of `500`.
- The wizard uses `AppSpacing.xl` (24) horizontal and `AppSpacing.lg` (16)
  vertical page padding, and `AppSpacing.lg` (16) between the step map and the
  content, matching the page padding rhythm.

## Steps

1. `lib/features/dashboard/presentation/screens/dashboard_screen.dart:161` —
   replace `const BoxConstraints(maxWidth: 1280)` with
   `const BoxConstraints(maxWidth: AppLayout.maxContent)`.

2. `lib/features/dashboard/presentation/screens/resident_dashboard_screen.dart:130`
   — replace `const BoxConstraints(maxWidth: 1280)` with
   `const BoxConstraints(maxWidth: AppLayout.maxContent)`.

3. `lib/features/dashboard/presentation/screens/conserje_dashboard_screen.dart:126`
   — replace `const BoxConstraints(maxWidth: 1280)` with
   `const BoxConstraints(maxWidth: AppLayout.maxContent)`.

4. `lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart` —
   wrap the scrolling content so it centers and caps like the other dashboards.
   Add the import at the top (next to the other `core/widgets` imports):

```dart
import '../../../../core/widgets/app_content.dart';
```

   Then replace:

```dart
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
```

   with:

```dart
        return AppContent(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
```

   and close the new wrapper by replacing the closing shown in "Where" (the
   `],` / `),` / `);` sequence before `},`) with:

```dart
            ],
          ),
        ),
      );
      },
    );
  }
}
```

   In other words, one extra `)` closes the `SingleChildScrollView` and the
   final `)` closes `AppContent`. After editing, run
   `dart format lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart`
   to normalize indentation.

5. `lib/features/dashboard/presentation/screens/modulo_proximamente_screen.dart:59`
   — replace `const BoxConstraints(maxWidth: 500)` with
   `const BoxConstraints(maxWidth: AppLayout.maxForm)`.

6. `lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:287`
   — replace the two padding values:

```dart
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
```

7. In the same file, replace the gap between the step map and the content:

```dart
                        const SizedBox(height: AppSpacing.lg),
```

   (Only the `SizedBox` that sits directly after `WizardStepMap(...)`; keep the
   `SizedBox` values inside the content and the navigation unchanged.)

## Check it

- `grep -rn "maxWidth: 1280" lib/features/dashboard || true` → no output (all three replaced; `|| true` just avoids a non-zero exit).
- `grep -c "maxWidth: AppLayout.maxContent" lib/features/dashboard/presentation/screens/dashboard_screen.dart lib/features/dashboard/presentation/screens/resident_dashboard_screen.dart lib/features/dashboard/presentation/screens/conserje_dashboard_screen.dart` → `1` in each file.
- `grep -c "AppContent(" lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart` → `1`.
- `grep -c "maxWidth: AppLayout.maxForm" lib/features/dashboard/presentation/screens/modulo_proximamente_screen.dart` → `1`.
- `grep -n "horizontal: AppSpacing.xl" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `1`.
- `dart analyze lib/features/dashboard lib/features/registro_residente` exits clean.

## Don't touch

- `lib/core/widgets/app_content.dart` and `lib/core/theme/design_tokens.dart`
  (use them as they are; do not change token values).
- The selector screen (`selector_proyecto_screen.dart`, its 920 width is
  intentional) and `solicitud_pendiente_screen.dart`.
- Grid/column breakpoints inside the dashboards, paddings from
  `EdgeInsets.fromLTRB(...)`, or `AppSpacing` values elsewhere.
- The wizard's navigation placement (that is a separate fix); if plan
  `wizard-navigation-placement` already ran, the `SizedBox` after
  `WizardStepMap(...)` still exists — only change its value.
- No new dependencies.

## STOP if

- Any quoted excerpt no longer matches (the codebase moved on).
- In the admin dashboard the closing braces don't line up after the wrap and
  `dart analyze` reports an error you can't resolve by adding/removing exactly
  one `)` for `AppContent`.
- A check fails twice.

## When you're done

Open the admin dashboard next to the resident one on a wide window: both now
center their content at the same width, and the registration wizard's padding
matches the rest of the app.
