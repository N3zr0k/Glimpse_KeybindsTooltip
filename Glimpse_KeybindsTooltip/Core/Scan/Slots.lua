local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local U = KT.util

local GetItemInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant

local Clean = U.Clean

local ACTION_BUTTONS_PER_BAR = 12

-- Slot-Offsets MULTIACTIONBAR1 bis 8 (Bar 8 nur in neueren Clients)
local MULTI_BAR_OFFSETS = { 60, 48, 24, 36, 144, 156, 168, 180 }

-- button.action ist zuverlässiger als die Rechnung (Seiten, Edit-Mode, neue Leisten)
local MULTI_BAR_FRAMES = {
    "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft",
    "MultiBar5", "MultiBar6", "MultiBar7", "MultiBar8",
}

-- ---------------------------------------------------------------------------
-- Leiste, Seite und Slot
-- ---------------------------------------------------------------------------

-- Eigene Namen, damit die Blizzard-Globals GetActionBarPage/GetBonusBarOffset nicht überdeckt werden
local function CurrentPage()
    local page = C_ActionBar and C_ActionBar.GetActionBarPage and C_ActionBar.GetActionBarPage()
    page = page or (GetActionBarPage and GetActionBarPage())
    return tonumber(Clean(page)) or 1
end

local function CurrentBonusOffset()
    local offset = C_ActionBar and C_ActionBar.GetBonusBarOffset and C_ActionBar.GetBonusBarOffset()
    offset = offset or (GetBonusBarOffset and GetBonusBarOffset())
    return tonumber(Clean(offset)) or 0
end

local function SlotFromFrame(frameName)
    local button = _G[frameName]
    if not button then return nil end

    local slot = button.action
    if slot == nil and button.GetAttribute then slot = button:GetAttribute("action") end

    slot = tonumber(Clean(slot))
    if slot and slot > 0 then return slot end
    return nil
end

-- ACTIONBUTTON3, MULTIACTIONBAR2BUTTON5 ... -> Slot. Erst über den Frame, sonst gerechnet.
local function SlotFromCommand(command)
    local button = strmatch(command, "^ACTIONBUTTON(%d+)$")

    if button then
        button = tonumber(button)
        if button < 1 or button > ACTION_BUTTONS_PER_BAR then return nil end

        local slot = SlotFromFrame("ActionButton" .. button)
        if slot then return slot end

        -- Bonusleiste (Gestalt, Stealth, Fahrzeug) hat Vorrang vor der Seite
        local bonus = CurrentBonusOffset()
        if bonus > 0 then
            return ACTION_BUTTONS_PER_BAR * (6 + bonus - 1) + button
        end

        return (math.max(CurrentPage(), 1) - 1) * ACTION_BUTTONS_PER_BAR + button
    end

    local bar, number = strmatch(command, "^MULTIACTIONBAR(%d+)BUTTON(%d+)$")
    bar, number = tonumber(bar), tonumber(number)
    if bar and number then
        local frameName = MULTI_BAR_FRAMES[bar]
        local slot = frameName and SlotFromFrame(frameName .. "Button" .. number)
        if slot then return slot end

        local offset = MULTI_BAR_OFFSETS[bar]
        if offset then return offset + number end
    end

    -- Extra-Aktionsknopf (Boss-Fähigkeiten, Questgegenstände)
    local extra = strmatch(command, "^EXTRAACTIONBUTTON(%d+)$")
    if extra then return SlotFromFrame("ExtraActionButton" .. extra) end

    return nil
end

-- ---------------------------------------------------------------------------
-- Makros und Actionbar-Slots auflösen
-- ---------------------------------------------------------------------------

local function MacroItemID(macroID)
    macroID = tonumber(macroID)
    if not macroID or not GetMacroItem then return nil end

    local itemName, itemLink = GetMacroItem(macroID)
    itemName, itemLink = Clean(itemName), Clean(itemLink)

    local itemID = itemLink and tonumber(strmatch(itemLink, "item:(%d+)"))
    if itemID then return itemID end

    if itemName and GetItemInfoInstant then
        return tonumber((GetItemInfoInstant(itemName)))
    end

    return nil
end

local function MacroSpellID(macroID)
    macroID = tonumber(macroID)
    if not macroID or not GetMacroSpell then return nil end

    return tonumber(Clean((GetMacroSpell(macroID))))
end

local function SpellFromSlot(slot, actionType, actionID)
    if C_ActionBar and C_ActionBar.GetSpell then
        local spellID = Clean(C_ActionBar.GetSpell(slot))
        if spellID then return tonumber(spellID) end
    end

    if actionType == "spell" then return tonumber(actionID) end
    if actionType == "macro" then return MacroSpellID(actionID) end

    return nil
end

-- Für Item-Makros liefert GetActionInfo keine brauchbare ID
local function ItemFromSlot(actionType, actionID)
    if actionType == "item" then return tonumber(actionID) end
    if actionType == "macro" then return MacroItemID(actionID) end

    return nil
end

U.CurrentPage, U.CurrentBonusOffset = CurrentPage, CurrentBonusOffset
U.SlotFromCommand = SlotFromCommand
U.MacroItemID, U.MacroSpellID = MacroItemID, MacroSpellID
U.SpellFromSlot, U.ItemFromSlot = SpellFromSlot, ItemFromSlot
