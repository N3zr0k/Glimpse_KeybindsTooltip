-- luacheck: ignore 113
local stub = require("wowstub")

-- Nachgebaute Belegungen: Befehl -> Tasten, Slot -> Aktion
local function Bindings(KT, keys, actions)
    local asked = 0
    KT.api.GetBindingKey = function(command)
        asked = asked + 1
        local list = keys[command]
        if list then return list[1], list[2] end
    end
    KT.api.GetActionInfo = function(slot)
        local action = actions[slot]
        if action then return action[1], action[2] end
    end
    return function() return asked end
end

local function Has(list, value)
    for _, entry in ipairs(list or {}) do
        if entry == value then return true end
    end
    return false
end

test("Format: Modifier in fester Reihenfolge, Tastenname vom Client", function()
    local KT = stub.load()
    local U = KT.util
    eq(U.FormatKeyboard("SHIFT-CTRL-F1"), "CTRL-SHIFT-F1", "Reihenfolge")
    eq(U.FormatKeyboard("C-S-F1"), "CTRL-SHIFT-F1", "Kurzform")
    KT.api.GetBindingText = function(key) return key == "HOME" and "Pos1" or nil end
    eq(U.FormatKeyboard("ALT-HOME"), "ALT-Pos1", "übersetzt")
end)

test("Format: Maustasten und Klick-Zauber", function()
    local KT = stub.load()
    local U = KT.util
    eq(U.FormatMouse("ALT-BUTTON4"), "ALT-Mouse 4", "Maus 4")
    eq(U.FormatMouse("MOUSEWHEELUP"), "Mouse Wheel Up", "Mausrad")
    KT.api.GetClickModifiers = function() return "SHIFT-CTRL" end
    eq(U.FormatClickCast({ button = "LeftButton", modifiers = 3 }), "CTRL-SHIFT-Left Click", "Klick-Zauber")
end)

test("Slots: Frame zuerst, sonst Seite, Bonusleiste und Multi-Leisten gerechnet", function()
    local KT = stub.load()
    local U = KT.util
    stub.frames.ActionButton3 = { action = 99 }
    eq(U.SlotFromCommand("ACTIONBUTTON3"), 99, "vom Frame")

    stub.frames.ActionButton3 = nil
    KT.api.GetActionBarPage = function() return 2 end
    eq(U.SlotFromCommand("ACTIONBUTTON3"), 15, "Seite 2")
    KT.api.GetBonusBarOffset = function() return 1 end
    eq(U.SlotFromCommand("ACTIONBUTTON3"), 75, "Bonusleiste vor Seite")
    eq(U.SlotFromCommand("MULTIACTIONBAR1BUTTON2"), 62, "Multi-Leiste 1")
    eq(U.SlotFromCommand("EXTRAACTIONBUTTON1"), nil, "Extra-Knopf ohne Frame")
    eq(U.SlotFromCommand("TOGGLEBACKPACK"), nil, "kein Leistenbefehl")
end)

test("Scan: Leisten, Gestalten, Makros und Klick-Zauber", function()
    local KT = stub.load()
    local api = KT.api
    local asked = Bindings(KT, {
        ACTIONBUTTON1 = { "Q" },
        MULTIACTIONBAR2BUTTON1 = { "SHIFT-BUTTON4" },
        SHAPESHIFTBUTTON1 = { "F1" },
        ["MACRO Sit"] = { "CTRL-S" },
    }, { [1] = { "spell", 133 }, [49] = { "item", 6948 } })
    api.GetNumShapeshiftForms = function() return 1 end
    api.GetShapeshiftFormInfo = function() return nil, nil, nil, 768 end
    api.GetNumMacros = function() return 1, 0 end
    api.GetMacroInfo = function(id) if id == 1 then return "Sit" end end
    api.GetClickBindings = function() return { { type = 1, actionID = 2061, button = "RightButton", modifiers = 0 } } end

    KT:RefreshBindings()
    eq(Has(KT.bindings.spell[133].keyboard, "Q"), true, "Zauber auf Leiste")
    eq(Has(KT.bindings.item[6948].mouse, "SHIFT-Mouse 4"), true, "Item mit Maustaste")
    eq(Has(KT.bindings.spell[768].keyboard, "F1"), true, "Gestalt")
    eq(Has(KT.bindings.macro[1].keyboard, "CTRL-S"), true, "Makro ohne Zauber")
    eq(Has(KT.bindings.spell[2061].clickCast, "Right Click"), true, "Klick-Zauber")
    eq(KT:CountBindings(), 5, "Anzahl")
    -- 12 + 8 * 12 + 1 Leistenbefehle, eine Gestalt, ein Makro: nicht alle Belegungen des Spiels
    eq(asked(), 111, "nur Leistenbefehle abgefragt")
end)

test("Scan: geheime Werte und Fehler brechen nichts", function()
    local KT, Glimpse = stub.load()
    Bindings(KT, { ACTIONBUTTON1 = { stub.SECRET } }, { [1] = { "spell", 133 } })
    KT:RefreshBindings()
    eq(KT:CountBindings(), 0, "geheime Taste ignoriert")

    KT.api.GetBindingKey = function() error("kaputt") end
    KT:RefreshBindings()
    eq(Glimpse.logged[#Glimpse.logged]:find("error scan", 1, true) ~= nil, true, "Fehler im Debug-Log")
end)

test("Tooltip: Abschnitte nach Optionen, Überschrift zuerst", function()
    local KT = stub.load()
    KT:OnInitialize()
    KT.bindings.spell[133] = { keyboard = { "Q" }, mouse = { "Mouse 4" }, clickCast = {} }

    local rows = KT:BuildLines("spell", 133)
    eq(#rows, 3, "Überschrift, Tastatur, Maus")
    eq(rows[1][1]:find("Keybindings", 1, true) ~= nil, true, "Überschrift")
    eq(rows[2][2], "Q", "Tastatur")

    KT.db.profile.showMouse = false
    eq(#KT:BuildLines("spell", 133), 2, "Maus ausgeblendet")
    KT.db.profile.showKeyboard = false
    eq(KT:BuildLines("spell", 133), nil, "nichts übrig, keine Überschrift")
    eq(KT:BuildLines("spell", 999), nil, "unbekannte ID")
    eq(KT:BuildLines("spell", nil), nil, "geheime ID")
end)

test("Tooltip: Zusatztaste wird beachtet", function()
    local KT, Glimpse = stub.load()
    KT:OnInitialize()
    KT:RegisterTooltips()
    KT.bindings.spell[133] = { keyboard = { "Q" }, mouse = {}, clickCast = {} }
    local provider = Glimpse.tooltipLines[Enum.TooltipDataType.Spell]

    KT.db.profile.modShift = true
    eq(provider(KT, { id = 133 }), nil, "ohne Shift nichts")
    stub.shiftDown = true
    eq(#provider(KT, { id = 133 }), 2, "mit Shift")
    stub.shiftDown = nil
end)

test("Events: im Kampf nur Leistenwechsel sofort, der Rest nach dem Kampf", function()
    local KT = stub.load()
    local scans = 0
    KT.RefreshBindings = function() scans = scans + 1 end
    KT.api.InCombatLockdown = function() return true end

    KT:OnBindingEvent("ACTIONBAR_SLOT_CHANGED")
    stub.flush()
    eq(scans, 0, "Slot-Änderung wartet")

    KT:OnBindingEvent("UPDATE_SHAPESHIFT_FORM")
    KT:OnBindingEvent("ACTIONBAR_PAGE_CHANGED")
    stub.flush()
    eq(scans, 1, "Gestalt und Seite sofort, zusammengefasst")

    KT:OnCombatEnd()
    stub.flush()
    eq(scans, 2, "nach dem Kampf nachgeholt")
    KT:OnCombatEnd()
    stub.flush()
    eq(scans, 2, "nur einmal")
end)

test("Debug: Befehl, Probe und Datenquelle", function()
    local KT, Glimpse = stub.load()
    KT:OnInitialize()
    KT.bindings.spell[133] = { keyboard = { "Q" }, mouse = {}, clickCast = {} }

    local lines = table.concat(Glimpse.probes["keybinds list"](), "\n")
    eq(lines:find("spell 133: keyboard = Q", 1, true) ~= nil, true, "Probe")
    eq(lines:find("Bindings found: 1", 1, true) ~= nil, true, "Anzahl")

    Glimpse.commands.keybinds(nil, "list")
    eq(table.concat(Glimpse.printed, "\n"), lines, "Befehl wie Probe")

    local source = Glimpse.dataSources.Glimpse_KeybindsTooltip()[1]
    eq(source, "no stored data, bindings read live from the client (1 found)", "Datenquelle")
end)
