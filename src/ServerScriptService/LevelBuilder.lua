-- LevelBuilder.lua
-- Automatically creates a basic arena for testing Mario Wars

local Workspace = game:GetService("Workspace")

local LevelBuilder = {}

-- Create a simple arena with platforms
local function buildArena()
	local arenaFolder = Workspace:FindFirstChild("Arena")

	-- Only build if arena doesn't exist
	if arenaFolder then
		print("Arena already exists, skipping build")
		return
	end

	arenaFolder = Instance.new("Folder")
	arenaFolder.Name = "Arena"
	arenaFolder.Parent = Workspace

	print("Building Mario Wars arena...")

	-- Main ground platform
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(200, 4, 200)
	ground.Position = Vector3.new(0, -2, 0)
	ground.BrickColor = BrickColor.new("Bright green")
	ground.Material = Enum.Material.Grass
	ground.Anchored = true
	ground.TopSurface = Enum.SurfaceType.Smooth
	ground.Parent = arenaFolder

	-- Central platform
	local centralPlatform = Instance.new("Part")
	centralPlatform.Name = "CentralPlatform"
	centralPlatform.Size = Vector3.new(30, 2, 30)
	centralPlatform.Position = Vector3.new(0, 20, 0)
	centralPlatform.BrickColor = BrickColor.new("Bright red")
	centralPlatform.Material = Enum.Material.SmoothPlastic
	centralPlatform.Anchored = true
	centralPlatform.TopSurface = Enum.SurfaceType.Smooth
	centralPlatform.Parent = arenaFolder

	-- Corner platforms
	local cornerPositions = {
		Vector3.new(40, 15, 40),
		Vector3.new(-40, 15, 40),
		Vector3.new(40, 15, -40),
		Vector3.new(-40, 15, -40),
	}

	for i, pos in ipairs(cornerPositions) do
		local platform = Instance.new("Part")
		platform.Name = "CornerPlatform" .. i
		platform.Size = Vector3.new(20, 2, 20)
		platform.Position = pos
		platform.BrickColor = BrickColor.new("Bright yellow")
		platform.Material = Enum.Material.SmoothPlastic
		platform.Anchored = true
		platform.TopSurface = Enum.SurfaceType.Smooth
		platform.Parent = arenaFolder
	end

	-- Mid-level platforms
	local midPositions = {
		Vector3.new(0, 30, 40),
		Vector3.new(0, 30, -40),
		Vector3.new(40, 30, 0),
		Vector3.new(-40, 30, 0),
	}

	for i, pos in ipairs(midPositions) do
		local platform = Instance.new("Part")
		platform.Name = "MidPlatform" .. i
		platform.Size = Vector3.new(15, 2, 15)
		platform.Position = pos
		platform.BrickColor = BrickColor.new("Bright blue")
		platform.Material = Enum.Material.SmoothPlastic
		platform.Anchored = true
		platform.TopSurface = Enum.SurfaceType.Smooth
		platform.Parent = arenaFolder
	end

	-- Top platform (high risk, high reward position)
	local topPlatform = Instance.new("Part")
	topPlatform.Name = "TopPlatform"
	topPlatform.Size = Vector3.new(12, 2, 12)
	topPlatform.Position = Vector3.new(0, 45, 0)
	topPlatform.BrickColor = BrickColor.new("Bright violet")
	topPlatform.Material = Enum.Material.Neon
	topPlatform.Anchored = true
	topPlatform.TopSurface = Enum.SurfaceType.Smooth
	topPlatform.Parent = arenaFolder

	-- Walls to prevent falling off
	local wallPositions = {
		{ pos = Vector3.new(0, 15, 105), size = Vector3.new(210, 30, 4) }, -- North
		{ pos = Vector3.new(0, 15, -105), size = Vector3.new(210, 30, 4) }, -- South
		{ pos = Vector3.new(105, 15, 0), size = Vector3.new(4, 30, 210) }, -- East
		{ pos = Vector3.new(-105, 15, 0), size = Vector3.new(4, 30, 210) }, -- West
	}

	for i, wallData in ipairs(wallPositions) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = wallData.size
		wall.Position = wallData.pos
		wall.BrickColor = BrickColor.new("Really red")
		wall.Material = Enum.Material.SmoothPlastic
		wall.Anchored = true
		wall.Transparency = 0.7
		wall.CanCollide = true
		wall.Parent = arenaFolder
	end

	-- Add some decorative elements
	local spawn = game:GetService("InsertService"):LoadAsset(1)
	if spawn then
		spawn:Destroy()
	end

	print("Arena built successfully!")
	print("- Ground platform")
	print("- Central platform")
	print("- 4 corner platforms")
	print("- 4 mid-level platforms")
	print("- 1 top platform")
	print("- 4 boundary walls")
end

-- Initialize
task.wait(1) -- Wait a moment for other services to load
buildArena()

return LevelBuilder
