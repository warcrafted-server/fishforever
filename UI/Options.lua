local ADDON, ns = ...

ns.UI = ns.UI or {}

local Options = {}
ns.UI.Options = Options

local L = ns.L
local category

local function settingsReady()
    return type(Settings) == "table"
        and type(Settings.RegisterVerticalLayoutCategory) == "function"
        and type(Settings.RegisterAddOnSetting) == "function"
        and type(Settings.CreateCheckbox) == "function"
        and type(Settings.CreateSlider) == "function"
        and type(Settings.CreateSliderOptions) == "function"
        and type(Settings.RegisterAddOnCategory) == "function"
end

local function addSetting(parent, variableName, key, tbl, default, labelKey, onChange)
    local setting = Settings.RegisterAddOnSetting(parent, variableName, key, tbl, type(default), L[labelKey], default)
    if setting and onChange and type(setting.SetValueChangedCallback) == "function" then
        setting:SetValueChangedCallback(function(_, value)
            onChange(value)
        end)
    end
    return setting
end

local function addCheckbox(parent, variableName, key, tbl, default, labelKey, tipKey, onChange)
    local setting = addSetting(parent, variableName, key, tbl, default, labelKey, onChange)
    if setting then
        Settings.CreateCheckbox(parent, setting, L[tipKey])
    end
    return setting
end

local function addSlider(parent, variableName, key, tbl, default, labelKey, tipKey, minValue, maxValue, step, formatter, onChange)
    local setting = addSetting(parent, variableName, key, tbl, default, labelKey, onChange)
    if not setting then
        return
    end
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    if options and formatter and type(options.SetLabelFormatter) == "function"
        and type(MinimalSliderWithSteppersMixin) == "table"
        and MinimalSliderWithSteppersMixin.Label then
        pcall(options.SetLabelFormatter, options, MinimalSliderWithSteppersMixin.Label.Right, formatter)
    end
    Settings.CreateSlider(parent, setting, options, L[tipKey])
    return setting
end

local function addHeader(layout, textKey)
    if type(CreateSettingsListSectionHeaderInitializer) == "function" then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L[textKey]))
    end
end

local function bobber()
    return ns.modules and ns.modules.BobberButton
end

local function onShown(value)
    local module = bobber()
    if module then
        module:SetShown(value)
    end
end

local function onScale()
    local module = bobber()
    if module then
        module:ApplyScale()
    end
end

local function onLook()
    local module = bobber()
    if module then
        module:ApplyLook()
    end
end

local function onLureButton()
    local module = ns.UI and ns.UI.LureButton
    if module then
        module:ApplyVisibility()
    end
end

local function onMinimapHide(value)
    local module = ns.UI and ns.UI.MinimapButton
    if module then
        module:SetHidden(value)
    end
end

local function registerPanel()
    local newCategory, layout = Settings.RegisterVerticalLayoutCategory(L.ADDON_NAME)
    if not newCategory or not layout then
        return
    end
    local settings = ns.db.settings

    addHeader(layout, "OPT_SEC_FISHING")
    addCheckbox(newCategory, "FishForever_AutoLoot", "autoLoot", settings, true, "OPT_AUTOLOOT", "OPT_AUTOLOOT_TIP")
    addCheckbox(newCategory, "FishForever_ShowInFishingMode", "showInFishingMode", settings.button, false, "OPT_SHOW_IN_MODE", "OPT_SHOW_IN_MODE_TIP")
    addCheckbox(newCategory, "FishForever_SessionReset", "resetOnLogin", settings.session, true, "OPT_SESSION_RESET", "OPT_SESSION_RESET_TIP")

    addHeader(layout, "OPT_SEC_BUTTON")
    addCheckbox(newCategory, "FishForever_ButtonShown", "shown", settings.button, false, "OPT_BUTTON_SHOWN", "OPT_BUTTON_SHOWN_TIP", onShown)
    addCheckbox(newCategory, "FishForever_ButtonLocked", "locked", settings.button, false, "OPT_BUTTON_LOCKED", "OPT_BUTTON_LOCKED_TIP")
    addSlider(newCategory, "FishForever_ButtonScale", "scale", settings.button, 1, "OPT_BUTTON_SCALE", "OPT_BUTTON_SCALE_TIP", 0.5, 2, 0.05, function(value)
        return string.format("%d%%", math.floor((tonumber(value) or 0) * 100 + 0.5))
    end, onScale)
    addCheckbox(newCategory, "FishForever_StatusText", "statusText", settings.button, true, "OPT_STATUS_TEXT", "OPT_STATUS_TEXT_TIP", onLook)
    addCheckbox(newCategory, "FishForever_Hotkey", "hotkey", settings.button, true, "OPT_HOTKEY", "OPT_HOTKEY_TIP", onLook)
    addCheckbox(newCategory, "FishForever_Flash", "flash", settings.alert, true, "OPT_FLASH", "OPT_FLASH_TIP")

    addHeader(layout, "OPT_SEC_LURE")
    addCheckbox(newCategory, "FishForever_LureButton", "button", settings.lure, true, "OPT_LURE_BUTTON", "OPT_LURE_BUTTON_TIP", onLureButton)
    addCheckbox(newCategory, "FishForever_LureWarn", "warn", settings.lure, true, "OPT_LURE_WARN", "OPT_LURE_WARN_TIP")
    addCheckbox(newCategory, "FishForever_LureSound", "sound", settings.lure, true, "OPT_LURE_SOUND", "OPT_LURE_SOUND_TIP")

    addHeader(layout, "OPT_SEC_SOUND")
    addCheckbox(newCategory, "FishForever_Sound", "sound", settings.alert, true, "OPT_SOUND", "OPT_SOUND_TIP")
    addCheckbox(newCategory, "FishForever_BoostSFX", "boostSFX", settings.alert, true, "OPT_BOOST_SFX", "OPT_BOOST_SFX_TIP")
    addSlider(newCategory, "FishForever_Dim", "dim", settings.alert, 30, "OPT_DIM", "OPT_DIM_TIP", 0, 100, 5, function(value)
        return string.format("%d%%", math.floor(tonumber(value) or 0))
    end)
    addSlider(newCategory, "FishForever_RestoreDelay", "restoreDelay", settings.alert, 10, "OPT_RESTORE_DELAY", "OPT_RESTORE_DELAY_TIP", 0, 60, 1, function(value)
        return string.format("%d s", math.floor(tonumber(value) or 0))
    end)

    addHeader(layout, "OPT_SEC_BAGS")
    addCheckbox(newCategory, "FishForever_BagsWarn", "warn", settings.bags, true, "OPT_BAGS_WARN", "OPT_BAGS_WARN_TIP")
    addSlider(newCategory, "FishForever_BagsThreshold", "threshold", settings.bags, 5, "OPT_BAGS_THRESHOLD", "OPT_BAGS_THRESHOLD_TIP", 1, 20, 1, function(value)
        return tostring(math.floor(tonumber(value) or 0))
    end)

    addHeader(layout, "OPT_SEC_MINIMAP")
    if type(Settings.RegisterProxySetting) == "function" then
        local setting = Settings.RegisterProxySetting(newCategory, "FishForever_MinimapShown", "boolean", L.OPT_MINIMAP, true,
            function()
                return not ns.db.settings.minimap.hide
            end,
            function(_, value)
                if value == nil then
                    value = _
                end
                local module = ns.UI and ns.UI.MinimapButton
                if module then
                    module:SetHidden(not value)
                end
            end)
        if setting then
            Settings.CreateCheckbox(newCategory, setting, L.OPT_MINIMAP_TIP)
        end
    else
        addCheckbox(newCategory, "FishForever_MinimapHide", "hide", settings.minimap, false, "OPT_MINIMAP_HIDE", "OPT_MINIMAP_HIDE_TIP", onMinimapHide)
    end

    Settings.RegisterAddOnCategory(newCategory)
    category = newCategory
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    if ns.readOnlyData or not settingsReady() then
        return
    end
    pcall(registerPanel)
end)

ns:RegisterSlashCommand("options", function()
    if ns.readOnlyData or not settingsReady() then
        ns:Print(L.MSG_OPTIONS_UNAVAILABLE)
        return
    end
    if category and type(Settings.OpenToCategory) == "function" then
        local ok, result
        if type(category.GetID) == "function" then
            ok, result = pcall(Settings.OpenToCategory, category:GetID())
        else
            ok, result = pcall(Settings.OpenToCategory, category)
        end
        if ok and result ~= false then
            return
        end
    end
    ns:Print(L.MSG_OPTIONS_HINT)
end, "SLASH_HELP_OPTIONS")
