local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local U = KT.util
local api = KT.api

local Clean, AddUnique, GetEntry = U.Clean, U.AddUnique, U.GetEntry
local AddKeys, FormatClickCast = U.AddKeys, U.FormatClickCast
local SlotFromCommand, SpellFromSlot, ItemFromSlot = U.SlotFromCommand, U.SpellFromSlot, U.ItemFromSlot
local MacroItemID, MacroSpellID = U.MacroItemID, U.MacroSpellID

-- Blizzard-Konstante, Charakter-Makros beginnen bei ID 121
local ACCOUNT_MACRO_COUNT = MAX_ACCOUNT_MACROS or 120

-- ---------------------------------------------------------------------------
-- Scan
-- ---------------------------------------------------------------------------

local function ScanActionBars()
    if not api.GetBindingKey then return end

    for _, command in ipairs(U.COMMANDS) do
        local key1, key2 = api.GetBindingKey(command)
        local slot = (Clean(key1) or Clean(key2)) and SlotFromCommand(command)

        if slot then
            local actionType, actionID
            if api.GetActionInfo then actionType, actionID = api.GetActionInfo(slot) end
            actionType, actionID = Clean(actionType), Clean(actionID)

            AddKeys("spell", SpellFromSlot(slot, actionType, actionID), key1, key2)
            AddKeys("item", ItemFromSlot(actionType, actionID), key1, key2)

            -- Für reine Makros (z. B. nur /sit) ohne Spell oder Item
            if actionType == "macro" then
                AddKeys("macro", actionID, key1, key2)
            end
        end
    end
end

-- Gestaltenleiste hat keine Actionbar-Slots, Zauber kommt von GetShapeshiftFormInfo
local function ScanStanceBar()
    if not (api.GetNumShapeshiftForms and api.GetShapeshiftFormInfo and api.GetBindingKey) then return end

    for index = 1, tonumber(Clean(api.GetNumShapeshiftForms())) or 0 do
        local _, _, _, spellID = api.GetShapeshiftFormInfo(index)
        local key1, key2 = api.GetBindingKey("SHAPESHIFTBUTTON" .. index)
        AddKeys("spell", tonumber(Clean(spellID)), key1, key2)
    end
end

-- Direkt belegte Makros ("MACRO <Name>"), auch ohne Zauber oder Item
local function ScanMacros()
    if not (api.GetNumMacros and api.GetMacroInfo and api.GetBindingKey) then return end

    local numAccount, numCharacter = api.GetNumMacros()

    local ids = {}
    for id = 1, tonumber(numAccount) or 0 do tinsert(ids, id) end
    for id = 1, tonumber(numCharacter) or 0 do tinsert(ids, ACCOUNT_MACRO_COUNT + id) end

    for _, macroID in ipairs(ids) do
        local name = Clean((api.GetMacroInfo(macroID)))

        if name then
            local key1, key2 = api.GetBindingKey("MACRO " .. name)
            if Clean(key1) or Clean(key2) then
                AddKeys("spell", MacroSpellID(macroID), key1, key2)
                AddKeys("item", MacroItemID(macroID), key1, key2)
                AddKeys("macro", macroID, key1, key2)
            end
        end
    end
end

-- Klick-Zauber, nur Einträge vom Typ Spell
local function ScanClickCasting()
    if not api.GetClickBindings then return end

    local profile = api.GetClickBindings()
    if not profile then return end

    local spellType = Enum and Enum.ClickBindingType and Enum.ClickBindingType.Spell or 1

    for _, binding in ipairs(profile) do
        if binding.type == spellType then
            local entry = GetEntry("spell", binding.actionID)
            if entry then AddUnique(entry.clickCast, FormatClickCast(binding)) end
        end
    end
end

function KT:RefreshBindings()
    for _, byID in pairs(self.bindings) do wipe(byID) end

    local ok, err = pcall(function()
        ScanActionBars()
        ScanStanceBar()
        ScanMacros()
        ScanClickCasting()
    end)
    if not ok then
        self.debug:Error("scan", "%s", tostring(err))
        return
    end

    self.debug:Log("scan", "bindings refreshed: %d", self:CountBindings())
end

function KT:CountBindings()
    local count = 0
    for _, byID in pairs(self.bindings) do
        for _ in pairs(byID) do count = count + 1 end
    end
    return count
end
