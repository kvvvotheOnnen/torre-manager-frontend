# 2026-11-24 · UI · Mejoras visuales

- **Branch:** `feature/koke/mejoras-visuales/2026-11-24`
- **Contexto:** revisión de UI con el catálogo `flutter-improve-design` y
  corrección de campos de texto que ocupaban todo el ancho en pantallas amplias.

## Cambios realizados

1. **Layout de contenido**
   - Nuevo `lib/core/widgets/app_content.dart` con `AppContent` (máximo 1200 px,
     centrado) y `AppFieldWidth` (máximo 520 px para campos sueltos).
   - Nuevas constantes `AppLayout` en `design_tokens.dart`.
   - Aplicado en marketplace y servicios (contenido) y en los buscadores de
     marketplace, servicios, paquetería, mis paquetes y gestión de residentes.

2. **Consistencia de inputs**
   - Se quitaron 60+ `border: OutlineInputBorder()` locales que sobreescribían
     el radio de 16 px del tema por el radio por defecto (4 px). Ahora todos los
     campos usan el borde del `inputDecorationTheme`.

3. **Reglas del catálogo aplicadas**
   - `textInputAction` en formularios multi-campo.
   - Formateo de teléfonos: `lib/core/utils/formato_telefono.dart` con
     `formatearTelefono` y `FormateadorTelefono`.
   - `orPlaceholder()` en `lib/core/utils/formato_texto.dart` para no mostrar
     `null`, vacío ni `"null"`.
   - Padding inferior dinámico (`appScrollPadding`) en las listas de paquetería
     y gestión de residentes.
   - Degradado en el borde de la lista horizontal del wizard de proyecto.
   - `FocusManager.instance.primaryFocus?.unfocus()` antes de abrir modales.
   - `og:image` y `twitter:image` absolutas en `web/index.html`.

## Decisiones

- El dominio público no está definido en el repositorio; las imágenes de Open
  Graph quedaron con `torre-manager.example.com` como marcador. Debe
  reemplazarse por el dominio real antes de desplegar.
- Se priorizó no agregar dependencias: formateo de teléfono y texto con helpers
  propios.

## Chat del Asistente IA (residente)

- `asistente_screen.dart`: el chat se centra con `AppContent(maxWidth: 880)` y
  el compositor deja de ocupar todo el ancho de la pantalla.
- El input vive en una barra flotante redondeada; el botón de enviar es circular
  y se deshabilita mientras el asistente responde o el campo está vacío.
- El spinner del botón se reemplazó por una burbuja animada de tres puntos
  ("escribiendo") del lado del asistente.
- El placeholder del campo muestra siempre la pregunta sugerida
  "¿En qué piso se encuentra el Quincho?" mientras está vacío.
- AppBar con flecha de volver al panel y subtítulo "Reglamento del edificio".
- Toda la columna del chat queda dentro de `SafeArea` para no quedar bajo la
  barra de navegación del sistema.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 116 tests en verde (incluye tests nuevos de formateo de
  teléfono y de `orPlaceholder`).

## Pendientes

- Reemplazar el dominio de ejemplo en `web/index.html`.
- Validar visualmente en anchos 390 / 900 / 1440 px en un entorno con backend.
