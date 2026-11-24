# Fix: Fill a form with the keyboard's action key

- Link: https://flutterpro.design/details/md/text-input-action
- Needs new dependency: none
- Estado: implementado en la rama de mejoras visuales.

## Why

Con dos o más campos de una línea el usuario debe tocar cada campo con el dedo.
La tecla de acción del teclado debe pasar al siguiente campo y, en el último,
enviar.

## Where y fix

- `lib/features/superadmin/presentation/screens/administradores_screen.dart`:
  nombre `textInputAction: TextInputAction.next`, correo `next`, contraseña
  `done` + `onFieldSubmitted: (_) => _submit()`.
- `lib/features/marketplace/presentation/widgets/publicacion_form_dialog.dart`:
  título `next`, precio `done` + `onFieldSubmitted: (_) => _guardar()`.
- `lib/features/servicios/presentation/widgets/trabajador_servicio_form_dialog.dart`:
  nombre, empresa y teléfono `next`. La descripción multilínea queda sin cambios.
- `lib/features/paqueteria/presentation/screens/paqueteria_gestion_screen.dart`
  (`_FormularioRegistro`): descripción y remitente `next`.

## Check

`flutter analyze` sin issues y recorrer cada formulario con Tab/Enter en web.
