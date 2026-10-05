local ADDON_NAME = ...

-- Default-Locale, der englische Text ist gleichzeitig der Key (siehe Glimpse/Locales).
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, true)

-- Tooltip
L["Keybindings"] = true
L["Keyboard"] = true
L["Mouse"] = true
L["Click-Cast"] = true

L["Left Click"] = true
L["Right Click"] = true
L["Middle Click"] = true
L["Mouse 4"] = true
L["Mouse 5"] = true
L["Mouse 6"] = true
L["Mouse 7"] = true
L["Mouse 8"] = true
L["Mouse Wheel Up"] = true
L["Mouse Wheel Down"] = true

-- Optionen
L["Show keyboard bindings"] = true
L["Show normal keyboard key bindings in tooltips."] = true
L["Show mouse bindings"] = true
L["Show mouse button and wheel bindings in tooltips."] = true
L["Show click-cast bindings"] = true
L["Show Blizzard click-casting bindings in tooltips."] = true

-- Slash-Befehl
L["Refreshes or lists the stored keybinds (refresh | list)"] = true
L["Usage: /gli keybinds refresh | list"] = true
L["Bindings refreshed."] = true
L["Current action bar page:"] = true
L["Current bonus bar offset:"] = true
L["Bindings found:"] = true
