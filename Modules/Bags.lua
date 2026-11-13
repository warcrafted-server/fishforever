local ADDON, ns = ...

local Bags = ns:NewModule("Bags")

local BAG_COUNT = 4
local WARN_INTERVAL = 20

local lastWarning = {}

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

function Bags:FreeSlots()
    local total = 0
    if not (C_Container and type(C_Container.GetContainerNumFreeSlots) == "function") then
        return total
    end
    for bag = 0, BAG_COUNT do
        local ok, freeSlots, bagFamily = pcall(C_Container.GetContainerNumFreeSlots, bag)
        if ok and not isSecret(freeSlots) and type(freeSlots) == "number" then
            if bagFamily == nil or (not isSecret(bagFamily) and bagFamily == 0) then
                total = total + freeSlots
            end
        end
    end
    return total
end

local function warn(kind, text, red, green, blue)
    local now = GetTime()
    local last = lastWarning[kind]
    if last and now - last < WARN_INTERVAL then
        return
    end
    lastWarning[kind] = now
    if UIErrorsFrame and type(UIErrorsFrame.AddMessage) == "function" then
        pcall(UIErrorsFrame.AddMessage, UIErrorsFrame, text, red, green, blue)
    end
end

ns:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", function(_, _, unit, _, spellID)
    if unit ~= "player" or type(ns.IsFishingSpell) ~= "function" then
        return
    end
    if not ns.IsFishingSpell(spellID) then
        return
    end
    local free = Bags:FreeSlots()
    if free == 0 then
        warn("full", ns.L.MSG_BAGS_FULL, 1, 0.54, 0.24)
    elseif free <= 2 then
        warn("low", ns.L.MSG_BAGS_LOW:format(free), 0.95, 0.83, 0.23)
    end
end)
