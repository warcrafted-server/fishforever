local ADDON, ns = ...

local LOG_MAX = 300
local pending = {}

ns.Log = ns.Log or {}

local function clean(text)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

local function append(log, line)
    log[#log + 1] = line
    while #log > LOG_MAX do
        table.remove(log, 1)
    end
end

local function flush(db)
    if #pending == 0 then
        return
    end
    if type(db.log) ~= "table" then
        db.log = {}
    end
    for i = 1, #pending do
        append(db.log, pending[i])
    end
    pending = {}
end

-- Everything the addon prints also goes to SavedVariables so it can be read
-- from disk after a /reload, where the chat log cannot be copied.
function ns.Log:Record(text)
    return pcall(function()
        local stamp = type(date) == "function" and date("%H:%M:%S") or ""
        local line = stamp .. " " .. clean(tostring(text))
        local db = ns.db
        if type(db) ~= "table" then
            pending[#pending + 1] = line
            while #pending > LOG_MAX do
                table.remove(pending, 1)
            end
            return
        end
        flush(db)
        if type(db.log) ~= "table" then
            db.log = {}
        end
        append(db.log, line)
    end)
end

ns:RegisterEvent("PLAYER_LOGIN", function()
    if type(ns.db) == "table" then
        pcall(flush, ns.db)
    end
end)
