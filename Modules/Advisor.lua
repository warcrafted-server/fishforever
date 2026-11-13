local ADDON, ns = ...

local Advisor = ns:NewModule("Advisor")

local FISHING_SKILL_LINE = 356

local lastTrainMax

local function pack(...)
    return { n = select("#", ...), ... }
end

local function currentMapID()
    if not (C_Map and type(C_Map.GetBestMapForUnit) == "function") then
        return nil
    end
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    if ok and type(mapID) == "number" then
        return mapID
    end
    return nil
end

local function zoneName(mapID)
    if type(mapID) ~= "number" then
        return nil
    end
    if not (C_Map and type(C_Map.GetMapInfo) == "function") then
        return nil
    end
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if ok and type(info) == "table" and type(info.name) == "string" and info.name ~= "" then
        return info.name
    end
    return nil
end

function Advisor:GetSkill()
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then
        return nil
    end
    local values = pack(pcall(GetProfessions))
    if not values[1] then
        return nil
    end
    for index = 2, values.n do
        local professionIndex = values[index]
        if type(professionIndex) == "number" then
            local info = pack(pcall(GetProfessionInfo, professionIndex))
            if info[1] and info[8] == FISHING_SKILL_LINE then
                local skill = info[4]
                local maxSkill = info[5]
                if type(skill) == "number" and type(maxSkill) == "number" then
                    return skill, maxSkill
                end
            end
        end
    end
    return nil
end

function Advisor:ZoneStatus(mapID)
    local zones = ns.Zones
    if type(mapID) ~= "number" or type(zones) ~= "table" or type(zones.minSkill) ~= "table" then
        return "unknown"
    end
    local minSkill = zones.minSkill[mapID]
    if type(minSkill) ~= "number" then
        return "unknown"
    end

    local noEscapeSkill = minSkill + (zones.NO_ESCAPE_MARGIN or 95)
    local skill = self:GetSkill()
    if not skill or skill < minSkill then
        return "tooLow", minSkill, noEscapeSkill
    elseif skill < noEscapeSkill then
        return "escapes", minSkill, noEscapeSkill
    end
    return "clean", minSkill, noEscapeSkill
end

function Advisor:Suggestions(skill)
    local clean, nextTier = {}, {}
    local zones = ns.Zones
    if type(skill) ~= "number" or type(zones) ~= "table" or type(zones.minSkill) ~= "table" then
        return clean, nextTier
    end

    local margin = zones.NO_ESCAPE_MARGIN or 95
    local nextMin
    for mapID, minSkill in pairs(zones.minSkill) do
        if type(minSkill) == "number" then
            local name = zoneName(mapID)
            if name then
                if skill >= minSkill + margin then
                    clean[#clean + 1] = { mapID = mapID, name = name, minSkill = minSkill }
                elseif minSkill > skill and (not nextMin or minSkill < nextMin) then
                    nextMin = minSkill
                end
            end
        end
    end

    if nextMin then
        for mapID, minSkill in pairs(zones.minSkill) do
            if minSkill == nextMin then
                local name = zoneName(mapID)
                if name then
                    nextTier[#nextTier + 1] = { mapID = mapID, name = name, minSkill = minSkill }
                end
            end
        end
    end

    table.sort(clean, function(a, b)
        if a.minSkill ~= b.minSkill then
            return a.minSkill > b.minSkill
        end
        return a.mapID < b.mapID
    end)
    while #clean > 5 do
        table.remove(clean)
    end
    table.sort(nextTier, function(a, b)
        return a.mapID < b.mapID
    end)
    return clean, nextTier
end

local function zoneStatusText(status, name, minSkill, noEscapeSkill)
    if status == "tooLow" then
        return ns.L.ADVISOR_ZONE_TOO_LOW:format(name, minSkill)
    elseif status == "escapes" then
        return ns.L.ADVISOR_ZONE_ESCAPES:format(name, noEscapeSkill)
    elseif status == "clean" then
        return ns.L.ADVISOR_ZONE_CLEAN:format(name)
    end
    return ns.L.ADVISOR_ZONE_UNKNOWN:format(name)
end

function Advisor:StatusLine()
    local skill, maxSkill = self:GetSkill()
    local skillText = skill and maxSkill and string.format("%d/%d", skill, maxSkill) or ns.L.ADVISOR_NOT_LEARNED
    local mapID = currentMapID()
    local name = zoneName(mapID) or "?"
    local status, minSkill, noEscapeSkill = self:ZoneStatus(mapID)
    return ns.L.ADVISOR_LINE:format(skillText, zoneStatusText(status, name, minSkill, noEscapeSkill))
end

function Advisor:CurrentZone()
    local mapID = currentMapID()
    return mapID, zoneName(mapID)
end

function Advisor:CheckTraining()
    local settings = ns.db and ns.db.settings
    local advisor = settings and settings.advisor
    if advisor and advisor.warn == false then
        return
    end
    local skill, maxSkill = self:GetSkill()
    if not skill or not maxSkill or maxSkill >= 300 then
        return
    end
    if skill < maxSkill - 5 or lastTrainMax == maxSkill then
        return
    end
    lastTrainMax = maxSkill
    ns:Print(ns.L.ADVISOR_WARN_TRAIN:format(maxSkill))
end

function Advisor:OnFishingMode(active)
    if not active then
        return
    end
    local settings = ns.db and ns.db.settings
    local advisor = settings and settings.advisor
    if advisor and advisor.warn == false then
        return
    end

    local mapID = currentMapID()
    local name = zoneName(mapID)
    local status, minSkill = self:ZoneStatus(mapID)
    if status == "tooLow" and name then
        ns:Print(ns.L.ADVISOR_WARN_TOO_LOW:format(name, minSkill))
    end
    self:CheckTraining()
end

ns:RegisterEvent("SKILL_LINES_CHANGED", function()
    Advisor:CheckTraining()
end)

ns:RegisterEvent("CHAT_MSG_SKILL", function()
    Advisor:CheckTraining()
end)

ns:RegisterSlashCommand("zone", function()
    local skill, maxSkill = Advisor:GetSkill()
    if not skill then
        ns:Print(ns.L.ADVISOR_NO_SKILL)
        return
    end
    ns:Print(ns.L.ADVISOR_SKILL:format(skill, maxSkill))

    local mapID = currentMapID()
    local name = zoneName(mapID) or "?"
    local status, minSkill, noEscapeSkill = Advisor:ZoneStatus(mapID)
    ns:Print(zoneStatusText(status, name, minSkill, noEscapeSkill))

    local clean, nextTier = Advisor:Suggestions(skill)
    if #clean > 0 then
        local entries = {}
        for index = 1, #clean do
            entries[index] = ns.L.ADVISOR_SUGGEST_ENTRY:format(clean[index].name, clean[index].minSkill)
        end
        ns:Print(ns.L.ADVISOR_SUGGEST_CLEAN:format(table.concat(entries, ", ")))
    end
    if #nextTier > 0 then
        local entries = {}
        for index = 1, #nextTier do
            entries[index] = ns.L.ADVISOR_SUGGEST_ENTRY:format(nextTier[index].name, nextTier[index].minSkill)
        end
        ns:Print(ns.L.ADVISOR_SUGGEST_NEXT:format(table.concat(entries, ", ")))
    end
end, "SLASH_HELP_ZONE")
