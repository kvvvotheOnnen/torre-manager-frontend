# Mejoras visuales del registro de residente

- **Fecha:** 2026-11-25
- **Rama:** feature/koke/mejoras-visuales-creacion-residente/25-11-2026

## Contexto

Se ejecutaron los cuatro planes de diseño generados para
`docs/improvements/design/` (peticiones directas del desarrollador), enfocados en
la pantalla de registro de residente y en la consistencia visual general:

1. `grid-background-scope`
2. `wizard-navigation-placement`
3. `spacing-and-centering`
4. `visual-polish`

## Cambios realizados

- **Fondo de cuadros:** `AppBackground` ahora tiene `showPattern` (por defecto
  `false`). El patrón de retícula solo se dibuja en el login
  (`showPattern: true`); el wizard, dashboards, selector, "próximamente" y
  splash usan el gradiente y halos sin cuadros.
- **Navegación del wizard:** "Atrás / Siguiente" pasó dentro del área
  desplazable, justo debajo del contenido del paso (con separación
  `AppSpacing.xl`), en lugar de quedar anclado al borde inferior.
- **Anchos y centrado:** los dashboards de administrador, residente, conserje y
  superadmin centran su contenido y lo limitan a `AppLayout.maxContent`
  (1200). El dashboard de administrador ahora usa `AppContent`. La pantalla
  "próximamente" usa `AppLayout.maxForm`. El wizard usa padding de página
  `AppSpacing.xl` / `AppSpacing.lg` y una separación uniforme.
- **Aspecto:** el contenido del paso se muestra sobre un `GlassCard` (mismo
  lenguaje que el login). Las tarjetas internas de residentes, mascotas y
  resúmenes usan `AppRadii.lgAll` y `AppShadows.soft`; la opción seleccionada
  gana una sombra suave.

## Verificación

- `dart format` aplicado a los archivos tocados.
- `flutter analyze`: sin issues.
- `flutter test`: 127 pruebas en verde.

## Pendientes

- Revisión visual manual en dispositivo/escritorio (colores y percepción del
  contraste del fondo sobrio).
- Las reglas del catálogo que no se seleccionaron quedaron documentadas en
  `docs/improvements/design/findings.md` para futuras iteraciones.

## Ajuste: halos fuera del login y centrado vertical del wizard

- Los halos luminosos de las esquinas ahora son opt-in (`showGlow` por defecto
  `false`); solo el login los conserva junto con la retícula de cuadros. El
  resto del sistema queda con el gradiente sobrio.
- El contenido del wizard de registro se centra verticalmente cuando cabe en
  pantalla (patrón `LayoutBuilder` + `ConstrainedBox(minHeight)` + `Column` con
  `MainAxisAlignment.center`), manteniendo el scroll cuando el contenido excede
  la altura disponible.
- Verificación: `flutter analyze` sin issues y `flutter test` 127 en verde.
