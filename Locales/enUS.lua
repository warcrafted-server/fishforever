local ADDON, ns = ...

local L = {
    ADDON_NAME = "FishForever",

    SLASH_HELP_HEADER = "Available commands:",
    SLASH_HELP_ENTRY = "  /ff %s - %s",
    SLASH_HELP_HELP = "Show this help.",
    SLASH_HELP_VERSION = "Show the addon version.",

    MSG_UNKNOWN_COMMAND = "Unknown command: %s.",
    MSG_HELP_HINT = "Type /ff help to see the available commands.",
    MSG_VERSION = "Version %s.",
    VERSION_UNKNOWN = "unknown",
    MSG_DATA_NEWER = "Your saved data comes from a newer version of FishForever. It will not be modified; please update the addon.",
}

setmetatable(L, {
    __index = function(_, key)
        return key
    end,
})

ns.L = L
