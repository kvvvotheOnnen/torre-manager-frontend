# Fix: El fondo de cuadros aparece en todo el sistema

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: N/A — petición directa del desarrollador (no proviene del catálogo).
- **Needs new dependency**: none

## Why

The login is the brand's entry signature, so its grid ("blueprint") background
belongs there and only there. Today the same grid is painted behind the
resident-registration wizard, the dashboard loading/error states, the project
selector, the "coming soon" module screen and the splash, where it competes with
content and makes those screens feel busier than they need to be. The grid
should render only on the login screen; every other screen keeps the gradient
and glows but loses the grid lines.

## Where

The grid is painted unconditionally inside `AppBackground`:

```dart
// lib/core/widgets/app_background.dart:8 — current
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = true,
    this.dark = false,
  });

  final Widget child;
  final bool showGlow;
  final bool dark;
```

```dart
// lib/core/widgets/app_background.dart:39 — current
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintPainter(
                lineColor: (isDark ? Colors.white : const Color(0xFF0B1220))
                    .withValues(alpha: isDark ? 0.05 : 0.045),
                step: 46,
              ),
            ),
          ),
```

All call sites that get the grid today:

```dart
// lib/features/auth/presentation/screens/login_screen.dart:56 — current (keep grid here)
      body: AppBackground(
        child: SafeArea(
```

```dart
// lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart:256 — current (remove grid)
      body: AppBackground(
        child: SafeArea(
```

```dart
// lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart:197 — current (remove grid)
    return AppBackground(
      child: Center(
```

```dart
// lib/features/dashboard/presentation/screens/admin_dashboard_screen.dart:223 — current (remove grid)
    return AppBackground(child: SafeArea(child: child));
```

```dart
// lib/features/dashboard/presentation/screens/modulo_proximamente_screen.dart:48 — current (remove grid)
      body: AppBackground(
        child: Center(
```

```dart
// lib/features/tenant/presentation/screens/selector_proyecto_screen.dart:24 — current (remove grid)
      body: AppBackground(
        child: SafeArea(
```

```dart
// lib/core/router/app_router.dart:297 — current (remove grid; splash is not login)
      body: AppBackground(
        child: Center(
```

## The fix

Make the grid opt-in with a new `showPattern` flag that defaults to `false`, so
every existing call site loses the grid automatically and only the login opts
back in by passing `showPattern: true`. The gradient and the glows stay as they
are on every screen.

## Steps

1. In `lib/core/widgets/app_background.dart`, add the constructor parameter and
   field:

```dart
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showGlow = true,
    this.showPattern = false,
    this.dark = false,
  });

  final Widget child;
  final bool showGlow;
  final bool showPattern;
  final bool dark;
```

2. In the same file, wrap the grid `CustomPaint` in the new flag (replace the
   `Positioned.fill(...)` block from "Where"):

```dart
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _BlueprintPainter(
                  lineColor: (isDark ? Colors.white : const Color(0xFF0B1220))
                      .withValues(alpha: isDark ? 0.05 : 0.045),
                  step: 46,
                ),
              ),
            ),
```

3. In `lib/features/auth/presentation/screens/login_screen.dart:56`, opt the
   login back into the grid:

```dart
      body: AppBackground(
        showPattern: true,
        child: SafeArea(
```

4. Do nothing at the other call sites (wizard, dashboards, selector, "coming
   soon", splash): with the default `false` they now render without the grid.

## Check it

- `grep -c "showPattern" lib/core/widgets/app_background.dart` → `3` (parameter
  entry, field, and the `if`).
- `grep -rn "showPattern: true" lib` → exactly one line, in
  `lib/features/auth/presentation/screens/login_screen.dart`.
- `grep -c "AppBackground(" lib/features/registro_residente/presentation/screens/registro_wizard_screen.dart` → `1` and it has no `showPattern` argument.
- `dart analyze lib/core/widgets/app_background.dart lib/features/auth/presentation/screens/login_screen.dart` exits clean.

## Don't touch

- The gradient colors, `_Glow` halos, `_BlueprintPainter` implementation, or
  `dark` handling.
- Any screen that is not `AppBackground` (e.g. `AppShell`, dashboards' inner
  `Scaffold` background colors).
- No new dependencies, no renaming of the widget or file.

## STOP if

- `lib/core/widgets/app_background.dart` no longer contains the exact
  constructor or `Positioned.fill` block quoted in "Where".
- The login call site doesn't match the quoted excerpt.
- A check fails twice.

## When you're done

Open the app and compare the login against the resident-registration wizard and
the dashboard: the login keeps its blueprint grid, while every other screen now
shows only the soft gradient and glows, so the content reads cleaner.
