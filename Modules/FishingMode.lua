local ADDON, ns = ...

local FishingMode = ns:NewModule("FishingMode")

local MAIN_HAND = 16
local OFF_HAND = 17
local BAG_COUNT = NUM_BAG_SLOTS or 4
local WEAPON_CLASS = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or 2
local FISHING_POLE_SUBCLASS = (Enum and Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole) or 20

local pendingAction

local function pack(...)
    return { n = select("#", ...), ... }
end

local function isSecret(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret == true
end

local function inCombat()
    if type(InCombatLockdown) ~= "function" then
        return false
    end
    local ok, value = pcall(InCombatLockdown)
    return ok and value == true
end

local function notify()
    if type(ns.FishingModeChanged) ~= "function" then
        return
    end
    local active = type(ns.charDB) == "table" and ns.charDB.fishingMode == true or false
    pcall(ns.FishingModeChanged, active)
end

local function itemInfoInstant(item)
    if item == nil or isSecret(item) then
        return nil
    end
    if not (C_Item and C_Item.GetItemInfoInstant) then
        return nil
    end
    local values = pack(pcall(C_Item.GetItemInfoInstant, item))
    if not values[1] or values[2] == nil or isSecret(values[2]) then
        return nil
    end
    return {
        id = values[2],
        classID = values[7],
        subclassID = values[8],
    }
end

local function isFishingPole(item)
    if type(item) ~= "table" then
        return false
    end
    if isSecret(item.classID) or isSecret(item.subclassID) then
        return false
    end
    return item.classID == WEAPON_CLASS and item.subclassID == FISHING_POLE_SUBCLASS
end

local function inventoryItem(slot)
    local id, link
    if type(GetInventoryItemID) == "function" then
        local ok, value = pcall(GetInventoryItemID, "player", slot)
        if ok then
            id = value
        end
    end
    if type(GetInventoryItemLink) == "function" then
        local ok, value = pcall(GetInventoryItemLink, "player", slot)
        if ok then
            link = value
        end
    end
    return id, link
end

local function slotHasPole(slot)
    if type(GetInventoryItemID) ~= "function" then
        -- Without the API the state cannot be verified, so keep what was saved.
        return true
    end
    local id = inventoryItem(slot)
    if id == nil or isSecret(id) then
        return false
    end
    return isFishingPole(itemInfoInstant(id))
end

local function findBagItem(itemID)
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
        return nil
    end
    for bag = 0, BAG_COUNT do
        local okSlots, slots = pcall(C_Container.GetContainerNumSlots, bag)
        if okSlots and type(slots) == "number" then
            for slot = 1, slots do
                local okInfo, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
                if okInfo and type(info) == "table" and not isSecret(info.itemID) then
                    if itemID == nil or info.itemID == itemID then
                        return info
                    end
                end
            end
        end
    end
    return nil
end

local function findFishingPole()
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
        return nil
    end
    for bag = 0, BAG_COUNT do
        local okSlots, slots = pcall(C_Container.GetContainerNumSlots, bag)
        if okSlots and type(slots) == "number" then
            for slot = 1, slots do
                local okInfo, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
                if okInfo and type(info) == "table" and not isSecret(info.itemID) then
                    if isFishingPole(itemInfoInstant(info.itemID)) then
                        local link = info.hyperlink
                        if isSecret(link) then
                            link = nil
                        end
                        return { id = info.itemID, link = link }
                    end
                end
            end
        end
    end
    return nil
end

local function itemName(itemID, link)
    if C_Item and itemID ~= nil and C_Item.GetItemNameByID then
        local ok, name = pcall(C_Item.GetItemNameByID, itemID)
        if ok and type(name) == "string" and name ~= "" and not isSecret(name) then
            return name
        end
    end
    if C_Item and C_Item.GetItemInfo then
        local ok, name = pcall(C_Item.GetItemInfo, link or itemID)
        if ok and type(name) == "string" and name ~= "" and not isSecret(name) then
            return name
        end
    end
    return tostring(itemID or link)
end

local function itemFromLink(link)
    if type(link) ~= "string" or isSecret(link) then
        return nil
    end
    return tonumber(link:match("item:(%d+)"))
end

local function hasSavedGear(saved)
    if type(saved) ~= "table" then
        return false
    end
    local entries = { saved.mainHand, saved.offHand }
    for i = 1, #entries do
        local entry = entries[i]
        if type(entry) == "table" and (entry[1] ~= nil or entry[2] ~= nil) then
            return true
        end
    end
    return false
end

local function activate()
    local charDB = ns.charDB
    if type(charDB) ~= "table" then
        return false
    end
    if charDB.fishingMode == true then
        return false
    end
    charDB.fishingMode = true
    notify()
    return true
end

local function deactivate()
    local charDB = ns.charDB
    if type(charDB) ~= "table" then
        return false
    end
    if charDB.fishingMode ~= true then
        return false
    end
    charDB.fishingMode = false
    notify()
    return true
end

local function restoreSlot(slot, entry)
    if type(entry) ~= "table" then
        return
    end
    local itemID = entry[1]
    if itemID == nil then
        itemID = itemFromLink(entry[2])
    end
    if itemID == nil then
        return
    end
    if inventoryItem(slot) == itemID then
        return
    end

    local bagInfo = findBagItem(itemID)
    if not bagInfo then
        ns:Print(ns.L.MSG_FISH_MISSING_ITEM:format(itemName(itemID, entry[2])))
        return
    end

    local item = bagInfo.hyperlink
    if type(item) ~= "string" or isSecret(item) then
        item = itemID
    end
    if C_Item and C_Item.EquipItemByName then
        pcall(C_Item.EquipItemByName, item, slot)
    end
end

function FishingMode:IsActive()
    return type(ns.charDB) == "table" and ns.charDB.fishingMode == true
end

function FishingMode:Enter()
    if inCombat() then
        pendingAction = "enter"
        ns:Print(ns.L.MSG_FISH_IN_COMBAT)
        return
    end

    local charDB = ns.charDB
    if type(charDB) ~= "table" then
        return
    end

    if slotHasPole(MAIN_HAND) then
        if activate() then
            ns:Print(ns.L.MSG_FISH_ENTERED)
        end
        return
    end

    local pole = findFishingPole()
    if not pole then
        ns:Print(ns.L.MSG_FISH_NO_POLE)
        return
    end

    if charDB.fishingMode ~= true then
        local mainID, mainLink = inventoryItem(MAIN_HAND)
        local offID, offLink = inventoryItem(OFF_HAND)
        charDB.savedGear = {
            mainHand = { mainID, mainLink },
            offHand = { offID, offLink },
        }
    end

    if C_Item and C_Item.EquipItemByName then
        pcall(C_Item.EquipItemByName, pole.link or pole.id, MAIN_HAND)
    end
    if activate() then
        ns:Print(ns.L.MSG_FISH_ENTERED)
    end
end

function FishingMode:Exit()
    if inCombat() then
        pendingAction = "exit"
        ns:Print(ns.L.MSG_FISH_IN_COMBAT)
        return
    end

    local charDB = ns.charDB
    if type(charDB) ~= "table" then
        return
    end

    local saved = charDB.savedGear
    if hasSavedGear(saved) then
        restoreSlot(MAIN_HAND, saved.mainHand)
        restoreSlot(OFF_HAND, saved.offHand)
    end

    charDB.savedGear = {}
    if deactivate() then
        ns:Print(ns.L.MSG_FISH_EXITED)
    end
end

function FishingMode:Toggle()
    if inCombat() then
        pendingAction = self:IsActive() and "exit" or "enter"
        ns:Print(ns.L.MSG_FISH_IN_COMBAT)
        return
    end
    if self:IsActive() then
        self:Exit()
    else
        self:Enter()
    end
end

ns:RegisterSlashCommand("fish", function()
    FishingMode:Toggle()
end, "SLASH_HELP_FISH")

ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    local action = pendingAction
    if not action then
        return
    end
    pendingAction = nil
    if action == "enter" then
        FishingMode:Enter()
    else
        FishingMode:Exit()
    end
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    local charDB = ns.charDB
    if type(charDB) ~= "table" or charDB.fishingMode ~= true then
        return
    end
    if slotHasPole(MAIN_HAND) then
        return
    end
    if hasSavedGear(charDB.savedGear) then
        -- The saved gear is still restorable; /ff fish must keep working.
        return
    end
    charDB.savedGear = {}
    deactivate()
end)
