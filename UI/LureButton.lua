local ADDON, ns = ...

local BUTTON_NAME = "FishForeverLureButton"
local BINDING = "CLICK " .. BUTTON_NAME .. ":LeftButton"
local MAIN_HAND = 16
local SIZE = 22
local FALLBACK_ICON = 136245

local L = ns.L
local Theme = ns.UI.Theme
local palette = Theme.palette

_G["BINDING_NAME_" .. BINDING] = L.BINDING_LURE

local button, icon, timerText
local appliedItemID
local pendingUpdate = false

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

local function refresh()
    if not button then
        return
    end
    local lure = ns.modules.Lure
    local itemID = lure and lure:FindBest()

    local iconID
    if itemID and C_Item and type(C_Item.GetItemIconByID) == "function" then
        local ok, value = pcall(C_Item.GetItemIconByID, itemID)
        if ok and type(value) == "number" then
            iconID = value
        end
    end
    icon:SetTexture(iconID or FALLBACK_ICON)
    icon:SetDesaturated(itemID == nil)

    local pole = isPoleEquipped()
    local hasLure, remaining = false, 0
    if lure then
        hasLure, remaining = lure:GetActive()
    end

    if pole and hasLure then
        local duration = lure and lure:Duration() or 0
        local fraction = duration > 0 and remaining / duration or 0
        local color = Theme:TimerColor(fraction)
        button:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        timerText:SetText(formatRemaining(remaining))
        timerText:SetTextColor(color[1], color[2], color[3])
    elseif pole then
        button:SetBackdropBorderColor(palette.orange[1], palette.orange[2], palette.orange[3], 1)
        timerText:SetText("")
    else
        button:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)
        timerText:SetText("")
    end
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

    button = CreateFrame("Button", BUTTON_NAME, bobber, "SecureActionButtonTemplate,BackdropTemplate")
    button:SetSize(SIZE, SIZE)
    button:SetPoint("BOTTOMLEFT", bobber, "TOPRIGHT", -8, -8)
    button:SetFrameLevel((bobber:GetFrameLevel() or 1) + 2)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetBackdrop(Theme.backdrop)
    button:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 0.95)
    button:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)

    icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexture(FALLBACK_ICON)

    timerText = button:CreateFontString(nil, "OVERLAY")
    timerText:SetFont(Theme.font.small[1], Theme.font.small[2], "OUTLINE")
    timerText:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)

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
