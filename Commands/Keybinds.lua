local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local Keybinds = Glimpse:GetModule("Keybinds")
local L = Keybinds.L
local U = Keybinds.util

-- /gli keybinds refresh | list

-- Für /gli keybinds list
local function PrintBindings()
    Glimpse:Print(L["Current action bar page:"] .. " " .. U.CurrentPage())
    Glimpse:Print(L["Current bonus bar offset:"] .. " " .. U.CurrentBonusOffset())

    local count = 0
    for kind, byID in pairs(Keybinds.bindings) do
        for id, entry in pairs(byID) do
            count = count + 1

            local parts = {}
            for _, section in ipairs({ "keyboard", "mouse", "clickCast" }) do
                if #entry[section] > 0 then
                    tinsert(parts, section .. " = " .. table.concat(entry[section], ", "))
                end
            end
            Glimpse:Printf("  %s %d: %s", kind, id, table.concat(parts, "; "))
        end
    end

    Glimpse:Print(L["Bindings found:"] .. " " .. count)
end

local function OnCommand(_, args)
    args = strlower(args or "")

    if args == "refresh" then
        Keybinds:RefreshBindings()
        Glimpse:Print(L["Bindings refreshed."])
    elseif args == "list" then
        PrintBindings()
    else
        Glimpse:Print(L["Usage: /gli keybinds refresh | list"])
    end
end

Glimpse:RegisterCommand("keybinds", L["Refreshes or lists the stored keybinds (refresh | list)"], OnCommand)
