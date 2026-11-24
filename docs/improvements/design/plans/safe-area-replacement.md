# Fix: Last list item hidden by the system navigation bar

- Link: https://flutterpro.design/details/md/safe-area-replacement
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

En móviles con barra de gestos el último elemento de una lista queda tapado.

## Fix

Se reutiliza `appScrollPadding(context, padding: ...)` de
`lib/core/widgets/app_scroll_view.dart`, que suma `MediaQuery.viewPaddingOf`
inferior al padding dado.

- `lib/features/paqueteria/presentation/screens/paqueteria_gestion_screen.dart`
  (`GridView.builder`).
- `lib/features/paqueteria/presentation/screens/mis_paquetes_screen.dart`
  (`GridView.builder`).
- `lib/features/solicitudes_residente/presentation/screens/gestion_residentes_screen.dart`
  (`ListView.separated`).

## Check

Probar en un dispositivo con gestos y desplazar hasta el final de cada lista.
