# FishForever

[Español](README.md)

Fishing addon for **WoW Forever**: one-touch bobber button, tackle box with lure timers, session stats and a community map of fishing pools.

> **Status:** 0.4.0. New features, already tested in game, are added day by day.

## Features

- **Fishing mode:** equips the fishing pole from your bags and gives your weapon and shield back when you leave. In combat it waits until combat ends.
- **One key to cast and loot:** one press = one action. It is not a bot: it never casts or loots on its own.
- **Loot goes straight to your bags.**
- **Lures with one press:** the lure button (or its key) applies the best lure in your bags and shows its time left; it warns you when it runs out.
- **Hear the bite:** while fishing, sound effects go up and music and ambience go down.
- **Native look:** action buttons like the ones on your bars (key, time sweep, flash on catch), plus a **minimap button**.
- **Bag warning** when you cast with few free slots.
- **Local catch log:** what you catch and where.

- **Session stats:** time, catches and gold per hour, success rate and what you caught by rarity.

Coming soon: zone advisor and a community map of fishing pools. See the full roadmap in [docs/ROADMAP.md](docs/ROADMAP.md).

## Requirements

- WoW Forever client.

## Installation

- **CurseForge:** search for FishForever in the CurseForge app or at https://www.curseforge.com/wow/addons/fishforever.
- **Manual:** extract the `FishForever` folder into `World of Warcraft\_forever_\Interface\AddOns\` and restart the game.

## Usage

1. Bind a key in **Key Bindings > AddOns > FishForever > Cast / loot**.
2. Right-click the minimap button to enter fishing mode (equips the pole).
3. Press the key to cast and, when a fish bites, press it again to loot. You can also loot by right-clicking the bobber.
4. To apply a lure, bind a key in **AddOns > FishForever > Apply lure** or click the small button on the corner of the floating button.
5. Right-click the minimap button to get your weapon and shield back.

Left-click the minimap button to show or hide the floating button; Shift + drag moves it.

| Command | What it does |
|---|---|
| `/ff` | Help |
| `/ff fish` | Toggle fishing mode |
| `/ff button` | Show or hide the floating button |
| `/ff lock` | Lock or unlock its position |
| `/ff sound` | Toggle the sound boost |
| `/ff minimap` | Show or hide the minimap button |
| `/ff stats` | Fishing session window (also Shift + left click on the minimap button) |

## Privacy

Today FishForever sends nothing: catches are only saved on your computer. When sharing arrives, FishForever will share **only non-personal data** with your group and guild: pool coordinates, what is caught where, and counts. Never your character name or individual history. Sharing can be turned off in Options, and once off the addon stops sending. The addon never connects to the internet: to contribute to the community it generates a text string that you choose whether to paste on the Warcrafted website. Details in [docs/DISENO.md](docs/DISENO.md).

## Credits and license

**FishForever** is developed and maintained by **WarCrafted**.
Copyright (C) 2026 WarCrafted.

Licensed under [WNCL-1.0](LICENSE): free to use, study, modify and share for non-commercial purposes. Selling or any commercial use requires written permission.

Copies and forks must keep this attribution and link to https://github.com/warcrafted-server/fishforever.

### Third-party material

This project contains no third-party material.

Website: https://portal.warcrafted.com/
