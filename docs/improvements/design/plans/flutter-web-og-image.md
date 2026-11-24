# Fix: Shared link shows a bare URL

- Link: https://flutterpro.design/details/md/flutter-web-og-image
- Needs new dependency: none
- Estado: implementado con dominio de ejemplo; requiere el dominio real.

## Why

Al compartir el enlace en WhatsApp, Slack o X no aparece tarjeta de vista previa
porque `og:image` y `twitter:image` eran rutas relativas.

## Fix

En `web/index.html`, `og:image` y `twitter:image` deben ser URLs absolutas.
Quedaron como `https://torre-manager.example.com/icons/Icon-512.png`.

## Pendiente

Reemplazar `torre-manager.example.com` por el dominio público de producción y
verificar la vista previa con el validador de Open Graph.
