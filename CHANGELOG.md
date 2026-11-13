# Changelog

Todos los cambios relevantes de este proyecto se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto usa [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

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
