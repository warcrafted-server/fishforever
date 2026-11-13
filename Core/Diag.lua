local ADDON, ns = ...

local CHECKS = {
    "IsFishingLoot",
    "GetNumLootItems",
    "GetLootSlotInfo",
    "GetLootSlotLink",
    "GetLootSlotType",
    "LootSlotHasItem",
    "C_Loot",
    "C_Map.GetBestMapForUnit",
    "C_Map.GetPlayerMapPosition",
    "C_Map.GetMapInfo",
    "GetSubZoneText",
    "GetZoneText",
    "C_Spell.GetSpellInfo",
    "C_Spell.GetSpellName",
    "C_SpellBook",
    "IsSpellKnown",
    "C_SpellBook.IsSpellKnown",
    "GetProfessions",
    "GetProfessionInfo",
    "C_TradeSkillUI.GetProfessionInfoBySkillLineID",
    "C_ChatInfo.RegisterAddonMessagePrefix",
    "C_ChatInfo.SendAddonMessage",
    "C_Container.GetContainerNumSlots",
    "C_Container.GetContainerItemInfo",
    "C_Container.UseContainerItem",
    "C_Item.EquipItemByName",
    "EquipItemByName",
    "C_Item.GetItemInfo",
    "C_Item.GetItemInfoInstant",
    "C_Item.GetItemNameByID",
    "GetInventoryItemID",
    "GetInventoryItemLink",
    "C_TradeSkillUI",
    "SetOverrideBinding",
    "SetOverrideBindingClick",
    "ClearOverrideBindings",
    "GetBindingKey",
    "SecureCmdList.INTERACT",
    "SLASH_INTERACT1",
    "ERR_FISH_ESCAPED",
    "InCombatLockdown",
    "UnitChannelInfo",
    "UnitCastingInfo",
    "PlaySound",
    "PlaySoundFile",
    "SOUNDKIT",
    "FlashClientIcon",
    "C_Timer.After",
    "C_Timer.NewTicker",
    "issecretvalue",
    "C_RestrictedActions",
    "C_GameRules",
    "GetCVar",
    "SetCVar",
    "C_CVar.GetCVar",
}

local CVARS = {
    "SoftTargetInteract",
    "SoftTargetInteractArc",
    "SoftTargetInteractRange",
    "Sound_EnableSFX",
    "Sound_SFXVolume",
    "Sound_MasterVolume",
    "autoLootDefault",
}

local BINDINGS = {
    "INTERACTTARGET",
    "INTERACTMOUSEOVER",
}

local INVENTORY_SLOTS = { 16, 17, 20, 21, 28, 29 }

local SPELL_IDS = { 7620, 7731, 7732, 18248, 33095, 51294, 88868, 110410, 131474, 131476, 131490 }

local DEBUG_EVENTS = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "LOOT_READY",
    "LOOT_OPENED",
    "LOOT_SLOT_CLEARED",
    "LOOT_CLOSED",
    "CHAT_MSG_LOOT",
    "CHAT_MSG_SKILL",
    "SKILL_LINES_CHANGED",
    "PLAYER_SOFT_INTERACT_CHANGED",
    "PLAYER_SOFT_ENEMY_CHANGED",
    "PLAYER_SOFT_FRIEND_CHANGED",
    "CURSOR_CHANGED",
    "UPDATE_MOUSEOVER_UNIT",
    "UI_ERROR_MESSAGE",
    "UI_INFO_MESSAGE",
    "BAG_UPDATE_DELAYED",
    "UNIT_INVENTORY_CHANGED",
    "PLAYER_EQUIPMENT_CHANGED",
    "ZONE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
}

local DEBUG_LOG_MAX = 1500
local DEBUG_MAX_ARGS = 8
local TICKER_INTERVAL = 0.1

local LOOT_INFO_FIELDS = {
    "texture",
    "name",
    "quantity",
    "currencyID",
    "quality",
    "locked",
    "isQuestItem",
    "questID",
    "isActive",
    "isHub",
    "itemID",
}

local debugFrame
local ticker
local lastSoftName, lastSoftExists, lastChannelName, lastChannelSpell

local function pack(...)
    return { n = select("#", ...), ... }
end

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function safe(value)
    if isSecret(value) then
        return "<secret>"
    end
    return value
end

local function safeText(value)
    if value == nil then
        return "nil"
    end
    if isSecret(value) then
        return "<secret>"
    end
    local ok, text = pcall(tostring, value)
    return ok and text or "<unreadable>"
end

local function timestamp()
    local clock = type(date) == "function" and date("%H:%M:%S") or ""
    local now = type(GetTime) == "function" and GetTime() or 0
    -- date() and GetTime() tick independently, so mixing their fractions
    -- produced out-of-order stamps; keep GetTime() as its own column.
    return string.format("%s [%.3f]", clock, now)
end

local function resolve(path)
    local current = _G
    for part in string.gmatch(path, "[^%.]+") do
        if type(current) ~= "table" then
            return nil
        end
        current = current[part]
        if current == nil then
            return nil
        end
    end
    return current
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, value = pcall(fn, ...)
    if not ok then
        return nil
    end
    return safe(value)
end

local function collectInventory()
    local inventory = {}
    for i = 1, #INVENTORY_SLOTS do
        local slot = INVENTORY_SLOTS[i]
        inventory[slot] = {
            itemID = safeCall(GetInventoryItemID, "player", slot),
            link = safeCall(GetInventoryItemLink, "player", slot),
        }
    end
    return inventory
end

local function collectSpells()
    local spells = {}
    for i = 1, #SPELL_IDS do
        local spellID = SPELL_IDS[i]
        local entry = { ok = false, known = false }
        if type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function" then
            local ok, info = pcall(C_Spell.GetSpellInfo, spellID)
            if ok and type(info) == "table" then
                entry.ok = true
                entry.name = safe(info.name)
                entry.spellID = safe(info.spellID)
                entry.iconID = safe(info.iconID)
            end
        end
        if type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellKnown) == "function" then
            local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID)
            entry.known = ok and known == true
        elseif type(IsSpellKnown) == "function" then
            local ok, known = pcall(IsSpellKnown, spellID)
            entry.known = ok and known == true
        end
        spells[tostring(spellID)] = entry
    end
    return spells
end

local function collectProfessions()
    local professions = {}
    local values = pack(pcall(GetProfessions))
    if not values[1] then
        return professions
    end
    for i = 2, values.n do
        local index = values[i]
        if type(index) == "number" then
            local info = pack(pcall(GetProfessionInfo, index))
            if info[1] then
                professions[#professions + 1] = {
                    name = safe(info[2]),
                    skillLevel = safe(info[4]),
                    maxSkillLevel = safe(info[5]),
                    skillLine = safe(info[8]),
                }
            end
        end
    end
    return professions
end

local function collectMap()
    local map = {}
    if type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function" then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and mapID ~= nil then
            map.id = safe(mapID)
            if type(C_Map.GetMapInfo) == "function" then
                local okInfo, info = pcall(C_Map.GetMapInfo, mapID)
                if okInfo and type(info) == "table" then
                    map.name = safe(info.name)
                end
            end
        end
    end
    map.zone = safeCall(GetZoneText)
    map.subzone = safeCall(GetSubZoneText)
    return map
end

-- Every bag item with its class and use spell, to identify fishing lures.
local function collectBags()
    local bags = {}
    if type(C_Container) ~= "table" or type(C_Container.GetContainerNumSlots) ~= "function" then
        return bags
    end
    for bag = 0, 4 do
        local slots = safeCall(C_Container.GetContainerNumSlots, bag) or 0
        for slot = 1, (type(slots) == "number" and slots or 0) do
            local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
            if ok and type(info) == "table" and info.itemID then
                local entry = {
                    bag = bag,
                    slot = slot,
                    itemID = safe(info.itemID),
                    link = safe(info.hyperlink),
                    count = safe(info.stackCount),
                }
                if type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function" then
                    local values = pack(pcall(C_Item.GetItemInfoInstant, info.itemID))
                    if values[1] then
                        entry.classID = safe(values[7])
                        entry.subclassID = safe(values[8])
                    end
                end
                if type(C_Item) == "table" and type(C_Item.GetItemSpell) == "function" then
                    local values = pack(pcall(C_Item.GetItemSpell, info.itemID))
                    if values[1] then
                        entry.spellName = safe(values[2])
                        entry.spellID = safe(values[3])
                    end
                end
                bags[#bags + 1] = entry
            end
        end
    end
    return bags
end

-- Temporary weapon enchant (fishing lure) on the main hand.
local function collectWeaponEnchant()
    local values = pack(pcall(GetWeaponEnchantInfo))
    if not values[1] then
        return { ok = false }
    end
    local result = { ok = true }
    for i = 2, math.min(values.n, 9) do
        result[i - 1] = safe(values[i])
    end
    return result
end

-- Native templates and atlases available for a modern look.
local UI_TEMPLATES = {
    "ActionButtonTemplate", "SecureActionButtonTemplate,ActionButtonTemplate",
    "ButtonFrameTemplate", "PortraitFrameTemplate", "DefaultPanelTemplate", "DefaultPanelFlatTemplate",
    "UIPanelButtonTemplate", "UIPanelCloseButton", "UIPanelCloseButtonDefaultAnchors",
    "PanelTabButtonTemplate", "TooltipBackdropTemplate", "NineSlicePanelTemplate",
    "ActionButtonSpellAlertTemplate", "UIMenuButtonStretchTemplate", "SharedButtonSmallTemplate",
}

local UI_ATLASES = {
    "UI-HUD-ActionBar-IconFrame", "UI-HUD-ActionBar-IconFrame-Mouseover", "UI-HUD-ActionBar-IconFrame-Down",
    "UI-HUD-ActionBar-IconFrame-Slot", "UI-HUD-ActionBar-IconFrame-Flash", "UI-HUD-ActionBar-IconFrame-Border",
    "UI-DiamondDialogBox-Border", "UI-DialogBox-Background-Dark", "PetList-ButtonBackground",
    "PetList-ButtonSelect", "PetList-ButtonHighlight", "Options_List_Active", "Options_List_Hover",
    "UI-Frame-Bar-Fill-Green", "UI-CastingBar-Full-Standard", "UI-CastingBar-Background",
    "ui-castingbar-filling-channel", "ui-castingbar-tier1-empower", "UI-HUD-MicroMenu-Questlog-Up",
    "Professions-Icon-Quality-Tier1", "loottoast-itemborder-gold", "loottab-set-itemborder-white",
    "auctionhouse-itemicon-border-white", "auctionhouse-itemicon-border-uncommon", "auctionhouse-itemicon-border-rare",
    "CircleMaskScalable", "UI-Frame-IconMask", "minimap-trackingborder", "ui-hud-minimap-button",
    "common-dropdown-c-button", "common-button-square-gray-up", "128-RedButton-UP", "128-GoldRedButton-UP",
    "UI-QuestTrackerButton-Secondary-Collapse", "groupfinder-icon-redx", "tooltip-glues-NineSlice-CornerTopLeft",
}

local function collectUI()
    local result = { templates = {}, atlases = {} }
    for i = 1, #UI_TEMPLATES do
        local name = UI_TEMPLATES[i]
        local ok, frame = pcall(CreateFrame, "Button", nil, UIParent, name)
        result.templates[name] = ok and frame ~= nil
        if ok and frame then
            frame:Hide()
        end
    end
    local getAtlas = type(C_Texture) == "table" and C_Texture.GetAtlasInfo
    result.atlasAPI = type(getAtlas) == "function"
    if result.atlasAPI then
        for i = 1, #UI_ATLASES do
            local name = UI_ATLASES[i]
            local ok, info = pcall(getAtlas, name)
            result.atlases[name] = ok and type(info) == "table"
        end
    end
    return result
end

local function collectSamples()
    return {
        inventory = collectInventory(),
        bags = collectBags(),
        ui = collectUI(),
        weaponEnchant = collectWeaponEnchant(),
        spells = collectSpells(),
        professions = collectProfessions(),
        map = collectMap(),
    }
end

local function collectBuild(diag)
    local values = pack(pcall(GetBuildInfo))
    if not values[1] then
        return
    end
    local interface = safe(values[5])
    diag.version = safe(values[2])
    diag.build = safe(values[3])
    diag.interface = tonumber(interface) or interface
end

local function checkSecureTemplate(checks)
    local ok, frame = pcall(CreateFrame, "Button", nil, UIParent, "SecureActionButtonTemplate")
    local created = ok and frame ~= nil
    checks.SecureActionButtonTemplate = {
        ok = created,
        type = created and type(frame) or "nil",
    }
end

local function readCVar(name)
    if type(C_CVar) == "table" and type(C_CVar.GetCVar) == "function" then
        local ok, value = pcall(C_CVar.GetCVar, name)
        if ok then
            return safe(value)
        end
    end
    if type(GetCVar) == "function" then
        local ok, value = pcall(GetCVar, name)
        if ok then
            return safe(value)
        end
    end
    return false
end

local function readBinding(name)
    if type(GetBindingKey) ~= "function" then
        return false
    end
    local values = pack(pcall(GetBindingKey, name))
    if not values[1] then
        return false
    end
    local keys = {}
    for i = 2, values.n do
        local key = safe(values[i])
        if key ~= nil then
            keys[#keys + 1] = key
        end
    end
    return keys
end

local function countChecks(checks)
    local found, missing = 0, 0
    for _, check in pairs(checks) do
        if check.ok then
            found = found + 1
        else
            missing = missing + 1
        end
    end
    return found, missing
end

local function collect()
    local checks = {}
    for i = 1, #CHECKS do
        local path = CHECKS[i]
        local ok, value = pcall(resolve, path)
        if not ok then
            value = nil
        end
        checks[path] = { ok = value ~= nil, type = type(value) }
    end
    checkSecureTemplate(checks)

    local cvars = {}
    for i = 1, #CVARS do
        cvars[CVARS[i]] = readCVar(CVARS[i])
    end

    local bindings = {}
    for i = 1, #BINDINGS do
        bindings[BINDINGS[i]] = readBinding(BINDINGS[i])
    end

    local diag = {
        date = safeCall(date, "%Y-%m-%d %H:%M:%S"),
        locale = safeCall(GetLocale),
        checks = checks,
        cvars = cvars,
        bindings = bindings,
        samples = collectSamples(),
    }
    collectBuild(diag)
    return diag
end

local function ensureDB()
    if type(ns.db) == "table" then
        return ns.db
    end
    if type(FishForeverDB) == "table" then
        ns.db = FishForeverDB
        return ns.db
    end
    return nil
end

local function runDiag()
    local db = ensureDB()
    if not db then
        ns:Print(ns.L.MSG_DIAG_NOT_READY)
        return
    end

    local okCombat, inCombat = pcall(InCombatLockdown)
    if okCombat and inCombat then
        ns:Print(ns.L.MSG_DIAG_IN_COMBAT)
        return
    end

    local ok, diag = pcall(collect)
    if not ok or type(diag) ~= "table" then
        ns:Print(ns.L.MSG_DIAG_FAILED)
        return
    end

    db.diag = diag
    local found, missing = countChecks(diag.checks)
    ns:Print(ns.L.MSG_DIAG_SAVED:format(found, missing))
end

local function debugDB()
    local db = ensureDB()
    if not db then
        return nil
    end
    if type(db.debug) ~= "table" then
        db.debug = { enabled = false }
    end
    return db
end

local function debugEnabled(db)
    return type(db) == "table" and type(db.debug) == "table" and db.debug.enabled == true
end

local function appendDebug(line)
    local db = debugDB()
    if not db then
        return
    end
    local log = db.debugLog
    if type(log) ~= "table" then
        log = {}
        db.debugLog = log
    end
    log[#log + 1] = line
    while #log > DEBUG_LOG_MAX do
        table.remove(log, 1)
    end
end

local function logLoot()
    if type(IsFishingLoot) == "function" then
        local ok, value = pcall(IsFishingLoot)
        if ok then
            appendDebug(timestamp() .. " IsFishingLoot=" .. safeText(value))
        end
    end

    if type(GetNumLootItems) ~= "function" then
        return
    end
    local okTotal, total = pcall(GetNumLootItems)
    if not okTotal or type(total) ~= "number" or isSecret(total) then
        return
    end

    for slot = 1, total do
        local link = safeCall(GetLootSlotLink, slot)
        local infoParts = {}
        local values = pack(pcall(GetLootSlotInfo, slot))
        if values[1] then
            local fields = math.min(values.n - 1, #LOOT_INFO_FIELDS)
            for i = 1, fields do
                infoParts[#infoParts + 1] = LOOT_INFO_FIELDS[i] .. "=" .. safeText(values[i + 1])
            end
        end
        local line = timestamp() .. " loot slot " .. slot .. " link=" .. safeText(link)
        if #infoParts > 0 then
            line = line .. " " .. table.concat(infoParts, " | ")
        end
        appendDebug(line)
    end
end

local function onDebugEvent(event, ...)
    local db = debugDB()
    if not debugEnabled(db) then
        return
    end

    if string.sub(event, 1, 5) == "UNIT_" then
        local unit = ...
        if unit ~= "player" then
            return
        end
    end

    local count = select("#", ...)
    if count > DEBUG_MAX_ARGS then
        count = DEBUG_MAX_ARGS
    end
    local parts = {}
    for i = 1, count do
        parts[i] = safeText((select(i, ...)))
    end

    local line = timestamp() .. " " .. event
    if #parts > 0 then
        line = line .. " " .. table.concat(parts, " | ")
    end
    appendDebug(line)

    if event == "LOOT_OPENED" or event == "LOOT_READY" then
        logLoot()
    end
end

local function tick()
    local db = debugDB()
    if not debugEnabled(db) then
        return
    end

    local softName = safeCall(UnitName, "softinteract")
    local softExists = safeCall(UnitExists, "softinteract")
    if softName ~= lastSoftName then
        lastSoftName = softName
        appendDebug(timestamp() .. " softinteract.name=" .. safeText(softName))
    end
    if softExists ~= lastSoftExists then
        lastSoftExists = softExists
        appendDebug(timestamp() .. " softinteract.exists=" .. safeText(softExists))
    end

    local channelName, channelSpell
    if type(UnitChannelInfo) == "function" then
        local values = pack(pcall(UnitChannelInfo, "player"))
        if values[1] then
            channelName = safeText(values[2])
            -- spellID is the 8th return in current clients and the last one in
            -- older ones, which dropped the fields that follow it.
            local spellIndex
            if values.n >= 11 then
                spellIndex = 9
            elseif values.n == 10 then
                spellIndex = 10
            else
                spellIndex = values.n
            end
            channelSpell = safeText(values[spellIndex])
        end
    end
    if channelName ~= lastChannelName or channelSpell ~= lastChannelSpell then
        lastChannelName = channelName
        lastChannelSpell = channelSpell
        appendDebug(timestamp() .. " channel name=" .. safeText(channelName)
            .. " spellID=" .. safeText(channelSpell))
    end
end

local function stopTicker()
    if ticker then
        pcall(ticker.Cancel, ticker)
        ticker = nil
    end
end

local function startTicker()
    stopTicker()
    if type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" then
        local ok, created = pcall(C_Timer.NewTicker, TICKER_INTERVAL, function()
            pcall(tick)
        end)
        if ok then
            ticker = created
        end
    end
end

local function startRecorder()
    if not debugFrame then
        local ok, frame = pcall(CreateFrame, "Frame")
        if not ok or frame == nil then
            return
        end
        debugFrame = frame
        pcall(debugFrame.SetScript, debugFrame, "OnEvent", function(_, event, ...)
            pcall(onDebugEvent, event, ...)
        end)
    end
    for i = 1, #DEBUG_EVENTS do
        pcall(debugFrame.RegisterEvent, debugFrame, DEBUG_EVENTS[i])
    end
    startTicker()
end

local function stopRecorder()
    if debugFrame then
        for i = 1, #DEBUG_EVENTS do
            pcall(debugFrame.UnregisterEvent, debugFrame, DEBUG_EVENTS[i])
        end
    end
    stopTicker()
end

local function toggleDebug()
    local db = debugDB()
    if not db then
        ns:Print(ns.L.MSG_DIAG_NOT_READY)
        return
    end

    local enabled = db.debug.enabled ~= true
    db.debug.enabled = enabled
    if enabled then
        db.debugLog = {}
        lastSoftName, lastSoftExists = nil, nil
        lastChannelName, lastChannelSpell = nil, nil
        startRecorder()
        ns:Print(ns.L.MSG_DEBUG_ON)
    else
        stopRecorder()
        ns:Print(ns.L.MSG_DEBUG_OFF)
    end
end

ns:RegisterSlashCommand("diag", runDiag, "SLASH_HELP_DIAG")
ns:RegisterSlashCommand("debug", toggleDebug, "SLASH_HELP_DEBUG")

ns:RegisterEvent("PLAYER_LOGIN", function()
    local db = debugDB()
    if debugEnabled(db) then
        startRecorder()
    end
end)
