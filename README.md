# Glimpse: KeybindsTooltip

<p align="center"><img src="docs/icon.png" alt="KeybindsTooltip icon" width="160"></p>

Shows the keyboard, mouse and click-cast bindings of spells, items and macros in their tooltips.
An extension for [Glimpse](https://github.com/N3zr0k/Glimpse) (requires Glimpse 0.2.2 or newer).

## Contents

* [What you get](#what-you-get)
* [Options](#options)
* [Commands](#commands)
* [Installation](#installation)
* [Development](#development)

## What you get

Hover a spell, an item or a macro and the tooltip gets a "Keybindings" section below a divider, one row per kind
with an icon, the kind on the left and the keys on the right (several keys are separated by commas):

```
Keybindings
[icon] Keyboard      SHIFT-1, F5
[icon] Mouse         Mouse 4
[icon] Click-Cast    Shift Left Click
```

* Scans all action bars including stance, bonus, override and vehicle bars, your macros and Blizzard click-casting.
* The bindings are read again whenever they change (bars, key bindings, macros), no manual refresh needed.
* Works in tooltips of spells, items and macros; everything the game hides from addons is skipped safely.

## Options

Open them with `/gli config`, then Glimpse > KeybindsTooltip.

* Show keyboard bindings, show mouse bindings, show click-cast bindings: each kind can be switched off individually.
* Only while a key is held: the rows appear only while Shift, Ctrl and/or Alt are held (all selected keys must be held).

Settings follow the Glimpse profile.

## Commands

| Command | Does |
| --- | --- |
| `/gli keybinds refresh` | Reads the bindings again |
| `/gli keybinds list` | Prints all stored bindings, the current action bar page and bonus bar offset (for finding problems) |

## Installation

Install [Glimpse](https://github.com/N3zr0k/Glimpse/releases) first, then unpack this addon next to it into the
AddOns folder of the Forever client (during the beta, for example
`D:\Games\World of Warcraft\_classic_beta_\Interface\AddOns`, your install folder will differ). The folder must be called `Glimpse_KeybindsTooltip`.

## Development

Clone the repository straight into the AddOns folder (the folder name equals the repository name) and run
`/reload` after each change. Checks: `python3 tools/check.py` and `luacheck .`.

## License

MIT, see [LICENSE](LICENSE).
