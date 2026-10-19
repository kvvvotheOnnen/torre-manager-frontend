# Torre Manager - Contexto para el Agente de IA y Directrices de Arquitectura

> **Regla de Sincronización (obligatoria):** este archivo es el **documento maestro** y vive en la raíz del monorepo (`/home/koke/code/torre-manager/AGENTS.md`). **Toda actualización que se realice aquí debe reflejarse de inmediato en el `AGENTS.md` de ambos repositorios** (`torre-manager-backend/AGENTS.md` y `torre_manager_frontend/AGENTS.md`). Los tres archivos deben permanecer **idénticos** y están versionados en Git; nunca editar el `AGENTS.md` de un repositorio de forma aislada. Tras cualquier cambio, copiar el maestro a ambos repos y commitear.

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

### 4.1 Flujo Estricto de Comunicación y Transformación de Datos (Backend a Flutter)

Para garantizar el desacoplamiento absoluto que exige Clean Architecture, la comunicación entre la API RESTful (Laravel) y el cliente multiplataforma (Flutter) debe someterse a un flujo estricto de transformación de datos. Está rigurosamente prohibido que la Capa de Dominio tenga conocimiento alguno sobre formatos de red (JSON), protocolos HTTP o librerías externas.

El ciclo de vida de los datos (desde el JSON entrante hasta la Entidad en memoria) debe respetar la siguiente cadena de responsabilidades:

1. **Fuentes de Datos Externas (DataSources - Capa de Datos):**
   
   - Son las *únicas* clases autorizadas dentro de la arquitectura para importar y utilizar el cliente HTTP `dio`.
   
   - Su responsabilidad exclusiva es ejecutar las llamadas a los endpoints de Laravel, capturar las respuestas crudas en formato JSON, y procesar los códigos de estado HTTP (ej. capturar errores 40x/50x y lanzar excepciones específicas de infraestructura).
   
   - **Restricción:** Un DataSource jamás retorna una Entidad de Dominio; siempre debe retornar un Modelo de Datos (DTO) o lanzar una Excepción.

2. **Modelos de Datos / DTOs (Capa de Datos):**
   
   - Actúan como el puente serializable entre la respuesta del servidor y la aplicación. Representan la estructura exacta del JSON devuelto por la API.
   
   - Tienen el monopolio de la lógica de serialización y deserialización. Son las únicas clases que deben contener los métodos constructores de fábrica `fromJson(Map<String, dynamic> json)` y `toJson()`.
   
   - Estos modelos suelen heredar de la Entidad pura correspondiente, añadiéndole exclusivamente la capacidad de parsing.

3. **Implementación de Repositorios (Capa de Datos):**
   
   - Operan como el "traductor" y la barrera anticorrupción final antes de llegar al Dominio.
   
   - Su flujo de trabajo es el siguiente: 1) Invocan al DataSource. 2) Reciben el Modelo/DTO instanciado con los datos de la red. 3) **Mapean** o extraen de ese DTO únicamente los atributos necesarios para construir una Entidad pura. 4) Retornan la Entidad viva a la Capa de Dominio.

**Regla Cero de Aislamiento para el Agente:** *Bajo ninguna circunstancia las Entidades puras ubicadas en `/Domain/Entities` deben contener métodos de parsing (`fromJson()`, `toJson()`), constructores que reciban diccionarios JSON, ni dependencias de paquetes como `dio` o anotaciones de serialización. La Capa de Dominio debe permanecer 100% agnóstica a la existencia de una API.*

## 5. Estado Actual del Proyecto

* **Repositorio Backend:** Inicializado. Recursos frontend eliminados. Rutas API habilitadas. Directorio `src/` creado y mapeado.
* **Repositorio Frontend:** Inicializado. App de contador por defecto limpiada. Dependencias base instaladas (`dio`, `go_router`, `flutter_bloc`, `equatable`, `shared_preferences`). Directorios base (`core/`, `features/`) creados. `.gitignore` actualizado para secretos y Firebase.

## 6. Próximos Pasos Inmediatos para el Agente de IA

1. Comenzar la implementación de la **Capa de Dominio** para la primera funcionalidad core (ej. `Auth` o `Paqueteria`).
2. Crear las **Entidades** puras (ej. `Usuario`, `Encomienda`).
3. Crear los **Casos de Uso** que contienen las reglas de negocio.
4. Definir las **Interfaces de los Repositorios** (Contratos).
   *Regla: No implementar Modelos de Datos, Fuentes de Datos o UI/Controladores hasta que la capa de Dominio de la funcionalidad específica esté completa y revisada.*

## 7. Bitácoras de Agentes y Logs del Sistema

Son dos cosas **distintas** y no deben confundirse: la bitácora es documentación versionada del trabajo del agente; los logs del sistema son salida de ejecución **no versionada**.

### 7.1 Bitácora de Agentes (obligatoria)

* **Qué es:** registro narrativo del trabajo realizado por el agente de IA en cada repositorio (qué se hizo, decisiones de diseño, verificación y pendientes).
* **Ubicación:** `docs/agents_log/` en la raíz de **cada** repositorio (`torre-manager-backend` y `torre_manager_frontend`). Está **versionada en Git**.
* **Uso obligatorio:** al cerrar cada paso o hito, el agente **DEBE crear o actualizar** la bitácora correspondiente **antes** de dar la tarea por terminada. No es opcional.
* **Nomenclatura:** `YYYY-MM-DD_modulo_descripcion.md` (ej. `2026-10-19_auth_pasos-1-2-3.md`).
* **Contenido mínimo:** fecha, branch, contexto, cambios realizados, decisiones de diseño, verificación y pendientes.
* **Regla Cero de Secretos:** la bitácora **jamás** debe contener credenciales, tokens, API keys, correos o nombres reales, cadenas de conexión, contenido de `.env` ni rutas absolutas del entorno local. Este repositorio es público.

### 7.2 Logs del Sistema (runtime)

* **Herramienta:** se usa el **logging nativo de Laravel (Monolog)** mediante el facade `Log` o el contrato **PSR-3** (`Psr\Log\LoggerInterface`). No crear mecanismos propios ni agregar paquetes de logging sin aprobación.
* **Ubicación:** `storage/logs/` (ej. `storage/logs/laravel.log`). **Prohibido** crear un directorio `logs/` en la raíz del repositorio o **versionar logs de runtime** en Git.
* **Visualización:** el archivo `storage/logs/laravel.log`, `docker compose logs -f app` (salida a stderr) y `php artisan pail` en desarrollo.
* **Dónde loguear:** únicamente en la capa de **infraestructura** (controladores, middleware y repositorios de la capa de Datos). El Dominio es puro y **no** escribe logs.
* **Prohibido** loguear contraseñas, tokens, hashes o datos personales (PII).
