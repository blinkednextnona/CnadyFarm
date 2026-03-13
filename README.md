# Candy Farm V1
Basic Candy Farm for Steal Time Simulator

## How to Use
Paste this into your executor:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/blinkednextnona/CandyFarmLoader/refs/heads/main/Loader.lua"))()
```

## Features

### Farming
- Auto-farm candy canes (closest or highest value mode)
- Human-like walking with curved paths (Bezier curves)
- Smart pathfinding around obstacles
- Auto-collect with configurable distance
- Zone restriction (set two corners to limit farm area)

### Safety
- Flee from armed players or all players
- Configurable safety radius
- Anti-Admin detection (kicks if suspicious items found)
- TP Protection while fleeing
- Anti-AFK

### Movement
- Adjustable walk speed
- Cheat TP (teleport near targets)
- Stuck detection with auto-recovery
- Smooth human-like curved pathing

### Visuals
- Trajectory path beam to current target
- Color wheel picker for custom path color
- Rainbow, Strobe, and Custom Cycle color modes
- 10 custom color slots for cycle animations
- Color speed and fade settings
- Zone boundary visualization

### Webhook
- Discord webhook notifications
- Configurable interval (seconds, minutes, hours)
- Auto-alerts on disconnect or kick
- Live stats (hearts collected, per hour rate, time active)

### Extra
- Loop Buy Case 26
- Auto Start Farm on next join
- Lag Fixer (hides textures for FPS boost)
- Settings auto-save/load between sessions

## Controls
- **RightShift** — Toggle UI visibility
- **Drag top bar** — Move the window

## Tabs
| Tab | What's in it |
|---|---|
| Home | Farm on/off, live stats |
| Farm | Target mode, collect distance, lag fixer |
| Safety | Flee mode, safety radius, anti-admin, anti-AFK |
| Move | Walk speed, stuck threshold, cheat TP |
| Visuals | Color picker, color modes, custom slots |
| Webhook | Discord URL, interval, test send |
| Zone | Set corners, restrict farm area |
| Extra | Case 26, auto-start, UI controls |
