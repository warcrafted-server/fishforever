local ADDON, ns = ...

ns.UI = ns.UI or {}

local ZonesPopup = {}
ns.UI.ZonesPopup = ZonesPopup

local FRAME_NAME = "FishForeverZones"
local WIDTH = 300
local PADDING = 12
local LINE_HEIGHT = 16
local ICON = 136245
-- The native portrait hangs below the title bar; start the text under it.
local NATIVE_TOP = 62

local Theme = ns.UI.Theme
local palette = Theme.palette
local L = ns.L

local frame, content
local linePool = {}

local function createText(parent, objectName, fallbackKey, color, flags)
    local text = parent:CreateFontString(nil, "OVERLAY")
    Theme:SetFont(text, objectName, fallbackKey, flags)
    if color then
        text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end
    return text
end

local function contentWidth()
    local width = 0
    if content and type(content.GetWidth) == "function" then
        local ok, value = pcall(content.GetWidth, content)
        if ok and type(value) == "number" then
            width = value
        end
    end
    if width <= 0 then
        width = WIDTH - PADDING * 2
    end
    return width
end

local function contentOffsets()
    local topOffset, bottomOffset = frame.fishForeverTop or 34, PADDING
    if content == frame.Inset then
        local okFrameTop, frameTop = pcall(frame.GetTop, frame)
        local okContentTop, contentTop = pcall(content.GetTop, content)
        if okFrameTop and okContentTop and type(frameTop) == "number" and type(contentTop) == "number" then
            topOffset = frameTop - contentTop
        end
        local okFrameBottom, frameBottom = pcall(frame.GetBottom, frame)
        local okContentBottom, contentBottom = pcall(content.GetBottom, content)
        if okFrameBottom and okContentBottom and type(frameBottom) == "number" and type(contentBottom) == "number" then
            bottomOffset = contentBottom - frameBottom
        end
        if type(topOffset) ~= "number" or topOffset < 0 or topOffset > 120 then
            topOffset = 34
        end
        if type(bottomOffset) ~= "number" or bottomOffset < 0 or bottomOffset > 120 then
            bottomOffset = PADDING
        end
    end
    return topOffset, bottomOffset
end

local function lineAt(index)
    local line = linePool[index]
    if not line then
        line = content:CreateFontString(nil, "OVERLAY")
        line:SetJustifyH("LEFT")
        linePool[index] = line
    end
    return line
end

local function zoneStatusText(advisor, mapID, name)
    local status, minSkill, noEscapeSkill = advisor:ZoneStatus(mapID)
    if status == "tooLow" then
        return L.ADVISOR_ZONE_TOO_LOW:format(name, minSkill)
    elseif status == "escapes" then
        return L.ADVISOR_ZONE_ESCAPES:format(name, noEscapeSkill)
    elseif status == "clean" then
        return L.ADVISOR_ZONE_CLEAN:format(name)
    end
    return L.ADVISOR_ZONE_UNKNOWN:format(name)
end

local function buildLines()
    local advisor = ns.modules.Advisor
    local skill, maxSkill
    if advisor then
        skill, maxSkill = advisor:GetSkill()
    end
    if not skill then
        return {
            { text = L.ADVISOR_NO_SKILL, color = palette.text, object = "GameFontHighlightSmall", fallback = "small" },
        }
    end

    local lines = {}
    lines[#lines + 1] = {
        text = L.ADVISOR_SKILL:format(skill, maxSkill),
        color = palette.text,
        object = "GameFontNormal",
        fallback = "label",
    }

    local mapID, name = advisor:CurrentZone()
    lines[#lines + 1] = {
        text = zoneStatusText(advisor, mapID, name or "?"),
        color = palette.text,
        object = "GameFontHighlightSmall",
        fallback = "small",
        gapBefore = 2,
    }

    local clean, nextTier = advisor:Suggestions(skill)
    lines[#lines + 1] = {
        text = L.ZONES_CLEAN,
        color = palette.title,
        object = "GameFontNormal",
        fallback = "label",
        gapBefore = 10,
    }
    if #clean == 0 then
        lines[#lines + 1] = { text = L.ZONES_NONE, color = palette.textDim, object = "GameFontHighlightSmall", fallback = "small" }
    else
        for index = 1, #clean do
            lines[#lines + 1] = {
                text = L.ADVISOR_SUGGEST_ENTRY:format(clean[index].name, clean[index].minSkill),
                color = palette.ok,
                object = "GameFontHighlightSmall",
                fallback = "small",
            }
        end
    end

    lines[#lines + 1] = {
        text = L.ZONES_NEXT,
        color = palette.title,
        object = "GameFontNormal",
        fallback = "label",
        gapBefore = 10,
    }
    if #nextTier == 0 then
        lines[#lines + 1] = { text = L.ZONES_NONE, color = palette.textDim, object = "GameFontHighlightSmall", fallback = "small" }
    else
        for index = 1, #nextTier do
            lines[#lines + 1] = {
                text = L.ADVISOR_SUGGEST_ENTRY:format(nextTier[index].name, nextTier[index].minSkill),
                color = palette.orange,
                object = "GameFontHighlightSmall",
                fallback = "small",
            }
        end
    end

    lines[#lines + 1] = {
        text = L.ZONES_RULE,
        color = palette.textDim,
        object = "GameFontHighlightSmall",
        fallback = "small",
        gapBefore = 10,
    }
    return lines
end

function ZonesPopup:Refresh()
    if not frame then
        return
    end
    local lines = buildLines()
    local width = contentWidth()
    local y = 0
    for index = 1, #lines do
        local data = lines[index]
        local line = lineAt(index)
        Theme:SetFont(line, data.object, data.fallback)
        line:SetText(data.text)
        line:SetTextColor(data.color[1], data.color[2], data.color[3], 1)
        line:SetWidth(width)
        if data.gapBefore then
            y = y + data.gapBefore
        end
        line:ClearAllPoints()
        line:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        line:Show()
        local height = line:GetStringHeight()
        if type(height) ~= "number" or height <= 0 then
            height = LINE_HEIGHT
        end
        y = y + math.ceil(height)
    end
    for index = #lines + 1, #linePool do
        linePool[index]:Hide()
    end

    local topOffset, bottomOffset = contentOffsets()
    frame:SetHeight(topOffset + y + PADDING + bottomOffset)
end

local function tryFrame(template)
    local ok, created = pcall(CreateFrame, "Frame", FRAME_NAME, UIParent, template)
    if ok and created then
        return created
    end
    return nil
end

local function createFrame()
    local native = true
    frame = tryFrame("PortraitFrameTemplate")
    if not frame then
        native = false
        frame = tryFrame("BackdropTemplate") or CreateFrame("Frame", FRAME_NAME, UIParent)
    end

    frame.fishForeverTop = native and NATIVE_TOP or 34
    if native then
        local portrait = false
        if type(frame.SetPortraitToAsset) == "function" then
            portrait = pcall(frame.SetPortraitToAsset, frame, ICON) or portrait
        end
        if not portrait and type(frame.SetPortraitTextureRaw) == "function" then
            pcall(frame.SetPortraitTextureRaw, frame, ICON)
        end
    end

    frame:SetFrameStrata("DIALOG")
    frame:SetWidth(WIDTH)
    frame:SetHeight(200)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    if frame.EnableMouse then
        frame:EnableMouse(true)
    end

    if not native and frame.SetBackdrop then
        frame:SetBackdrop(Theme.backdrop)
        frame:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 1)
        frame:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)
    end

    local hasTitle = false
    if type(frame.SetTitle) == "function" then
        local ok = pcall(frame.SetTitle, frame, L.ZONES_TITLE)
        hasTitle = hasTitle or ok
    end
    if frame.TitleText and type(frame.TitleText.SetText) == "function" then
        local ok = pcall(frame.TitleText.SetText, frame.TitleText, L.ZONES_TITLE)
        hasTitle = hasTitle or ok
    end
    if not hasTitle then
        local title = createText(frame, "GameFontNormalLarge", "title", palette.title)
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -8)
        title:SetText(L.ZONES_TITLE)
    end

    local close = frame.CloseButton
    if not close then
        local ok, created = pcall(CreateFrame, "Button", nil, frame, "UIPanelCloseButton")
        if ok then
            close = created
        end
    end
    if close then
        if close ~= frame.CloseButton then
            close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
        end
        close:SetScript("OnClick", function()
            ZonesPopup:Hide()
        end)
    end

    local drag = frame.TitleContainer or frame
    if drag then
        if drag.EnableMouse then
            drag:EnableMouse(true)
        end
        if drag.RegisterForDrag then
            drag:RegisterForDrag("LeftButton")
        end
        drag:SetScript("OnDragStart", function()
            frame:StartMoving()
        end)
        drag:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
        end)
    end

    content = frame.Inset
    if content and (type(content.CreateFontString) ~= "function" or type(content.CreateTexture) ~= "function") then
        content = nil
    end
    if not content then
        content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -frame.fishForeverTop)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    end

    frame:Hide()

    if type(UISpecialFrames) == "table" then
        UISpecialFrames[#UISpecialFrames + 1] = FRAME_NAME
    end
end

local function ensureFrame()
    if not frame then
        createFrame()
    end
    return frame
end

function ZonesPopup:Show()
    ensureFrame()

    local stats = _G.FishForeverStats
    frame:ClearAllPoints()
    if stats and type(stats.IsShown) == "function" and stats:IsShown() then
        frame:SetPoint("TOPLEFT", stats, "TOPRIGHT", 8, 0)
    else
        frame:SetPoint("CENTER")
    end

    frame:Show()
    self:Refresh()
    frame:Raise()
end

function ZonesPopup:Hide()
    if frame then
        frame:Hide()
    end
end

function ZonesPopup:Toggle()
    if frame and frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
