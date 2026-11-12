local ADDON, ns = ...

-- Records every fishing catch locally, whatever the sharing settings say:
-- sharing only decides what leaves the client, never what is collected.

local Recorder = ns:NewModule("Recorder")

-- Known fishing spell IDs across client generations; the localized spell name
-- is also accepted so an unexpected ID on this client still matches.
local FISHING_SPELLS = {
    [7620] = true, [7731] = true, [7732] = true, [18248] = true, [33095] = true,
    [51294] = true, [88868] = true, [110410] = true, [131474] = true, [131476] = true,
    [131490] = true,
}

-- Loot opening this long after the channel ends still counts as a catch
-- when IsFishingLoot is unavailable.
local LOOT_WINDOW = 3

local fishingNames
local lastChannelEnd = 0
local channeling = false
local lastLootAt = 0

local function isSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value) or false
end

local function spellName(id)
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, id)
        if ok and type(name) == "string" and not isSecret(name) then
            return name
        end
    end
end

local function isFishingSpell(spellID)
    if isSecret(spellID) then
        return false
    end
    if FISHING_SPELLS[spellID] then
        return true
    end
    if not fishingNames then
        fishingNames = {}
        for id in pairs(FISHING_SPELLS) do
            local name = spellName(id)
            if name then
                fishingNames[name] = true
            end
        end
    end
    local name = spellName(spellID)
    return name ~= nil and fishingNames[name] == true
end

local function playerPosition()
    if not (C_Map and C_Map.GetBestMapForUnit) then
        return
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID or isSecret(mapID) then
        return
    end
    local x, y
    local pos = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(mapID, "player")
    if pos then
        x, y = pos:GetXY()
        if isSecret(x) or isSecret(y) then
            x, y = nil, nil
        end
    end
    return mapID, x, y
end

local function itemIDFromLink(link)
    if type(link) ~= "string" or isSecret(link) then
        return
    end
    return tonumber(link:match("item:(%d+)"))
end

local function isFishingLoot()
    if type(IsFishingLoot) == "function" then
        local ok, result = pcall(IsFishingLoot)
        if ok and not isSecret(result) then
            return result and true or false
        end
    end
    return channeling or (GetTime() - lastChannelEnd) <= LOOT_WINDOW
end

-- Spots are keyed by rounded map coordinates (0-1000) so nearby casts merge.
local function recordSpot(finds, mapID, x, y, now)
    if not (x and y) then
        return
    end
    local rx, ry = math.floor(x * 1000 + 0.5), math.floor(y * 1000 + 0.5)
    local key = mapID .. ":" .. rx .. ":" .. ry
    local spot = finds.spots[key]
    if not spot then
        spot = { mapID = mapID, x = rx, y = ry, catches = 0, firstSeen = now, shared = false }
        finds.spots[key] = spot
    end
    spot.catches = spot.catches + 1
    spot.lastSeen = now
end

local function recordLoot()
    local db = ns.db
    if ns.readOnlyData or type(db) ~= "table" then
        return
    end
    -- LOOT_READY and LOOT_OPENED can both fire for the same loot window.
    local now = GetTime()
    if now - lastLootAt < 0.5 or not isFishingLoot() then
        return
    end
    lastLootAt = now

    local mapID, x, y = playerPosition()
    if not mapID then
        return
    end
    local finds = db.finds
    local byMap = finds.catches[mapID]
    if not byMap then
        byMap = {}
        finds.catches[mapID] = byMap
    end

    local got = 0
    for slot = 1, (GetNumLootItems() or 0) do
        if not LootSlotHasItem or LootSlotHasItem(slot) then
            local itemID = itemIDFromLink(GetLootSlotLink(slot))
            local _, _, quantity = GetLootSlotInfo(slot)
            if isSecret(quantity) or type(quantity) ~= "number" then
                quantity = 1
            end
            if itemID then
                local entry = byMap[itemID]
                if not entry then
                    entry = { total = 0, shared = 0 }
                    byMap[itemID] = entry
                end
                entry.total = entry.total + quantity
                got = got + 1
            end
        end
    end
    if got > 0 then
        recordSpot(finds, mapID, x, y, time())
    end
end

function Recorder:PendingCount()
    local pending = 0
    local db = ns.db
    if type(db) ~= "table" then
        return 0
    end
    for _, byMap in pairs(db.finds.catches) do
        for _, entry in pairs(byMap) do
            pending = pending + (entry.total - entry.shared)
        end
    end
    return pending
end

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", function(_, _, unit, _, spellID)
    if unit == "player" and isFishingSpell(spellID) then
        channeling = true
    end
end)

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", function(_, _, unit)
    if unit == "player" and channeling then
        channeling = false
        lastChannelEnd = GetTime()
    end
end)

local function onLoot()
    local ok, err = pcall(recordLoot)
    if not ok and ns.Log then
        ns.Log:Record("Recorder error: " .. tostring(err))
    end
end

ns:RegisterEvent("LOOT_READY", onLoot)
ns:RegisterEvent("LOOT_OPENED", onLoot)

ns:RegisterSlashCommand("stats", function()
    ns:Print(ns.L.MSG_STATS:format(Recorder:PendingCount()))
end, "SLASH_HELP_STATS")
