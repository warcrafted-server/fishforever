# Changelog

Todos los cambios relevantes de este proyecto se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto usa [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

## [0.4.0] - 2026-11-14

### Añadido

- Aviso en el centro de la pantalla al lanzar con pocos huecos en las bolsas (5 o menos, en ámbar) o con las bolsas llenas (en naranja), como mucho una vez por minuto. Nunca bloquea el lanzamiento.
- Oro por hora en la ventana de la sesión (cuarta tarjeta) y valor de venta total de lo pescado.
- `/ff diag` incluye los huecos libres de las bolsas y precios de venta de ejemplo.

### Cambiado

- Aspecto nativo del juego: el botón flotador y el de cebo son botones de acción como los de tus barras (marco del juego, tecla asignada en la esquina, barrido de tiempo y destello al capturar). El botón de cebo late en dorado cuando llevas la caña sin cebo y te quedan en las bolsas.
- La ventana de la sesión usa el marco de ventana del juego, con retrato, título y cierre nativos, tarjetas con capturas, capturas por hora y éxito, y filas con el icono enmarcado por rareza, barra de proporción y tooltip del objeto. «Reiniciar» es el botón rojo del juego.

### Corregido

- El botón flotador ya no se queda iluminado como pulsado al lanzar o recoger con la tecla.
- El aviso «Se acabó el cebo» ya no sale al entrar o salir del modo pesca; solo cuando el cebo se agota de verdad.

## [0.3.0] - 2026-11-14

### Añadido

- Botón de cebo junto al botón flotador con su propio atajo («Poner cebo» en Accesorios > FishForever): una pulsación pone en la caña el mejor cebo de las bolsas. Muestra cuántos cebos quedan y el tiempo restante del cebo puesto (verde, ámbar y rojo); el borde se vuelve naranja con la caña sin cebo.
- Aviso con sonido cuando el cebo se acaba en modo pesca, con la tecla para poner otro.
- `/ff diag` incluye los objetos de las bolsas y el cebo de la caña.

## [0.2.0] - 2026-11-13

### Añadido

- Ventana de la sesión de pesca (`/ff stats` o Mayús + clic izquierdo en el botón del minimapa): tiempo pescando, lanzamientos, capturas, escapados, capturas por hora, porcentaje de éxito y lista de lo pescado con icono y color de rareza. Se mantiene al recargar la interfaz y empieza de cero al entrar al juego; «Reiniciar» pide confirmación y no borra el registro de capturas.

### Cambiado

- `/ff stats` abre la ventana de la sesión en lugar de mostrar las capturas pendientes de compartir.

## [0.1.0] - 2026-11-13

### Añadido

- Esqueleto del addon: `FishForever.toc` (interfaz 16001), namespace y despachador de eventos, comandos `/ff` y `/fishforever` (`help`, `version`) y localización esES/enUS.
- SavedVariables `FishForeverDB` (cuenta) y `FishForeverCharDB` (personaje) con versión de esquema, estructura de hallazgos y de consentimiento, y migraciones secuenciales. Los datos de una versión más nueva del addon no se tocan.
- Registro persistente: todo lo que el addon escribe en el chat queda también en SavedVariables.
- `/ff diag`: diagnóstico de API, CVars, atajos de teclado, hechizos y profesiones guardado en SavedVariables.
- `/ff debug`: grabador de eventos de pesca y botín para analizar la picada.
- Registro de capturas siempre activo: qué se pesca en cada mapa y en qué puntos, aunque la compartición esté desactivada. `/ff stats` muestra las capturas pendientes de compartir.
- Modo pesca (`/ff fish` o clic derecho en el botón): equipa la caña de las bolsas y devuelve el arma y el escudo anteriores; en combate se aplaza hasta salir de él.
- Botón flotador seguro: una pulsación lanza la caña y, con el corcho en el agua, la misma tecla lo recoge (atajo en Accesorios > FishForever). Anillo de tiempo verde, ámbar y rojo, y aviso de captura o pez escapado. `/ff button` y `/ff lock`.
- Realce de sonido al pescar (efectos al máximo, música y ambiente bajados) para oír la picada, ya que el cliente no la notifica; se restaura al dejar de pescar. `/ff sound` lo activa o desactiva.
- La pesca va directa a las bolsas al recogerla (sin hacer clic en la ventana de botín).
- Botón en el minimapa: clic izquierdo muestra u oculta el botón flotador (oculto por defecto) y clic derecho activa o desactiva el modo pesca. `/ff minimap` lo oculta.
- El botón flotador muestra la tecla para recoger mientras pescas y, al activar el modo pesca sin tecla asignada, avisa de dónde asignarla.

### Cambiado

- Titular de la licencia y autor unificados como WarCrafted.

### Limitaciones conocidas

- Este cliente no tiene `/interact`: un clic en el botón flotador lanza, pero solo la tecla (o el clic derecho sobre el corcho) recoge.

## [0.0.1] - 2026-11-12

### Añadido

- Documentación inicial: README en español e inglés, hoja de ruta (`docs/ROADMAP.md`) y notas de diseño (`docs/DISENO.md`).
- Licencia WNCL-1.0 (uso no comercial, con atribución a warcrafted).
- `TODO.md` con los datos pendientes y el trabajo de la 0.1.0.
