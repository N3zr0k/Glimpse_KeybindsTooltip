local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")

-- Gemeinsame Helfer für Scan/, über KT.util statt Globals
local U = {}
KT.util = U

-- Secret-Werte -> nil, sie dürfen weder verglichen noch umgewandelt werden
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
