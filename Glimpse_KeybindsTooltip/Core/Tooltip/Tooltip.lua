local ADDON_NAME = ...
local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local L = KT.L

-- Nur der Inhalt, Anhängen/Trennlinie/Icons/Secrets macht Glimpse (RegisterTooltipLine):
--
--   Tastenbelegung
--   [Icon] Tastatur       CTRL-F1, Q
--   [Icon] Maus           SHIFT-Maus 4
--   [Icon] Klick-Zauber   Linksklick

local MEDIA_PATH = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\"

local COLORS = {
    header = { 1.00, 0.82, 0.00 },
    keyboard = { 1.00, 0.82, 0.00 },
    mouse = { 0.40, 0.80, 1.00 },
    clickCast = { 0.40, 1.00, 0.50 },
}

-- In Anzeigereihenfolge: { Bindings-Feld, Option, Locale-Key, Icon-Datei }
local SECTIONS = {
    { "keyboard", "showKeyboard", "Keyboard", "Keyboard" },
    { "mouse", "showMouse", "Mouse", "Mouse" },
    { "clickCast", "showClickCast", "Click-Cast", "ClickCast" },
}

-- Enum.TooltipDataType-Name -> Bindings-Art
local TYPES = {
    Spell = "spell",
    Item = "item",
    Macro = "macro",
}

-- Farbe als Escape, weil Glimpse beide Seiten gleich färbt und die Tasten weiß bleiben sollen
local function Colored(text, color)
    return format("|cff%02x%02x%02x%s|r",
        math.floor(color[1] * 255), math.floor(color[2] * 255), math.floor(color[3] * 255), text)
end

--- Zeilen für eine Spell-, Item- oder Makro-ID, oder nil. id ist nil, wenn secret.
function KT:BuildLines(kind, id)
    local entry = id and self.bindings[kind][id]
    if not entry then return nil end

    local profile = self.db.profile
    local rows = {}

    for _, section in ipairs(SECTIONS) do
        local key, option, label, icon = section[1], section[2], section[3], section[4]
        local keys = entry[key]

        if profile[option] and #keys > 0 then
            tinsert(rows, {
                Colored(L[label], COLORS[key]), table.concat(keys, ", "), 1, 1, 1,
                icon = MEDIA_PATH .. icon,
            })
        end
    end

    -- keine Abschnitte = keine Überschrift
    if #rows == 0 then return nil end

    tinsert(rows, 1, { Colored(L["Keybindings"], COLORS.header) })
    return rows
end

function KT:RegisterTooltips()
    for typeName, kind in pairs(TYPES) do
        local dataType = Enum.TooltipDataType and Enum.TooltipDataType[typeName]

        if dataType then
            self:RegisterTooltipLine(dataType, function(module, data)
                if not Glimpse:ModifiersHeld(module.db.profile) then return nil end
                return module:BuildLines(kind, data.id)
            end)
        else
            self:Debug("Tooltip-Typ nicht vorhanden:", typeName)
        end
    end
end

local TOOLTIPS = { "GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2" }

-- Sichtbare Tooltips neu aufbauen, z. B. nach Optionsänderung
function KT:RefreshTooltips()
    for _, name in ipairs(TOOLTIPS) do
        local tooltip = _G[name]

        if tooltip and tooltip:IsShown() then
            if tooltip.RefreshData then
                tooltip:RefreshData()
            else
                tooltip:Hide()
            end
        end
    end
end
