local ADDON, ns = ...

local Lure = ns:NewModule("Lure")

local LURE_DURATION = 600
local BAG_COUNT = 4

-- Only 6529 (Shiny Bauble) is verified in this client; the rest are classic-era IDs.
local LURES = {
    [6529] = 25,
    [6530] = 50,
    [6811] = 50,
    [6532] = 75,
    [7307] = 75,
    [6533] = 100,
}

local cachedBest
local scanned = false
local lastHasLure = false
local ticker
local pollFrame
local pollElapsed = 0

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function notifyChanged()
    if type(ns.LureChanged) == "function" then
        pcall(ns.LureChanged)
    end
end

local function notifyExpired()
    if type(ns.LureExpired) == "function" then
        pcall(ns.LureExpired)
    end
end

local function isUsable(itemID)
    if not (C_Item and type(C_Item.IsUsableItem) == "function") then
        return true
    end
    local ok, usable = pcall(C_Item.IsUsableItem, itemID)
    if not ok or isSecret(usable) then
        return true
    end
    return usable and true or false
end

local function scanBags()
    if not (C_Container and type(C_Container.GetContainerNumSlots) == "function"
        and type(C_Container.GetContainerItemInfo) == "function") then
        return nil
    end

    local counts = {}
    local usability = {}
    for bag = 0, BAG_COUNT do
        local okSlots, slots = pcall(C_Container.GetContainerNumSlots, bag)
        if okSlots and type(slots) == "number" and not isSecret(slots) then
            for slot = 1, slots do
                local okInfo, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
                if okInfo and type(info) == "table" and not isSecret(info.itemID) then
                    local itemID = info.itemID
                    if LURES[itemID] then
                        if usability[itemID] == nil then
                            usability[itemID] = isUsable(itemID)
                        end
                        if usability[itemID] then
                            local stacks = info.stackCount
                            if isSecret(stacks) or type(stacks) ~= "number" or stacks < 1 then
                                stacks = 1
                            end
                            counts[itemID] = (counts[itemID] or 0) + stacks
                        end
                    end
                end
            end
        end
    end

    local bestID, bestBonus
    for itemID, bonus in pairs(LURES) do
        local count = counts[itemID]
        if count and count > 0 then
            if bestBonus == nil or bonus > bestBonus or (bonus == bestBonus and itemID < bestID) then
                bestID, bestBonus = itemID, bonus
            end
        end
    end
    if not bestID then
        return nil
    end
    return { itemID = bestID, bonus = bestBonus, count = counts[bestID] }
end

local function resultChanged(best)
    if cachedBest == nil or best == nil then
        return cachedBest ~= best
    end
    return cachedBest.itemID ~= best.itemID
        or cachedBest.bonus ~= best.bonus
        or cachedBest.count ~= best.count
end

local function rescan()
    local best = scanBags()
    local changed = resultChanged(best)
    cachedBest = best
    scanned = true
    if changed then
        notifyChanged()
    end
end

-- A lure only "runs out" when it disappears with its last seconds on the
-- clock; swapping weapons in and out of fishing mode also makes the main-hand
-- enchant vanish and must not warn.
local EXPIRY_MARGIN = 3
local lastRemaining = 0

local function onPoll()
    local hasLure, remaining = Lure:GetActive()
    local was, wasRemaining = lastHasLure, lastRemaining
    lastHasLure, lastRemaining = hasLure, remaining

    if was and not hasLure and wasRemaining <= EXPIRY_MARGIN then
        local fishing = ns.modules.FishingMode
        if type(fishing) == "table" and type(fishing.IsActive) == "function" and fishing:IsActive() then
            notifyExpired()
        end
    end

    if hasLure or hasLure ~= was then
        notifyChanged()
    end
end

local function startPolling()
    if ticker or pollFrame then
        return
    end
    if type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" then
        local ok, created = pcall(C_Timer.NewTicker, 1, function()
            pcall(onPoll)
        end)
        if ok and created then
            ticker = created
            return
        end
    end

    local ok, frame = pcall(CreateFrame, "Frame")
    if not ok or frame == nil then
        return
    end
    pollFrame = frame
    frame:SetScript("OnUpdate", function(_, delta)
        pollElapsed = pollElapsed + delta
        if pollElapsed >= 1 then
            pollElapsed = pollElapsed - 1
            pcall(onPoll)
        end
    end)
end

function Lure:FindBest()
    if not scanned then
        rescan()
    end
    if not cachedBest then
        return nil
    end
    return cachedBest.itemID, cachedBest.bonus, cachedBest.count
end

function Lure:GetActive()
    local hasLure, remaining = false, 0
    if type(GetWeaponEnchantInfo) ~= "function" then
        return hasLure, remaining
    end

    local ok, mainHand, expiration = pcall(GetWeaponEnchantInfo)
    if not ok or isSecret(mainHand) or not mainHand then
        return hasLure, remaining
    end

    hasLure = true
    if not isSecret(expiration) and type(expiration) == "number" then
        remaining = math.max(0, expiration / 1000)
    end
    return hasLure, remaining
end

function Lure:Duration()
    return LURE_DURATION
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    lastHasLure = Lure:GetActive()
    startPolling()
    rescan()
end)

ns:RegisterEvent("BAG_UPDATE_DELAYED", rescan)
