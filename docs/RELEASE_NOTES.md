## 0.6.0 (2026-11-17)

### Added
- Zone and skill advisor: **/ff zone** tells you whether you can fish in the current zone at your level (minimum Fishing skill per zone, from the WoW Classic table), whether fish still escape and from which skill they stop, and which zones to try next.
- Advisor warnings: when you turn on fishing mode in a zone your skill does not reach yet, and when your Fishing is close to its maximum so you remember to train.
- The session window shows a line with your Fishing skill and the zone.
- An "Advisor" section in the options panel to turn the tips on or off.

## 0.6.0 (2026-11-17)

### Añadido
- Asesor de zona y nivel de pesca: **/ff zone** dice si puedes pescar en la zona actual con tu nivel (Pesca mínimo por zona, tabla de WoW Classic), si todavía se te escapan peces y a partir de qué nivel no, y qué zonas probar a continuación.
- Avisos del asesor: al activar el modo pesca en una zona a la que aún no llega tu nivel, y cuando tu Pesca se acerca a su máximo para recordarte entrenar.
- La ventana de la sesión muestra una línea con tu nivel de Pesca y la zona.
- Sección «Asesor» en el panel de opciones para activar o desactivar los consejos.

## 0.5.0 (2026-11-16)

### Added
- Native options panel (**/ff options**, under Options > AddOns > FishForever) with everything configurable: loot straight to the bags, floating button (show, lock, size, messages, key, catch flash), lures (button, hide it when you have none, warning and sound), sound (boost, music and ambience level, restore delay), bag warning (on or off and how many free slots) and the minimap button.
- Option to hide the lure button when you have no lures in your bags or on your pole (on by default).

### Changed
- The minimap button, the bag warning, the lure warning and the sound boost now read their settings from the panel and apply them right away.

## 0.5.0 (2026-11-16)

### Añadido
- Panel de opciones nativo (**/ff options**, en Opciones > Addons > FishForever) con todo lo configurable: botín directo a las bolsas, botón flotador (mostrar, bloquear, tamaño, mensajes, tecla, destello), cebos (botón, ocultarlo sin cebos, aviso y sonido), sonido (realce, nivel de música y ambiente, tiempo de restauración), aviso de bolsas (activarlo y cuántos huecos libres) y botón del minimapa.
- Opción para ocultar el botón de cebo cuando no tienes cebos en las bolsas ni en la caña (activada por defecto).

### Cambiado
- El botón del minimapa, el aviso de bolsas, el aviso del cebo y el realce de sonido leen ahora sus ajustes del panel y los aplican al momento.

## 0.4.1 (2026-11-15)

### Changed
- The lure button hides when you have no lures in your bags or on your pole, and comes back when you get one.

### Added
- A warning when you log in with the published addon and a development copy enabled at the same time, since they clash.
- Fishing mode now tells you when it has no weapon to swap back (for example when the pole was already equipped) instead of doing nothing.

## 0.4.1 (2026-11-15)

### Cambiado
- El botón de cebo se oculta cuando no tienes cebos en las bolsas ni en la caña, y vuelve a aparecer al conseguir uno.

### Añadido
- Aviso al entrar al juego si el addon publicado y una copia de desarrollo están activos a la vez, porque chocan entre sí.
- El modo pesca ahora avisa cuando no tiene arma que devolver (por ejemplo, si la caña ya estaba equipada) en lugar de no hacer nada.

## 0.4.0 (2026-11-14)

### Added
- Bag space warning in the centre of the screen when you cast with 5 or fewer free slots (amber) or with full bags (orange), at most once a minute. It never blocks the cast.
- Gold per hour in the session window (a fourth card) and the total vendor value of your catch.

### Changed
- Native game look: the floating button and the lure button are action buttons like the ones on your bars (game frame, bound key in the corner, timer sweep and a flash when you catch something). The lure button pulses gold when your pole has no lure and you have some in your bags.
- The session window uses the game's own window frame, with portrait, title and close button, summary cards and rows with rarity-framed icons, a share bar and the item tooltip. Reset is the game's red button.

### Fixed
- The floating button no longer stays lit as pressed after casting or looting with the key.
- "Your lure ran out" no longer appears when entering or leaving fishing mode, only when the lure really runs out.

## 0.4.0 (2026-11-14)

### Añadido
- Aviso en el centro de la pantalla al lanzar con 5 huecos libres o menos (ámbar) o con las bolsas llenas (naranja), como mucho una vez por minuto. Nunca bloquea el lanzamiento.
- Oro por hora en la ventana de la sesión (cuarta tarjeta) y valor de venta total de lo pescado.

### Cambiado
- Aspecto nativo del juego: el botón flotador y el de cebo son botones de acción como los de tus barras (marco del juego, tecla asignada en la esquina, barrido de tiempo y destello al capturar). El botón de cebo late en dorado cuando la caña no lleva cebo y te quedan en las bolsas.
- La ventana de la sesión usa el marco de ventana del juego, con retrato, título y cierre, tarjetas de resumen y filas con el icono enmarcado por rareza, barra de proporción y tooltip del objeto. «Reiniciar» es el botón rojo del juego.

### Corregido
- El botón flotador ya no se queda iluminado como pulsado al lanzar o recoger con la tecla.
- «Se acabó el cebo» ya no sale al entrar o salir del modo pesca; solo cuando el cebo se agota de verdad.

## 0.3.0 (2026-11-14)

### Added
- Lure button next to the floating button, with its own key (Key Bindings > AddOns > FishForever > Apply lure): one press applies the best lure in your bags to the fishing pole. It shows how many lures you have and the time left on the pole (green, amber, red); its border turns orange when the pole has no lure.
- A warning with a sound when your lure runs out in fishing mode, telling you the key to apply another.

## 0.3.0 (2026-11-14)

### Añadido
- Botón de cebo junto al botón flotador, con su propia tecla (Atajos de teclado > Accesorios > FishForever > Poner cebo): una pulsación pone en la caña el mejor cebo de tus bolsas. Muestra cuántos cebos te quedan y el tiempo restante en la caña (verde, ámbar y rojo); su borde se vuelve naranja si la caña no lleva cebo.
- Aviso con sonido cuando el cebo se acaba en modo pesca, con la tecla para poner otro.

## 0.2.0 (2026-11-13)

### Added
- Fishing session window (**/ff stats** or Shift + left click on the minimap button): time fishing, casts, catches, fish that got away, catches per hour, success rate and a list of what you caught with icon and rarity colour. It survives a UI reload and starts fresh when you log in; Reset asks for confirmation and never deletes your catch log.

### Changed
- **/ff stats** now opens the session window.

## 0.2.0 (2026-11-13)

### Añadido
- Ventana de la sesión de pesca (**/ff stats** o Mayús + clic izquierdo en el botón del minimapa): tiempo pescando, lanzamientos, capturas, escapados, capturas por hora, porcentaje de éxito y lista de lo pescado con icono y color de rareza. Se mantiene al recargar la interfaz y empieza de cero al entrar al juego; «Reiniciar» pide confirmación y no borra el registro de capturas.

### Cambiado
- **/ff stats** ahora abre la ventana de la sesión.

## 0.1.0 (2026-11-13) — first release

**Fishing with one key** for World of Warcraft: Forever.

### Added
- Fishing mode: right-click the minimap button (or **/ff fish**) to equip your fishing pole from your bags; again to get your weapon and shield back. Waits for combat to end.
- One key to cast and loot (Key Bindings > AddOns > FishForever). One press, one action: it never casts or loots on its own.
- Fishing loot goes straight to your bags.
- Sound boost while fishing so you hear the bite; your volumes come back afterwards (**/ff sound**).
- Floating button with a time ring, the loot key and catch or escaped messages (**/ff button**, **/ff lock**); minimap button (**/ff minimap**).
- Local catch log (**/ff stats**). Nothing is sent anywhere.
- English and Spanish.

### Known limits
- Clicking the floating button casts, but only the key (or a right click on the bobber) loots: this client has no way for an addon button to loot.

## 0.1.0 (2026-11-13) — primera versión

**Pescar con una sola tecla** en World of Warcraft: Forever.

### Añadido
- Modo pesca: clic derecho en el botón del minimapa (o **/ff fish**) para equipar la caña de tus bolsas; otra vez para recuperar arma y escudo. Espera a que acabe el combate.
- Una tecla para lanzar y recoger (Atajos de teclado > Accesorios > FishForever). Una pulsación, una acción: nunca lanza ni recoge solo.
- El botín de pesca va directo a las bolsas.
- Realce de sonido al pescar para oír la picada; después vuelven tus volúmenes (**/ff sound**).
- Botón flotador con anillo de tiempo, la tecla para recoger y aviso de captura o pez escapado (**/ff button**, **/ff lock**); botón en el minimapa (**/ff minimap**).
- Registro local de capturas (**/ff stats**). No se envía nada a ningún sitio.
- Español e inglés.

### Limitaciones conocidas
- Un clic en el botón flotador lanza, pero solo la tecla (o el clic derecho sobre el corcho) recoge: este cliente no permite que un botón de addon recoja.
