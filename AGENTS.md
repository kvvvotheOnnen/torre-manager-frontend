# Torre Manager - Contexto para el Agente de IA y Directrices de Arquitectura

## 1. Visión General del Proyecto

**Torre Manager** es una plataforma SaaS escalable (Móvil y Web) diseñada para la administración de condominios y edificios. Reemplaza sistemas heredados proporcionando funcionalidades modulares como control de acceso, reserva de áreas comunes (Quincho), trazabilidad de paquetería y pago de gastos comunes en línea.

## 2. Paradigma Arquitectónico: Clean Architecture y Feature-First

Tanto el Backend (Laravel) como el Frontend (Flutter) deben adherirse estrictamente a **Clean Architecture** agrupada por **Funcionalidades (Enfoque Feature-First)**. Esto garantiza una alta modularidad, permitiendo activar o desactivar módulos por recinto (SaaS Multi-Tenant) mediante Feature Flags.

### 2.1 La Regla de Dependencia

* **Capa de Dominio (Core):** Entidades, Casos de Uso e Interfaces de Repositorios. Debe ser 100% agnóstica a frameworks, bases de datos o la interfaz de usuario.
* **Capa de Datos (Data):** Implementaciones de Repositorios, Fuentes de Datos (llamadas API/consultas DB) y Modelos (DTOs).
* **Capa de Presentación/Aplicación:** Componentes de UI, Gestión de Estado (Flutter) y Controladores HTTP/Rutas (Laravel).

### 2.2 Plantilla de Estructura de Directorios por Feature

Cada nueva funcionalidad (ej. `Paqueteria`, `Quincho`, `Auth`) debe seguir esta estructura interna:

* `/Domain`
  * `/Entities`
  * `/UseCases`
  * `/Repositories` (Interfaces)
* `/Data`
  * `/Models` (DTOs)
  * `/DataSources`
  * `/Repositories` (Implementaciones)
* `/Presentation` (UI y Estado / Controladores HTTP)

## 3. Especificaciones del Backend (Laravel 11 API RESTful)

* **Rol:** Proveedor de API puro. Sin vistas web (Vite/Blade eliminados).
* **Ubicación de la Lógica Core:** Un directorio personalizado `src/` en la raíz del proyecto maneja las capas de Dominio y Datos de Clean Architecture. Está mapeado en `composer.json` bajo `psr-4` como `"Features\\": "src/"`.
* **Infraestructura:** El directorio `app/` por defecto de Laravel se usa estrictamente para la infraestructura del framework (Middlewares, Providers y Controladores HTTP delgados).
* **Autenticación y Seguridad:** Gestionada vía Laravel Sanctum (JWT/Tokens).
* **Base de Datos:** MySQL/PostgreSQL mediante Eloquent ORM.

## 4. Especificaciones del Frontend (Flutter)

* **Rol:** Cliente multiplataforma (Android, iOS, Web).
* **Gestión de Estado:** `flutter_bloc` / Patrón BLoC.
* **Red (Networking):** Cliente HTTP `dio` configurado con interceptores para inyectar los tokens JWT en las cabeceras.
* **Enrutamiento:** `go_router` con enrutamiento declarativo y protecciones RBAC (Control de Acceso Basado en Roles).
* **Nombre de la App Core:** `TorreManagerApp` (Sin nombres de clientes estáticos en el código).

## 5. Estado Actual del Proyecto

* **Repositorio Backend:** Inicializado. Recursos frontend eliminados. Rutas API habilitadas. Directorio `src/` creado y mapeado.
* **Repositorio Frontend:** Inicializado. App de contador por defecto limpiada. Dependencias base instaladas (`dio`, `go_router`, `flutter_bloc`, `equatable`, `shared_preferences`). Directorios base (`core/`, `features/`) creados. `.gitignore` actualizado para secretos y Firebase.

## 6. Próximos Pasos Inmediatos para el Agente de IA

1. Comenzar la implementación de la **Capa de Dominio** para la primera funcionalidad core (ej. `Auth` o `Paqueteria`).
2. Crear las **Entidades** puras (ej. `Usuario`, `Encomienda`).
3. Crear los **Casos de Uso** que contienen las reglas de negocio.
4. Definir las **Interfaces de los Repositorios** (Contratos).
   *Regla: No implementar Modelos de Datos, Fuentes de Datos o UI/Controladores hasta que la capa de Dominio de la funcionalidad específica esté completa y revisada.*
