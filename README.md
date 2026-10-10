# Glimpse: KeybindsTooltip

<p align="center"><img src="docs/icon.png" alt="KeybindsTooltip icon" width="160"></p>

<p align="center">
  <a href="https://github.com/N3zr0k/Glimpse_KeybindsTooltip/releases"><img src="https://img.shields.io/github/v/release/N3zr0k/Glimpse_KeybindsTooltip?include_prereleases&sort=date&label=latest" alt="latest"></a>
  <a href="https://github.com/N3zr0k/Glimpse_KeybindsTooltip/releases"><img src="https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fgithub.com%2FN3zr0k%2FGlimpse_KeybindsTooltip%2Freleases.atom&search=%2F%28release%29s%2Ftag%2Fv%5B0-9.%5D%2B%22%7C%2Freleases%2Ftag%2Fv%5B0-9.%5D%2B-%28alpha%7Cbeta%7Clatest%29&replace=%241%242&label=status&color=blue" alt="status"></a>
  <a href="https://github.com/N3zr0k/Glimpse_KeybindsTooltip/commits/main"><img src="https://img.shields.io/github/last-commit/N3zr0k/Glimpse_KeybindsTooltip/main?label=last%20push" alt="last push"></a>
  <a href="https://github.com/N3zr0k/Glimpse_KeybindsTooltip/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/N3zr0k/Glimpse_KeybindsTooltip/ci.yml?branch=main&label=CI" alt="CI"></a>
</p>

Shows the keyboard, mouse and click-cast bindings of spells, items and macros in their tooltips.

Requires [Glimpse](https://github.com/N3zr0k/Glimpse) 0.3.0 or newer. For WoW Forever (interface 16001).

## Contents

* [Features](#features)
* [Options](#options)
* [Commands](#commands)
* [Installation](#installation)
* [For developers](#for-developers)
* [Credits](#credits)
* [License](#license)

## Features

Hover a spell, an item or a macro and the tooltip gets a "Keybindings" section, one row per kind:

```
Keybindings
[icon] Keyboard      SHIFT-1, F5
[icon] Mouse         Mouse 4
[icon] Click-Cast    Shift Left Click
```

* Scans all action bars including stance, bonus, override and vehicle bars, your macros and Blizzard click-casting.
* Bindings are read again whenever they change, no manual refresh needed.
* Everything the game hides from addons is skipped safely.

## Options

Open them with `/gli config`, then Glimpse > KeybindsTooltip. Settings follow the Glimpse profile.

* Show keyboard, mouse and click-cast bindings, each on its own.
* Only while a key is held: Shift, Ctrl and/or Alt (all selected keys must be held).

## Commands

| Command | Does |
| --- | --- |
| `/gli keybinds refresh` | Reads the bindings again |
| `/gli keybinds list` | Prints all stored bindings, the action bar page and bonus bar offset (troubleshooting) |
| `/gli probe keybinds list` | The same as a Glimpse probe, also written to the debug log (`/gli debug log`) |

Debug output uses the Glimpse debugger with the categories `scan` and `tooltip` (`/gli debug KeybindsTooltip scan on`).
`/gli probe db sources` lists KeybindsTooltip as reading bindings live; it stores no data.

## Installation

Install [Glimpse](https://github.com/N3zr0k/Glimpse/releases) first, then unpack this addon next to it into the AddOns
folder of the Forever client, during the beta for example `D:\Games\World of Warcraft\_classic_beta_\Interface\AddOns`.
The folder must be called `Glimpse_KeybindsTooltip`.

## For developers

The addon lives in the folder `Glimpse_KeybindsTooltip/` of the repository; link that folder into the AddOns folder
(junction) and `/reload` after each change. Checks:

```
lua tests/run.lua          # logic tests without WoW (Blizzard functions are replaced through KT.api)
luacheck .
python3 tools/check.py
```

## Credits

Author: N3zr0k. Special thanks to Flovy and sMash for testing.

## License

MIT, see [LICENSE](LICENSE).
