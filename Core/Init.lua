local ADDON, ns = ...

ns.modules = {}

local dispatcher = CreateFrame("Frame")
local handlers = {}

local function dispatch(event, ...)
    local list = handlers[event]
    if not list then
        return
    end

    -- Work on a copy so a handler may unregister itself while being called.
    local snapshot = {}
    for i = 1, #list do
        snapshot[i] = list[i]
    end

    for i = 1, #snapshot do
        snapshot[i](ns, event, ...)
    end
end

dispatcher:SetScript("OnEvent", function(_, event, ...)
    dispatch(event, ...)
end)

function ns:RegisterEvent(event, handler)
    local list = handlers[event]
    if not list then
        list = {}
        handlers[event] = list
        dispatcher:RegisterEvent(event)
    end

    for i = 1, #list do
        if list[i] == handler then
            return
        end
    end

    list[#list + 1] = handler
end

function ns:UnregisterEvent(event, handler)
    local list = handlers[event]
    if not list then
        return
    end

    for i = #list, 1, -1 do
        if list[i] == handler then
            table.remove(list, i)
        end
    end

    if #list == 0 then
        handlers[event] = nil
        dispatcher:UnregisterEvent(event)
    end
end

local prefix = "|cff33ff99" .. ns.L.ADDON_NAME .. "|r"

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. ": " .. tostring(message))
end

function ns:NewModule(name)
    local module = self.modules[name]
    if not module then
        module = {}
        self.modules[name] = module
    end
    return module
end

ns:RegisterEvent("ADDON_LOADED", function(_, _, loadedAddon)
    if loadedAddon ~= ADDON then
        return
    end
    if ns.OnInitialize then
        ns:OnInitialize()
    end
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    if ns.OnEnable then
        ns:OnEnable()
    end
end)
