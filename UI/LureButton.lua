local ADDON, ns = ...

local BUTTON_NAME = "FishForeverLureButton"
local BINDING = "CLICK " .. BUTTON_NAME .. ":LeftButton"
local MAIN_HAND = 16
local FALLBACK_ICON = 136245

local L = ns.L
local Theme = ns.UI.Theme
local palette = Theme.palette

_G["BINDING_NAME_" .. BINDING] = L.BINDING_LURE

local button, icon, timerText, countText
local appliedItemID
local pendingUpdate = false
local glowing = false

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function pack(...)
    return { n = select("#", ...), ... }
end

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

local function formatRemaining(seconds)
    if seconds >= 60 then
        return math.ceil(seconds / 60) .. "m"
    end
    return math.ceil(seconds) .. "s"
end

local function itemName(itemID)
    if C_Item and type(C_Item.GetItemNameByID) == "function" then
        local ok, name = pcall(C_Item.GetItemNameByID, itemID)
        if ok and type(name) == "string" and name ~= "" and not isSecret(name) then
            return name
        end
    end
    return "#" .. tostring(itemID)
end

local function isPoleEquipped()
    if type(GetInventoryItemID) ~= "function" then
        return false
    end
    local ok, itemID = pcall(GetInventoryItemID, "player", MAIN_HAND)
    if not ok or itemID == nil or isSecret(itemID) then
        return false
    end
    if not (C_Item and type(C_Item.GetItemInfoInstant) == "function") then
        return false
    end
    local values = pack(pcall(C_Item.GetItemInfoInstant, itemID))
    if not values[1] or isSecret(values[7]) or isSecret(values[8]) then
        return false
    end
    local weapon = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or 2
    local pole = (Enum and Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole) or 20
    return values[7] == weapon and values[8] == pole
end

local function applyAttributes(itemID)
    if InCombatLockdown() then
        pendingUpdate = true
        return
    end
    if itemID then
        button:SetAttribute("type1", "macro")
        button:SetAttribute("macrotext1", "/use item:" .. itemID .. "\n/use 16")
    else
        button:SetAttribute("type1", nil)
    end
    appliedItemID = itemID
    pendingUpdate = false
end

local function updateAttributes(force)
    if not button then
        return
    end
    local lure = ns.modules.Lure
    local itemID = lure and lure:FindBest()
    if not force and itemID == appliedItemID then
        return
    end
    if InCombatLockdown() then
        pendingUpdate = true
        return
    end
    applyAttributes(itemID)
end

-- A soft pulsing gold frame: the native proc glow is too loud for a reminder.
local pulse
local function createPulse()
    local frame = button:CreateTexture(nil, "OVERLAY", nil, 7)
    local ok = type(frame.SetAtlas) == "function" and pcall(frame.SetAtlas, frame, "UI-HUD-ActionBar-IconFrame-Mouseover")
    if ok then
        frame:SetAllPoints(button)
    else
        frame:SetPoint("TOPLEFT", -2, 2)
        frame:SetPoint("BOTTOMRIGHT", 2, -2)
        frame:SetColorTexture(1, 0.82, 0.2, 0.35)
    end
    frame:SetVertexColor(1, 0.82, 0.2)
    frame:SetBlendMode("ADD")
    frame:Hide()

    local group = frame:CreateAnimationGroup()
    group:SetLooping("BOUNCE")
    local fade = group:CreateAnimation("Alpha")
    fade:SetFromAlpha(0.25)
    fade:SetToAlpha(0.9)
    fade:SetDuration(0.9)
    fade:SetSmoothing("IN_OUT")
    pulse = { texture = frame, anim = group }
end

local function setGlow(on)
    on = on and true or false
    if on == glowing or not button then
        return
    end
    glowing = on
    if not pulse then
        createPulse()
    end
    if on then
        pulse.texture:Show()
        pulse.anim:Play()
    else
        pulse.anim:Stop()
        pulse.texture:Hide()
    end
end

local function refresh()
    if not button then
        return
    end
    local lure = ns.modules.Lure
    local itemID, bonus, count
    if lure then
        itemID, bonus, count = lure:FindBest()
    end

    local iconID
    if itemID and C_Item and type(C_Item.GetItemIconByID) == "function" then
        local ok, value = pcall(C_Item.GetItemIconByID, itemID)
        if ok and type(value) == "number" then
            iconID = value
        end
    end
    icon:SetTexture(iconID or FALLBACK_ICON)
    icon:SetDesaturated(itemID == nil)

    if countText then
        countText:SetText(count and count > 0 and tostring(count) or "")
    end

    local pole = isPoleEquipped()
    local hasLure, remaining = false, 0
    if lure then
        hasLure, remaining = lure:GetActive()
    end

    if pole and hasLure then
        local duration = lure and lure:Duration() or 0
        local fraction = duration > 0 and remaining / duration or 0
        local color = Theme:TimerColor(fraction)
        timerText:SetText(formatRemaining(remaining))
        timerText:SetTextColor(color[1], color[2], color[3])
    else
        timerText:SetText("")
    end

    setGlow(pole and not hasLure and itemID ~= nil)
end

local function showTooltip(self)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L.ADDON_NAME, palette.title[1], palette.title[2], palette.title[3])

    local lure = ns.modules.Lure
    local itemID, bonus, count
    if lure then
        itemID, bonus, count = lure:FindBest()
    end
    if itemID then
        GameTooltip:AddLine(itemName(itemID), 1, 1, 1, true)
        GameTooltip:AddLine(L.TIP_LURE_BONUS:format(bonus), 1, 1, 1, true)
        GameTooltip:AddLine(L.TIP_LURE_COUNT:format(count), palette.textDim[1], palette.textDim[2], palette.textDim[3], true)
    else
        GameTooltip:AddLine(L.TIP_LURE_NONE, palette.textDim[1], palette.textDim[2], palette.textDim[3], true)
    end

    local hasLure, remaining = false, 0
    if lure then
        hasLure, remaining = lure:GetActive()
    end
    if hasLure and isPoleEquipped() then
        GameTooltip:AddLine(L.TIP_LURE_LEFT:format(formatRemaining(remaining)), palette.ok[1], palette.ok[2], palette.ok[3], true)
    end

    GameTooltip:AddLine(L.TIP_LURE_APPLY, 1, 1, 1, true)
    if not boundKey() then
        GameTooltip:AddLine(L.TIP_LURE_NO_KEY, palette.orange[1], palette.orange[2], palette.orange[3], true)
    end
    GameTooltip:Show()
end

local function create()
    local bobber = _G.FishForeverBobberButton
    if not bobber or button then
        return button ~= nil
    end

    button = CreateFrame("Button", BUTTON_NAME, bobber, "ActionButtonTemplate,SecureActionButtonTemplate")
    button:SetScale(0.55)
    button:SetPoint("CENTER", bobber, "TOPRIGHT", -4, -4)
    button:SetFrameLevel((bobber:GetFrameLevel() or 1) + 2)
    button:RegisterForClicks("AnyUp", "AnyDown")

    icon = button.icon
    if not icon then
        icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
    end
    icon:SetTexture(FALLBACK_ICON)

    countText = button.Count

    timerText = button:CreateFontString(nil, "OVERLAY")
    Theme:SetFont(timerText, "GameFontHighlightSmallOutline", "small", "OUTLINE")
    timerText:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)

    if button.HotKey then
        local function updateHotKey()
            button.HotKey:SetText(keyLabel())
        end
        updateHotKey()
        ns:RegisterEvent("UPDATE_BINDINGS", updateHotKey)
    end

    button:SetScript("OnEnter", showTooltip)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    updateAttributes(true)
    refresh()
    return true
end

local function setup()
    if create() then
        return
    end
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(0, setup)
    end
end

function ns.LureChanged()
    updateAttributes(false)
    refresh()
end

function ns.LureExpired()
    local lure = ns.modules.Lure
    local itemID = lure and lure:FindBest()
    if not itemID then
        ns:Print(L.MSG_LURE_NONE_LEFT)
    else
        local key = boundKey()
        if key then
            ns:Print(L.MSG_LURE_EXPIRED:format(key))
        else
            ns:Print(L.MSG_LURE_EXPIRED_CLICK)
        end
    end
    if type(PlaySound) == "function" and SOUNDKIT and SOUNDKIT.RAID_WARNING ~= nil then
        pcall(PlaySound, SOUNDKIT.RAID_WARNING)
    end
end

ns:RegisterEvent("PLAYER_LOGIN", setup)

ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    if pendingUpdate then
        updateAttributes(true)
    end
end)

ns:RegisterEvent("UNIT_INVENTORY_CHANGED", function(_, _, unit)
    if unit == "player" then
        refresh()
    end
end)
