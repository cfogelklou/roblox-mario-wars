-- SpawnManager.lua
-- Manages multiple spawn locations for players

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local SpawnManager = {}
SpawnManager.SpawnLocations = {}

-- Initialize spawn locations
local function initializeSpawns()
	-- Create spawn locations folder in workspace if it doesn't exist
	local workspace = game:GetService("Workspace")
	local spawnsFolder = workspace:FindFirstChild("SpawnLocations")

	if not spawnsFolder then
		spawnsFolder = Instance.new("Folder")
		spawnsFolder.Name = "SpawnLocations"
		spawnsFolder.Parent = workspace

		-- Create default spawn points if none exist
		local spawnPositions = {
			Vector3.new(0, 10, 0),
			Vector3.new(50, 10, 50),
			Vector3.new(-50, 10, 50),
			Vector3.new(50, 10, -50),
			Vector3.new(-50, 10, -50),
			Vector3.new(0, 10, 50),
			Vector3.new(0, 10, -50),
			Vector3.new(50, 10, 0),
		}

		for i, position in ipairs(spawnPositions) do
			local spawn = Instance.new("SpawnLocation")
			spawn.Name = "Spawn" .. i
			spawn.Position = position
			spawn.Size = Vector3.new(10, 1, 10)
			spawn.BrickColor = BrickColor.new("Bright green")
			spawn.Material = Enum.Material.SmoothPlastic
			spawn.Anchored = true
			spawn.CanCollide = true
			spawn.Transparency = 0.3
			spawn.TopSurface = Enum.SurfaceType.Smooth
			spawn.BottomSurface = Enum.SurfaceType.Smooth

			-- Make spawn neutral (any team can spawn here)
			spawn.Neutral = true
			spawn.Duration = 0

			spawn.Parent = spawnsFolder
			table.insert(SpawnManager.SpawnLocations, spawn)
		end

		print("Created " .. #spawnPositions .. " spawn locations")
	else
		-- Load existing spawn locations
		for _, spawn in pairs(spawnsFolder:GetChildren()) do
			if spawn:IsA("SpawnLocation") then
				table.insert(SpawnManager.SpawnLocations, spawn)
			end
		end
		print("Loaded " .. #SpawnManager.SpawnLocations .. " spawn locations")
	end
end

-- Get a random spawn location
function SpawnManager:GetRandomSpawn()
	if #self.SpawnLocations > 0 then
		return self.SpawnLocations[math.random(1, #self.SpawnLocations)]
	end
	return nil
end

-- Initialize on server start
initializeSpawns()

return SpawnManager
