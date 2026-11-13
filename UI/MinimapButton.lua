local ADDON, ns = ...

ns.UI = ns.UI or {}

local MinimapButton = {}
ns.UI.MinimapButton = MinimapButton

local BUTTON_NAME = "FishForeverMinimapButton"
local ICON = 136245
local BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local BACKGROUND = "Interface\\Minimap\\UI-Minimap-Background"
local HIGHLIGHT = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
local DEFAULT_ANGLE = 200

local L = ns.L
local Theme = ns.UI.Theme
local palette = Theme.palette

local button

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() and true or false
end

local function getSettings()
    local settings = ns.db and ns.db.settings
    if type(settings) ~= "table" then
        return nil
    end
    local minimap = settings.minimap
    if type(minimap) ~= "table" then
        minimap = {}
        settings.minimap = minimap
    end
    if minimap.hide == nil then
        minimap.hide = false
    end
    minimap.angle = tonumber(minimap.angle) or DEFAULT_ANGLE
    if minimap.angle < 0 then
        minimap.angle = minimap.angle + 360
    end
    if minimap.angle >= 360 then
        minimap.angle = minimap.angle % 360
    end
    return minimap
end

local function updatePosition()
    if not button or not Minimap then
        return
    end
    local width = Minimap.GetWidth and Minimap:GetWidth() or 150
    local height = Minimap.GetHeight and Minimap:GetHeight() or width
    local radius = width / 2 + 5
    if Minimap.GetMinimapShape then
        local ok, shape = pcall(Minimap.GetMinimapShape, Minimap)
        if ok and shape == "SQUARE" then
            radius = math.max(width, height) / 2 + 5
        end
    end
    local settings = getSettings()
    local angle = math.rad(settings and settings.angle or DEFAULT_ANGLE)
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function updateDrag(self)
    if not self.dragging or not Minimap or type(GetCursorPosition) ~= "function" then
        return
    end
    local mx, my = GetCursorPosition()
    local scale = Minimap.GetEffectiveScale and Minimap:GetEffectiveScale() or 1
    mx, my = mx / scale, my / scale
    local cx, cy = Minimap:GetCenter()
    if not cx or not cy then
        return
    end
    local angle = math.deg(math.atan2(my - cy, mx - cx))
    if angle < 0 then
        angle = angle + 360
    end
    local settings = getSettings()
    if settings then
        settings.angle = angle
    end
    updatePosition()
end

local function showTooltip(owner)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:AddLine(L.ADDON_NAME, palette.title[1], palette.title[2], palette.title[3])
    GameTooltip:AddLine(L.TIP_MINIMAP_LEFT, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MINIMAP_RIGHT, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MINIMAP_SHIFT, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MINIMAP_OPTIONS, 1, 1, 1, true)
    GameTooltip:AddLine(L.TIP_MINIMAP_DRAG, palette.textDim[1], palette.textDim[2], palette.textDim[3], true)

    local active = ns.modules.FishingMode and ns.modules.FishingMode:IsActive()
    if active then
        GameTooltip:AddLine(L.STATUS_MINIMAP_ON, palette.ok[1], palette.ok[2], palette.ok[3], true)
    else
        GameTooltip:AddLine(L.STATUS_MINIMAP_OFF, palette.textDim[1], palette.textDim[2], palette.textDim[3], true)
    end
    GameTooltip:Show()
end

local function createButton()
    if button or not Minimap then
        return
    end

    local b = CreateFrame("Button", BUTTON_NAME, Minimap)
    button = b
    b:SetSize(31, 31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")

    local background = b:CreateTexture(nil, "BACKGROUND")
    background:SetTexture(BACKGROUND)
    background:SetSize(20, 20)
    background:SetPoint("CENTER")

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ICON)
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetTexture(BORDER)
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    local highlight = b:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(HIGHLIGHT)
    highlight:SetBlendMode("ADD")
    highlight:SetSize(31, 31)
    highlight:SetPoint("TOPLEFT")

    b:SetScript("OnEnter", function(self)
        showTooltip(self)
    end)
    b:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    b:SetScript("OnClick", function(_, mouseButton)
        local shift = type(IsShiftKeyDown) == "function" and IsShiftKeyDown()
        if mouseButton == "RightButton" and shift then
            if ns.UI and ns.UI.Options then
                ns.UI.Options.Open()
            end
        elseif mouseButton == "RightButton" then
            ns.modules.FishingMode:Toggle()
        elseif shift then
            if ns.UI and ns.UI.StatsWindow then
                ns.UI.StatsWindow:Toggle()
            end
        else
            ns.modules.BobberButton:SetShown(not ns.db.settings.button.shown)
        end
    end)
    b:SetScript("OnDragStart", function(self)
        if inCombat() then
            return
        end
        self.dragging = true
        self:SetScript("OnUpdate", updateDrag)
    end)
    b:SetScript("OnDragStop", function(self)
        self.dragging = false
        self:SetScript("OnUpdate", nil)
        updatePosition()
    end)

    MinimapButton:Refresh()
end

function MinimapButton:Refresh()
    if not button then
        return
    end
    local settings = getSettings()
    if not settings then
        return
    end
    if settings.hide then
        button:Hide()
    else
        button:Show()
        updatePosition()
    end
end

function MinimapButton:SetHidden(hide)
    hide = hide and true or false
    local settings = getSettings()
    if settings and not ns.readOnlyData then
        settings.hide = hide
    end
    if not button then
        return
    end
    if hide then
        button:Hide()
    else
        button:Show()
        updatePosition()
    end
end

function MinimapButton:Toggle()
    local settings = getSettings()
    if not settings then
        return
    end
    local hide
    if ns.readOnlyData then
        hide = (button and button:IsShown()) and true or false
    else
        hide = not settings.hide
    end
    self:SetHidden(hide)
    ns:Print(hide and L.MSG_MINIMAP_OFF or L.MSG_MINIMAP_ON)
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    createButton()
end)

ns:RegisterSlashCommand("minimap", function()
    MinimapButton:Toggle()
end, "SLASH_HELP_MINIMAP")
