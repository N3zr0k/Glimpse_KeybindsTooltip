local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")

-- Kleine Helfer, die Format.lua, Slots.lua und Scan.lua gemeinsam nutzen. Sie hängen an
-- KT.util, damit die Dateien sich nicht über Globals unterhalten müssen.
local U = {}
KT.util = U

-- Rückgabewerte der Blizzard-Funktionen können als secret geschützt sein. Die dürfen wir weder
-- vergleichen noch umwandeln, also lassen wir sie weg (nil).
local function Clean(value)
    if value ~= nil and Glimpse:IsSecret(value) then return nil end
    return value
end

local function AddUnique(list, value)
    if not value or value == "" then return end

    for i = 1, #list do
        if list[i] == value then return end
    end
    tinsert(list, value)
end

local function GetEntry(kind, id)
    id = tonumber(id)
    if not id then return nil end

    local byID = KT.bindings[kind]
    local entry = byID[id]
    if not entry then
        entry = { keyboard = {}, mouse = {}, clickCast = {} }
        byID[id] = entry
    end
    return entry
end

U.Clean, U.AddUnique, U.GetEntry = Clean, AddUnique, GetEntry
