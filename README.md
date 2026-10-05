# Glimpse: Keybinds

Shows the keyboard, mouse and click-cast bindings of spells, items and macros in their tooltips.
An extension for [Glimpse](https://github.com/N3zr0k/Glimpse) (requires Glimpse 0.1.0 or newer).

* Scans all action bars including stance, bonus, override and vehicle bars, macros and Blizzard click-casting
* Keyboard, mouse and click-cast bindings are shown as separate rows with an icon and can be switched off individually
* Optional: only show the rows while Shift, Ctrl and/or Alt are held (all selected keys must be held)
* Commands: `/gli keybinds refresh`, `/gli keybinds list`

## Installation

Install [Glimpse](https://github.com/N3zr0k/Glimpse/releases) first, then unpack this addon next to it into the
`Interface/AddOns` folder. The folder must be called `Glimpse_Keybinds`.

## Development

Clone the repository straight into the AddOns folder (the folder name equals the repository name) and run
`/reload` after each change. Checks: `python3 tools/check.py` and `luacheck .`.

## License

MIT, see [LICENSE](LICENSE).
