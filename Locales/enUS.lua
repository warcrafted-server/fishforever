local ADDON, ns = ...

local L = {
    ADDON_NAME = "FishForever",

    SLASH_HELP_HEADER = "Available commands:",
    SLASH_HELP_ENTRY = "  /ff %s - %s",
    SLASH_HELP_HELP = "Show this help.",
    SLASH_HELP_VERSION = "Show the addon version.",
    SLASH_HELP_DIAG = "Check which client APIs are present and save the result to FishForeverDB.diag.",
    SLASH_HELP_DEBUG = "Toggle the event recorder saved to FishForeverDB.debugLog.",

    MSG_UNKNOWN_COMMAND = "Unknown command: %s.",
    MSG_HELP_HINT = "Type /ff help to see the available commands.",
    MSG_VERSION = "Version %s.",
    VERSION_UNKNOWN = "unknown",
    SLASH_HELP_STATS = "Show how many catches are recorded and not yet shared.",
    MSG_STATS = "Catches recorded and not yet shared: %d.",
    MSG_DATA_NEWER = "Your saved data comes from a newer version of FishForever. It will not be modified; please update the addon.",

    MSG_DIAG_IN_COMBAT = "The diagnostic cannot run in combat. Try again after combat.",
    MSG_DIAG_SAVED = "Diagnostic saved (%d found, %d missing). Do /reload and read FishForeverDB.diag.",
    MSG_DIAG_FAILED = "The diagnostic could not be completed. Check the chat for details.",
    MSG_DIAG_NOT_READY = "FishForever is still loading. Try again in a moment.",
    MSG_DEBUG_ON = "Event recording enabled. Fish a few times, then do /reload and read FishForeverDB.debugLog.",
    MSG_DEBUG_OFF = "Event recording disabled.",
}

setmetatable(L, {
    __index = function(_, key)
        return key
    end,
})

ns.L = L
