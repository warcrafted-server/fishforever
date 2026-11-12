local ADDON, ns = ...

local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then
    return
end

local L = ns.L

local translations = {
    ADDON_NAME = "FishForever",

    SLASH_HELP_HEADER = "Comandos disponibles:",
    SLASH_HELP_ENTRY = "  /ff %s - %s",
    SLASH_HELP_HELP = "Muestra esta ayuda.",
    SLASH_HELP_VERSION = "Muestra la versión del addon.",
    SLASH_HELP_DIAG = "Comprueba qué API del cliente hay y guarda el resultado en FishForeverDB.diag.",
    SLASH_HELP_DEBUG = "Activa o desactiva el registro de eventos guardado en FishForeverDB.debugLog.",

    MSG_UNKNOWN_COMMAND = "Comando desconocido: %s.",
    MSG_HELP_HINT = "Escribe /ff help para ver los comandos disponibles.",
    MSG_VERSION = "Versión %s.",
    VERSION_UNKNOWN = "desconocida",
    SLASH_HELP_STATS = "Muestra cuántas capturas hay registradas y sin compartir.",
    MSG_STATS = "Capturas registradas y sin compartir: %d.",
    MSG_DATA_NEWER = "Tus datos guardados son de una versión más nueva de FishForever. No se modificarán; actualiza el addon.",

    MSG_DIAG_IN_COMBAT = "El diagnóstico no puede ejecutarse en combate. Inténtalo de nuevo al salir.",
    MSG_DIAG_SAVED = "Diagnóstico guardado (%d encontradas, %d ausentes). Haz /reload y lee FishForeverDB.diag.",
    MSG_DIAG_FAILED = "No se pudo completar el diagnóstico. Revisa el chat para más detalles.",
    MSG_DIAG_NOT_READY = "FishForever todavía se está cargando. Inténtalo de nuevo en un momento.",
    MSG_DEBUG_ON = "Registro de eventos activado. Pesca unas cuantas veces, haz /reload y lee FishForeverDB.debugLog.",
    MSG_DEBUG_OFF = "Registro de eventos desactivado.",
}

for key, value in pairs(translations) do
    L[key] = value
end
