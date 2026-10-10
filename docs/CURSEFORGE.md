# CurseForge texts: Glimpse: KeybindsTooltip

## Project name

Glimpse: KeybindsTooltip

## Summary

Shows the keyboard, mouse and click-cast bindings of spells, items and macros right in their tooltips.

## Badges

[![latest](https://img.shields.io/github/v/release/N3zr0k/Glimpse_KeybindsTooltip?include_prereleases&amp;sort=date&amp;label=latest)](https://github.com/N3zr0k/Glimpse_KeybindsTooltip/releases) [![last push](https://img.shields.io/github/last-commit/N3zr0k/Glimpse_KeybindsTooltip/main?label=last%20push)](https://github.com/N3zr0k/Glimpse_KeybindsTooltip/commits/main) [![CI](https://img.shields.io/github/actions/workflow/status/N3zr0k/Glimpse_KeybindsTooltip/ci.yml?branch=main&amp;label=CI)](https://github.com/N3zr0k/Glimpse_KeybindsTooltip/actions/workflows/ci.yml)

## Description

> ## ⚠ Requires the Glimpse core addon
> **Glimpse: KeybindsTooltip only works together with [Glimpse](https://www.curseforge.com/wow/addons/glimpse).** Install Glimpse first (version 0.3.0 or newer), otherwise this addon does not load.
> 👉 https://www.curseforge.com/wow/addons/glimpse

Which key was that again? **Glimpse: KeybindsTooltip** adds your bindings to the tooltip of every spell, item and macro:

```
Keybindings
[icon] Keyboard      SHIFT-1, F5
[icon] Mouse         Mouse 4
[icon] Click-Cast    Shift Left Click
```

## What it reads

- All action bars: main bar with its pages, stance, stealth, bonus, vehicle and override bars, the extra bars and the extra action button.
- Macros bound directly to a key, also macros without a spell or item such as `/sit`.
- Blizzard click-casting.

## Good to know

- Bindings update by themselves whenever you change keys, macros or bars. In combat only page and form changes are read at once, everything else waits until the fight ends.
- Keyboard, mouse and click-cast rows can be switched on or off one by one (Glimpse options, *KeybindsTooltip*).
- Optional: show the section only while Shift, Ctrl and/or Alt is held.
- Stores no data, everything is read live from the game.
- English, German and French.

## Commands

- `/gli keybinds refresh` reads the bindings again.
- `/gli keybinds list` prints all found bindings (troubleshooting).

## Links

- Core addon: [Glimpse on CurseForge](https://www.curseforge.com/wow/addons/glimpse) · [GitHub](https://github.com/N3zr0k/Glimpse)
- Source and issues: [GitHub](https://github.com/N3zr0k/Glimpse_KeybindsTooltip)
- MIT license
