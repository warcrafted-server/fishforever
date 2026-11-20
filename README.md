# FishForever

[English](README.en.md)

Addon de pesca para **WoW Forever**: botón flotador de un toque, caja de aparejos con temporizador de cebos, estadísticas y mapa colaborativo de bancos de peces.

> **Estado:** 0.4.0. Cada día se van añadiendo novedades ya probadas en el juego.

## Qué hace

- **Modo pesca:** equipa la caña de tus bolsas y al salir devuelve tu arma y escudo. En combate espera a que termine.
- **Una tecla para lanzar y recoger:** una pulsación = una acción. No es un bot: nunca lanza ni recoge solo.
- **El botín va directo a las bolsas.**
- **Cebos con una pulsación:** el botón de cebo (o su tecla) pone el mejor cebo de tus bolsas y muestra su tiempo restante; avisa cuando se acaba.
- **Oye la picada:** al pescar suben los efectos de sonido y bajan la música y el ambiente.
- **Aspecto nativo:** botones de acción como los de tus barras (tecla, barrido de tiempo, destello al capturar), y **botón en el minimapa**.
- **Asesor de zona y nivel** (`/ff zone`): si puedes pescar donde estás y qué zonas probar.
- **Panel de opciones** nativo (`/ff options`) con todos los ajustes.
- **Aviso de bolsas** al lanzar con pocos huecos libres.
- **Registro local de capturas:** qué pescas y dónde.

- **Estadísticas de la sesión:** tiempo, capturas y oro por hora, éxito y lo pescado por rareza.

Próximamente: asesor de zona y mapa colaborativo de bancos. La hoja de ruta completa está en [docs/ROADMAP.md](docs/ROADMAP.md).

## Requisitos

- Cliente de WoW Forever.

## Instalación

- **CurseForge:** busca FishForever en la app de CurseForge o en https://www.curseforge.com/wow/addons/fishforever.
- **Manual:** descomprime la carpeta `FishForever` en `World of Warcraft\_forever_\Interface\AddOns\` y reinicia el juego.

## Uso

1. Asigna una tecla en **Atajos de teclado > Accesorios > FishForever > Lanzar / recoger**.
2. Clic derecho en el botón del minimapa para entrar en el modo pesca (equipa la caña).
3. Pulsa la tecla para lanzar y, cuando pique, otra vez para recoger. También puedes recoger con clic derecho sobre el corcho.
4. Para poner el cebo, asigna una tecla en **Accesorios > FishForever > Poner cebo** o haz clic en el botón pequeño de la esquina del botón flotador.
5. Clic derecho en el botón del minimapa para volver a tu arma y escudo.

El clic izquierdo en el botón del minimapa muestra u oculta el botón flotador; con Mayús + arrastrar lo mueves.

| Comando | Qué hace |
|---|---|
| `/ff` | Ayuda |
| `/ff fish` | Activa o desactiva el modo pesca |
| `/ff button` | Muestra u oculta el botón flotador |
| `/ff lock` | Bloquea o desbloquea su posición |
| `/ff sound` | Activa o desactiva el realce de sonido |
| `/ff minimap` | Muestra u oculta el botón del minimapa |
| `/ff zone` | Consejo de pesca para la zona actual según tu nivel |
| `/ff options` | Abre el panel de opciones (también Mayús + clic derecho en el minimapa) |
| `/ff stats` | Ventana de la sesión de pesca (también Mayús + clic izquierdo en el minimapa) |

## Privacidad

Hoy FishForever no envía nada: las capturas se guardan solo en tu equipo. Cuando llegue la compartición, FishForever compartirá con tu grupo y hermandad **solo datos no personales**: coordenadas de bancos, qué se pesca y dónde, y conteos. Nunca el nombre del personaje ni un historial individual. La compartición podrá desactivarse en Opciones y, al desactivarla, el addon deja de enviar. El addon no se conecta a internet: para aportar a la comunidad generará una cadena de texto que tú decides si pegas en la web de Warcrafted. Detalles en [docs/DISENO.md](docs/DISENO.md).

## Créditos y licencia

**FishForever** está desarrollado y mantenido por **WarCrafted**.
Copyright (C) 2026 WarCrafted.

Licencia [WNCL-1.0](LICENSE): puedes usarlo, estudiarlo, modificarlo y compartirlo gratis con fines no comerciales. Venderlo o cualquier uso comercial requiere permiso por escrito.

Las copias y los forks deben conservar esta atribución y enlazar a https://github.com/warcrafted-server/fishforever.

### Material de terceros

Este proyecto no contiene material de terceros.

Web: https://portal.warcrafted.com/
