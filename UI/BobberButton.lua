local ADDON, ns = ...

-- One press = one action. The button is a SecureActionButton that casts
-- Fishing; while the bobber is out, the key bound to it is temporarily
-- overridden with the game's own INTERACTTARGET binding (the bobber is the
-- soft-interact target), so the next press loots. Nothing ever happens
-- without a player press.

local BUTTON_NAME = "FishForeverBobberButton"
local BINDING = "CLICK " .. BUTTON_NAME .. ":LeftButton"
local FISHING_SPELL = 7620
local RESULT_TIME = 2

local L = ns.L
local Theme = ns.UI.Theme
local palette = Theme.palette

local BobberButton = ns:NewModule("BobberButton")

_G["BINDING_HEADER_FISHFOREVER"] = L.ADDON_NAME
_G["BINDING_NAME_" .. BINDING] = L.BINDING_CAST_LOOT

local button, cooldown, status
local channel -- { startTime, endTime } in seconds while fishing
local bobberOut = false
local resultUntil = 0

local function fishingSpell()
    if C_Spell and C_Spell.GetSpellName then
        local name = C_Spell.GetSpellName(FISHING_SPELL)
        if type(name) == "string" then
            return name
        end
    end
    return FISHING_SPELL
end

local function setCastAction()
    button:SetAttribute("type1", "spell")
    button:SetAttribute("spell1", fishingSpell())
end

-- Short label of the first key bound to the button, or nil when unbound.
local function boundKey()
    local key = GetBindingKey(BINDING)
    if not key then
        return nil
    end
    if type(GetBindingText) == "function" then
        local ok, text = pcall(GetBindingText, key)
        if ok and type(text) == "string" and text ~= "" then
            return text
        end
    end
    return key
end

local function keyLabel()
    local key = GetBindingKey(BINDING)
    if not key then
        return ""
    end
    if type(GetBindingText) == "function" then
        local ok, text = pcall(GetBindingText, key, true)
        if ok and type(text) == "string" and text ~= "" then
            return text
        end
    end
    return key
end

local function lootHint()
    local key = boundKey()
    return key and L.STATUS_LOOT_KEY:format(key) or L.STATUS_LOOT_MOUSE
end

local function setStatus(text, color)
    status:SetText(text or "")
    if color then
        status:SetTextColor(color[1], color[2], color[3])
    end
end

-- Override bindings are protected: only touched out of combat.
local function armLoot()
    if InCombatLockdown() or bobberOut then
        return
    end
    for _, key in ipairs({ GetBindingKey(BINDING) }) do
        SetOverrideBinding(button, true, key, "INTERACTTARGET")
    end
    -- A mouse click on the button must not recast and lose the bobber. This
    -- client has no /interact, so only a key (or a click on the bobber) loots.
    button:SetAttribute("type1", nil)
    bobberOut = true
end

local function disarmLoot()
    if InCombatLockdown() then
        return
    end
    ClearOverrideBindings(button)
    setCastAction()
    bobberOut = false
end

local function showResult(text, color)
    resultUntil = GetTime() + RESULT_TIME
    setStatus(text, color)
end

local function flashCatch()
    if not (button and button.Flash) then
        return
    end
    button.Flash:Show()
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(0.3, function()
            if button and button.Flash then
                button.Flash:Hide()
            end
        end)
    else
        button.Flash:Hide()
    end
end

local function refresh()
    local now = GetTime()
    if channel then
        local total = channel.endTime - channel.startTime
        local remaining = total > 0 and math.max(0, (channel.endTime - now) / total) or 0
        local color = Theme:TimerColor(remaining)
        if cooldown then
            cooldown:SetSwipeColor(color[1], color[2], color[3], 0.75)
        end
        setStatus(lootHint(), color)
    elseif now >= resultUntil then
        setStatus("")
    end
end

local function savePosition()
    local point, _, _, x, y = button:GetPoint()
    local cfg = ns.db.settings.button
    cfg.point, cfg.x, cfg.y = point, x, y
end

local function showTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L.ADDON_NAME, palette.title[1], palette.title[2], palette.title[3])
    GameTooltip:AddLine(L.TIP_CAST, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_LOOT, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MODE, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MOVE, palette.textDim[1], palette.textDim[2], palette.textDim[3], true)
    if not boundKey() then
        GameTooltip:AddLine(L.TIP_NO_KEY, palette.orange[1], palette.orange[2], palette.orange[3], true)
    end
    GameTooltip:Show()
end

local function create()
    local cfg = ns.db.settings.button

    button = CreateFrame("Button", BUTTON_NAME, UIParent, "ActionButtonTemplate,SecureActionButtonTemplate")
    button:SetScale(1.15 * (cfg.scale or 1))
    button:SetPoint(cfg.point or "CENTER", UIParent, cfg.point or "CENTER", cfg.x or 0, cfg.y or -150)
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:RegisterForDrag("LeftButton")
    -- Left button only: a generic "type" would also cast on right click,
    -- which is reserved for toggling fishing mode.
    setCastAction()

    local icon = button.icon
    if not icon then
        icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
    end
    icon:SetTexture(136245)

    cooldown = button.cooldown
    if cooldown then
        cooldown:SetDrawEdge(false)
        cooldown:SetReverse(true)
        cooldown:SetHideCountdownNumbers(false)
    end

    status = button:CreateFontString(nil, "OVERLAY")
    Theme:SetFont(status, "GameFontNormalSmall", "label")
    status:SetShadowOffset(1, -1)
    status:SetShadowColor(0, 0, 0, 1)
    status:SetPoint("TOP", button, "BOTTOM", 0, -4)

    if button.Count then
        button.Count:Hide()
    end
    if button.Name then
        button.Name:Hide()
    end

    if button.HotKey then
        local function updateHotKey()
            button.HotKey:SetText(keyLabel())
        end
        updateHotKey()
        ns:RegisterEvent("UPDATE_BINDINGS", updateHotKey)
    end

    button:HookScript("OnClick", function(_, mouse, down)
        if mouse == "RightButton" and not down then
            ns.modules.FishingMode:Toggle()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        if not cfg.locked and IsShiftKeyDown() and not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePosition()
    end)
    button:SetScript("OnEnter", showTooltip)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnUpdate", refresh)

    button:SetShown(cfg.shown)
end

function BobberButton:SetShown(shown)
    if InCombatLockdown() then
        ns:Print(L.MSG_NOT_IN_COMBAT)
        return
    end
    ns.db.settings.button.shown = shown
    button:SetShown(shown)
end

-- Called by FishingMode; nudges players who have not bound the key yet.
function ns.FishingModeChanged(active)
    if active and not boundKey() then
        ns:Print(L.TIP_NO_KEY)
    end
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    create()
end)

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", function(_, _, unit, _, spellID)
    if unit ~= "player" or not ns.IsFishingSpell(spellID) then
        return
    end
    local _, _, _, startMS, endMS = UnitChannelInfo("player")
    if type(startMS) == "number" and type(endMS) == "number" then
        channel = { startTime = startMS / 1000, endTime = endMS / 1000 }
        if cooldown then
            cooldown:SetCooldown(channel.startTime, channel.endTime - channel.startTime)
        end
    else
        channel = { startTime = GetTime(), endTime = GetTime() + 30 }
    end
    armLoot()
end)

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", function(_, _, unit, _, spellID)
    if unit ~= "player" or not ns.IsFishingSpell(spellID) then
        return
    end
    channel = nil
    if cooldown then
        cooldown:Clear()
    end
    disarmLoot()
end)

-- Last chance to clear protected bindings before the combat lockdown starts.
ns:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    if bobberOut then
        ClearOverrideBindings(button)
        setCastAction()
        bobberOut = false
    end
end)

ns:RegisterEvent("LOOT_OPENED", function()
    if type(IsFishingLoot) == "function" and IsFishingLoot() then
        showResult(L.STATUS_CAUGHT, palette.ok)
        flashCatch()
    end
end)

ns:RegisterEvent("UI_INFO_MESSAGE", function(_, _, _, message)
    if ERR_FISH_ESCAPED and message == ERR_FISH_ESCAPED then
        showResult(L.STATUS_ESCAPED, palette.missing)
    end
end)

ns:RegisterSlashCommand("button", function()
    BobberButton:SetShown(not ns.db.settings.button.shown)
end, "SLASH_HELP_BUTTON")

ns:RegisterSlashCommand("lock", function()
    local cfg = ns.db.settings.button
    cfg.locked = not cfg.locked
    ns:Print(cfg.locked and L.MSG_LOCKED or L.MSG_UNLOCKED)
end, "SLASH_HELP_LOCK")
