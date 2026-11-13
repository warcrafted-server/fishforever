local ADDON, ns = ...

ns.UI = ns.UI or {}

local function hex(value)
    return {
        tonumber(value:sub(1, 2), 16) / 255,
        tonumber(value:sub(3, 4), 16) / 255,
        tonumber(value:sub(5, 6), 16) / 255,
        1,
    }
end

-- Same family as Lorewake and FarmAdvisor (UI-4 mockup tokens), see docs/DISENO.md.
local palette = {
    windowBg = hex("15100b"),
    barBg = hex("1d160f"),
    panelBg = hex("191209"),
    highlightBg = hex("221910"),
    windowBorder = hex("5a4630"),
    panelBorder = hex("2e2418"),
    title = hex("e6b84a"),
    sectionLabel = hex("c9a24a"),
    text = hex("e9dfc8"),
    textDim = hex("a3957c"),
    ok = hex("7fe08a"),
    missing = hex("ff6b62"),
    amber = hex("f2d43a"),
    orange = hex("ff8a3d"),
    primaryBg = hex("6b1d12"),
    primaryBorder = hex("b8914a"),
}

local GAME_FONT = "Fonts\\FRIZQT__.TTF"
local BODY_FONT = "Fonts\\ARIALN.TTF"

ns.UI.Theme = {
    palette = palette,
    font = {
        title = { GAME_FONT, 14 },
        label = { GAME_FONT, 11 },
        body = { BODY_FONT, 13 },
        small = { BODY_FONT, 11 },
    },
    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    },
}

-- Timer colour from the remaining fraction (1 = just cast, 0 = about to expire).
function ns.UI.Theme:TimerColor(remaining)
    if remaining > 0.5 then
        return palette.ok
    elseif remaining > 0.2 then
        return palette.amber
    end
    return palette.missing
end
