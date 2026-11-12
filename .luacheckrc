std = "lua51"
max_line_length = false
ignore = { "211/ADDON" }

globals = {
    "FishForeverDB",
    "FishForeverCharDB",
    "SLASH_FISHFOREVER1",
    "SLASH_FISHFOREVER2",
    "SlashCmdList",
}

read_globals = {
    "CreateFrame",
    "GetLocale",
    "C_AddOns",
    "GetAddOnMetadata",
    "DEFAULT_CHAT_FRAME",
    "print",
    "strtrim",
    "strsplit",
    "strlower",
}

exclude_files = {
    ".agentrelay/",
    ".agents/",
}
