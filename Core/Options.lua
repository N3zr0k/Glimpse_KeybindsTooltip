local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local L = KT.L

-- { Option, Name, Beschreibung } der Checkboxen im Optionen-Panel
local TOGGLES = {
    { "showKeyboard", "Show keyboard bindings", "Show normal keyboard key bindings in tooltips." },
    { "showMouse", "Show mouse bindings", "Show mouse button and wheel bindings in tooltips." },
    { "showClickCast", "Show click-cast bindings", "Show Blizzard click-casting bindings in tooltips." },
}

function KT:BuildOptions()
    local args = {}

    for order, toggle in ipairs(TOGGLES) do
        local key, name, desc = toggle[1], toggle[2], toggle[3]
        args[key] = {
            type = "toggle", order = order,
            width = "full", -- volle Breite, damit die Optionen untereinander stehen
            name = L[name],
            desc = L[desc],
            get = function() return self.db.profile[key] end,
            set = function(_, value)
                self.db.profile[key] = value
                -- offene Tooltips neu aufbauen, damit die Änderung sofort sichtbar ist
                self:RefreshTooltips()
            end,
        }
    end

    -- Zusatztasten: Gruppe aus dem Glimpse-Core
    args.modifiers = Glimpse:BuildModifierOptions(self.db.profile, function() self:RefreshTooltips() end, #TOGGLES + 1)

    return args
end
