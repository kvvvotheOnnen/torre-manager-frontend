# 2026-11-28 - Merge control-acceso-notificaciones (rama de integracion)

- **Branch:** `ultimo-merge-funciones-martins-koke`
- **Base:** `feature/koke/mejoras-visuales-creacion-residente/25-11-2026`
- **Merge de:** `origin/feature/martin/control-acceso-notificaciones/2026-11-24` (1 commit: campanita con badge, bandeja y aprobacion de publicaciones)

## Cambios realizados

- Merge de la rama de notificaciones sobre la rama de mejoras visuales de registro.
- Divergencia: 21 commits locales vs 1 commit entrante.
- Conflictos (2): `lib/main.dart` y `lib/features/marketplace/presentation/screens/marketplace_screen.dart`.

### Resolucion main.dart

- Ambos lados agregaban un campo BLoC en el mismo punto. Union: se conservan `RegistroResidenteBloc` y `NotificacionesBloc`. Ambos quedan inicializados, cerrados y provistos via `BlocProvider.value`.

### Resolucion marketplace_screen.dart (conflicto estructural)

- El lado local rediseño la pantalla (wrapper `AppContent`, `AppFieldWidth` en el buscador, reindentacion); el lado entrante agrego la funcionalidad de solicitudes (vista Solicitudes con badge, aprobacion y rechazo).
- Estrategia: se conservo la estructura visual del lado local y se reinsertaron manualmente las 3 adiciones funcionales del lado entrante dentro de esa estructura:
  1. Boton `_BotonVista` "Solicitudes" (`if (puedeAprobar)`) en el Wrap de vistas.
  2. Empty states con `switch (state.vista)` incluyendo `MarketplaceVista.solicitudes`.
  3. Parametros `onAprobar`/`onRechazar` en `PublicacionCard` para la vista solicitudes.

## Decisiones de diseno

- Condicion del boton "Catalogo": el lado entrante la cambio de `puedePublicar && !puedeGestionar` a `!puedeGestionar` (para que aprobadores sin permiso de publicar vean el catalogo). Se conservo el cambio del lado entrante por ser funcional y deliberado.
- Las partes no conflictuadas (imports, `_gestionarRechazo`, `_solicitarContadorSolicitudes`, `_BotonVista` con contador, `puedeAprobar`) se auto-fusionaron correctamente.
- `dart format` aplicado a los archivos resueltos.

## Verificacion

- `flutter analyze`: sin problemas.
- `flutter test`: 131/131 pasando.
- Sin marcadores de conflicto remanentes (`git diff --check` limpio).

## Pendientes

- Push manual de la rama por parte del usuario.
- Validacion visual en runtime de la pantalla marketplace (solicitudes + rediseno juntos) por ser un conflicto estructural resuelto a mano.
