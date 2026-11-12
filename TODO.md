# TODO

## Alta prioridad (0.1.0)

- Confirmar el número de interfaz (`## Interface`) con `/dump select(4, GetBuildInfo())`. Cliente conocido: versión 1.60.1, build 70888 (9 nov 2026).
- Verificar en el cliente las API que se usarán (mensajes de addon, equipamiento, botón seguro) antes de depender de ellas.
- Esqueleto del addon: `.toc`, `Core`, `Locales` (esES/enUS), `Modules`, `UI`, `Data`.
- SavedVariables con versión de esquema, estructura de hallazgos y consentimiento, y migraciones.
- Modo pesca, botón flotador de un toque y aviso de picada.
- `.pkgmeta` y GitHub Action de publicación en CurseForge (BigWigs packager).
- Crear el proyecto en CurseForge y poner su ID en `## X-Curse-Project-ID`.

## Media prioridad

- Aplicar el estilo visual de Lorewake (en espera: Lorewake se está actualizando; esperar aviso).
- Configurar `luacheck`.

## Siguientes versiones

Ver [docs/ROADMAP.md](docs/ROADMAP.md).
