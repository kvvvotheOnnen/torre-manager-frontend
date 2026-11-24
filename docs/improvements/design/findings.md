# Hallazgos de diseño · rama mejoras visuales

Revisión con el catálogo `flutter-improve-design` (2026-11-24). Cada hallazgo fue
implementado en la rama `feature/koke/mejoras-visuales/2026-11-24`, salvo el
indicado como pendiente.

## 1. Give every text field the right keyboard action

Users should be able to fill a form and submit it with the keyboard's action key alone: it moves them to the next field, and on the last one, submits. No tapping each field by hand.

Link: https://flutterpro.design/details/md/text-input-action

## 2. Format phone numbers

A phone number shown or typed as one long run of digits is hard to read and easy to mistype. It should be formatted everywhere the user sees one, including while they type to a text field.

Link: https://flutterpro.design/details/md/format-phone-numbers

## 3. Never show "null" on screen

When a string field comes back `null` or empty from the API and gets displayed directly, the user sees the word "null" or a blank spot on screen. A bad experience, and something they should never see. Instead, gate those values to show "-" or "N/A".

Link: https://flutterpro.design/details/md/never-show-null

## 4. Don't let the system navigation bar cover the bottom of scrollable lists

The last item of scrollable lists gets obscured by the system navigation bar. Leave space as tall as that bar at the end of the list so the last item has a breathing room against the bar.

Link: https://flutterpro.design/details/md/safe-area-replacement

## 5. Make horizontal lists feel scrollable

A horizontal scrollable list might not always signal that it's scrollable. Especially when the visible content just fits the view and no item is cut in half. Fading the edge hints users that there's more and they can scroll it.

Link: https://flutterpro.design/details/md/shader-mask

## 6. Unfocus the text field before opening a modal

Opening a modal while a text field is focused brings the keyboard back when the modal closes, even though the user was done typing. Unfocus before opening and it stays away.

Link: https://flutterpro.design/details/md/unfocus-before-modal

## 7. Give Flutter web links a preview card

Shared in WhatsApp, Slack or X, the app's link shows as a bare URL. It should show a proper preview card with a title, description and image.

Link: https://flutterpro.design/details/md/flutter-web-og-image

Estado: implementado con dominio de ejemplo. Pendiente reemplazar
`torre-manager.example.com` en `web/index.html` por el dominio público real.

## Fuera del catálogo · inputs a ancho completo

En pantallas anchas (web/escritorio) los formularios y buscadores se estiraban a
todo el ancho disponible. Se introdujo `AppContent`/`AppFieldWidth` y se
aplicaron en marketplace, servicios, paquetería y gestión de residentes.
