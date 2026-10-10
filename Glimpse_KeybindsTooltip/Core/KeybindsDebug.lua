local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local L = KT.L

-- Ausgaben für Tester: /gli keybinds list, /gli probe keybinds list und die Zeile in /gli probe db sources

local SECTIONS = { "keyboard", "mouse", "clickCast" }
local KINDS = { "spell", "item", "macro" }

--- Gefundene Belegungen als Zeilen, sortiert nach Art und ID
function KT:BindingLines()
    local U = self.util
    local lines = {
        L["Current action bar page:"] .. " " .. U.CurrentPage(),
        L["Current bonus bar offset:"] .. " " .. U.CurrentBonusOffset(),
    }

    for _, kind in ipairs(KINDS) do
        local ids = {}
        for id in pairs(self.bindings[kind]) do ids[#ids + 1] = id end
        table.sort(ids)

        for _, id in ipairs(ids) do
            local entry, parts = self.bindings[kind][id], {}
            for _, section in ipairs(SECTIONS) do
                if #entry[section] > 0 then
                    parts[#parts + 1] = section .. " = " .. table.concat(entry[section], ", ")
                end
            end
            lines[#lines + 1] = format("  %s %d: %s", kind, id, table.concat(parts, "; "))
        end
    end

    lines[#lines + 1] = L["Bindings found:"] .. " " .. self:CountBindings()
    return lines
end

function KT:RegisterDebug()
    if Glimpse.RegisterProbe then
        Glimpse:RegisterProbe("keybinds", "list", function() return self:BindingLines() end,
            "Glimpse: KeybindsTooltip: found bindings, action bar page and bonus bar")
    end
    if Glimpse.RegisterDataSource then
        Glimpse:RegisterDataSource("Glimpse_KeybindsTooltip", function()
            return { format("no stored data, bindings read live from the client (%d found)", self:CountBindings()) }
        end)
    end
end
