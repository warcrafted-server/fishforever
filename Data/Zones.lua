local ADDON, ns = ...

-- Minimum Fishing skill to cast in each zone, keyed by uiMapID (IDs from the
-- client's UiMap table). Values: WoW Classic table from
-- https://warcrafttavern.com/wow-classic/guides/fishing-1-300
-- "To fish without ever losing a fish requires a skill differential of 95
-- above the minimum listed." Confirmed by in-game data: escapes in Loch Modan
-- (minimum 1) at skill 75.
-- Zones missing from that source (Badlands, Blasted Lands, Searing Gorge,
-- capital cities, custom zones) are left out on purpose: unknown, not zero.
-- Sub-zones with a higher requirement (Jaguero Isle 205, Bay of Storms 330,
-- Jademir Lake 330) are noted in `harder` and not used for the zone value.

ns.Zones = {
    NO_ESCAPE_MARGIN = 95,

    minSkill = {
        -- Tier 1
        [1411] = 1,   -- Durotar
        [1412] = 1,   -- Mulgore
        [1413] = 1,   -- The Barrens
        [1420] = 1,   -- Tirisfal Glades
        [1421] = 1,   -- Silverpine Forest
        [1426] = 1,   -- Dun Morogh
        [1429] = 1,   -- Elwynn Forest
        [1432] = 1,   -- Loch Modan
        [1436] = 1,   -- Westfall
        [1438] = 1,   -- Teldrassil
        [1439] = 1,   -- Darkshore
        -- Tier 2
        [1424] = 55,  -- Hillsbrad Foothills
        [1431] = 55,  -- Duskwood
        [1433] = 55,  -- Redridge Mountains
        [1437] = 55,  -- Wetlands
        [1440] = 55,  -- Ashenvale
        [1442] = 55,  -- Stonetalon Mountains
        -- Tier 3
        [1416] = 130, -- Alterac Mountains
        [1417] = 130, -- Arathi Highlands
        [1434] = 130, -- Stranglethorn Vale
        [1435] = 130, -- Swamp of Sorrows
        [1441] = 130, -- Thousand Needles
        [1443] = 130, -- Desolace
        [1445] = 130, -- Dustwallow Marsh
        -- Tier 4
        [1422] = 205, -- Western Plaguelands
        [1425] = 205, -- The Hinterlands
        [1444] = 205, -- Feralas
        [1446] = 205, -- Tanaris
        [1447] = 205, -- Azshara
        [1448] = 205, -- Felwood
        [1449] = 205, -- Un'Goro Crater
        [1450] = 205, -- Moonglade
        -- Tier 5
        [1423] = 330, -- Eastern Plaguelands
        [1428] = 330, -- Burning Steppes
        [1430] = 330, -- Deadwind Pass
        [1451] = 330, -- Silithus
        [1452] = 330, -- Winterspring
    },

    -- Zones where part of the water needs more skill than the zone value.
    harder = {
        [1434] = 205, -- Jaguero Isle
        [1444] = 330, -- Jademir Lake
        [1447] = 330, -- Bay of Storms
    },
}
