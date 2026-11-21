# Changelog

Todos los cambios relevantes de este proyecto se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto usa [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

## [0.8.0] - 2026-11-21

### Añadido

- Botón «Zonas» en la ventana de la sesión: abre una ventana con las zonas de pesca recomendadas para tu nivel, las que no pierden peces y las siguientes a probar, con la regla de escapes explicada.

## [0.7.0] - 2026-11-20

### Añadido

- Mayús + clic derecho en el botón del minimapa abre el panel de opciones, y el tooltip del botón lo indica.

## [0.6.1] - 2026-11-18

### Corregido

- La barra de proporción de cada objeto en la ventana de la sesión vuelve a ser fina y ya no se superpone al nombre del objeto.

## [0.6.0] - 2026-11-17

### Añadido

- Asesor de zona y nivel de pesca: `/ff zone` dice si puedes pescar en la zona actual con tu nivel (Pesca mínimo por zona, tabla de WoW Classic), si todavía se te escapan peces y a partir de qué nivel no, y qué zonas probar a continuación.
- Avisos del asesor: al activar el modo pesca en una zona donde aún no llega tu nivel, y cuando tu Pesca se acerca a su máximo para recordarte entrenar.
- La ventana de la sesión muestra una línea con tu nivel de Pesca y la zona.
- Sección «Asesor» en el panel de opciones para activar o desactivar los consejos.

## [0.5.0] - 2026-11-16

### Añadido

- Panel de opciones nativo (`/ff options`, en Opciones > Addons > FishForever) con todo lo configurable: botín directo a las bolsas, mostrar el botón flotador en modo pesca, sesión nueva al entrar al juego, botón flotador (mostrar, bloquear, tamaño, mensajes, tecla, destello), cebos (mostrar el botón, ocultarlo sin cebos, aviso y sonido), sonido (realce, efectos al máximo, nivel de música y ambiente, tiempo de restauración), bolsas (aviso y umbral de huecos) y minimapa.
- Opción para que el botón de cebo se oculte cuando no tienes cebos en las bolsas ni en la caña (activada por defecto, como en la 0.4.1).

### Cambiado

- El botón del minimapa, el aviso de bolsas, el aviso del cebo y el realce de sonido leen ahora sus ajustes del panel y los aplican al momento.

## [0.4.1] - 2026-11-15

### Cambiado

- El botón de cebo se oculta cuando no tienes cebos en las bolsas ni en la caña, y vuelve a aparecer al conseguir uno.

### Añadido

- Aviso al entrar al juego si el addon publicado y la copia de desarrollo están activos a la vez, porque chocan entre sí.
- Al activar el modo pesca con la caña ya equipada, o al desactivarlo sin arma guardada, el addon lo explica en el chat en lugar de no hacer nada.

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
