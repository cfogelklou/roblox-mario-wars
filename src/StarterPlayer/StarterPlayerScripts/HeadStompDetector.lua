-- HeadStompDetector.lua
-- Client-side script to detect when player stomps on another player's head

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local lastStompTime = 0
local STOMP_COOLDOWN = 0.5 -- Prevent multiple stomps in quick succession

-- Check if player is above another player's head and moving downward
local function checkForHeadStomp()
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return
	end

	-- Check if player is moving downward fast enough
	local velocity = rootPart.AssemblyLinearVelocity
	if velocity.Y > GameConfig.STOMP_VELOCITY_THRESHOLD then
		return -- Not falling fast enough
	end

	-- Check for other players and bots below
	local potentialVictims = {}

	-- Add all human players
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			table.insert(potentialVictims, { character = otherPlayer.Character, player = otherPlayer })
		end
	end

	-- Add all bot characters from workspace
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("IsBot") and obj ~= character then
			table.insert(potentialVictims, { character = obj, player = nil })
		end
	end

	-- Check each potential victim
	for _, victim in ipairs(potentialVictims) do
		local otherCharacter = victim.character
		local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
		local otherRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
		local otherHead = otherCharacter:FindFirstChild("Head")

		if otherHumanoid and otherRootPart and otherHead and otherHumanoid.Health > 0 then
			-- Calculate if we're above their head
			local myFeet = rootPart.Position.Y - (rootPart.Size.Y / 2)
			local theirHead = otherHead.Position.Y + (otherHead.Size.Y / 2)

			local horizontalDistance = Vector2.new(
				rootPart.Position.X - otherRootPart.Position.X,
				rootPart.Position.Z - otherRootPart.Position.Z
			).Magnitude

			-- Check if we're close enough horizontally and above their head
			if horizontalDistance < 4 and myFeet >= theirHead and myFeet - theirHead < GameConfig.STOMP_HEAD_DISTANCE then
				local currentTime = tick()

				-- Prevent multiple stomps too quickly
				if currentTime - lastStompTime >= STOMP_COOLDOWN then
					lastStompTime = currentTime

					-- Apply bounce to this player
					if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						-- Create upward bounce
						local currentVelocity = rootPart.AssemblyLinearVelocity
						rootPart.AssemblyLinearVelocity =
							Vector3.new(currentVelocity.X, GameConfig.STOMP_BOUNCE_VELOCITY, currentVelocity.Z)

						-- Notify server of the stomp
						if victim.player then
							-- Human victim
							RemoteEvents.HeadStompEvent:FireServer(victim.player)
							print("Stomped " .. victim.player.Name .. "!")
						else
							-- Bot victim - server-side detection will handle this
							print("Stomped bot " .. otherCharacter.Name .. "!")
						end
					end
				end
			end
		end
	end
end

-- Run detection every frame
RunService.Heartbeat:Connect(checkForHeadStomp)

print("HeadStompDetector initialized for " .. player.Name)
