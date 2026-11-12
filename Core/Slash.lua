local ADDON, ns = ...

local commands = {}
local commandOrder = {}

local function printHelp()
    local L = ns.L
    local lines = { L.SLASH_HELP_HEADER }

    for i = 1, #commandOrder do
        local name = commandOrder[i]
        local command = commands[name]
        lines[#lines + 1] = L.SLASH_HELP_ENTRY:format(name, L[command.helpKey])
    end

    ns:Print(table.concat(lines, "\n"))
end

local function getVersion()
    local version
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        version = C_AddOns.GetAddOnMetadata(ADDON, "Version")
    elseif GetAddOnMetadata then
        version = GetAddOnMetadata(ADDON, "Version")
    end
    return version or ns.L.VERSION_UNKNOWN
end

local function printVersion()
    ns:Print(ns.L.MSG_VERSION:format(getVersion()))
end

function ns:RegisterSlashCommand(name, handler, helpKey)
    name = strlower(name)
    if not commands[name] then
        commandOrder[#commandOrder + 1] = name
    end
    commands[name] = {
        handler = handler,
        helpKey = helpKey,
    }
end

ns:RegisterSlashCommand("help", printHelp, "SLASH_HELP_HELP")
ns:RegisterSlashCommand("version", printVersion, "SLASH_HELP_VERSION")

local function handleSlash(input)
    input = strtrim(input or "")
    local command, rest = strsplit(" ", input, 2)
    command = strlower(command or "")

    if command == "" then
        printHelp()
        return
    end

    local entry = commands[command]
    if entry then
        entry.handler(strtrim(rest or ""))
        return
    end

    ns:Print(ns.L.MSG_UNKNOWN_COMMAND:format(command))
    ns:Print(ns.L.MSG_HELP_HINT)
end

SLASH_FISHFOREVER1 = "/fishforever"
SLASH_FISHFOREVER2 = "/ff"
SlashCmdList["FISHFOREVER"] = handleSlash
