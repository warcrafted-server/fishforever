local ADDON, ns = ...

ns.UI = ns.UI or {}

local StatsWindow = {}
ns.UI.StatsWindow = StatsWindow

local FRAME_NAME = "FishForeverStats"
local WIDTH = 300
local PADDING = 12
local TITLE_HEIGHT = 24
local SUMMARY_ROWS = 6
local ROW_HEIGHT = 16
local MAX_ITEM_ROWS = 12
local BUTTON_WIDTH = 80
local BUTTON_HEIGHT = 20
local CONFIRM_SECONDS = 3
local SUMMARY_TOP = TITLE_HEIGHT + 10
local ITEMS_HEADER_Y = SUMMARY_TOP + SUMMARY_ROWS * ROW_HEIGHT + 4
local ITEMS_TOP = ITEMS_HEADER_Y + ROW_HEIGHT

local Theme = ns.UI.Theme
local palette = Theme.palette
local L = ns.L

local QUALITY_HEX = { "9d9d9d", "ffffff", "1eff00", "0070dd", "a335ee", "ff8000" }

local frame
local titleBar
local summaryRows = {}
local itemRows = {}
local moreText
local emptyText
local resetLabel
local resetConfirmUntil = 0
local elapsed = 0

local function hex(value)
    return {
        tonumber(value:sub(1, 2), 16) / 255,
        tonumber(value:sub(3, 4), 16) / 255,
        tonumber(value:sub(5, 6), 16) / 255,
    }
end

local QUALITY_COLORS = {}
for index = 1, #QUALITY_HEX do
    QUALITY_COLORS[index - 1] = hex(QUALITY_HEX[index])
end

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
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

local function itemIcon(itemID)
    if C_Item and type(C_Item.GetItemIconByID) == "function" then
        local ok, icon = pcall(C_Item.GetItemIconByID, itemID)
        if ok and type(icon) == "number" then
            return icon
        end
    end
    return nil
end

local function getSettings()
    local db = ns.db
    if type(db) ~= "table" or type(db.settings) ~= "table" then
        return nil
    end
    local stats = db.settings.stats
    if type(stats) ~= "table" then
        if ns.readOnlyData then
            return nil
        end
        stats = {}
        db.settings.stats = stats
    end
    return stats
end

local function savePosition()
    if ns.readOnlyData then
        return
    end
    local stats = getSettings()
    if not stats then
        return
    end
    local point, _, _, x, y = frame:GetPoint()
    if point then
        stats.point, stats.x, stats.y = point, x, y
    end
end

local function createText(parent, font, color, justify)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont(font[1], font[2])
    text:SetTextColor(color[1], color[2], color[3], 1)
    if justify then
        text:SetJustifyH(justify)
    end
    return text
end

local function createButton(parent, text, primary, width, height)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button:SetBackdrop(Theme.backdrop)
    local background = primary and palette.primaryBg or palette.panelBg
    local border = primary and palette.primaryBorder or palette.panelBorder
    button:SetBackdropColor(background[1], background[2], background[3], 1)
    button:SetBackdropBorderColor(border[1], border[2], border[3], 1)

    local label = createText(button, Theme.font.label, palette.text)
    label:SetPoint("CENTER")
    label:SetText(text)

    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(palette.highlightBg[1], palette.highlightBg[2], palette.highlightBg[3], 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(background[1], background[2], background[3], 1)
    end)
    return button, label
end

local function cancelResetConfirm()
    resetConfirmUntil = 0
    if resetLabel then
        resetLabel:SetText(L.STATS_RESET)
    end
end

local function startResetConfirm()
    resetConfirmUntil = GetTime() + CONFIRM_SECONDS
    resetLabel:SetText(L.STATS_RESET_CONFIRM)
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        local expected = resetConfirmUntil
        C_Timer.After(CONFIRM_SECONDS, function()
            if resetConfirmUntil == expected then
                cancelResetConfirm()
            end
        end)
    end
end

local function refresh()
    if not frame then
        return
    end
    local session = ns.modules.Session
    local data = session and session:Get() or nil

    local casts = data and data.casts or 0
    local catches = data and data.catches or 0
    local perHour = session and session:CatchesPerHour() or 0

    summaryRows[1].value:SetText(formatTime(session and session:ActiveTime() or 0))
    summaryRows[2].value:SetText(tostring(casts))
    summaryRows[3].value:SetText(tostring(catches))
    summaryRows[4].value:SetText(tostring(data and data.escapes or 0))
    summaryRows[5].value:SetText(perHour ~= 0 and string.format("%.1f", perHour) or "-")
    summaryRows[6].value:SetText(casts > 0 and string.format("%d%%", math.floor(catches / casts * 100 + 0.5)) or "-")

    local items = data and data.items or {}
    local list = {}
    for itemID, entry in pairs(items) do
        if type(entry) == "table" and (entry.count or 0) > 0 then
            list[#list + 1] = { id = itemID, count = entry.count, quality = entry.quality }
        end
    end
    table.sort(list, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return a.id < b.id
    end)

    local shown = math.min(#list, MAX_ITEM_ROWS)
    for i = 1, MAX_ITEM_ROWS do
        local row = itemRows[i]
        local item = list[i]
        if item then
            row:Show()
            row.name:SetText(itemName(item.id))
            local color = QUALITY_COLORS[item.quality] or palette.text
            row.name:SetTextColor(color[1], color[2], color[3], 1)
            row.count:SetText(tostring(item.count))
            local icon = itemIcon(item.id)
            if icon then
                row.icon:SetTexture(icon)
                row.icon:Show()
            else
                row.icon:SetTexture(nil)
                row.icon:Hide()
            end
        else
            row:Hide()
        end
    end

    if #list == 0 then
        emptyText:Show()
    else
        emptyText:Hide()
    end

    if #list > MAX_ITEM_ROWS then
        moreText:SetText(L.STATS_MORE:format(#list - MAX_ITEM_ROWS))
        moreText:Show()
    else
        moreText:Hide()
    end

    local listHeight = ROW_HEIGHT
    if shown > 0 then
        listHeight = shown * ROW_HEIGHT
        if #list > MAX_ITEM_ROWS then
            listHeight = listHeight + ROW_HEIGHT
        end
    end
    frame:SetHeight(ITEMS_TOP + listHeight + 8 + BUTTON_HEIGHT + PADDING)
end

local function createFrame()
    frame = CreateFrame("Frame", FRAME_NAME, UIParent, "BackdropTemplate")
    frame:SetSize(WIDTH, 206)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop(Theme.backdrop)
    frame:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 1)
    frame:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)

    local stats = getSettings()
    local point = type(stats) == "table" and stats.point or "CENTER"
    local x = type(stats) == "table" and stats.x or 0
    local y = type(stats) == "table" and stats.y or 0
    frame:SetPoint(point, UIParent, point, x, y)

    local bar = frame:CreateTexture(nil, "BACKGROUND")
    bar:SetPoint("TOPLEFT")
    bar:SetPoint("TOPRIGHT")
    bar:SetHeight(TITLE_HEIGHT)
    bar:SetColorTexture(palette.barBg[1], palette.barBg[2], palette.barBg[3], 1)

    titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT")
    titleBar:SetPoint("TOPRIGHT")
    titleBar:SetHeight(TITLE_HEIGHT)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        savePosition()
    end)

    local title = createText(titleBar, Theme.font.title, palette.title)
    title:SetPoint("LEFT", titleBar, "LEFT", PADDING, 0)
    title:SetText(L.STATS_TITLE)

    local closeButton, closeLabel = createButton(titleBar, L.STATS_CLOSE, true, 18, 18)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
    closeLabel:SetFont(Theme.font.small[1], Theme.font.small[2])
    closeButton:SetScript("OnClick", function()
        StatsWindow:Hide()
    end)

    local labels = {
        L.STATS_TIME,
        L.STATS_CASTS,
        L.STATS_CATCHES,
        L.STATS_ESCAPES,
        L.STATS_PER_HOUR,
        L.STATS_SUCCESS,
    }
    for index = 1, SUMMARY_ROWS do
        local rowY = SUMMARY_TOP + (index - 1) * ROW_HEIGHT
        local label = createText(frame, Theme.font.label, palette.sectionLabel)
        label:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -rowY)
        label:SetText(labels[index])

        local value = createText(frame, Theme.font.label, palette.text, "RIGHT")
        value:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -rowY)
        value:SetText("-")
        summaryRows[index] = { value = value }
    end

    local itemsTitle = createText(frame, Theme.font.label, palette.sectionLabel)
    itemsTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -ITEMS_HEADER_Y)
    itemsTitle:SetText(L.STATS_ITEMS)

    for index = 1, MAX_ITEM_ROWS do
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(WIDTH - PADDING * 2, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -(ITEMS_TOP + (index - 1) * ROW_HEIGHT))

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(14, 14)
        row.icon:SetPoint("LEFT", row, "LEFT", 0, 0)

        row.name = createText(row, Theme.font.small, palette.text, "LEFT")
        row.name:SetPoint("LEFT", row, "LEFT", 18, 0)
        row.name:SetPoint("RIGHT", row, "RIGHT", -40, 0)

        row.count = createText(row, Theme.font.small, palette.text, "RIGHT")
        row.count:SetPoint("RIGHT", row, "RIGHT", 0, 0)

        row:Hide()
        itemRows[index] = row
    end

    emptyText = createText(frame, Theme.font.small, palette.textDim)
    emptyText:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -ITEMS_TOP)
    emptyText:SetText(L.STATS_EMPTY)

    moreText = createText(frame, Theme.font.small, palette.textDim)
    moreText:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -(ITEMS_TOP + MAX_ITEM_ROWS * ROW_HEIGHT))
    moreText:Hide()

    local resetButton
    resetButton, resetLabel = createButton(frame, L.STATS_RESET, false, BUTTON_WIDTH, BUTTON_HEIGHT)
    resetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    resetButton:SetScript("OnClick", function()
        if resetConfirmUntil ~= 0 and GetTime() <= resetConfirmUntil then
            cancelResetConfirm()
            if ns.modules.Session then
                ns.modules.Session:Reset()
            end
            refresh()
        else
            startResetConfirm()
        end
    end)

    frame:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed >= 1 then
            elapsed = elapsed - 1
            refresh()
        end
    end)

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

function StatsWindow:Show()
    ensureFrame()
    elapsed = 0
    frame:Show()
    refresh()
    frame:Raise()
end

function StatsWindow:Hide()
    if not frame then
        return
    end
    cancelResetConfirm()
    frame:Hide()
end

function StatsWindow:Toggle()
    if frame and frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

ns.SessionChanged = function()
    if frame and frame:IsShown() then
        refresh()
    end
end
