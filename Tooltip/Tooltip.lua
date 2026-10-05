local ADDON_NAME = ...
local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local L = KT.L

-- Die Zeilen im Tooltip. Das Anhängen, die Trennlinie, das Symbol links und der Schutz vor
-- Secret-Werten übernimmt Glimpse (RegisterTooltipLine), hier wird nur festgelegt, was drinsteht:
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

-- Reihenfolge im Tooltip: Eintrag in der Bindings-Tabelle, Option, Text (Locale-Key), Icon-Datei
local SECTIONS = {
    { "keyboard", "showKeyboard", "Keyboard", "Keyboard" },
    { "mouse", "showMouse", "Mouse", "Mouse" },
    { "clickCast", "showClickCast", "Click-Cast", "ClickCast" },
}

-- Tooltip-Typ (Name in Enum.TooltipDataType) -> Art der Belegung
local TYPES = {
    Spell = "spell",
    Item = "item",
    Macro = "macro",
}

-- Die Farbe steckt als Escape im Text, damit der rechte Teil der Zeile (die Tasten) weiß bleibt.
-- Glimpse färbt beide Seiten einer Doppelzeile gleich.
local function Colored(text, color)
    return format("|cff%02x%02x%02x%s|r",
        math.floor(color[1] * 255), math.floor(color[2] * 255), math.floor(color[3] * 255), text)
end

--- Liefert die Tooltip-Zeilen für eine Spell-, Item- oder Makro-ID, oder nil.
-- id fehlt, wenn sie nicht vorhanden oder geschützt war. Dann gibt es nichts anzuzeigen.
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

    -- Ohne sichtbare Abschnitte gibt es auch keine Überschrift und keine Trennlinie
    if #rows == 0 then return nil end

    tinsert(rows, 1, { Colored(L["Keybindings"], COLORS.header) })
    return rows
end

function KT:RegisterTooltips()
    for typeName, kind in pairs(TYPES) do
        local dataType = Enum.TooltipDataType and Enum.TooltipDataType[typeName]

        if dataType then
            -- Der Provider bekommt (module, data, tooltip, hidden), data ist schon bereinigt
            self:RegisterTooltipLine(dataType, function(module, data)
                -- ohne die gewählten Zusatztasten bleibt der Tooltip unverändert
                if not Glimpse:ModifiersHeld(module.db.profile) then return nil end
                return module:BuildLines(kind, data.id)
            end)
        else
            self:Debug("Tooltip-Typ nicht vorhanden:", typeName)
        end
    end
end

local TOOLTIPS = { "GameTooltip", "ItemRefTooltip", "ShoppingTooltip1", "ShoppingTooltip2" }

-- Baut sichtbare Tooltips neu auf, z. B. nachdem eine Option geändert wurde
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
