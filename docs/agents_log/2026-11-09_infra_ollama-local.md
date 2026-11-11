# 2026-11-09 - Infra - Despliegue de Ollama local

## Contexto

Requisito del proyecto: demostrar un modelo de IA local capaz de responder
consultas sobre documentos de infraestructura (zonas seguras, retiro de vidrio,
retiro de cajas, tarifas de quincho). Uso previsto: una sola persona de forma
simultánea, con backend y frontend desplegables en el mismo VPS.

## Cambios realizados

- Se creó el archivo `compose.yaml` en el directorio de despliegue del VPS con
  un único servicio `ollama`.
- Se creó la red Docker `torre-net` (compartida por el servicio) para que
  backend y frontend se conecten al modelo como `http://ollama:11434`.
- Se publicó el puerto únicamente en loopback (`127.0.0.1:11434`), sin abrir
  puertos en el firewall.
- Se descargó el modelo `qwen2.5:7b-instruct` (Q4_K_M, ~4.7 GB).

## Decisiones de diseño

- Inferencia solo CPU (el servidor no tiene GPU). Con un usuario concurrente,
  el 7B Q4 es el mejor balance calidad/latencia.
- Límites de recursos del contenedor: 6 vCPU, 12 GiB de memoria y sin swap,
  para no competir con los servicios existentes del VPS (proxy, base de datos,
  aplicaciones).
- `OLLAMA_NUM_PARALLEL=1` y `OLLAMA_MAX_LOADED_MODELS=1` por el perfil de uso.
- `OLLAMA_KEEP_ALIVE=30m` para mantener el modelo caliente durante una demo.
- Persistencia de pesos en volumen Docker `ollama_models`.

## Verificación

- Modelo listado por la API local y por el endpoint `/api/tags`.
- Prueba de generación en español correcta; velocidad observada ~7 tokens/s.
- Consumo observado del contenedor: ~8.5 GiB de memoria (bajo el tope de 12 GiB)
  y CPU acotada por cgroup.
- Puerto accesible solo desde loopback del servidor.
- Acceso público al puerto rechazado/bloqueado.
- Resolución y acceso desde un contenedor en `torre-net` mediante
  `http://ollama:11434`.

## Pendientes

- Ingesta de PDF y capa RAG en backend (extracción, chunks, embeddings).
- Definir si los PDF son digitales o escaneados (posible OCR).
- Integrar los servicios de backend y frontend en el mismo `compose.yaml`.
- Añadir un modelo de embeddings multilingüe cuando comience la fase RAG.
