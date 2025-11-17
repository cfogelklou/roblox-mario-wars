# Mario Wars - Roblox Edition

A multiplayer battle game inspired by Mario Wars where players compete by jumping on each other's heads!

## Game Overview

In Mario Wars, players spawn in an arena and must score points by jumping on other players' heads (like in Super Mario Bros). The first player to reach **20 points wins** the game!

### Game Features

- **Head Stomp Combat**: Jump on other players' heads to score points
- **Bounce Mechanic**: Get a boost upward after successfully stomping an opponent
- **Multiple Spawn Locations**: 8 different spawn points around the map
- **Live Leaderboard**: See everyone's scores in real-time
- **Auto-respawn**: Players respawn after 3 seconds when stomped
- **Winner Announcement**: Big celebration screen when someone wins
- **Auto-reset**: Game automatically resets 10 seconds after someone wins

## Setup Instructions

### Option 1: Using Rojo (Recommended for Development)

1. **Install Rojo** (if you haven't already):
   ```bash
   # Install with Aftman (recommended)
   aftman add rojo-rbx/rojo

   # Or install from: https://rojo.space/docs/installation/
   ```

2. **Start Rojo Server**:
   ```bash
   rojo serve
   ```

3. **Open Roblox Studio**:
   - Create a new baseplate or open an existing place
   - Install the Rojo plugin from the Roblox plugin marketplace
   - Click "Connect" in the Rojo plugin
   - The project will sync to your game!

4. **Set Up the Environment**:
   - The spawn locations will be created automatically
   - You may want to add platforms and obstacles for more interesting gameplay
   - Consider adding a baseplate or ground so players don't fall forever

### Option 2: Manual Setup in Roblox Studio

If you prefer not to use Rojo:

1. **Create the folder structure** in Roblox Studio:
   ```
   ReplicatedStorage/
     - GameConfig (ModuleScript)
     - RemoteEvents (ModuleScript)
     - RemoteEvents/ (Folder, created by RemoteEvents script)

   ServerScriptService/
     - GameManager (Script)
     - SpawnManager (Script)

   StarterPlayer/
     StarterPlayerScripts/
       - HeadStompDetector (LocalScript)

   StarterGui/
     - GameUI (LocalScript)
   ```

2. **Copy the code** from each `.lua` file in `src/` to the corresponding script in Roblox Studio

3. **The spawn locations** will be created automatically by the SpawnManager script

## Project Structure

```
roblox-mario-wars/
├── src/
│   ├── ReplicatedStorage/
│   │   ├── GameConfig.lua          # Game settings and constants
│   │   └── RemoteEvents.lua        # Client-server communication
│   ├── ServerScriptService/
│   │   ├── GameManager.lua         # Main game logic, scoring, win detection
│   │   └── SpawnManager.lua        # Handles spawn location creation
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       └── HeadStompDetector.lua  # Detects when player stomps others
│   └── StarterGui/
│       └── GameUI.lua              # Winner announcements and UI
├── default.project.json            # Rojo project configuration
└── README.md                       # This file
```

## How to Play

1. **Movement**: Use standard Roblox controls (WASD to move, Space to jump)
2. **Attack**: Jump on another player's head while falling to score a point
3. **Strategy**:
   - Time your jumps to land on opponents
   - Use the bounce after stomping to chain attacks
   - Avoid being underneath other players!
4. **Win**: First player to 20 points wins the round

## Configuration

You can customize the game by editing `src/ReplicatedStorage/GameConfig.lua`:

```lua
SCORE_TO_WIN = 20                    -- Points needed to win (default: 20)
RESPAWN_DELAY = 3                    -- Seconds before respawn (default: 3)
STOMP_VELOCITY_THRESHOLD = -20       -- How fast you need to fall (default: -20)
STOMP_HEAD_DISTANCE = 3              -- Distance to count as stomp (default: 3)
STOMP_SCORE = 1                      -- Points per stomp (default: 1)
STOMP_BOUNCE_VELOCITY = 50           -- Bounce height after stomp (default: 50)
```

## Building Your Arena

The game comes with basic spawn points, but you'll want to create an interesting arena:

### Suggestions:
- **Platforms**: Create platforms at different heights
- **Moving Platforms**: Add moving parts for dynamic gameplay
- **Obstacles**: Add walls and barriers
- **Themed Environment**: Create a Mario-themed world with pipes, blocks, etc.
- **Power-ups** (advanced): Extend the game with speed boosts or jump height modifiers

### Tips for Level Design:
- Make sure there's a ground/floor so players don't fall into the void
- Create multiple height levels for interesting combat
- Leave enough space for players to jump around
- Consider adding safe zones or healing areas (requires custom code)

## Troubleshooting

### Players aren't spawning
- Make sure the SpawnManager script is running
- Check the Output window for errors
- Verify that spawn locations were created in Workspace/SpawnLocations

### Head stomps aren't detecting
- Check that the HeadStompDetector is in StarterPlayerScripts
- Verify RemoteEvents are properly set up
- Look for errors in the Output window

### Scores aren't updating
- Ensure GameManager is running in ServerScriptService
- Check that the RemoteEvents are connected
- Look for errors in the server log

### Game doesn't reset after someone wins
- Check the GameManager script is running
- Verify the winner detection is working (check Output)
- Make sure RemoteEvents are firing to clients

## For New Roblox Developers

### Key Concepts Used:
- **RemoteEvents**: Allow communication between server and clients
- **ModuleScripts**: Reusable code that can be required by other scripts
- **Leaderboards**: Using the "leaderstats" folder to show player scores
- **Character**: Each player has a Character model with Humanoid and parts
- **Heartbeat**: RunService event that fires every frame

### Next Steps:
- Learn about [Roblox Studio basics](https://create.roblox.com/docs/studio)
- Understand [Client-Server model](https://create.roblox.com/docs/scripting/client-server)
- Explore [RemoteEvents](https://create.roblox.com/docs/scripting/events/remote)
- Study [Character and Humanoid](https://create.roblox.com/docs/characters)

## Credits

Game concept inspired by the classic "Mario War" fan game.

## License

Free to use and modify for your own Roblox games!
