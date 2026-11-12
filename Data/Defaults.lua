local ADDON, ns = ...

-- Bump SCHEMA_VERSION only together with a new entry in ns.migrations (Core/SavedVars.lua).
ns.SCHEMA_VERSION = 1

-- Bump when the consent notice gains something relevant, so it is shown again once.
ns.NOTICE_VERSION = 1

-- Account-wide data. Never store character names or per-character history here:
-- finds are meant to be shared and must stay non-personal.
ns.defaults = {
    schemaVersion = ns.SCHEMA_VERSION,
    log = {},
    debug = { enabled = false },
    debugLog = {},

    consent = {
        noticeSeen = 0,          -- last NOTICE_VERSION acknowledged
        shareGroup = true,
        shareGuild = true,
        community = {
            neverAsk = false,
            lastPrompt = 0,      -- time() of the last reminder shown
            lastExport = 0,      -- time() of the last export
            catchThreshold = 150,
            dayThreshold = 14,
        },
    },

    finds = {
        -- pools["<mapID>:<x>:<y>"] = { mapID, x, y, seen = count, firstSeen = time(), shared = bool }
        -- x and y are rounded map coordinates (0-1000) so the same pool merges.
        pools = {},
        -- catches[mapID][itemID] = { total = n, shared = n }; pending = total - shared
        catches = {},
        -- spots["<mapID>:<x>:<y>"] = { mapID, x, y, catches, firstSeen, lastSeen, shared }
        -- where the player caught something; pool detection comes later.
        spots = {},
    },

    settings = {
        autoLoot = true,     -- take fishing loot straight to the bags
        button = {
            shown = false,
            locked = false,
            point = "CENTER",
            x = 0,
            y = -150,
            scale = 1,
        },
        alert = {
            sound = true,
            flash = true,
        },
    },
}

ns.charDefaults = {
    schemaVersion = ns.SCHEMA_VERSION,
    -- Items equipped before entering fishing mode, restored on exit.
    savedGear = {},
    fishingMode = false,
}
