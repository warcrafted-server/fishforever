local ADDON, ns = ...

ns.UI = ns.UI or {}

local Consent = {}
ns.UI.Consent = Consent

local FRAME_NAME = "FishForeverConsent"
local WIDTH = 360
local PADDING = 18
local TITLE_GAP = 8
local CHECK_GAP = 12
local CHECK_ROW = 20
local CHECK_SPACING = 6
local NOTE_GAP = 6
local BODY_GAP = 14
local BUTTON_WIDTH = 90
local BUTTON_HEIGHT = 22

local Theme = ns.UI.Theme
local palette = Theme.palette
local L = ns.L

local frame
local title
local body
local groupCheck
local guildCheck
local note
local okButton
local optionsButton

local expanded = false
local pending = false

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown() and true or false
end

local function shouldShowNotice()
    if ns.readOnlyData then
        return false
    end
    local consent = type(ns.db) == "table" and ns.db.consent or nil
    if type(consent) ~= "table" then
        return false
    end
    return (consent.noticeSeen or 0) < (ns.NOTICE_VERSION or 0)
end

local function markSeen()
    if ns.readOnlyData or type(ns.db) ~= "table" or type(ns.db.consent) ~= "table" then
        return
    end
    ns.db.consent.noticeSeen = ns.NOTICE_VERSION
end

local function layout()
    local titleHeight = math.ceil(title:GetStringHeight() or 0)
    if titleHeight < 10 then
        titleHeight = 16
    end
    local bodyHeight = math.ceil(body:GetStringHeight() or 0)
    if bodyHeight < 40 then
        bodyHeight = 90
    end

    local height = PADDING + titleHeight + TITLE_GAP + bodyHeight
    if expanded then
        local noteHeight = math.ceil(note:GetStringHeight() or 0)
        if noteHeight < 20 then
            noteHeight = 45
        end
        height = height + CHECK_GAP + CHECK_ROW * 2 + CHECK_SPACING + NOTE_GAP + noteHeight
    end
    height = height + BODY_GAP + BUTTON_HEIGHT + PADDING
    frame:SetHeight(height)
end

local function createButton(parent, text, primary)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    button:SetBackdrop(Theme.backdrop)
    local background = primary and palette.primaryBg or palette.panelBg
    local border = primary and palette.primaryBorder or palette.panelBorder
    button:SetBackdropColor(background[1], background[2], background[3], 1)
    button:SetBackdropBorderColor(border[1], border[2], border[3], 1)

    local label = button:CreateFontString(nil, "OVERLAY")
    label:SetFont(Theme.font.label[1], Theme.font.label[2])
    label:SetTextColor(palette.text[1], palette.text[2], palette.text[3], 1)
    label:SetPoint("CENTER")
    label:SetText(text)

    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(palette.highlightBg[1], palette.highlightBg[2], palette.highlightBg[3], 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(background[1], background[2], background[3], 1)
    end)
    return button
end

local function createCheckbox(parent, text, key, top, gap)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(CHECK_ROW, CHECK_ROW)
    check:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -(gap or CHECK_GAP))
    check:SetScript("OnClick", function(self)
        if ns.readOnlyData or type(ns.db) ~= "table" or type(ns.db.consent) ~= "table" then
            return
        end
        ns.db.consent[key] = self:GetChecked() and true or false
    end)

    local label = check:CreateFontString(nil, "OVERLAY")
    label:SetFont(Theme.font.body[1], Theme.font.body[2])
    label:SetTextColor(palette.text[1], palette.text[2], palette.text[3], 1)
    label:SetPoint("LEFT", check, "RIGHT", 6, 0)
    label:SetText(text)
    return check
end

local function expandOptions()
    if expanded then
        return
    end
    expanded = true
    groupCheck:Show()
    guildCheck:Show()
    note:Show()
    layout()
end

local function syncCheckboxes()
    local consent = type(ns.db) == "table" and ns.db.consent or nil
    groupCheck:SetChecked(type(consent) == "table" and consent.shareGroup == true)
    guildCheck:SetChecked(type(consent) == "table" and consent.shareGuild == true)
end

local function show(expandedOptions)
    if expandedOptions then
        expandOptions()
    end
    syncCheckboxes()
    layout()
    frame:Show()
    frame:Raise()
end

local function createFrame()
    frame = CreateFrame("Frame", FRAME_NAME, UIParent, "BackdropTemplate")
    frame:SetSize(WIDTH, 160)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetBackdrop(Theme.backdrop)
    frame:SetBackdropColor(palette.windowBg[1], palette.windowBg[2], palette.windowBg[3], 1)
    frame:SetBackdropBorderColor(palette.windowBorder[1], palette.windowBorder[2], palette.windowBorder[3], 1)
    frame:SetScript("OnDragStart", function(self)
        if not inCombat() then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    frame:Hide()

    title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont(Theme.font.title[1], Theme.font.title[2])
    title:SetTextColor(palette.title[1], palette.title[2], palette.title[3], 1)
    title:SetPoint("TOPLEFT", PADDING, -PADDING)
    title:SetText(L.CONSENT_TITLE)

    body = frame:CreateFontString(nil, "OVERLAY")
    body:SetFont(Theme.font.body[1], Theme.font.body[2])
    body:SetTextColor(palette.text[1], palette.text[2], palette.text[3], 1)
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -TITLE_GAP)
    body:SetWidth(WIDTH - PADDING * 2)
    body:SetJustifyH("LEFT")
    body:SetText(L.CONSENT_TEXT)

    groupCheck = createCheckbox(frame, L.CONSENT_SHARE_GROUP, "shareGroup", body, CHECK_GAP)
    guildCheck = createCheckbox(frame, L.CONSENT_SHARE_GUILD, "shareGuild", groupCheck, CHECK_SPACING)
    groupCheck:Hide()
    guildCheck:Hide()

    note = frame:CreateFontString(nil, "OVERLAY")
    note:SetFont(Theme.font.small[1], Theme.font.small[2])
    note:SetTextColor(palette.textDim[1], palette.textDim[2], palette.textDim[3], 1)
    note:SetPoint("TOPLEFT", guildCheck, "BOTTOMLEFT", 0, -NOTE_GAP)
    note:SetWidth(WIDTH - PADDING * 2)
    note:SetJustifyH("LEFT")
    note:SetText(L.CONSENT_NOTE)
    note:Hide()

    okButton = createButton(frame, L.CONSENT_OK, true)
    okButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)
    okButton:SetScript("OnClick", function()
        markSeen()
        frame:Hide()
    end)

    optionsButton = createButton(frame, L.CONSENT_OPTIONS, false)
    optionsButton:SetPoint("RIGHT", okButton, "LEFT", -8, 0)
    optionsButton:SetScript("OnClick", function()
        markSeen()
        expandOptions()
    end)

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

function Consent:Show(expandedOptions)
    if inCombat() then
        return false
    end
    ensureFrame()
    show(expandedOptions == true)
    return true
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    if not shouldShowNotice() then
        return
    end
    local function showNotice()
        if not shouldShowNotice() then
            return
        end
        if inCombat() then
            pending = true
            return
        end
        ensureFrame()
        show(false)
    end
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(3, showNotice)
    else
        showNotice()
    end
end)

ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    if not pending then
        return
    end
    pending = false
    if shouldShowNotice() then
        ensureFrame()
        show(false)
    end
end)

ns:RegisterSlashCommand("privacy", function()
    if not Consent:Show(true) then
        ns:Print(L.MSG_NOT_IN_COMBAT)
    end
end, "SLASH_HELP_PRIVACY")
