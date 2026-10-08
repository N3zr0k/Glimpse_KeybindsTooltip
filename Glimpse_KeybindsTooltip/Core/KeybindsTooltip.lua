local ADDON_NAME = ...
local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- Zeigt in Zauber-, Item- und Makro-Tooltips die Tasten, Maustasten und Klick-Zauber.
--
-- Aufteilung: Core/          = Modul, Events, Optionen
--             Core/Scan/     = Belegungen einlesen und formatieren
--             Core/Tooltip/  = Tooltip-Zeilen
--             Commands/      = Slash-Befehl
local KT = Glimpse:NewModule("KeybindsTooltip", nil, "AceEvent-3.0")
KT.L = L

-- Nach Art getrennt, weil sich Spell-, Item- und Makro-IDs überschneiden:
-- bindings[art][id] = { keyboard = {}, mouse = {}, clickCast = {} }
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

-- Cooldown- und State-Events fehlen bewusst, die feuern im Kampf ständig
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
    self.db = Glimpse.db:RegisterNamespace("KeybindsTooltip", defaults)

    Glimpse:RegisterAddonOptions(ADDON_NAME, self:BuildOptions())
end

function KT:OnEnable()
    for _, event in ipairs(EVENTS) do
        -- unbekannte Events werfen je nach Client einen Fehler
        local ok = pcall(self.RegisterEvent, self, event, "ScheduleRefresh")
        if not ok then self:Debug("Event nicht verfügbar:", event) end
    end

    self:RegisterEvent("MODIFIER_STATE_CHANGED", "OnModifierChanged")
    self:InstallClickBindingHook()
    self:RegisterTooltips()
    self:ScheduleRefresh()
end

function KT:OnModifierChanged()
    if Glimpse:ModifiersRequired(self.db.profile) then self:RefreshTooltips() end
end

-- Event-Salven (z. B. Formwechsel) zu einem Scan zusammenfassen
function KT:ScheduleRefresh()
    if self.refreshPending then return end
    self.refreshPending = true

    C_Timer.After(0.1, function()
        self.refreshPending = false
        if self:IsEnabled() then self:RefreshBindings() end
    end)
end

-- Kein Event beim Speichern des Klick-Zauber-Profils. Hook nur einmal, auch bei erneutem Enable.
function KT:InstallClickBindingHook()
    if self.clickHookInstalled then return end
    if not (C_ClickBindings and C_ClickBindings.SetProfileByInfo) then return end

    hooksecurefunc(C_ClickBindings, "SetProfileByInfo", function()
        if self:IsEnabled() then self:ScheduleRefresh() end
    end)
    self.clickHookInstalled = true
end
