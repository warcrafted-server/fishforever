# Diseño / Design

## Español

### Principios

- **Una pulsación = una acción.** El addon nunca lanza ni recoge solo. Usa `SecureActionButtonTemplate` y bindings oficiales.
- **Combate:** no se modifican marcos protegidos con `InCombatLockdown()` activo; los cambios pendientes se aplican al salir de combate.
- **Solo API existentes en el cliente de WoW Forever**, verificadas antes de usarlas.
- **Un único namespace**, sin globales innecesarias. Módulos: `Core`, `UI`, `Locales`, `Data`, `Modules`.
- **Localización:** todos los textos en `Locales/`. `esES` y `esMX` usan español; cualquier otro locale, inglés.

### Interfaz

- **Botón flotador** con tres estados: reposo, lanzado y picada (parpadea y se agita).
- **Caja de aparejos** (abanico o cajón lateral al pasar el ratón) con cada cebo y su bonus.
- **Anillo de temporizador** alrededor del cebo activo (verde, ámbar, rojo) y resalte del cebo recomendado.
- Identidad propia: no se copia el diseño de otros addons de pesca.

### Estilo visual

Misma familia que Lorewake y FarmAdvisor (estilo Diario de mazmorras), con los tokens de la maqueta UI-4 de FarmAdvisor:

- Ventana `#15100b` con borde `#5a4630`; barras `#1d160f`; paneles `#191209` con borde `#2e2418`; separadores `#2a2015`.
- Título en mayúsculas pequeñas dorado `#e6b84a` (fuente `FRIZQT__`), etiquetas de sección `#c9a24a`, texto `#e9dfc8`, texto secundario `#a3957c`.
- Pestañas con subrayado dorado en la activa; botón de cerrar rojo oscuro; botón principal `#6b1d12` con borde `#b8914a`.
- Estados: correcto `#7fe08a`, falta `#ff6b62`, ámbar `#f2d43a`, naranja `#ff8a3d` (también para el anillo de temporizador verde → ámbar → rojo).

### Datos y privacidad

- Solo datos no personales: coordenadas de bancos, qué se pesca y dónde, conteos. Nunca el nombre del personaje ni historial individual.
- Compartición con grupo y hermandad **activada por defecto** y desactivable en Opciones; al desactivarla deja de enviar.
- Aviso la primera vez y tras actualizaciones relevantes, con botones *Entendido* / *Opciones*.
- Mensajes de addon con prefijo propio (API exacta pendiente de verificar en el cliente).
- **Comunidad:** el addon no envía nada a internet. Genera una cadena exportable que el jugador pega en un formulario web de Warcrafted; una GitHub Action programada valida, agrega y publica los datos en el addon `FishForever_Data`. Un banco nuevo solo entra si lo reportan varios jugadores distintos.
- Cada hallazgo se marca como compartido al exportar; hay contador de pendientes.
- **Recordatorio** (Compartir / Más tarde / No preguntar más) por N capturas sin compartir (150), X días (14) o bancos nuevos. Nunca en combate ni pescando; máximo una vez al día; umbrales configurables.

### SavedVariables

Desde la 0.1.0 incluyen `schemaVersion`, la estructura de hallazgos y la de consentimiento, con migraciones secuenciales para no romper los datos de los usuarios al actualizar.

## English

### Principles

- **One keypress = one action.** The addon never casts or loots on its own. It uses `SecureActionButtonTemplate` and official bindings.
- **Combat:** protected frames are never modified while `InCombatLockdown()` is true; pending changes apply after combat.
- **Only APIs that exist in the WoW Forever client**, verified before use.
- **Single namespace**, no unnecessary globals. Modules: `Core`, `UI`, `Locales`, `Data`, `Modules`.
- **Localization:** all strings in `Locales/`. `esES` and `esMX` use Spanish; any other locale uses English.

### Interface

- **Bobber button** with three states: idle, cast and bite (flashes and shakes).
- **Tackle box** (fan or side drawer on hover) showing each lure and its bonus.
- **Timer ring** around the active lure (green, amber, red) and highlight of the recommended lure.
- Own identity: no copying of other fishing addons. Visual style will be based on Lorewake (pending).

### Data and privacy

- Non-personal data only: pool coordinates, what is caught where, counts. Never character names or individual history.
- Group and guild sharing **on by default**, can be turned off in Options; once off, nothing is sent.
- Notice on first run and after relevant updates, with *Got it* / *Options* buttons.
- Addon messages with a custom prefix (exact API to be verified in the client).
- **Community:** the addon never sends anything to the internet. It generates an exportable string the player pastes into a Warcrafted web form; a scheduled GitHub Action validates, aggregates and publishes the data in the `FishForever_Data` addon. A new pool is only accepted once several different players report it.
- Each find is marked as shared on export; a pending counter is shown.
- **Reminder** (Share / Later / Don't ask again) after N unshared catches (150), X days (14) or new pools. Never in combat or while fishing; at most once a day; thresholds configurable.

### SavedVariables

From 0.1.0 they include `schemaVersion`, the finds structure and the consent structure, with sequential migrations so user data is never broken on update.
