local ADDON_NAME = ...
local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- Erweiterung für Glimpse: zeigt in Tooltips von Zaubern, Gegenständen und Makros, auf welche
-- Tasten, Maustasten oder Klick-Zauber sie gelegt sind.
--
-- Aufteilung: Core/      = Modul, Events, Optionen
--             Scan/      = Belegungen einlesen und formatieren
--             Tooltip/   = Tooltip-Zeilen
--             Commands/  = Slash-Befehl
local KT = Glimpse:NewModule("KeybindsTooltip", nil, "AceEvent-3.0") -- AceEvent für die Events unten
KT.L = L

-- Gefundene Belegungen, getrennt nach Art, damit sich Spell-, Item- und Makro-IDs nicht
-- überschreiben: bindings[art][id] = { keyboard = {}, mouse = {}, clickCast = {} }
KT.bindings = { spell = {}, item = {}, macro = {} }

local defaults = {
    profile = {
        showKeyboard = true,
        showMouse = true,
        showClickCast = true,
        modShift = false,
        modCtrl = false,
        modAlt = false,
    },
}

-- Events, nach denen sich eine Belegung geändert haben kann. Cooldown- und State-Events fehlen
-- bewusst: sie feuern ständig im Kampf und ändern nichts an den Belegungen.
local EVENTS = {
    "PLAYER_ENTERING_WORLD",
    "UPDATE_BINDINGS",
    "UPDATE_MACROS",
    "ACTIONBAR_PAGE_CHANGED",
    "ACTIONBAR_SLOT_CHANGED",
    "UPDATE_BONUS_ACTIONBAR",
    "UPDATE_SHAPESHIFT_FORM",
    "UPDATE_SHAPESHIFT_FORMS",
    "UPDATE_STEALTH",
    "UPDATE_OVERRIDE_ACTIONBAR",
    "UPDATE_EXTRA_ACTIONBAR",
    "UPDATE_MULTI_CAST_ACTIONBAR",
    "UPDATE_POSSESS_BAR",
    "UPDATE_VEHICLE_ACTIONBAR",
    "CLICKBINDINGS_SET_HIGHLIGHTS_SHOWN",
}

function KT:OnInitialize()
    -- eigener Namespace in der Glimpse-DB, wandert mit dem Profil
    self.db = Glimpse.db:RegisterNamespace("KeybindsTooltip", defaults)

    -- BuildOptions steht in Core/Options.lua
    Glimpse:RegisterAddonOptions(ADDON_NAME, self:BuildOptions())
end

function KT:OnEnable()
    for _, event in ipairs(EVENTS) do
        -- Ein Event, das der Client nicht kennt, wirft beim Registrieren einen Fehler.
        -- Das soll nicht den ganzen Start abbrechen.
        local ok = pcall(self.RegisterEvent, self, event, "ScheduleRefresh")
        if not ok then self:Debug("Event nicht verfügbar:", event) end
    end

    self:RegisterEvent("MODIFIER_STATE_CHANGED", "OnModifierChanged")
    self:InstallClickBindingHook()
    self:RegisterTooltips()
    self:ScheduleRefresh()
end

-- Beim Drücken oder Loslassen sichtbare Tooltips neu aufbauen, aber nur wenn Tasten verlangt sind
function KT:OnModifierChanged()
    if Glimpse:ModifiersRequired(self.db.profile) then self:RefreshTooltips() end
end

-- Mehrere Events kurz hintereinander (z. B. beim Formwechsel) sollen nur einen Scan auslösen
function KT:ScheduleRefresh()
    if self.refreshPending then return end
    self.refreshPending = true

    C_Timer.After(0.1, function()
        self.refreshPending = false
        if self:IsEnabled() then self:RefreshBindings() end
    end)
end

-- Beim Speichern eines Klick-Zauber-Profils gibt es kein Event, deshalb hängen wir uns an die
-- Blizzard-Funktion. Es wird nur einmal gehookt, auch wenn das Modul mehrfach aktiviert wird.
function KT:InstallClickBindingHook()
    if self.clickHookInstalled then return end
    if not (C_ClickBindings and C_ClickBindings.SetProfileByInfo) then return end

    hooksecurefunc(C_ClickBindings, "SetProfileByInfo", function()
        if self:IsEnabled() then self:ScheduleRefresh() end
    end)
    self.clickHookInstalled = true
end
