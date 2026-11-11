# 2026-11-10 - Asistente IA - Integración con modelo local

## Contexto

Branch: `feature/koke/asistente-ia/2026-11-10`.

Se implementa la integración del modelo local (`qwen2.5:7b-instruct` vía
Ollama) para responder consultas sobre el reglamento de infraestructura de un
proyecto. El alcance definido por el usuario:

- Un solo PDF por proyecto, asociado al proyecto activo.
- El administrador carga el PDF (módulo "IA admin", solo rol administrador).
- El residente consulta el modelo (módulo "IA" con ícono de estrella, solo rol
  residente).
- El superadmin no tiene acceso al módulo "IA admin".
- Enfoque de menor consumo: texto completo del PDF en el prompt (sin embeddings).

## Cambios realizados

### Documento de ejemplo
- `docs/ejemplos/vanguardia_center_infraestructura.md` (fuente editable).
- `docs/ejemplos/vanguardia_center_infraestructura.pdf` (2 páginas, texto
  extraíble, generado desde el Markdown).

### Feature `Asistente`
- Dominio: entidades `Documento`, `PaginasDocumento`, `FuenteRespuesta`,
  `RespuestaAsistente`; contratos de repositorio y casos de uso (resolver
  proyecto, subir, obtener, eliminar, consultar).
- Datos: `DocumentoRepository`, `PdfTextExtractor` (smalot/pdfparser),
  `OllamaDataSource` y `OllamaRepository`.
- Migración `documentos` con `proyecto_id` único (un PDF por proyecto).
- Endpoints:
  - `GET/POST/DELETE /api/admin/asistente/documento` (rol administrador).
  - `POST /api/residente/asistente/consultas` (rol residente).
- Extracción con marcadores `[Documento: ...]` y `[Página N]` para citar.
- Presupuesto de contexto: hasta 6000 tokens estimados por documento.

### Catálogo de módulos
- Se agrega `ModuloGeneral::AsistenteIaAdmin` ("IA admin").
- El catálogo oculta ese módulo al superadmin.
- El módulo "IA" del residente es una entrada del dashboard de residente, no
  del catálogo de administradores.

## Decisiones de diseño

- Enfoque A (texto completo en el prompt): no requiere modelo de embeddings ni
  índice vectorial, reduce recursos y maximiza fidelidad para un PDF corto.
- El proyecto del administrador se resuelve con `X-Proyecto-Id` validando
  pertenencia; el del residente se toma de `usuarios.proyecto_id`.
- El archivo se guarda en el disco `local` con nombre único para evitar
  colisiones y borrados accidentales.
- Temperatura 0.1 y `num_ctx` configurable (8192 por defecto).
- Variables de entorno `OLLAMA_*` centralizadas en `config/services.php`.

## Verificación

- Suite backend completa: 61 tests en verde.
- Pint sobre los archivos nuevos/modificados: sin problemas.
- Prueba real contra el modelo local con el PDF de ejemplo:
  - Pregunta sobre vidrio/cartones: responde citando `[Página 2]`.
  - Pregunta fuera del documento (tarifa de quincho): responde
    "No encuentro esa información en el documento."
- Frontend: `flutter analyze` sin issues y 46 tests en verde.

### Prueba local contra el Ollama del servidor

Se validó el flujo completo sin desplegar backend ni frontend:

- El backend local corre en Docker y no puede alcanzar a Ollama en el host
  cuando el firewall del equipo bloquea el tráfico contenedor -> host
  (`host.docker.internal` da timeout).
- Solución aplicada: un contenedor `ollama-tunnel` en la misma red Docker que
  el backend, que reenvía por SSH el puerto 11434 usando el agente SSH del
  host. El backend usa `OLLAMA_BASE_URL=http://ollama-tunnel:11434`.
- La configuración de acceso (host, usuario, puerto, llaves) permanece en
  `~/.ssh` y en el `.env` local; no se versiona ningún dato del servidor.
- Se ejecutó la migración local y una prueba end-to-end por HTTP:
  - Login de administrador y subida del PDF de ejemplo: `201`, 2 páginas.
  - Consulta de residente sobre vidrio/cartones: respuesta con cita
    `[Página 1]` en ~38 s (incluye carga inicial del modelo).
  - Consulta fuera del documento (tarifa de quincho): responde
    "No encuentro esa información en el documento." en ~4 s.
- Se documentaron ambas variantes (túnel en contenedor y túnel en host) en la
  guía de desarrollo.

## Pendientes

- Desplegar backend y frontend en el VPS junto a Ollama (misma red Docker).
- Definir `OLLAMA_BASE_URL` en el entorno de producción.
- Evaluar limpiar el historial del chat al cerrar sesión (hoy el BLoC es global).
