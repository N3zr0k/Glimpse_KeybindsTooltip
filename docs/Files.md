# Glimpse: KeybindsTooltip – Dateien

Alle Dateien im Addon-Ordner `Glimpse_KeybindsTooltip/`, in Ladereihenfolge.

KeybindsTooltip speichert keine Daten. Glimpse: Database wird weder gelesen noch beschrieben, die Belegungen kommen bei
jedem Scan live aus dem Client. Gespeichert werden nur die Einstellungen, im Namespace `KeybindsTooltip` von
`Glimpse.db` (SavedVariable `GlimpseSettings` des Cores).

| Datei | Beschreibung | Datenbank | Abhängigkeiten |
| --- | --- | --- | --- |
| `Glimpse_KeybindsTooltip.toc` | TOC: Version, Mindestversion Core (`X-Glimpse-MinVersion`), lädt nur die Haupt-XML | – | Addon Glimpse (`## Dependencies`) |
| `Glimpse_KeybindsTooltip.xml` | Haupt-XML, bindet die XMLs der Ordner in fester Reihenfolge ein | – | – |
| `Locales/Locales.xml` | Lädt die Sprachdateien, enUS zuerst | – | – |
| `Locales/enUS.lua` | Englische Texte, Standardsprache | – | AceLocale-3.0 (aus Glimpse) |
| `Locales/deDE.lua` | Deutsche Texte | – | AceLocale-3.0 |
| `Locales/frFR.lua` | Französische Texte | – | AceLocale-3.0 |
| `Core/Core.xml` | Lädt Modul, Debug und Optionen | – | – |
| `Core/KeybindsTooltip.lua` | Legt das Modul an: `api`-Tabelle, Debugger (`scan`, `tooltip`), Events, kein Scan im Kampf außer bei Seiten- und Gestaltwechsel | Einstellungen: liest und schreibt Namespace `KeybindsTooltip` in `Glimpse.db` | `Glimpse:NewModule`, `Glimpse:NewDebugger`, AceEvent-3.0, `C_ActionBar`, `C_ClickBindings`, `C_Timer` |
| `Core/KeybindsDebug.lua` | Ausgabe für `/gli keybinds list`, Probe `/gli probe keybinds list`, Zeile in `/gli probe db sources` | – | `Glimpse:RegisterProbe`, `Glimpse:RegisterDataSource` |
| `Core/Options.lua` | Optionsseite: Tastatur, Maus, Klick-Zauber ein/aus, Modifier-Tasten | Einstellungen: liest und schreibt Namespace `KeybindsTooltip` | `Glimpse:RegisterAddonOptions`, `Glimpse:BuildModifierOptions` |
| `Core/Scan/Scan.xml` | Lädt die Scan-Dateien (ScanUtil vor ScanFormat/ScanSlots vor Scan) | – | – |
| `Core/Scan/ScanUtil.lua` | Gemeinsame Helfer: `Clean` (Secret-Werte → nil), `AddUnique`, `GetEntry` | – | `Glimpse:IsSecret` |
| `Core/Scan/ScanFormat.lua` | Tasten, Maustasten und Klick-Zauber in lesbaren Text mit Modifiern umwandeln | – | `GetBindingText`, `C_ClickBindings.GetStringFromModifiers` |
| `Core/Scan/ScanSlots.lua` | Liste der Leisten-Befehle, Slot aus Befehl (Seite, Bonusleiste, Multi-Leisten), Zauber und Item aus Slot oder Makro | – | Aktionsleisten-Frames, `GetActionInfo`, `GetMacroSpell`, `GetMacroItem`, `C_Item` |
| `Core/Scan/Scan.lua` | Scan: Aktionsleisten, Gestaltenleiste, direkt belegte Makros, Klick-Zauber; füllt `KT.bindings` (nur im Speicher) | – | `GetBindingKey`, `GetShapeshiftFormInfo`, `GetMacroInfo`, `C_ClickBindings.GetProfileInfo` |
| `Core/Tooltip/Tooltip.xml` | Lädt die Tooltip-Anzeige | – | – |
| `Core/Tooltip/Tooltip.lua` | Tooltip-Zeilen für Zauber, Items und Makros, Neuaufbau sichtbarer Tooltips | Einstellungen: liest Namespace `KeybindsTooltip` | `module:RegisterTooltipLine`, `Glimpse:ModifiersHeld`, `Enum.TooltipDataType` |
| `Commands/Commands.xml` | Lädt die Slash-Befehle | – | – |
| `Commands/Keybinds.lua` | `/gli keybinds refresh` und `/gli keybinds list` | – | `Glimpse:RegisterCommand` |
| `Media/Icon.tga` | Addon-Icon (TOC und Optionen) | – | – |
| `Media/Keyboard.tga` | Icon der Tooltip-Zeile Tastatur | – | – |
| `Media/Mouse.tga` | Icon der Tooltip-Zeile Maus | – | – |
| `Media/ClickCast.tga` | Icon der Tooltip-Zeile Klick-Zauber | – | – |
| `LICENSE` | MIT-Lizenz, wird mit dem Addon ausgeliefert | – | – |
