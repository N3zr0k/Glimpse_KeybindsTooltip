local ADDON_NAME = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "deDE")
if not L then return end

-- Tooltip
L["Keybindings"] = "Tastenbelegung"
L["Keyboard"] = "Tastatur"
L["Mouse"] = "Maus"
L["Click-Cast"] = "Klick-Zauber"

L["Left Click"] = "Linksklick"
L["Right Click"] = "Rechtsklick"
L["Middle Click"] = "Mittelklick"
L["Mouse 4"] = "Maus 4"
L["Mouse 5"] = "Maus 5"
L["Mouse 6"] = "Maus 6"
L["Mouse 7"] = "Maus 7"
L["Mouse 8"] = "Maus 8"
L["Mouse Wheel Up"] = "Mausrad hoch"
L["Mouse Wheel Down"] = "Mausrad runter"

-- Optionen
L["Show keyboard bindings"] = "Tastatur-Belegungen anzeigen"
L["Show normal keyboard key bindings in tooltips."] = "Zeigt normale Tastatur-Belegungen in Tooltips an."
L["Show mouse bindings"] = "Maus-Belegungen anzeigen"
L["Show mouse button and wheel bindings in tooltips."] = "Zeigt Maus- und Mausrad-Belegungen in Tooltips an."
L["Show click-cast bindings"] = "Klick-Zauber-Belegungen anzeigen"
L["Show Blizzard click-casting bindings in tooltips."] = "Zeigt Blizzard-Klick-Zauber-Belegungen in Tooltips an."

-- Slash-Befehl
L["Refreshes or lists the stored keybinds (refresh | list)"] = "Aktualisiert oder listet die gespeicherten Belegungen (refresh | list)"
L["Usage: /gli keybinds refresh | list"] = "Verwendung: /gli keybinds refresh | list"
L["Bindings refreshed."] = "Tastenbelegungen aktualisiert."
L["Current action bar page:"] = "Aktuelle Aktionsleisten-Seite:"
L["Current bonus bar offset:"] = "Aktueller Bonusleisten-Offset:"
L["Bindings found:"] = "Belegungen gefunden:"
