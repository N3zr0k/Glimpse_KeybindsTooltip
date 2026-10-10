local ADDON_NAME = ...
local Glimpse = LibStub("AceAddon-3.0"):GetAddon("Glimpse")
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- Zeigt in Zauber-, Item- und Makro-Tooltips die Tasten, Maustasten und Klick-Zauber.
--
-- Aufteilung: Core/          = Modul, Events, Optionen, Debug
--             Core/Scan/     = Belegungen einlesen und formatieren
--             Core/Tooltip/  = Tooltip-Zeilen
--             Commands/      = Slash-Befehl
local KT = Glimpse:NewModule("KeybindsTooltip", nil, "AceEvent-3.0")
KT.L = L
KT.debug = Glimpse:NewDebugger("KeybindsTooltip", { "scan", "tooltip" })

-- Nach Art getrennt, weil sich Spell-, Item- und Makro-IDs überschneiden:
-- bindings[art][id] = { keyboard = {}, mouse = {}, clickCast = {} }
KT.bindings = { spell = {}, item = {}, macro = {} }

-- C_-Namespace bevorzugt, sonst die alte globale Funktion
local function Either(namespace, name)
    return namespace and namespace[name] or _G[name]
end

-- Blizzard-Funktionen gebündelt, damit Tests sie ersetzen können. Was der Client nicht kennt, bleibt nil.
KT.api = {
    GetBindingKey = GetBindingKey,
    GetBindingText = GetBindingText,
    GetActionInfo = GetActionInfo,
    GetActionSpell = C_ActionBar and C_ActionBar.GetSpell,
    GetActionBarPage = Either(C_ActionBar, "GetActionBarPage"),
    GetBonusBarOffset = Either(C_ActionBar, "GetBonusBarOffset"),
    GetNumShapeshiftForms = GetNumShapeshiftForms,
    GetShapeshiftFormInfo = GetShapeshiftFormInfo,
    GetNumMacros = GetNumMacros,
    GetMacroInfo = GetMacroInfo,
    GetMacroItem = GetMacroItem,
    GetMacroSpell = GetMacroSpell,
    GetItemInfoInstant = Either(C_Item, "GetItemInfoInstant"),
    GetClickBindings = C_ClickBindings and C_ClickBindings.GetProfileInfo,
    GetClickModifiers = C_ClickBindings and C_ClickBindings.GetStringFromModifiers,
    InCombatLockdown = InCombatLockdown,
    After = C_Timer and C_Timer.After,
    GetFrame = function(name) return _G[name] end,
    -- Kein Event beim Speichern des Klick-Zauber-Profils, daher Hook
    HookClickBindings = function(func)
        if not (C_ClickBindings and C_ClickBindings.SetProfileByInfo) then return false end
        hooksecurefunc(C_ClickBindings, "SetProfileByInfo", func)
        return true
    end,
}
local api = KT.api

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

-- Event -> sofort (true) oder im Kampf erst danach (false). Seiten-, Gestalt- und Bonusleisten-Wechsel ändern
-- im Kampf, welche Taste welchen Zauber auslöst, daher sofort. Cooldown- und State-Events fehlen bewusst.
local EVENTS = {
    PLAYER_ENTERING_WORLD = true,
    ACTIONBAR_PAGE_CHANGED = true,
    UPDATE_BONUS_ACTIONBAR = true,
    UPDATE_SHAPESHIFT_FORM = true,
    UPDATE_SHAPESHIFT_FORMS = true,
    UPDATE_STEALTH = true,
    UPDATE_OVERRIDE_ACTIONBAR = true,
    UPDATE_EXTRA_ACTIONBAR = true,
    UPDATE_MULTI_CAST_ACTIONBAR = true,
    UPDATE_POSSESS_BAR = true,
    UPDATE_VEHICLE_ACTIONBAR = true,
    UPDATE_BINDINGS = false,
    UPDATE_MACROS = false,
    ACTIONBAR_SLOT_CHANGED = false,
    CLICKBINDINGS_SET_HIGHLIGHTS_SHOWN = false,
}
KT.EVENTS = EVENTS

function KT:OnInitialize()
    self.db = Glimpse.db:RegisterNamespace("KeybindsTooltip", defaults)

    Glimpse:RegisterAddonOptions(ADDON_NAME, self:BuildOptions())
    self:RegisterDebug()
end

function KT:OnEnable()
    for event in pairs(EVENTS) do
        -- unbekannte Events werfen je nach Client einen Fehler
        local ok = pcall(self.RegisterEvent, self, event, "OnBindingEvent")
        if not ok then self.debug:Log("scan", "event not available: %s", event) end
    end

    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    self:RegisterEvent("MODIFIER_STATE_CHANGED", "OnModifierChanged")
    self:InstallClickBindingHook()
    self:RegisterTooltips()
    self:ScheduleRefresh()
end

function KT:OnBindingEvent(event)
    if not EVENTS[event] and api.InCombatLockdown and api.InCombatLockdown() then
        self.refreshAfterCombat = true
        return
    end
    self:ScheduleRefresh()
end

function KT:OnCombatEnd()
    if not self.refreshAfterCombat then return end
    self.refreshAfterCombat = false
    self:ScheduleRefresh()
end

function KT:OnModifierChanged()
    if Glimpse:ModifiersRequired(self.db.profile) then self:RefreshTooltips() end
end

-- Event-Salven (z. B. Formwechsel) zu einem Scan zusammenfassen
function KT:ScheduleRefresh()
    if self.refreshPending then return end
    self.refreshPending = true

    api.After(0.1, function()
        self.refreshPending = false
        if self:IsEnabled() then self:RefreshBindings() end
    end)
end

-- Hook nur einmal, auch bei erneutem Enable
function KT:InstallClickBindingHook()
    if self.clickHookInstalled then return end
    self.clickHookInstalled = api.HookClickBindings(function()
        if self:IsEnabled() then self:ScheduleRefresh() end
    end)
end
