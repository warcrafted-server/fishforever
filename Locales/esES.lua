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

    MSG_UNKNOWN_COMMAND = "Comando desconocido: %s.",
    MSG_HELP_HINT = "Escribe /ff help para ver los comandos disponibles.",
    MSG_VERSION = "Versión %s.",
    VERSION_UNKNOWN = "desconocida",
}

for key, value in pairs(translations) do
    L[key] = value
end
