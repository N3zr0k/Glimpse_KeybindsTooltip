# Glimpse: KeybindsTooltip – Funktionen

Stand 0.3.2-alpha.1. Benötigt Glimpse (Core) 0.3.0 oder neuer.

## Funktionen

| Funktion | Beschreibung | Option (Standard) |
| --- | --- | --- |
| Tasten im Tooltip | Zauber-, Item- und Makro-Tooltips bekommen einen Abschnitt „Tastenbelegung“ mit je einer Zeile für Tastatur, Maus und Klick-Zauber. | Tastatur (an), Maus (an), Klick-Zauber (an) |
| Nur mit gedrückter Taste | Der Abschnitt erscheint nur, solange Shift, Strg und/oder Alt gedrückt sind (alle gewählten Tasten). | Modifier (alle aus = immer sichtbar) |
| Aktionsleisten | Hauptleiste mit Seiten, Bonus-, Gestalt-, Stealth-, Fahrzeug- und Override-Leiste, Multi-Leisten 1–8, Extra-Aktionsknopf. Gelesen werden nur die rund 110 Leisten-Befehle. | – |
| Gestaltenleiste | Gestalten und Haltungen mit ihren Tasten. | – |
| Makros | Direkt belegte Makros zeigen ihre Taste im Makro-Tooltip, auch ohne Zauber oder Item (z. B. `/sit`). Enthält das Makro einen Zauber oder ein Item, steht die Taste auch dort. | – |
| Klick-Zauber | Blizzard-Klick-Zauber (Zauber-Einträge) mit Maustaste und Modifiern. | – |
| Automatisch aktuell | Neuer Scan bei jeder Änderung an Tasten, Makros, Leisten und Klick-Zaubern. Im Kampf warten Tasten-, Makro- und Slot-Änderungen bis zum Kampfende; Seiten-, Gestalt- und Bonusleisten-Wechsel werden sofort gelesen. | – |
| Secret-Werte | Was der Client vor Addons verbirgt, wird übersprungen, ohne Fehler. | – |
| `/gli keybinds refresh` und `list` | Neu einlesen; alle gefundenen Belegungen mit Leistenseite und Bonusleiste ausgeben. | – |
| `/gli probe keybinds list` | Wie `list`, zusätzlich im Debug-Log. Debugger-Kategorien `scan` und `tooltip`. | – |

## Datenbank

KeybindsTooltip liest und schreibt nichts in Glimpse: Database. Die Belegungen kommen bei jedem Scan live aus dem
Client und liegen nur im Speicher (`KT.bindings`).

| Namespace | Daten | Lesen | Schreiben |
| --- | --- | --- | --- |
| – | keine | nein | nein |

Einstellungen liegen nicht in der Datenbank, sondern im Namespace `KeybindsTooltip` von `Glimpse.db` (Profil, wird
gelesen und geschrieben). In `/gli probe db sources` steht KeybindsTooltip als „keine gespeicherten Daten“.
