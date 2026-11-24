# Fix: Horizontal step map looks static

- Link: https://flutterpro.design/details/md/shader-mask
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

Una lista horizontal sin corte visible no comunica que se puede desplazar.

## Fix

En `lib/features/superadmin/presentation/widgets/wizard_step_map.dart` envolver
el `SingleChildScrollView` en un `ShaderMask` con `BlendMode.dstIn` y gradiente
`[black, black, transparent]` con stops `[0, 0.9, 1]`.

## Check

Abrir el wizard de proyecto y confirmar el degradado en el borde derecho.
