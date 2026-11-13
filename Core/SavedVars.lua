local ADDON, ns = ...

-- ns.migrations[n] upgrades a table from schema n-1 to n. Each one must be
-- idempotent and must never delete user finds; it receives the account table
-- and the character table (either may already be at a newer shape).
ns.migrations = {
    -- [2] = function(db, charDB) ... end,
}

local function copyDefaults(src, dst)
    for key, value in pairs(src) do
        if type(value) == "table" then
            if type(dst[key]) ~= "table" then
                dst[key] = {}
            end
            copyDefaults(value, dst[key])
        elseif dst[key] == nil then
            dst[key] = value
        end
    end
    return dst
end

local function migrate(db, charDB)
    local from = db.schemaVersion or 1
    if from > ns.SCHEMA_VERSION then
        -- Data written by a newer FishForever: leave it untouched rather than
        -- risk losing fields this version does not know about.
        ns.readOnlyData = true
        ns:Print(ns.L.MSG_DATA_NEWER)
        return
    end
    for version = from + 1, ns.SCHEMA_VERSION do
        local step = ns.migrations[version]
        if step then
            step(db, charDB)
        end
        db.schemaVersion = version
    end
    charDB.schemaVersion = ns.SCHEMA_VERSION
end

function ns:InitSavedVariables()
    local isNew = type(FishForeverDB) ~= "table"
    if isNew then
        FishForeverDB = {}
    end
    if type(FishForeverCharDB) ~= "table" then
        FishForeverCharDB = {}
    end

    if not isNew then
        migrate(FishForeverDB, FishForeverCharDB)
    end
    if not ns.readOnlyData then
        copyDefaults(ns.defaults, FishForeverDB)
        copyDefaults(ns.charDefaults, FishForeverCharDB)
    end

    ns.db = FishForeverDB
    ns.charDB = FishForeverCharDB
end

function ns:OnInitialize()
    self:InitSavedVariables()
end
