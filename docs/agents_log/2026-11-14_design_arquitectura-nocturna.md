# Rediseño visual "Arquitectura nocturna" (núcleo)

- **Fecha:** 2026-11-14
- **Branch:** `feature/newdesign/koke/14-11-2026`
- **Alcance:** frontend únicamente (no se tocó backend).

## Contexto

Se solicitó un nuevo estilo visual llamativo para Torre Manager. Se acordó la dirección "Arquitectura nocturna": azul marino profundo, acentos ámbar/dorado, superficies glass, tipografía display y soporte de tema claro/oscuro. Se priorizó el núcleo visual reutilizable antes que el resto de pantallas.

## Cambios realizados

### Sistema de diseño (`lib/core/theme/`)
- `app_colors.dart`: paleta claro/oscuro, gradientes de marca, héroe y oro, extensión `context.palette`.
- `design_tokens.dart`: espaciado, radios, sombras y duraciones.
- `app_typography.dart`: Space Grotesk para títulos y Manrope para cuerpo; precarga de pesos.
- `app_theme.dart`: `ThemeData` claro/oscuro con `ColorScheme`, inputs, cards, botones, diálogos, snackbars, scrollbars, selección de texto y transiciones sin animación en web/desktop.
- `theme_mode_controller.dart`: persistencia de `ThemeMode` con `SharedPreferences` y `ThemeModeScope`.

### UI kit (`lib/core/widgets/`)
- `app_background.dart`, `brand_mark.dart`, `glass_card.dart`, `module_card.dart`, `app_shell.dart`, `top_bar.dart`, `section_header.dart`, `empty_state.dart`, `status_pill.dart`, `app_scroll_view.dart`, `app_title.dart`, `app_error_view.dart`.

### Pantallas del núcleo
- `login_screen.dart`: layout hero + tarjeta glass, versión móvil, haptics y validación existente.
- `admin_dashboard_screen.dart`, `resident_dashboard_screen.dart`, `conserje_dashboard_screen.dart`: shell responsive con sidebar/drawer, barra superior, héroe de bienvenida y grilla de módulos unificada.
- `dashboard_screen.dart` (superadmin): mismo sistema visual.
- `selector_proyecto_screen.dart`: tarjetas de recinto con chips de módulos.
- `modulo_proximamente_screen.dart`: estado "próximamente" rediseñado.

### Aplicación y web
- `main.dart`: temas claro/oscuro, `ThemeModeScope`, clamp de escala de texto, `ErrorWidget.builder`, scrollbars y precarga de fuentes.
- `app_router.dart`: títulos por pantalla (`AppTitle`) y splash de marca.
- `web/index.html`: splash de carga con marca, meta Open Graph/Twitter, `theme-color` y descripción.
- `web/manifest.json`: nombre, colores y descripción de Torre Manager.
- `pubspec.yaml`: nueva dependencia `google_fonts`.

## Decisiones de diseño

- La lógica de BLoC, rutas de negocio, dominio y datos no se modificó.
- Se conservaron los textos que los tests verifican (`Bienvenido, ...`, `MÓDULOS DEL PROYECTO`, `MÓDULOS GENERALES`, `No habilitado para este proyecto.`).
- El blur (`BackdropFilter`) se limita a login, selector y tarjetas glass para no afectar rendimiento.
- Se prefirió un componente `ModuleCard` y un `AppShell` reutilizables para evitar duplicación entre dashboards.

## Verificación

- `flutter analyze`: sin issues.
- `flutter test`: 49 pruebas aprobadas.
- `flutter build web --release`: compilación exitosa.
- Pendiente de revisión visual manual en navegador y dispositivos.

## Pendientes / siguientes iteraciones

- Aplicar el sistema visual a superadmin (proyectos, wizard, administradores, accesorias), paquetería, infraestructura, asistente y mi información.
- Conectar notificaciones reales en el dashboard de residente.
- Evaluar empaquetar las fuentes como assets para uso 100% offline.
- Revisar Open Graph con dominio absoluto de producción para `og:image` y `twitter:image`.
