local ADDON, ns = ...

-- One press = one action. The button is a SecureActionButton that casts
-- Fishing; while the bobber is out, the key bound to it is temporarily
-- overridden with the game's own INTERACTTARGET binding (the bobber is the
-- soft-interact target), so the next press loots. Nothing ever happens
-- without a player press.

local BUTTON_NAME = "FishForeverBobberButton"
local BINDING = "CLICK " .. BUTTON_NAME .. ":LeftButton"
local FISHING_SPELL = 7620
local SIZE = 52
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

local function setBorder(color)
    button:SetBackdropBorderColor(color[1], color[2], color[3], 1)
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
    -- A mouse click on the button must not recast and lose the bobber.
    button:SetAttribute("type", nil)
    bobberOut = true
end

local function disarmLoot()
    if InCombatLockdown() then
        return
    end
    ClearOverrideBindings(button)
    button:SetAttribute("type", "spell")
    bobberOut = false
end

local function showResult(text, color)
    resultUntil = GetTime() + RESULT_TIME
    setStatus(text, color)
    setBorder(color)
end

local function refresh()
    local now = GetTime()
    if channel then
        local total = channel.endTime - channel.startTime
        local remaining = total > 0 and math.max(0, (channel.endTime - now) / total) or 0
        local color = Theme:TimerColor(remaining)
        cooldown:SetSwipeColor(color[1], color[2], color[3], 0.75)
        setBorder(color)
        setStatus(L.STATUS_CAST, color)
    elseif now >= resultUntil then
        setBorder(palette.windowBorder)
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
    if not GetBindingKey(BINDING) then
        GameTooltip:AddLine(L.TIP_NO_KEY, palette.orange[1], palette.orange[2], palette.orange[3], true)
    end
    GameTooltip:Show()
end

local function create()
    local cfg = ns.db.settings.button

    button = CreateFrame("Button", BUTTON_NAME, UIParent, "SecureActionButtonTemplate,BackdropTemplate")
    button:SetSize(SIZE, SIZE)
    button:SetScale(cfg.scale or 1)
    button:SetPoint(cfg.point or "CENTER", UIParent, cfg.point or "CENTER", cfg.x or 0, cfg.y or -150)
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:RegisterForDrag("LeftButton")
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", fishingSpell())

    button:SetBackdrop(Theme.backdrop)
    button:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 0.95)
    setBorder(palette.windowBorder)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 3, -3)
    icon:SetPoint("BOTTOMRIGHT", -3, 3)
    icon:SetTexture(136245)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(icon)
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(false)

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(icon)
    highlight:SetColorTexture(1, 0.85, 0.5, 0.12)

    status = button:CreateFontString(nil, "OVERLAY")
    status:SetFont(Theme.font.label[1], Theme.font.label[2], "OUTLINE")
    status:SetPoint("TOP", button, "BOTTOM", 0, -4)

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
        cooldown:SetCooldown(channel.startTime, channel.endTime - channel.startTime)
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
    cooldown:Clear()
    disarmLoot()
end)

-- Last chance to clear protected bindings before the combat lockdown starts.
ns:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    if bobberOut then
        ClearOverrideBindings(button)
        button:SetAttribute("type", "spell")
        bobberOut = false
    end
end)

ns:RegisterEvent("LOOT_OPENED", function()
    if type(IsFishingLoot) == "function" and IsFishingLoot() then
        showResult(L.STATUS_CAUGHT, palette.ok)
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
