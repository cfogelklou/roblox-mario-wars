# Quick Setup Guide

This guide will help you get Mario Wars running in Roblox Studio as quickly as possible.

## Fastest Setup (5 minutes)

### Step 1: Install Rojo
```bash
# Download from https://rojo.space/docs/installation/
# Or use Aftman: aftman add rojo-rbx/rojo
```

### Step 2: Start the Project
```bash
cd roblox-mario-wars
rojo serve
```

### Step 3: Connect Roblox Studio
1. Open Roblox Studio
2. Create a new **Baseplate** game
3. Go to PLUGINS tab → Install "Rojo" from the plugin marketplace (first time only)
4. Click the **Rojo** button in plugins
5. Click **Connect** (default: localhost:34872)
6. You should see "Connected!" message

### Step 4: Play!
1. Click the **Play** button in Roblox Studio
2. The arena, spawn points, and all game systems will automatically initialize
3. For multiplayer testing, click the dropdown next to Play and select **2 Players** or more

## What Gets Created Automatically

When you run the game, these scripts automatically set up:

- **8 Spawn Locations** - Green platforms scattered around the map
- **Complete Arena** - Multi-level platform arena with walls
- **Leaderboard** - Shows each player's score
- **Game UI** - Instructions and winner announcements

## Testing the Game

### Single Player Testing
- You won't be able to test stomping mechanics alone
- But you can verify:
  - Spawn points are created
  - Arena is built
  - UI appears
  - Scripts run without errors

### Multiplayer Testing (Recommended)
1. In Roblox Studio, click dropdown next to **Play** button
2. Select **2 Players**, **3 Players**, or more
3. Multiple windows will open
4. Jump on other players' heads to test stomping
5. First to 20 points wins!

### Controls
- **WASD** - Move
- **Space** - Jump
- Land on another player's head while falling down to score

## Customization

### Change Win Score
Edit `src/ReplicatedStorage/GameConfig.lua`:
```lua
SCORE_TO_WIN = 10  -- Change from 20 to 10 for faster games
```

### Adjust Stomp Detection
In the same file:
```lua
STOMP_VELOCITY_THRESHOLD = -15  -- Less speed needed (easier)
STOMP_HEAD_DISTANCE = 4         -- Larger stomp zone (easier)
```

### Modify Arena
Edit or disable `src/ServerScriptService/LevelBuilder.lua` to customize the arena, or build your own in Roblox Studio!

## Troubleshooting

### "Failed to connect" in Rojo plugin
- Make sure `rojo serve` is running in terminal
- Check that port 34872 is not blocked
- Try restarting Rojo and reconnecting

### No spawn points appear
- Check Output window (View → Output) for errors
- Verify `SpawnManager.lua` is in ServerScriptService
- Make sure you pressed Play (scripts only run during play mode)

### Stomping doesn't work
- You need at least 2 players to test
- Make sure you're falling fast enough (jump from a height)
- Land directly on the other player's head
- Check Output window for "Stomped [player]!" messages

### Scripts not running
- Ensure all files are in correct locations (Rojo should handle this)
- Check for red errors in Output window
- Verify the connection in Rojo plugin shows "Connected"

## Next Steps

Once everything works:

1. **Publish your game**:
   - File → Publish to Roblox
   - Fill in game details
   - Click "Create"

2. **Customize the arena**:
   - Add your own platforms
   - Create themed decorations
   - Add obstacles and interesting geometry

3. **Enhance gameplay**:
   - Add power-ups
   - Create different game modes
   - Add sound effects and music

4. **Share with friends**:
   - Make game public
   - Share the game link
   - Get feedback and iterate!

## Need Help?

- **Roblox Documentation**: https://create.roblox.com/docs
- **Rojo Documentation**: https://rojo.space/docs
- **DevForum**: https://devforum.roblox.com

Happy developing! 🍄⭐
