# DispelMate

One-click dispelling for World of Warcraft (Anniversary Edition). A button automatically appears when a party or raid member near you has a dispellable debuff, showing the curse icon and target name. Click it to dispel.

## Supported Classes

| Class | Spell |
|-------|-------|
| Mage  | Remove Lesser Curse |
| Druid | Remove Curse |

The addon silently disables itself on unsupported classes.

## How It Works

- When you join a party or raid, DispelMate begins scanning group members for curse debuffs.
- If a cursed member is found in range, a button appears showing the debuff icon, target name, and how many others are afflicted.
- Left-click the button to cast your decurse spell on the target.
- The button auto-hides once all curses are cleared.
- The button is draggable (outside of combat) so you can reposition it wherever you like.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/dm test` | Show the button with dummy entries to preview the UI |
| `/dm reset` | Hide the button |
| `/dm` | List available commands |

## Installation

Copy the `DispelMate` folder into your `Interface/AddOns` directory and `/reload` or restart the game.

## Roadmap

- Magic dispel support for additional classes (Priest, Paladin)
