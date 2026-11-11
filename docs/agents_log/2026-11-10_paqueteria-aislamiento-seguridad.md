# 2026-11-10 — Paquetería: aislamiento y seguridad (frontend)

- **Módulo:** Paquetería
- **Rama:** `test-martin` (frontend)

## Contexto

Se corrigió el estado compartido entre perfiles y se ajustó el flujo de unidades,
edición y carga de fotografías para funcionar de forma segura en web.

## Cambios realizados

- El estado de Paquetería se limpia al iniciar sesión con una identidad y al
  cerrar sesión; las consultas muestran carga sin conservar paquetes previos.
- Las respuestas asíncronas iniciadas antes del cambio de identidad ya no pueden
  volver a poblar paquetes o unidades en el estado actual.
- El DTO conserva los identificadores del proyecto y la unidad principal.
- El registro usa el proyecto de la unidad elegida y no solicita un ID de
  residente editable por el operador.
- La edición conserva la unidad original, deriva el destinatario en el servidor
  y valida descripción y remitente antes de enviar.
- Las fotos circulan como bytes y nombre de archivo en el selector, vista previa
  y carga multipart, evitando dependencias de rutas locales en Flutter Web.
- Se añadieron pruebas de mapeo de identificadores y de respuesta tardía tras
  limpiar la identidad.

## Decisiones de diseño

- Se usa un contador de generación del estado de identidad para ignorar
  respuestas asíncronas obsoletas, incluso si llegan después de cerrar sesión.
- No se puede editar un paquete histórico sin unidad asociada; se informa al
  operador en vez de enviar una actualización incompleta.

## Verificación

- `flutter analyze`: sin observaciones.
- `flutter test`: 41 pruebas aprobadas.
- `flutter build web --dart-define=API_BASE_URL=http://localhost:8000`: aprobado.

## Pendientes

- Pruebas manuales adicionales del cambio de perfil y registro/edición de
  paquetes desde navegador.

## Corrección de vistas previas fotográficas

- Se conservaron las imágenes guardadas en tarjetas y detalles de residente y
  conserje, además de la vista previa en edición.
- El diálogo de registro ahora se reconstruye al elegir una foto y muestra su
  vista previa debajo del selector antes de enviar el formulario.
- Verificación posterior: `flutter analyze` sin observaciones, `flutter test`
  con 41 pruebas aprobadas y compilación Web aprobada.
- Prueba manual en navegador: conserjería ve una fotografía guardada en la lista;
  la carga de imagen terminó sin errores de consola.

## Tarjetas en cuadrícula responsive

- Las listas de residente y conserjería usan tarjetas verticales con la imagen o
  un ícono de reemplazo arriba y los datos debajo.
- La grilla muestra una columna en móvil, dos en tablet y tres en escritorio;
  se conservaron el detalle, la búsqueda y las acciones de conserjería.
- No se cambiaron API, backend ni datos.
- Verificación: `flutter analyze` sin observaciones, `flutter test` con 41
  pruebas aprobadas y compilación Web aprobada. Revisión visual manual en
  conserjería confirmó la tarjeta con imagen y otra con ícono de reemplazo.
- Pendiente: revisión visual manual de la grilla del residente.

## Tarjetas compactas con fotografía expandible

- Las grillas de residente y conserjería usan un ancho máximo por tarjeta
  (320 y 330 px respectivamente) en lugar de un número fijo de columnas, por lo
  que se muestran más tarjetas angostas en pantallas amplias.
- La fotografía ocupa todo el alto restante de la tarjeta mediante `Expanded`,
  en vez de un alto fijo, y conserva `BoxFit.contain`. El contenido queda
  compacto debajo y ya no se reserva un espacio vacío antes del estado.
- En conserjería, el estado y las acciones usan `Wrap` para mantenerse dentro de
  tarjetas angostas.
- No se modificaron API, backend, datos ni acciones disponibles.
- Verificación: `flutter analyze` sin observaciones, `flutter test` con 41
  pruebas aprobadas y compilación Web aprobada.

## Ajuste de tamaño y encaje de imágenes

- Se redujo la altura de las tarjetas de residente a 340 px y de conserjería a
  370 px, compactando los espacios internos sin retirar datos ni acciones.
- El área de imagen aumentó a 190 px de alto; `BoxFit.contain` mantiene visible
  la imagen completa dentro del ancho disponible, con fondo neutro para los
  márgenes que aparezcan según su proporción.
- Verificación: `flutter analyze` sin observaciones, `flutter test` con 41
  pruebas aprobadas y compilación Web aprobada. En navegador se confirmó la
  tarjeta compacta y la foto ajustada completa en la lista de conserjería.
- No hubo cambios de API, backend ni datos.

## Detalle de paquete ampliado

- El diálogo de detalle ahora admite hasta 820 px de ancho y 90% del alto de la
  pantalla, con márgenes reducidos.
- La fotografía ocupa un área de hasta 540 px de alto, calculada según la
  pantalla, y usa `BoxFit.contain` para mostrarse completa sin recortes.
- Los datos y acciones se mantienen debajo y el contenido puede desplazarse si
  no cabe en pantallas pequeñas.

## Corrección al confirmar retiro

- El diálogo de retiro utilizaba un controlador de texto liberado antes de que
  terminara su animación de salida, lo que provocaba una aserción al confirmar.
- Ahora el diálogo administra su propio controlador y lo libera al desaparecer;
  la pantalla solo recibe el nombre confirmado.
- La acción desde el detalle del paquete abre el formulario después de cerrar el
  detalle, evitando operaciones de navegación superpuestas.
- Verificación: `flutter analyze` sin observaciones, `flutter test` con 41
  pruebas aprobadas y compilación Web aprobada.
- Verificación: `flutter analyze` sin observaciones, `flutter test` con 41
  pruebas aprobadas y compilación Web aprobada.
