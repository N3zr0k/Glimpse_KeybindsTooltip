local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local U = KT.util

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
    if not (GetNumBindings and GetBinding and GetBindingKey) then return end

    for index = 1, tonumber(Clean(GetNumBindings())) or 0 do
        local command = Clean((GetBinding(index)))
        local slot = command and SlotFromCommand(command)

        if slot then
            local key1, key2 = GetBindingKey(command)

            local actionType, actionID
            if GetActionInfo then actionType, actionID = GetActionInfo(slot) end
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
    if not (GetNumShapeshiftForms and GetShapeshiftFormInfo and GetBindingKey) then return end

    for index = 1, tonumber(Clean(GetNumShapeshiftForms())) or 0 do
        local _, _, _, spellID = GetShapeshiftFormInfo(index)
        local key1, key2 = GetBindingKey("SHAPESHIFTBUTTON" .. index)
        AddKeys("spell", tonumber(Clean(spellID)), key1, key2)
    end
end

-- Direkt belegte Makros ("MACRO <Name>")
local function ScanMacros()
    if not (GetNumMacros and GetMacroInfo and GetBindingKey) then return end

    local numAccount, numCharacter = GetNumMacros()

    local ids = {}
    for id = 1, tonumber(numAccount) or 0 do tinsert(ids, id) end
    for id = 1, tonumber(numCharacter) or 0 do tinsert(ids, ACCOUNT_MACRO_COUNT + id) end

    for _, macroID in ipairs(ids) do
        local spellID, itemID = MacroSpellID(macroID), MacroItemID(macroID)
        local name = (spellID or itemID) and Clean((GetMacroInfo(macroID)))

        if name then
            local key1, key2 = GetBindingKey("MACRO " .. name)
            AddKeys("spell", spellID, key1, key2)
            AddKeys("item", itemID, key1, key2)
        end
    end
end

-- Klick-Zauber, nur Einträge vom Typ Spell
local function ScanClickCasting()
    if not (C_ClickBindings and C_ClickBindings.GetProfileInfo) then return end

    local profile = C_ClickBindings.GetProfileInfo()
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
    if not ok then geterrorhandler()(err) end

    self:Debug("Belegungen aktualisiert")
end
