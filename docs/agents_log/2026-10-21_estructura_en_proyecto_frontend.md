# Bitácora — Estructura integrada en la creación de proyecto (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** Infraestructura ya no es un módulo aparte del dashboard; se integra a "Gestión de Proyectos".

## Cambios realizados

- **Dashboard**: se eliminó la tarjeta "Infraestructura" del rol superadmin. El superadmin solo ve "Gestión de Proyectos" (que ahora incluye la creación de la estructura) y "Administradores". El administrador conserva "Infraestructura" para operar su recinto.
- **Entidades**: `TipoCondominio` con `edificio` (+ etiqueta y descripción); `TipoAgrupacion` con `edificio` (+ extensión de etiqueta); nueva `DefinicionAgrupacion`.
- **Formulario de creación de proyecto**: constructor de estructura adaptativo al tipo elegido:
  - `Torres` → lista de torres/bloques (nombre, piso desde/hasta, unidades por piso).
  - `Casas` → lista de manzanas (nombre, cantidad de casas).
  - `Edificio` → un solo edificio con pisos y unidades por piso (sin torres).
  - `Mixto` → torres + manzanas.
  El payload envía `agrupaciones[]` junto con módulos, instalaciones y administradores; todo se crea en una sola operación.
- DataSource/repositorio/UseCase/BLoC actualizados para transportar `agrupaciones`.

## Verificación

- `flutter analyze`: sin issues. `flutter test`: 4 passed.
- Backend verificado en conjunto: al crear un proyecto tipo "torres" se generan sus agrupaciones y unidades (visible en el módulo de Infraestructura del administrador).

## Guía de prueba

1. Login superadmin → "Gestión de Proyectos" → FAB "Proyecto".
2. Elegir tipo: Torres / Casas / Edificio / Mixto (nota cómo cambia la sección "Estructura del recinto").
3. Definir la estructura, módulos, instalaciones y administradores → "Crear proyecto".
4. Login con el administrador asignado → "Infraestructura" muestra la estructura creada; un proyecto tipo Edificio aparece sin torres, solo con sus pisos.

## Pendientes

- Edición de estructura post-creación.
