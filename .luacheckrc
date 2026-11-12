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
    "C_CVar",
    "C_Map",
    "C_Spell",
    "C_SpellBook",
    "C_Timer",
    "GetAddOnMetadata",
    "DEFAULT_CHAT_FRAME",
    "UIParent",
    "date",
    "GetTime",
    "GetBuildInfo",
    "GetZoneText",
    "GetSubZoneText",
    "GetProfessions",
    "GetProfessionInfo",
    "GetInventoryItemID",
    "GetInventoryItemLink",
    "GetBindingKey",
    "GetCVar",
    "IsFishingLoot",
    "GetNumLootItems",
    "GetLootSlotLink",
    "GetLootSlotInfo",
    "IsSpellKnown",
    "InCombatLockdown",
    "UnitName",
    "UnitExists",
    "UnitChannelInfo",
    "issecretvalue",
    "print",
    "strtrim",
    "strsplit",
    "strlower",
}

exclude_files = {
    ".agentrelay/",
    ".agents/",
}
