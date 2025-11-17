-- BotController.lua
-- Handles AI logic for individual bot players

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BotController = {}
BotController.__index = BotController

-- Bot AI parameters
local BOT_UPDATE_RATE = 0.1 -- Update AI 10 times per second
local BOT_TARGET_RANGE = 100 -- Maximum distance to consider targets
local BOT_STOMP_RANGE = 15 -- Distance to attempt stomp
local BOT_EVASION_RANGE = 20 -- Distance to detect threats above
local BOT_JUMP_COOLDOWN = 1.5 -- Cooldown between jumps
local BOT_RETARGET_INTERVAL = 2 -- Seconds between target changes

-- Bot difficulty presets
local BOT_DIFFICULTIES = {
	EASY = {
		reactionTime = 0.5,
		accuracy = 0.6,
		aggressiveness = 0.5,
	},
	MEDIUM = {
		reactionTime = 0.3,
		accuracy = 0.75,
		aggressiveness = 0.7,
	},
	HARD = {
		reactionTime = 0.1,
		accuracy = 0.9,
		aggressiveness = 0.9,
	},
}

function BotController.new(botPlayer, difficulty)
	local self = setmetatable({}, BotController)

	self.botPlayer = botPlayer
	self.difficulty = BOT_DIFFICULTIES[difficulty] or BOT_DIFFICULTIES.MEDIUM
	self.active = true
	self.currentTarget = nil
	self.lastJumpTime = 0
	self.lastRetargetTime = 0
	self.updateConnection = nil

	return self
end

-- Start the bot's AI loop
function BotController:Start()
	local lastUpdate = 0

	self.updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		lastUpdate = lastUpdate + deltaTime

		if lastUpdate >= BOT_UPDATE_RATE and self.active then
			lastUpdate = 0
			self:Update()
		end
	end)
end

-- Stop the bot's AI
function BotController:Stop()
	self.active = false
	if self.updateConnection then
		self.updateConnection:Disconnect()
		self.updateConnection = nil
	end
end

-- Main AI update loop
function BotController:Update()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
		return
	end

	local humanoid = character.Humanoid

	-- Don't update if dead or respawning
	if humanoid.Health <= 0 then
		return
	end

	-- Select or update target
	local currentTime = tick()
	if not self.currentTarget or currentTime - self.lastRetargetTime >= BOT_RETARGET_INTERVAL then
		self.currentTarget = self:FindBestTarget()
		self.lastRetargetTime = currentTime
	end

	-- Check for threats above (evasion)
	if self:ShouldEvade() then
		self:Evade()
		return
	end

	-- Move towards target and attempt stomp
	if self.currentTarget then
		self:MoveTowardsTarget()
		self:AttemptStomp()
	else
		-- No target, wander to a random platform
		self:Wander()
	end
end

-- Get all potential targets (human players and bots)
function BotController:GetAllTargets()
	local targets = {}

	-- Add human players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(targets, { character = player.Character, name = player.Name })
		end
	end

	-- Add bot characters
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("IsBot") and obj ~= self.botPlayer.Character then
			table.insert(targets, { character = obj, name = obj.Name })
		end
	end

	return targets
end

-- Find the best target to go after
function BotController:FindBestTarget()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	local rootPart = character.HumanoidRootPart
	local myPosition = rootPart.Position

	local bestTarget = nil
	local bestScore = -math.huge

	-- Consider all potential targets
	for _, target in ipairs(self:GetAllTargets()) do
		local targetChar = target.character
		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = targetChar:FindFirstChild("Humanoid")

		if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
			local distance = (targetRoot.Position - myPosition).Magnitude

			-- Only consider targets within range
			if distance <= BOT_TARGET_RANGE then
				-- Score based on distance (closer is better) and position (prefer targets below us)
				local distanceScore = (BOT_TARGET_RANGE - distance) / BOT_TARGET_RANGE
				local heightDiff = myPosition.Y - targetRoot.Position.Y
				local heightScore = heightDiff > 0 and 0.5 or 0 -- Bonus if we're above them

				local totalScore = distanceScore + heightScore

				if totalScore > bestScore then
					bestScore = totalScore
					bestTarget = targetChar
				end
			end
		end
	end

	return bestTarget
end

-- Check if there's a threat above us that we should evade
function BotController:ShouldEvade()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Head") then
		return false
	end

	local rootPart = character.HumanoidRootPart
	local head = character.Head
	local myPosition = rootPart.Position
	local myHeadTop = head.Position.Y + (head.Size.Y / 2)

	-- Check all potential threats
	for _, target in ipairs(self:GetAllTargets()) do
		local otherChar = target.character
		local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
		local otherHumanoid = otherChar:FindFirstChild("Humanoid")

		if otherRoot and otherHumanoid and otherHumanoid.Health > 0 then
			local otherPosition = otherRoot.Position

			-- Check horizontal distance
			local horizontalDist = math.sqrt((otherPosition.X - myPosition.X) ^ 2 + (otherPosition.Z - myPosition.Z) ^ 2)

			-- Check if they're above us and falling
			local heightDiff = otherPosition.Y - myHeadTop
			local otherVelocity = otherRoot.AssemblyLinearVelocity

			if horizontalDist <= BOT_EVASION_RANGE and heightDiff > 0 and heightDiff <= 20 and otherVelocity.Y < -10 then
				return true
			end
		end
	end

	return false
end

-- Evade by moving away from threats
function BotController:Evade()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
		return
	end

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart
	local myPosition = rootPart.Position

	-- Find the average position of threats
	local threatVector = Vector3.new(0, 0, 0)
	local threatCount = 0

	for _, target in ipairs(self:GetAllTargets()) do
		local otherRoot = target.character:FindFirstChild("HumanoidRootPart")
		if otherRoot then
			local otherVelocity = otherRoot.AssemblyLinearVelocity
			if otherVelocity.Y < -10 then -- Falling
				local direction = (otherRoot.Position - myPosition)
				threatVector = threatVector + direction
				threatCount = threatCount + 1
			end
		end
	end

	if threatCount > 0 then
		-- Move away from average threat position
		threatVector = threatVector / threatCount
		local evadeDirection = -threatVector.Unit
		evadeDirection = Vector3.new(evadeDirection.X, 0, evadeDirection.Z) -- Keep horizontal

		local evadePosition = myPosition + (evadeDirection * 10)
		humanoid:MoveTo(evadePosition)

		-- Jump to potentially dodge
		local currentTime = tick()
		if currentTime - self.lastJumpTime >= BOT_JUMP_COOLDOWN then
			humanoid.Jump = true
			self.lastJumpTime = currentTime
		end
	end
end

-- Move towards current target
function BotController:MoveTowardsTarget()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
		return
	end

	if not self.currentTarget then
		return
	end

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart
	local targetRoot = self.currentTarget:FindFirstChild("HumanoidRootPart")

	if not targetRoot then
		return
	end

	local myPosition = rootPart.Position
	local targetPosition = targetRoot.Position

	-- Simple direct movement (Roblox humanoids handle pathfinding reasonably well)
	humanoid:MoveTo(targetPosition)

	-- Jump if target is above us
	local heightDiff = targetPosition.Y - myPosition.Y
	if heightDiff > 5 then
		local currentTime = tick()
		if currentTime - self.lastJumpTime >= BOT_JUMP_COOLDOWN then
			-- Use aggressiveness to determine jump probability
			if math.random() < self.difficulty.aggressiveness then
				humanoid.Jump = true
				self.lastJumpTime = currentTime
			end
		end
	end
end

-- Attempt to stomp the target
function BotController:AttemptStomp()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
		return
	end

	if not self.currentTarget then
		return
	end

	local rootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local targetRoot = self.currentTarget:FindFirstChild("HumanoidRootPart")

	if not targetRoot then
		return
	end

	local myPosition = rootPart.Position
	local targetPosition = targetRoot.Position

	local distance = (targetPosition - myPosition).Magnitude
	local heightDiff = myPosition.Y - targetPosition.Y

	-- If we're close and above the target, jump to stomp
	if distance <= BOT_STOMP_RANGE and heightDiff < 5 and heightDiff > -3 then
		local currentTime = tick()
		if currentTime - self.lastJumpTime >= BOT_JUMP_COOLDOWN then
			-- Use accuracy to determine if we should jump now
			if math.random() < self.difficulty.accuracy then
				humanoid.Jump = true
				self.lastJumpTime = currentTime
			end
		end
	end
end

-- Wander to a random position when no target
function BotController:Wander()
	local character = self.botPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
		return
	end

	local humanoid = character.Humanoid
	local rootPart = character.HumanoidRootPart

	-- Random position within the arena
	local randomX = math.random(-80, 80)
	local randomZ = math.random(-80, 80)
	local wanderPosition = Vector3.new(randomX, rootPart.Position.Y, randomZ)

	humanoid:MoveTo(wanderPosition)

	-- Occasionally jump while wandering
	if math.random() < 0.1 then -- 10% chance per update
		local currentTime = tick()
		if currentTime - self.lastJumpTime >= BOT_JUMP_COOLDOWN then
			humanoid.Jump = true
			self.lastJumpTime = currentTime
		end
	end
end

return BotController
