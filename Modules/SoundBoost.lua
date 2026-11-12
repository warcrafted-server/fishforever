local ADDON, ns = ...

-- The client fires no event when a fish bites, so the alert is the game's own
-- splash sound made audible: effects up, music and ambience down while fishing.

local SoundBoost = ns:NewModule("SoundBoost")

local BOOST = {
    Sound_EnableSFX = "1",
    Sound_SFXVolume = "1.0",
    Sound_MusicVolume = "0",
    Sound_AmbienceVolume = "0",
}

-- Keep the boost between consecutive casts instead of flickering the volume.
local RESTORE_DELAY = 10

local restoreToken = 0

local function getCVar(name)
    if C_CVar and C_CVar.GetCVar then
        return C_CVar.GetCVar(name)
    end
    return GetCVar(name)
end

local function setCVar(name, value)
    if C_CVar and C_CVar.SetCVar then
        C_CVar.SetCVar(name, value)
    else
        SetCVar(name, value)
    end
end

local function enabled()
    return ns.db and ns.db.settings.alert.sound
end

-- Originals live in SavedVariables so a crash or /reload mid-fishing can
-- still give the player their own volumes back.
function SoundBoost:Start()
    restoreToken = restoreToken + 1
    local alert = ns.db and ns.db.settings.alert
    if not alert or not enabled() or alert.savedVolumes then
        return
    end
    local saved = {}
    for name, value in pairs(BOOST) do
        saved[name] = getCVar(name)
        setCVar(name, value)
    end
    alert.savedVolumes = saved
end

function SoundBoost:Restore()
    restoreToken = restoreToken + 1
    local alert = ns.db and ns.db.settings.alert
    local saved = alert and alert.savedVolumes
    if not saved then
        return
    end
    for name, value in pairs(saved) do
        if value ~= nil then
            setCVar(name, value)
        end
    end
    alert.savedVolumes = nil
end

function SoundBoost:ScheduleRestore()
    restoreToken = restoreToken + 1
    local token = restoreToken
    C_Timer.After(RESTORE_DELAY, function()
        if token == restoreToken then
            SoundBoost:Restore()
        end
    end)
end

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", function(_, _, unit, _, spellID)
    if unit == "player" and ns.IsFishingSpell(spellID) then
        SoundBoost:Start()
    end
end)

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", function(_, _, unit, _, spellID)
    if unit == "player" and ns.IsFishingSpell(spellID) then
        SoundBoost:ScheduleRestore()
    end
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    SoundBoost:Restore()
end)

ns:RegisterEvent("PLAYER_LOGOUT", function()
    SoundBoost:Restore()
end)

ns:RegisterSlashCommand("sound", function()
    local alert = ns.db.settings.alert
    alert.sound = not alert.sound
    if not alert.sound then
        SoundBoost:Restore()
    end
    ns:Print(alert.sound and ns.L.MSG_SOUND_ON or ns.L.MSG_SOUND_OFF)
end, "SLASH_HELP_SOUND")
