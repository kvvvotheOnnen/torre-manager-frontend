# Pantalla Marketplace

- **Fecha:** 2026-11-17
- **Branch:** `feature/martin/marketplace/2026-11-17`
- **Módulo:** Marketplace / Tienda de residentes

## Contexto

Se implementó la pantalla cliente del módulo Marketplace para residentes,
propietarios, conserjes y administradores. Consume la API creada en el mismo
backend y reutiliza la capa de funciones del dashboard para mostrar u ocultar
acciones sin evaluar roles en el cliente.

## Cambios realizados

### Dominio y datos

- Feature `lib/features/marketplace/` con entidades `PublicacionMarketplace`,
  `PublicacionFoto` y enums de categoría, condición y estado.
- Repositorio con `Either<Failure, T>` y casos de uso para listar catálogo,
  publicaciones propias, historial, favoritos, crear, actualizar, retirar,
  vender, eliminar y alternar favorito.
- DTO defensivo y datasource Dio con multipart para la imagen.
- Helper local `formato_moneda.dart` para precios CLP y fechas, sin agregar
  `intl`.

### Presentación

- `MarketplaceScreen` con buscador, chips de categoría, vistas Catálogo, Mis
  publicaciones, Mis favoritos e Historial, y filtro Disponibles/Todas para el
  administrador.
- Tarjeta con imagen 16:9, precio, condición, categoría, descripción, badge de
  estado, corazón de favoritos y botón Contactar deshabilitado.
- Diálogo de detalle, formulario de creación/edición con imagen opcional,
  diálogo de retiro/venta y diálogo de moderación con motivo obligatorio.
- El botón de editar/eliminar se controla con los flags que envía el backend.

### Integración

- Rutas `/marketplace` y `/admin/modulos/marketplace`.
- `funcion_rutas.dart` abre la pantalla desde las tarjetas de residente y
  conserje.
- `icono_funcion.dart` y el dashboard administrador usan `storefront`.
- `main.dart` instancia y provee `MarketplaceBloc`.

## Decisiones de diseño

- El cliente no conoce roles: usa `acciones.publicar`, `gestionar`, `moderar` y
  `favoritos` de la función, más los flags por publicación.
- El filtrado por categoría y texto es local, igual que en servicios, para que
  los chips respondan de inmediato.
- El administrador entra con la vista "Todas" y puede alternar a "Disponibles".
- No se muestran favoritos ni historial al administrador.
- El conserje solo ve el catálogo y el botón de eliminar con motivo.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 90 pruebas, todas pasan.
- Pruebas nuevas: DTO, BLoC y formato de moneda/fecha.
- `dart format` aplicado al feature y a los tests.

## Ajuste posterior: accesos separados de las categorías

- Los accesos Catálogo, Mis publicaciones, Mis favoritos e Historial dejaron de
  ser `ChoiceChip` mezclados con las categorías.
- Ahora son botones (`FilledButton.tonal` cuando están activos y
  `OutlinedButton` cuando no) en una fila independiente sobre las categorías.
- El administrador mantiene Disponibles/Todas como botones en esa misma fila.
- El botón Publicar se conserva como FAB.
- Verificación: `flutter analyze` sin issues y 90 pruebas en verde; las 11 pruebas
  del marketplace pasan.

## Ajuste posterior: pestaña de eliminadas para el administrador

- El administrador ahora tiene los botones **Todas**, **Disponibles** y
  **Eliminadas**, en ese orden.
- **Eliminadas** consulta `?estado=eliminada` y muestra solo las publicaciones
  moderadas por el administrador o el conserje, con su motivo.
- Se agregó `MarketplaceVista.eliminadas`; el listado, repositorio, datasource y
  caso de uso aceptan un estado opcional.
- Al cambiar entre Todas, Disponibles y Eliminadas no se hacen peticiones
  duplicadas.
- Estado vacío específico: "Sin publicaciones eliminadas".
- Se agregaron dos pruebas de BLoC para la nueva vista y el regreso a
  disponibles.
- Verificación: `flutter analyze` sin issues y 13 pruebas del marketplace en
  verde.

## Ajuste posterior: actualización local y feedback de escritura

- Tras crear, editar, retirar, vender o eliminar, el BLoC ya no vuelve a pedir
  el listado completo: aplica la publicación devuelta por la API o la quita por
  id según la vista activa.
- Al crear desde Historial o Mis favoritos, la vista cambia a Mis publicaciones
  para que la nueva publicación quede visible sin recargar.
- Al vender desde Mis favoritos, la publicación se reemplaza por la versión
  vendida para conservar los tres días de visibilidad; al retirarla se quita.
- Se agregó `procesandoId` y `ocupado` al estado. La tarjeta muestra una barra de
  progreso, deshabilita sus acciones y el corazón; el FAB muestra
  "Procesando..." mientras se completa una escritura.
- Se mantiene `MarketplaceSolicitadas` para pull-to-refresh, cambio de vista y
  reintento.
- Pruebas actualizadas y nuevas para edición local, retiro/venta/eliminación sin
  recarga y estado `procesandoId` con un `Completer`.
- Verificación: `flutter analyze` sin issues; `flutter test` con 94 pruebas en
  verde, 15 de ellas del marketplace.

## Ajuste posterior: publicaciones propias fuera de los listados generales

- El catálogo y las vistas generales del administrador ya no muestran las
  publicaciones propias; estas se consultan en Mis publicaciones e Historial.
- El administrador ahora tiene los botones **Todas**, **Disponibles**,
  **Eliminadas**, **Mis publicaciones** e **Historial**.
- Residente y propietario mantienen Catálogo, Mis publicaciones, Mis favoritos e
  Historial; el conserje mantiene solo el catálogo.
- Al crear una publicación, la pantalla cambia siempre a Mis publicaciones y la
  inserta al inicio, sin mostrarla en el catálogo ni volver a Todas.
- Se eliminó el helper de inserción en catálogo, que ya no se usaba.
- Se actualizó la prueba de creación para verificar la vista Mis publicaciones,
  el flag `todas` en falso y la ausencia de recarga.
- Verificación: `flutter analyze` sin issues; `flutter test` con 96 pruebas en
  verde, 17 de ellas del marketplace.

## Ajuste posterior: filtro local de publicaciones propias y eliminadas

- `publicacionesVisibles` oculta las publicaciones propias y las eliminadas
  cuando la vista es el catálogo general, como respaldo del filtro del backend.
- En la vista **Eliminadas** también oculta las publicaciones propias, para que
  solo aparezcan las moderadas de otros usuarios.
- Se agregaron dos pruebas de estado para cubrir ambos casos.
- Verificación: `flutter analyze` sin issues; `flutter test` con 96 pruebas en
  verde, 17 de ellas del marketplace.

## Pendientes

- Prueba visual en dispositivo o emulador.
- Selector de imagen en web.
- Conectar el botón Contactar cuando exista el flujo real.
- Notificaciones de moderación cuando el backend agregue listeners.
- El módulo queda sin commit, según lo solicitado.
