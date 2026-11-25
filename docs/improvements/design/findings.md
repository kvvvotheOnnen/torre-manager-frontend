# Mejoras de diseño — hallazgos seleccionados

> Revisión de UI/UX del app Flutter (`torre_manager_frontend`). Solo se
> seleccionaron las peticiones directas del desarrollador; no se eligieron
> reglas del catálogo. Cada hallazgo tiene su plan en `plans/`.

**12. Botón "Siguiente" pegado al fondo de la pantalla (tu petición)**

En el wizard de registro, la barra de navegación ("Atrás / Siguiente") queda anclada casi al borde inferior del eje Y, lejos del contenido, así que el pulgar o el cursor recorren un camino largo entre el último campo y la acción. La navegación debería quedar más cerca del contenido que el usuario acaba de llenar, con una separación visual coherente.

- **Origen:** petición directa del desarrollador (no es una regla del catálogo).

**13. Armonía de separaciones y centrado de componentes (tu petición)**

Las pantallas mezclan valores de espaciado distintos entre componentes (márgenes, paddings y huecos que no siguen una misma escala), y el contenido no siempre queda centrado en pantalla: en algunas vistas se ve pegado a un lado o con anchos inconsistentes. Unificar la escala de separación y centrar los bloques de contenido da calma visual y consistencia entre pantallas.

- **Origen:** petición directa del desarrollador (no es una regla del catálogo).

**14. Mejora del aspecto visual general (tu petición)**

El wizard y otras pantallas nuevas se ven funcionales pero planas comparadas con el login: jerarquía de títulos, peso de las tarjetas y acabado de los controles no siguen el mismo lenguaje visual. Un repaso general de aspecto (tarjetas, botones, cabeceras, estados vacíos) elevaría la percepción de calidad del resto del sistema.

- **Origen:** petición directa del desarrollador (no es una regla del catálogo).

**15. Quitar el fondo de cuadros de todo el sistema, salvo el login (tu petición)**

El fondo con patrón de cuadros (grid) se usa actualmente en varias pantallas del sistema. Ese fondo debería existir únicamente en el login, como firma visual de entrada; el resto del sistema debería usar un fondo sobrio para no competir con el contenido.

- **Origen:** petición directa del desarrollador (no es una regla del catálogo).
