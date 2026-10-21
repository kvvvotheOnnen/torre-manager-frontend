# Bitácora — Cierre de sesión: vertical Infraestructura y SaaS multi-tenant (Frontend)

- **Fecha:** 2026-10-21
- **Branch:** `feature/koke/registropropiedad/21-10-2026`
- **Contexto:** índice y notas operativas de la sesión completa (frontend).

## Hitos de la sesión (documentados en detalle)

1. `2026-10-21_infraestructura_dominio_frontend.md` — Dominio de Infraestructura (entidades espejo, contratos, casos de uso).
2. `2026-10-21_infraestructura_datos_frontend.md` — DTOs, DataSource `dio`, repositorio.
3. `2026-10-21_infraestructura_ui_frontend.md` — BLoC, pantallas, restauración de sesión y guards RBAC en `go_router`.
4. `2026-10-21_superadmin_dashboard_frontend.md` — Rol superadmin, dashboard unificado por rol y módulo de proyectos.
5. `2026-10-21_fase1_cuentas_frontend.md` — UI de administradores para el superadmin.
6. `2026-10-21_fase2_proyectos_frontend.md` — Formulario de creación de proyecto.
7. `2026-10-21_fase3_multitenant_frontend.md` — Selector de proyecto y cabecera `X-Proyecto-Id` (incluye guía de prueba end-to-end).
8. `2026-10-21_estructura_en_proyecto_frontend.md` — Estructura adaptada al tipo de condominio, tipo `edificio` y dashboard sin módulo Infraestructura.
9. `2026-10-21_fix_atributos_instalaciones.md` — Parseo defensivo de `atributos` + tests.

## Decisiones transversales

- Clean Architecture: Domain (Equatable, `Either<Failure, T>` con `fpdart`), Data (DTOs con `fromJson`/`toEntity`, único punto con `dio`), Presentation (BLoC + `go_router`).
- Entidades de dominio sin parsing; los DTOs son la única capa que conoce el JSON.
- El proyecto activo (tenant) viaja por la cabecera `X-Proyecto-Id` inyectada en el interceptor de `dio` y persistida en `shared_preferences`.

## Notas operativas (importante)

- En **Chrome** el valor por defecto `API_BASE_URL` (`http://10.0.2.2:8000`) no resuelve; hay que ejecutar:
  `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`.
- Tras cambios de código, detener y relanzar `flutter run` (o hot restart `Shift+R`); ante dudas de caché del navegador, hacer hard refresh.
- Backend requerido levantado (`docker compose up -d`) y base sincronizada (`migrate:fresh --seed`).
- No versionar secretos ni logs; `.gitignore` cubre Firebase y credenciales.

## Verificación global

- `flutter analyze`: sin issues. `flutter test`: 8 passed.
- Flujo manual validado: login por rol, dashboard por rol, registro de administradores, creación de proyecto con estructura, selector de proyecto para administradores multi-recinto.

## Pendientes

- Módulos y contexto de proyecto para residente y conserje.
- Edición de estructura del recinto posterior a la creación.
