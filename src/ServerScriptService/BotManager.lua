-- BotManager.lua
-- Manages bot players to ensure minimum player count

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BotController = require(ServerScriptService.BotController)
local GameConfig = require(ReplicatedStorage.GameConfig)

local BotManager = {}

-- Configuration
BotManager.MIN_PLAYERS = 4 -- Minimum total players (human + bots)
BotManager.activeBots = {} -- Table of bot players and their controllers
BotManager.botCounter = 0 -- Counter for unique bot names

-- Bot name pool
local BOT_NAMES = {
	"BotLuigi",
	"BotMario",
	"BotPeach",
	"BotToad",
	"BotYoshi",
	"BotWario",
	"BotWaluigi",
	"BotDaisy",
	"BotBowser",
	"BotRosalina"
}

-- Initialize the bot manager
function BotManager:Init()
	print("[BotManager] Initializing bot manager...")

	-- Listen for player changes
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoving(player)
	end)

	-- Initial bot check
	self:UpdateBotCount()
end

-- Called when a player joins
function BotManager:OnPlayerAdded(player)
	print("[BotManager] Player joined:", player.Name)

	-- Wait a moment for character to load, then update bots
	task.wait(1)
	self:UpdateBotCount()
end

-- Called when a player leaves
function BotManager:OnPlayerRemoving(player)
	print("[BotManager] Player removing:", player.Name)

	-- Check if this is a bot we're managing
	if self.activeBots[player] then
		self:RemoveBot(player)
	else
		-- Human player left, add more bots if needed
		self:UpdateBotCount()
	end
end

-- Update bot count to maintain minimum players
function BotManager:UpdateBotCount()
	local humanPlayers = self:GetHumanPlayerCount()
	local currentBots = self:GetBotCount()
	local totalPlayers = humanPlayers + currentBots

	print(string.format("[BotManager] Players: %d human, %d bots, %d total", humanPlayers, currentBots, totalPlayers))

	if totalPlayers < self.MIN_PLAYERS then
		-- Need to add bots
		local botsToAdd = self.MIN_PLAYERS - totalPlayers
		print(string.format("[BotManager] Adding %d bots to reach minimum of %d players", botsToAdd, self.MIN_PLAYERS))

		for i = 1, botsToAdd do
			self:CreateBot()
		end
	elseif totalPlayers > self.MIN_PLAYERS and currentBots > 0 then
		-- Too many players and we have bots, remove some bots
		local botsToRemove = math.min(currentBots, totalPlayers - self.MIN_PLAYERS)

		if botsToRemove > 0 then
			print(string.format("[BotManager] Removing %d bots (enough human players)", botsToRemove))

			local removed = 0
			for botPlayer, _ in pairs(self.activeBots) do
				if removed >= botsToRemove then
					break
				end

				self:RemoveBot(botPlayer)
				removed = removed + 1
			end
		end
	end
end

-- Get count of human players
function BotManager:GetHumanPlayerCount()
	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if not self.activeBots[player] then
			count = count + 1
		end
	end
	return count
end

-- Get count of bot players
function BotManager:GetBotCount()
	local count = 0
	for _, _ in pairs(self.activeBots) do
		count = count + 1
	end
	return count
end

-- Create a new bot player
function BotManager:CreateBot()
	self.botCounter = self.botCounter + 1

	-- Create a unique bot name
	local baseName = BOT_NAMES[((self.botCounter - 1) % #BOT_NAMES) + 1]
	local botName = baseName

	-- Make sure name is unique
	local nameCounter = 1
	while Players:FindFirstChild(botName) do
		nameCounter = nameCounter + 1
		botName = baseName .. nameCounter
	end

	print("[BotManager] Creating bot:", botName)

	-- Create a fake player using a Model to represent the bot
	-- Note: In Roblox, we can't actually create Player instances, so we'll create
	-- a character with a special flag to identify it as a bot
	local botPlayer = Players:CreateHumanoidModelFromUserId(1)

	-- Since we can't create real Player objects, we'll use a workaround:
	-- We'll create the bot character directly and add it to the workspace
	local botCharacter = self:CreateBotCharacter(botName)

	if not botCharacter then
		warn("[BotManager] Failed to create bot character for:", botName)
		return
	end

	-- Create a pseudo-player entry
	local botPlayerData = {
		Name = botName,
		Character = botCharacter,
		UserId = -self.botCounter, -- Negative IDs for bots
		IsBot = true
	}

	-- Setup leaderboard for bot (need to integrate with GameManager)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = botCharacter

	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Value = 0
	score.Parent = leaderstats

	-- Randomly select bot difficulty
	local difficulties = {"EASY", "MEDIUM", "HARD"}
	local difficulty = difficulties[math.random(1, #difficulties)]

	-- Create bot controller
	local controller = BotController.new(botPlayerData, difficulty)
	controller:Start()

	-- Store bot info
	self.activeBots[botPlayerData] = {
		character = botCharacter,
		controller = controller,
		difficulty = difficulty
	}

	print(string.format("[BotManager] Bot '%s' created with %s difficulty", botName, difficulty))

	return botPlayerData
end

-- Create a bot character model
function BotManager:CreateBotCharacter(botName)
	-- Create a basic character model
	local character = Instance.new("Model")
	character.Name = botName
	character.Parent = workspace

	-- Create HumanoidRootPart
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.CanCollide = true
	rootPart.Anchored = false
	rootPart.Parent = character

	-- Create Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = character
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- Create Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.BrickColor = BrickColor.new("Bright blue") -- Distinguish bots visually
	head.Material = Enum.Material.SmoothPlastic
	head.CanCollide = true
	head.Parent = character

	-- Create Face
	local face = Instance.new("Decal")
	face.Name = "face"
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head

	-- Create Torso
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Material = Enum.Material.SmoothPlastic
	torso.CanCollide = true
	torso.Parent = character

	-- Create Left Arm
	local leftArm = Instance.new("Part")
	leftArm.Name = "Left Arm"
	leftArm.Size = Vector3.new(1, 2, 1)
	leftArm.BrickColor = BrickColor.new("Bright blue")
	leftArm.Material = Enum.Material.SmoothPlastic
	leftArm.CanCollide = false
	leftArm.Parent = character

	-- Create Right Arm
	local rightArm = Instance.new("Part")
	rightArm.Name = "Right Arm"
	rightArm.Size = Vector3.new(1, 2, 1)
	rightArm.BrickColor = BrickColor.new("Bright blue")
	rightArm.Material = Enum.Material.SmoothPlastic
	rightArm.CanCollide = false
	rightArm.Parent = character

	-- Create Left Leg
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "Left Leg"
	leftLeg.Size = Vector3.new(1, 2, 1)
	leftLeg.BrickColor = BrickColor.new("Bright green")
	leftLeg.Material = Enum.Material.SmoothPlastic
	leftLeg.CanCollide = false
	leftLeg.Parent = character

	-- Create Right Leg
	local rightLeg = Instance.new("Part")
	rightLeg.Name = "Right Leg"
	rightLeg.Size = Vector3.new(1, 2, 1)
	rightLeg.BrickColor = BrickColor.new("Bright green")
	rightLeg.Material = Enum.Material.SmoothPlastic
	rightLeg.CanCollide = false
	rightLeg.Parent = character

	-- Create joints (Motor6D)
	local neck = Instance.new("Motor6D")
	neck.Name = "Neck"
	neck.Part0 = torso
	neck.Part1 = head
	neck.C0 = CFrame.new(0, 1, 0)
	neck.C1 = CFrame.new(0, -0.5, 0)
	neck.Parent = torso

	local leftShoulder = Instance.new("Motor6D")
	leftShoulder.Name = "Left Shoulder"
	leftShoulder.Part0 = torso
	leftShoulder.Part1 = leftArm
	leftShoulder.C0 = CFrame.new(-1.5, 0.5, 0)
	leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
	leftShoulder.Parent = torso

	local rightShoulder = Instance.new("Motor6D")
	rightShoulder.Name = "Right Shoulder"
	rightShoulder.Part0 = torso
	rightShoulder.Part1 = rightArm
	rightShoulder.C0 = CFrame.new(1.5, 0.5, 0)
	rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
	rightShoulder.Parent = torso

	local leftHip = Instance.new("Motor6D")
	leftHip.Name = "Left Hip"
	leftHip.Part0 = torso
	leftHip.Part1 = leftLeg
	leftHip.C0 = CFrame.new(-0.5, -1, 0)
	leftHip.C1 = CFrame.new(0, 1, 0)
	leftHip.Parent = torso

	local rightHip = Instance.new("Motor6D")
	rightHip.Name = "Right Hip"
	rightHip.Part0 = torso
	rightHip.Part1 = rightLeg
	rightHip.C0 = CFrame.new(0.5, -1, 0)
	rightHip.C1 = CFrame.new(0, 1, 0)
	rightHip.Parent = torso

	local rootJoint = Instance.new("Motor6D")
	rootJoint.Name = "RootJoint"
	rootJoint.Part0 = rootPart
	rootJoint.Part1 = torso
	rootJoint.C0 = CFrame.new(0, 0, 0)
	rootJoint.C1 = CFrame.new(0, 0, 0)
	rootJoint.Parent = rootPart

	-- Set PrimaryPart
	character.PrimaryPart = rootPart

	-- Position bot at a spawn location (will use SpawnManager)
	local SpawnManager = require(ServerScriptService.SpawnManager)
	local spawnLocation = SpawnManager:GetRandomSpawn()

	if spawnLocation then
		character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 3, 0))
	else
		-- Fallback spawn
		character:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
	end

	-- Add a BoolValue to mark this as a bot
	local botMarker = Instance.new("BoolValue")
	botMarker.Name = "IsBot"
	botMarker.Value = true
	botMarker.Parent = character

	-- Add name tag
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "NameTag"
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = botName .. " [BOT]"
	nameLabel.TextColor3 = Color3.new(0, 1, 1) -- Cyan for bots
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboardGui

	return character
end

-- Remove a bot player
function BotManager:RemoveBot(botPlayer)
	local botInfo = self.activeBots[botPlayer]

	if not botInfo then
		return
	end

	print("[BotManager] Removing bot:", botPlayer.Name)

	-- Stop the controller
	if botInfo.controller then
		botInfo.controller:Stop()
	end

	-- Remove the character
	if botInfo.character and botInfo.character.Parent then
		botInfo.character:Destroy()
	end

	-- Remove from active bots
	self.activeBots[botPlayer] = nil
end

-- Get all bot players (for integration with game systems)
function BotManager:GetAllBotPlayers()
	local bots = {}
	for botPlayer, _ in pairs(self.activeBots) do
		table.insert(bots, botPlayer)
	end
	return bots
end

-- Check if a player/character is a bot
function BotManager:IsBot(playerOrCharacter)
	-- Check if it's in our active bots table
	for botPlayer, botInfo in pairs(self.activeBots) do
		if botPlayer == playerOrCharacter or botInfo.character == playerOrCharacter then
			return true
		end
	end

	-- Check if character has bot marker
	if typeof(playerOrCharacter) == "Instance" and playerOrCharacter:IsA("Model") then
		return playerOrCharacter:FindFirstChild("IsBot") ~= nil
	end

	return false
end

return BotManager
