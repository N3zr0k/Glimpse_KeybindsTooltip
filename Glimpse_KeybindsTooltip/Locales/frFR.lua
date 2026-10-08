local ADDON_NAME = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "frFR")
if not L then return end

-- Tooltip
L["Keybindings"] = "Raccourcis clavier"
L["Keyboard"] = "Clavier"
L["Mouse"] = "Souris"
L["Click-Cast"] = "Lancer par clic"

L["Left Click"] = "Clic gauche"
L["Right Click"] = "Clic droit"
L["Middle Click"] = "Clic du milieu"
L["Mouse 4"] = "Souris 4"
L["Mouse 5"] = "Souris 5"
L["Mouse 6"] = "Souris 6"
L["Mouse 7"] = "Souris 7"
L["Mouse 8"] = "Souris 8"
L["Mouse Wheel Up"] = "Molette vers le haut"
L["Mouse Wheel Down"] = "Molette vers le bas"

-- Optionen
L["Show keyboard bindings"] = "Afficher les raccourcis clavier"
L["Show normal keyboard key bindings in tooltips."] = "Affiche les raccourcis clavier dans les infobulles."
L["Show mouse bindings"] = "Afficher les raccourcis souris"
L["Show mouse button and wheel bindings in tooltips."] = "Affiche les boutons de la souris et de la molette dans les infobulles."
L["Show click-cast bindings"] = "Afficher les raccourcis clic"
L["Show Blizzard click-casting bindings in tooltips."] = "Affiche les raccourcis de lancement par clic de Blizzard dans les infobulles."

-- Slash-Befehl
L["Refreshes or lists the stored keybinds (refresh | list)"] = "Actualise ou liste les raccourcis enregistrés (refresh | list)"
L["Usage: /gli keybinds refresh | list"] = "Utilisation : /gli keybinds refresh | list"
L["Bindings refreshed."] = "Les raccourcis ont été actualisés."
L["Current action bar page:"] = "Page de barre d’action actuelle :"
L["Current bonus bar offset:"] = "Décalage de barre bonus actuel :"
L["Bindings found:"] = "Raccourcis trouvés :"
