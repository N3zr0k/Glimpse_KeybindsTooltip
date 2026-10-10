local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local KT = Glimpse:GetModule("KeybindsTooltip")
local L = KT.L

-- /gli keybinds refresh | list

local function OnCommand(_, args)
    args = strlower(args or "")

    if args == "refresh" then
        KT:RefreshBindings()
        Glimpse:Print(L["Bindings refreshed."])
    elseif args == "list" then
        for _, line in ipairs(KT:BindingLines()) do Glimpse:Print(line) end
    else
        Glimpse:Print(L["Usage: /gli keybinds refresh | list"])
    end
end

Glimpse:RegisterCommand("keybinds", L["Refreshes or lists the stored keybinds (refresh | list)"], OnCommand)
