local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local U = KT.util
local L = KT.L

local Clean, AddUnique, GetEntry = U.Clean, U.AddUnique, U.GetEntry

-- ---------------------------------------------------------------------------
-- Modifier und Tasten formatieren
-- ---------------------------------------------------------------------------

-- Blizzard-Schreibweisen (C-S-F1, CTRL-SHIFT-F1, META-F1 ...) normalisieren
local MODIFIERS = {
    C = "CTRL", CTRL = "CTRL", CONTROL = "CTRL",
    S = "SHIFT", SHIFT = "SHIFT",
    A = "ALT", ALT = "ALT",
    M = "CMD", META = "CMD", CMD = "CMD",
}

-- feste Anzeigereihenfolge, egal wie Blizzard sie liefert
local MODIFIER_ORDER = { "CTRL", "ALT", "SHIFT", "CMD" }

local function NormalizeModifier(name)
    return name and MODIFIERS[strupper(name)]
end

-- { CTRL = true, ... } -> sortierte Liste
local function OrderModifiers(set)
    local ordered = {}
    for _, name in ipairs(MODIFIER_ORDER) do
        if set[name] then tinsert(ordered, name) end
    end
    return ordered
end

-- "CTRL-ALT-BUTTON4" -> { "CTRL", "ALT" }, "BUTTON4"
local function SplitKey(key)
    local set, base = {}, key

    while true do
        local modifier, rest = strmatch(base, "^([^-]+)%-(.+)$")
        local normalized = NormalizeModifier(modifier)
        if not normalized then break end

        set[normalized] = true
        base = rest
    end

    return OrderModifiers(set), base
end

local function Join(modifiers, text)
    if #modifiers == 0 then return text end
    return table.concat(modifiers, "-") .. "-" .. text
end

local function FormatKeyboard(key)
    local modifiers, base = SplitKey(key)

    -- Nur die Taste übersetzen lassen, das 3. Argument von GetBindingText wirkt je nach Client anders
    local text = base
    if GetBindingText then
        local localized = GetBindingText(base, "KEY_", false)
        if localized and localized ~= "" then text = localized end
    end

    return Join(modifiers, text)
end

-- Locale-Keys der Maustasten, für Tastenbelegungen und Klick-Zauber
local MOUSE_TEXT = {
    BUTTON1 = "Left Click", BUTTON2 = "Right Click", BUTTON3 = "Middle Click",
    BUTTON4 = "Mouse 4", BUTTON5 = "Mouse 5", BUTTON6 = "Mouse 6",
    BUTTON7 = "Mouse 7", BUTTON8 = "Mouse 8",
    MOUSEWHEELUP = "Mouse Wheel Up", MOUSEWHEELDOWN = "Mouse Wheel Down",
}

local CLICKCAST_TEXT = {
    LeftButton = "Left Click", RightButton = "Right Click", MiddleButton = "Middle Click",
    Button4 = "Mouse 4", Button5 = "Mouse 5", Button6 = "Mouse 6",
    Button7 = "Mouse 7", Button8 = "Mouse 8",
}

local function IsMouse(key)
    local _, base = SplitKey(key)
    base = strupper(base)
    return strfind(base, "BUTTON", 1, true) ~= nil
        or base == "MOUSEWHEELUP" or base == "MOUSEWHEELDOWN"
end

local function FormatMouse(key)
    local modifiers, base = SplitKey(key)
    base = strupper(base)

    local name = MOUSE_TEXT[base]
    return Join(modifiers, name and L[name] or base)
end

local function FormatClickCast(binding)
    local name = CLICKCAST_TEXT[binding.button]
    local button = name and L[name] or tostring(binding.button)

    local set = {}
    local raw = binding.modifiers or 0

    if C_ClickBindings and C_ClickBindings.GetStringFromModifiers then
        local text = C_ClickBindings.GetStringFromModifiers(raw) or ""
        for part in string.gmatch(text, "[^%-]+") do
            local normalized = NormalizeModifier(part)
            if normalized then set[normalized] = true end
        end
    elseif bit and bit.band then
        -- Ältere Clients: Bitmaske Shift = 1, Ctrl = 2, Alt = 4
        local mask = tonumber(raw) or 0
        if bit.band(mask, 1) ~= 0 then set.SHIFT = true end
        if bit.band(mask, 2) ~= 0 then set.CTRL = true end
        if bit.band(mask, 4) ~= 0 then set.ALT = true end
    end

    return Join(OrderModifiers(set), button)
end

local function AddKey(entry, key)
    key = Clean(key)
    if not key or key == "" then return end

    if IsMouse(key) then
        AddUnique(entry.mouse, FormatMouse(key))
    else
        AddUnique(entry.keyboard, FormatKeyboard(key))
    end
end

-- Ohne Taste wird kein Eintrag angelegt
local function AddKeys(kind, id, key1, key2)
    key1, key2 = Clean(key1), Clean(key2)
    if not id or (not key1 and not key2) then return end

    local entry = GetEntry(kind, id)
    if entry then
        AddKey(entry, key1)
        AddKey(entry, key2)
    end
end

U.AddKeys, U.FormatClickCast = AddKeys, FormatClickCast
