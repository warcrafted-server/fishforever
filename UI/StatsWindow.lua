local ADDON, ns = ...

ns.UI = ns.UI or {}

local StatsWindow = {}
ns.UI.StatsWindow = StatsWindow

local FRAME_NAME = "FishForeverStats"
local WIDTH = 380
local PADDING = 12
local CARD_HEIGHT = 54
local CARD_GAP = 6
local LINE_GAP = 8
local LINE_HEIGHT = 16
local HEADER_GAP = 12
local HEADER_HEIGHT = 16
local SEPARATOR_GAP = 4
local ROWS_GAP = 6
local ROW_HEIGHT = 36
local MAX_ITEM_ROWS = 10
local MORE_HEIGHT = 16
local EMPTY_HEIGHT = 20
local BOTTOM_GAP = 8
local BUTTON_WIDTH = 110
local BUTTON_HEIGHT = 22
local CONFIRM_SECONDS = 3
local FALLBACK_ICON = 136245

local LINE_Y = CARD_HEIGHT + LINE_GAP
local HEADER_Y = LINE_Y + LINE_HEIGHT + HEADER_GAP
local SEPARATOR_Y = HEADER_Y + HEADER_HEIGHT + SEPARATOR_GAP
local ROWS_Y = SEPARATOR_Y + 1 + ROWS_GAP

local Theme = ns.UI.Theme
local palette = Theme.palette
local L = ns.L

local QUALITY_HEX = { "9d9d9d", "ffffff", "1eff00", "0070dd", "a335ee", "ff8000" }

local frame, content
local cards = {}
local compactLine, headerText, separator
local itemRows = {}
local emptyText, moreText
local resetButton, resetLabel
local resetConfirmUntil = 0
local elapsed = 0
local shownRows = 0
local hasMore = false

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

local function pack(...)
    return { n = select("#", ...), ... }
end

local function itemSellPrice(itemID)
    if not (C_Item and type(C_Item.GetItemInfo) == "function") then
        return nil
    end
    local values = pack(pcall(C_Item.GetItemInfo, itemID))
    if not values[1] then
        return nil
    end
    local sellPrice = values[12]
    if not isSecret(sellPrice) and type(sellPrice) == "number" and sellPrice >= 0 then
        return sellPrice
    end
    if type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
    return nil
end

local function moneyText(copper)
    copper = math.max(0, math.floor(copper or 0))
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local rest = copper % 100
    local parts = {}
    if gold > 0 then
        parts[#parts + 1] = gold .. "g"
    end
    if silver > 0 then
        parts[#parts + 1] = silver .. "s"
    end
    if rest > 0 or #parts == 0 then
        parts[#parts + 1] = rest .. "c"
    end
    return table.concat(parts, " ")
end

local function formatMoney(copper, plain)
    copper = math.max(0, math.floor(copper or 0))
    if not plain then
        if C_CurrencyInfo and type(C_CurrencyInfo.GetCoinTextureString) == "function" then
            local ok, text = pcall(C_CurrencyInfo.GetCoinTextureString, copper)
            if ok and type(text) == "string" and text ~= "" then
                return text
            end
        end
        if type(GetCoinTextureString) == "function" then
            local ok, text = pcall(GetCoinTextureString, copper)
            if ok and type(text) == "string" and text ~= "" then
                return text
            end
        end
    end
    return moneyText(copper)
end

local function sessionValue(data)
    local total = 0
    local items = data and data.items or {}
    for itemID, entry in pairs(items) do
        if type(entry) == "table" and type(entry.count) == "number" and entry.count > 0 then
            local price = itemSellPrice(itemID)
            if price then
                total = total + entry.count * price
            end
        end
    end
    return total
end

local function inCombat()
    if type(InCombatLockdown) ~= "function" then
        return false
    end
    local ok, value = pcall(InCombatLockdown)
    return ok and value == true
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

local function applyAtlas(texture, atlas, fallback)
    if texture and type(texture.SetAtlas) == "function" then
        local ok = pcall(texture.SetAtlas, texture, atlas, true)
        if ok then
            return true
        end
    end
    if texture and fallback and type(texture.SetColorTexture) == "function" then
        texture:SetColorTexture(fallback[1], fallback[2], fallback[3], fallback[4] or 1)
    end
    return false
end

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

-- The native templates start their inset below the title bar, at a height that
-- varies by template; read it from the anchors instead of hardcoding it.
local function frameOffsets()
    local topOffset, bottomOffset = 34, PADDING
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

local function layout()
    local width = contentWidth()
    local cardWidth = (width - CARD_GAP * 3) / 4
    for index = 1, #cards do
        cards[index].frame:SetWidth(cardWidth)
    end
    compactLine:SetWidth(width)
    separator:SetWidth(width)
    emptyText:SetWidth(width)
    for index = 1, #itemRows do
        itemRows[index]:SetWidth(width)
    end

    local listHeight = EMPTY_HEIGHT
    if shownRows > 0 then
        listHeight = shownRows * ROW_HEIGHT
        if hasMore then
            listHeight = listHeight + MORE_HEIGHT
        end
    end
    local contentHeight = ROWS_Y + listHeight + BOTTOM_GAP + BUTTON_HEIGHT
    local topOffset, bottomOffset = frameOffsets()
    frame:SetHeight(topOffset + contentHeight + bottomOffset)
end

local function cancelResetConfirm()
    resetConfirmUntil = 0
    if resetButton and type(resetButton.SetText) == "function" then
        resetButton:SetText(L.STATS_RESET)
    end
    if resetLabel then
        resetLabel:SetText(L.STATS_RESET)
    end
end

local function startResetConfirm()
    resetConfirmUntil = GetTime() + CONFIRM_SECONDS
    if resetButton and type(resetButton.SetText) == "function" then
        resetButton:SetText(L.STATS_RESET_CONFIRM)
    end
    if resetLabel then
        resetLabel:SetText(L.STATS_RESET_CONFIRM)
    end
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
    local escapes = data and data.escapes or 0
    local perHour = session and session:CatchesPerHour() or 0
    local activeTime = session and session:ActiveTime() or 0
    local value = sessionValue(data)

    local goldPerHour = "-"
    if activeTime >= 60 and value > 0 then
        goldPerHour = formatMoney(value / activeTime * 3600, true)
    end

    cards[1].value:SetText(tostring(catches))
    cards[2].value:SetText(perHour ~= 0 and string.format("%.1f", perHour) or "-")
    cards[3].value:SetText(casts > 0 and string.format("%d%%", math.floor(catches / casts * 100 + 0.5)) or "-")
    cards[4].value:SetText(goldPerHour)
    compactLine:SetText(L.STATS_LINE:format(formatTime(activeTime), casts, escapes, formatMoney(value)))

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

    shownRows = math.min(#list, MAX_ITEM_ROWS)
    hasMore = #list > MAX_ITEM_ROWS
    layout()

    local maxCount = list[1] and list[1].count or 1
    for index = 1, MAX_ITEM_ROWS do
        local row = itemRows[index]
        local item = list[index]
        if item then
            row:Show()
            row.itemID = item.id
            local color = QUALITY_COLORS[item.quality] or palette.text
            row.name:SetText(itemName(item.id))
            row.name:SetTextColor(color[1], color[2], color[3], 1)
            row.count:SetText(tostring(item.count))
            row.icon:SetTexture(itemIcon(item.id) or FALLBACK_ICON)

            local subtle = item.quality == 0 or item.quality == 1
            if row.border and type(row.border.SetVertexColor) == "function" then
                row.border:SetVertexColor(color[1], color[2], color[3], subtle and 0.6 or 1)
            end

            local fillColor = subtle and palette.ok or color
            if row.barFill and type(row.barFill.SetVertexColor) == "function" then
                row.barFill:SetVertexColor(fillColor[1], fillColor[2], fillColor[3], 1)
            end

            local barWidth = 210
            if type(row.GetWidth) == "function" then
                local ok, value = pcall(row.GetWidth, row)
                if ok and type(value) == "number" and value > 0 then
                    barWidth = math.max(40, value - 104)
                end
            end
            if row.barBg then
                row.barBg:SetWidth(barWidth)
            end
            if row.barFill then
                local fraction = maxCount > 0 and item.count / maxCount or 0
                row.barFill:SetWidth(math.max(1, barWidth * fraction))
            end
            if row.highlight then
                row.highlight:Hide()
            end
        else
            row:Hide()
            row.itemID = nil
            if row.highlight then
                row.highlight:Hide()
            end
        end
    end

    if #list == 0 then
        emptyText:Show()
    else
        emptyText:Hide()
    end

    if hasMore then
        moreText:SetText(L.STATS_MORE:format(#list - MAX_ITEM_ROWS))
        moreText:Show()
    else
        moreText:Hide()
    end
end

local function buildContent()
    local labels = { L.STATS_CATCHES, L.STATS_PER_HOUR, L.STATS_SUCCESS, L.STATS_GOLD_HOUR }
    for index = 1, 4 do
        local card = CreateFrame("Frame", nil, content)
        card:SetHeight(CARD_HEIGHT)
        if index == 1 then
            card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        else
            card:SetPoint("TOPLEFT", cards[index - 1].frame, "TOPRIGHT", CARD_GAP, 0)
        end

        local background = card:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints(card)
        applyAtlas(background, "PetList-ButtonBackground", { palette.panelBg[1], palette.panelBg[2], palette.panelBg[3], 0.9 })

        local value = createText(card, "GameFontNormalHuge", "title", { 1, 1, 1, 1 })
        value:SetPoint("TOP", card, "TOP", 0, -6)
        value:SetText("-")

        local label = createText(card, "GameFontNormalSmall", "small", palette.textDim)
        label:SetPoint("BOTTOM", card, "BOTTOM", 0, 6)
        label:SetText(labels[index])

        cards[index] = { frame = card, value = value, label = label }
    end

    compactLine = createText(content, "GameFontHighlightSmall", "small", palette.text)
    compactLine:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -LINE_Y)
    compactLine:SetText("")

    headerText = createText(content, "GameFontNormal", "label", palette.title)
    headerText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -HEADER_Y)
    headerText:SetText(L.STATS_ITEMS)

    separator = content:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -SEPARATOR_Y)
    separator:SetColorTexture(palette.panelBorder[1], palette.panelBorder[2], palette.panelBorder[3], 0.8)

    for index = 1, MAX_ITEM_ROWS do
        local row = CreateFrame("Frame", nil, content)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(ROWS_Y + (index - 1) * ROW_HEIGHT))
        if row.EnableMouse then
            row:EnableMouse(true)
        end

        local background = row:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints(row)
        applyAtlas(background, "PetList-ButtonBackground", { palette.panelBg[1], palette.panelBg[2], palette.panelBg[3], 0.9 })
        row.background = background

        local highlight = row:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(row)
        applyAtlas(highlight, "PetList-ButtonHighlight", nil)
        highlight:Hide()
        row.highlight = highlight

        row.border = row:CreateTexture(nil, "OVERLAY")
        row.border:SetSize(32, 32)
        if not applyAtlas(row.border, "loottab-set-itemborder-white", nil) then
            applyAtlas(row.border, "auctionhouse-itemicon-border-white", { 1, 1, 1, 0.18 })
        end

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(28, 28)
        row.icon:SetTexture(FALLBACK_ICON)
        row.icon:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.border:SetPoint("CENTER", row.icon, "CENTER", 0, 0)

        row.name = createText(row, "GameFontNormal", "label", palette.text)
        row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 44, -5)
        row.name:SetPoint("TOPRIGHT", row, "TOPRIGHT", -64, -5)
        row.name:SetJustifyH("LEFT")

        local countObject = _G.GameFontHighlightLarge and "GameFontHighlightLarge" or "GameFontHighlight"
        row.count = createText(row, countObject, "label", palette.text)
        row.count:SetPoint("RIGHT", row, "RIGHT", -10, 0)
        row.count:SetJustifyH("RIGHT")

        row.barBg = row:CreateTexture(nil, "ARTWORK")
        row.barBg:SetHeight(4)
        row.barBg:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 44, 6)
        applyAtlas(row.barBg, "UI-CastingBar-Background", { 0, 0, 0, 0.5 })

        row.barFill = row:CreateTexture(nil, "ARTWORK")
        row.barFill:SetHeight(4)
        row.barFill:SetPoint("LEFT", row.barBg, "LEFT", 0, 0)
        applyAtlas(row.barFill, "UI-Frame-Bar-Fill-Green", { 1, 1, 1, 1 })

        row.itemID = nil
        row:SetScript("OnEnter", function(self)
            if self.highlight then
                self.highlight:Show()
            end
            if not GameTooltip then
                return
            end
            pcall(GameTooltip.SetOwner, GameTooltip, self, "ANCHOR_RIGHT")
            if self.itemID then
                if type(GameTooltip.SetItemByID) == "function" then
                    pcall(GameTooltip.SetItemByID, GameTooltip, self.itemID)
                elseif type(GameTooltip.SetHyperlink) == "function" then
                    pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. self.itemID)
                end
            end
            if GameTooltip.Show then
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self)
            if self.highlight then
                self.highlight:Hide()
            end
            if GameTooltip and GameTooltip.Hide then
                GameTooltip:Hide()
            end
        end)

        row:Hide()
        itemRows[index] = row
    end

    emptyText = createText(content, "GameFontDisable", "small", palette.textDim)
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -ROWS_Y)
    emptyText:SetJustifyH("CENTER")
    emptyText:SetText(L.STATS_EMPTY)
    emptyText:Hide()

    moreText = createText(content, "GameFontHighlightSmall", "small", palette.textDim)
    moreText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(ROWS_Y + MAX_ITEM_ROWS * ROW_HEIGHT))
    moreText:Hide()

    local ok, templateButton = pcall(CreateFrame, "Button", nil, content, "UIPanelButtonTemplate")
    if ok and templateButton then
        resetButton = templateButton
    else
        local okBackdrop, backdropButton = pcall(CreateFrame, "Button", nil, content, "BackdropTemplate")
        resetButton = (okBackdrop and backdropButton) or CreateFrame("Button", nil, content)
        if resetButton.SetBackdrop then
            resetButton:SetBackdrop(Theme.backdrop)
            resetButton:SetBackdropColor(palette.panelBg[1], palette.panelBg[2], palette.panelBg[3], 1)
            resetButton:SetBackdropBorderColor(palette.panelBorder[1], palette.panelBorder[2], palette.panelBorder[3], 1)
        end
        resetLabel = createText(resetButton, "GameFontNormalSmall", "small", palette.text)
        resetLabel:SetPoint("CENTER")
        resetLabel:SetText(L.STATS_RESET)
    end

    resetButton:SetWidth(BUTTON_WIDTH)
    if resetButton.SetHeight then
        resetButton:SetHeight(BUTTON_HEIGHT)
    end
    resetButton:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    if type(resetButton.SetText) == "function" then
        resetButton:SetText(L.STATS_RESET)
    end
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
    frame = tryFrame("ButtonFrameTemplate")
    if not frame then
        frame = tryFrame("PortraitFrameTemplate")
    end
    if not frame then
        native = false
        frame = tryFrame("BackdropTemplate") or CreateFrame("Frame", FRAME_NAME, UIParent)
    end

    frame:SetFrameStrata("HIGH")
    frame:SetWidth(WIDTH)
    frame:SetHeight(300)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    if frame.EnableMouse then
        frame:EnableMouse(true)
    end

    local stats = getSettings()
    local point = type(stats) == "table" and stats.point or "CENTER"
    local x = type(stats) == "table" and stats.x or 0
    local y = type(stats) == "table" and stats.y or 0
    frame:SetPoint(point, UIParent, point, x, y)

    if not native and frame.SetBackdrop then
        frame:SetBackdrop(Theme.backdrop)
        frame:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 1)
        frame:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)
    end

    local hasTitle = false
    if type(frame.SetTitle) == "function" then
        local ok = pcall(frame.SetTitle, frame, L.STATS_TITLE)
        hasTitle = hasTitle or ok
    end
    if frame.TitleText and type(frame.TitleText.SetText) == "function" then
        local ok = pcall(frame.TitleText.SetText, frame.TitleText, L.STATS_TITLE)
        hasTitle = hasTitle or ok
    end
    if not hasTitle then
        local title = createText(frame, "GameFontNormalLarge", "title", palette.title)
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -8)
        title:SetText(L.STATS_TITLE)
    end

    local hasPortrait = false
    if type(frame.SetPortraitToAsset) == "function" then
        local ok = pcall(frame.SetPortraitToAsset, frame, FALLBACK_ICON)
        hasPortrait = hasPortrait or ok
    end
    if type(frame.SetPortraitTextureRaw) == "function" then
        local ok = pcall(frame.SetPortraitTextureRaw, frame, FALLBACK_ICON)
        hasPortrait = hasPortrait or ok
    end
    if frame.PortraitContainer and type(frame.PortraitContainer.SetTexture) == "function" then
        local ok = pcall(frame.PortraitContainer.SetTexture, frame.PortraitContainer, FALLBACK_ICON)
        hasPortrait = hasPortrait or ok
    end
    if not hasPortrait then
        local portrait = frame:CreateTexture(nil, "ARTWORK")
        portrait:SetSize(32, 32)
        portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -6)
        portrait:SetTexture(FALLBACK_ICON)
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
            StatsWindow:Hide()
        end)
    end

    if type(ButtonFrameTemplate_HideButtonBar) == "function" then
        pcall(ButtonFrameTemplate_HideButtonBar, frame)
    end
    if frame.ButtonBar and frame.ButtonBar.Hide then
        frame.ButtonBar:Hide()
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
            if not inCombat() then
                frame:StartMoving()
            end
        end)
        drag:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
            savePosition()
        end)
    end

    content = frame.Inset
    if content and (type(content.CreateFontString) ~= "function" or type(content.CreateTexture) ~= "function") then
        content = nil
    end
    if not content then
        content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -34)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    end

    buildContent()

    frame:SetScript("OnHide", function()
        cancelResetConfirm()
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
