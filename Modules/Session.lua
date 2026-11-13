local ADDON, ns = ...

local Session = ns:NewModule("Session")

local MAX_GAP = 300
local MAX_QUALITY = 7

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function notify()
    if type(ns.SessionChanged) == "function" then
        pcall(ns.SessionChanged)
    end
end

local function getSession(writable)
    local charDB = ns.charDB
    if type(charDB) ~= "table" then
        return nil
    end
    local data = charDB.session
    if type(data) ~= "table" then
        if not writable or ns.readOnlyData then
            return nil
        end
        data = {}
        charDB.session = data
    end
    return data
end

local function touch(data, now)
    local lastActivity = data.lastActivity or 0
    if lastActivity > 0 and now - lastActivity <= MAX_GAP then
        data.activeTime = (data.activeTime or 0) + (now - lastActivity)
    end
    data.lastActivity = now
end

local function validQuality(quality)
    if isSecret(quality) or type(quality) ~= "number" then
        return nil
    end
    if quality < 0 or quality > MAX_QUALITY or quality ~= math.floor(quality) then
        return nil
    end
    return quality
end

local function recordCast()
    if ns.readOnlyData then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    if (data.startedAt or 0) == 0 then
        data.startedAt = time()
    end
    data.casts = (data.casts or 0) + 1
    touch(data, GetTime())
    notify()
end

local function recordEscape()
    if ns.readOnlyData then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    data.escapes = (data.escapes or 0) + 1
    notify()
end

function Session:Reset()
    if ns.readOnlyData then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    data.startedAt = 0
    data.lastActivity = 0
    data.activeTime = 0
    data.casts = 0
    data.catches = 0
    data.escapes = 0
    data.items = {}
    notify()
end

function Session:AddCatch(itemID, quantity, quality)
    if ns.readOnlyData or isSecret(itemID) or type(itemID) ~= "number" then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    if type(data.items) ~= "table" then
        data.items = {}
    end

    if isSecret(quantity) or type(quantity) ~= "number" or quantity < 1 then
        quantity = 1
    end

    local entry = data.items[itemID]
    if not entry then
        entry = { count = 0 }
        data.items[itemID] = entry
    end
    entry.count = (entry.count or 0) + quantity

    local valid = validQuality(quality)
    if valid ~= nil then
        entry.quality = valid
    end
    notify()
end

function Session:CountCatch()
    if ns.readOnlyData then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    data.catches = (data.catches or 0) + 1
    touch(data, GetTime())
    notify()
end

function Session:Get()
    return getSession(false)
end

function Session:ActiveTime()
    local data = getSession(false)
    if not data then
        return 0
    end
    local activeTime = data.activeTime or 0
    local lastActivity = data.lastActivity or 0
    if lastActivity > 0 then
        local live = GetTime() - lastActivity
        if live > 0 and live <= MAX_GAP then
            activeTime = activeTime + live
        end
    end
    return activeTime
end

function Session:CatchesPerHour()
    local activeTime = self:ActiveTime()
    if activeTime < 60 then
        return 0
    end
    local data = getSession(false)
    local catches = data and data.catches or 0
    return catches / (activeTime / 3600)
end

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", function(_, _, unit, _, spellID)
    if unit ~= "player" or type(ns.IsFishingSpell) ~= "function" then
        return
    end
    if ns.IsFishingSpell(spellID) then
        recordCast()
    end
end)

ns:RegisterEvent("UI_INFO_MESSAGE", function(_, _, _, message)
    if type(ERR_FISH_ESCAPED) ~= "string" or isSecret(message) then
        return
    end
    if message == ERR_FISH_ESCAPED then
        recordEscape()
    end
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    if ns.readOnlyData then
        return
    end
    local data = getSession(true)
    if not data then
        return
    end
    if (data.lastActivity or 0) ~= 0 then
        data.lastActivity = 0
        notify()
    end
end)

ns:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, _, isInitialLogin, isReloadingUi)
    if isInitialLogin == true and isReloadingUi ~= true then
        local settings = ns.db and ns.db.settings
        local sessionSettings = settings and settings.session
        if not (sessionSettings and sessionSettings.resetOnLogin == false) then
            Session:Reset()
        end
    end
end)
