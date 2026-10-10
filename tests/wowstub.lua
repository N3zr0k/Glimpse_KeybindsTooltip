-- luacheck: ignore 111 113 122 143 432
-- Minimale Nachbildung von WoW und Glimpse, damit sich die Logik offline testen lässt.
-- Aufruf aus dem Hauptordner des Repos:  lua tests/run.lua
local stub = {}

local ROOT = ((arg and arg[0] or ""):match("^(.*)/[^/]*$") or ".") .. "/../Glimpse_KeybindsTooltip/"

-- Ladereihenfolge wie in den XML-Dateien
local FILES = {
    "Core/KeybindsTooltip.lua", "Core/KeybindsDebug.lua", "Core/Options.lua",
    "Core/Scan/ScanUtil.lua", "Core/Scan/ScanFormat.lua", "Core/Scan/ScanSlots.lua", "Core/Scan/Scan.lua",
    "Core/Tooltip/Tooltip.lua", "Commands/Keybinds.lua",
}

function stub.reset()
    _G.unpack = _G.unpack or table.unpack
    _G.tinsert, _G.tremove = table.insert, table.remove
    _G.wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
    _G.format, _G.strmatch, _G.strfind = string.format, string.match, string.find
    _G.strlower, _G.strupper = string.lower, string.upper
    _G.tContains = function(t, v) for _, x in ipairs(t) do if x == v then return true end end return false end
    _G.Enum = { TooltipDataType = { Spell = 1, Item = 0, Macro = 25 }, ClickBindingType = { Spell = 1 } }
    -- Blizzard-Funktionen kommen in den Tests über KT.api, nicht als Globals
    for _, name in ipairs({ "GetBindingKey", "GetBindingText", "GetActionInfo", "GetNumMacros", "GetMacroInfo",
        "GetMacroItem", "GetMacroSpell", "GetNumShapeshiftForms", "GetShapeshiftFormInfo", "InCombatLockdown",
        "C_ActionBar", "C_Item", "C_ClickBindings", "C_Timer", "MAX_ACCOUNT_MACROS" }) do
        _G[name] = nil
    end
end

-- Glimpse-Core mit den Funktionen, die KeybindsTooltip benutzt
local function NewGlimpse()
    local Glimpse = { modules = {}, commands = {}, printed = {}, probes = {}, dataSources = {}, tooltipLines = {},
        logged = {} }
    Glimpse.db = { RegisterNamespace = function(_, _, defaults)
        local profile = {}
        for key, value in pairs(defaults.profile) do profile[key] = value end
        return { profile = profile }
    end }

    function Glimpse:NewModule(name)
        local module = { name = name, events = {}, enabled = true }
        function module:RegisterEvent(event, method)
            if event == "UNKNOWN_EVENT" then error("unknown event") end
            self.events[event] = method
        end
        function module:IsEnabled() return self.enabled end
        function module:GetName() return self.name end
        function module:RegisterTooltipLine(dataType, provider) Glimpse.tooltipLines[dataType] = provider end
        self.modules[name] = module
        return module
    end
    function Glimpse:GetModule(name) return self.modules[name] end
    function Glimpse:NewDebugger()
        return {
            Log = function(_, category, text, ...) Glimpse.logged[#Glimpse.logged + 1] = category .. ": " .. format(text, ...) end,
            Error = function(_, category, text, ...) Glimpse.logged[#Glimpse.logged + 1] = "error " .. category .. ": " .. format(text, ...) end,
        }
    end
    function Glimpse:RegisterAddonOptions(_, options) self.options = options end
    function Glimpse:BuildModifierOptions() return { type = "group" } end
    function Glimpse:ModifiersRequired(settings) return settings.modShift or settings.modCtrl or settings.modAlt end
    function Glimpse:ModifiersHeld(settings) return not settings.modShift or stub.shiftDown == true end
    function Glimpse:RegisterCommand(name, _, func) self.commands[name] = func end
    function Glimpse:RegisterProbe(group, name, func) self.probes[group .. " " .. name] = func end
    function Glimpse:RegisterDataSource(addon, func) self.dataSources[addon] = func end
    function Glimpse:IsSecret(value) return value == stub.SECRET end
    function Glimpse:Print(text) self.printed[#self.printed + 1] = text end
    return Glimpse
end

stub.SECRET = setmetatable({}, { __tostring = function() return "secret" end })

--- Lädt das Addon, gibt das Modul und Glimpse zurück. Die api-Tabelle ist leer bis auf After und GetFrame,
-- die Tests setzen, was sie brauchen.
function stub.load()
    local Glimpse = NewGlimpse()
    local L = setmetatable({}, { __index = function(_, key) return key end })
    _G.LibStub = function(name)
        if name == "AceLocale-3.0" then return { GetLocale = function() return L end } end
        return { GetAddon = function() return Glimpse end }
    end

    for _, file in ipairs(FILES) do
        local chunk = assert(loadfile(ROOT .. file))
        chunk("Glimpse_KeybindsTooltip")
    end

    local KT = Glimpse:GetModule("KeybindsTooltip")
    stub.timers, stub.frames = {}, {}
    KT.api.After = function(_, func) stub.timers[#stub.timers + 1] = func end
    KT.api.GetFrame = function(name) return stub.frames[name] end
    KT.api.HookClickBindings = function() return true end
    return KT, Glimpse
end

--- Wartende Timer ausführen
function stub.flush()
    local timers = stub.timers
    stub.timers = {}
    for _, func in ipairs(timers) do func() end
end

return stub
