-- GameManager.lua
-- Main server-side game logic for Mario Wars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local BotManager = require(ServerScriptService:WaitForChild("BotManager"))

local GameManager = {}
GameManager.GameActive = true
GameManager.Winner = nil
GameManager.BotManager = BotManager

-- Initialize leaderboard for a player
local function setupLeaderboard(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Value = 0
	score.Parent = leaderstats

	return leaderstats
end

-- Check if anyone has won
local function checkForWinner()
	if not GameManager.GameActive then
		return
	end

	-- Check human players
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local score = leaderstats:FindFirstChild("Score")
			if score and score.Value >= GameConfig.SCORE_TO_WIN then
				GameManager.GameActive = false
				GameManager.Winner = player

				-- Announce winner to all clients
				RemoteEvents.WinnerEvent:FireAllClients(player.Name, score.Value)

				print(player.Name .. " wins with " .. score.Value .. " points!")

				-- Reset game after 10 seconds
				task.wait(10)
				resetGame()

				return true
			end
		end
	end

	-- Check bot players
	for _, botPlayer in pairs(BotManager:GetAllBotPlayers()) do
		if botPlayer.Character then
			local leaderstats = botPlayer.Character:FindFirstChild("leaderstats")
			if leaderstats then
				local score = leaderstats:FindFirstChild("Score")
				if score and score.Value >= GameConfig.SCORE_TO_WIN then
					GameManager.GameActive = false
					GameManager.Winner = botPlayer

					-- Announce winner to all clients
					RemoteEvents.WinnerEvent:FireAllClients(botPlayer.Name, score.Value)

					print(botPlayer.Name .. " wins with " .. score.Value .. " points!")

					-- Reset game after 10 seconds
					task.wait(10)
					resetGame()

					return true
				end
			end
		end
	end

	return false
end

-- Reset the game
function resetGame()
	print("Resetting game...")
	GameManager.GameActive = true
	GameManager.Winner = nil

	-- Reset all human player scores
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local score = leaderstats:FindFirstChild("Score")
			if score then
				score.Value = 0
			end
		end
	end

	-- Reset all bot player scores
	for _, botPlayer in pairs(BotManager:GetAllBotPlayers()) do
		if botPlayer.Character then
			local leaderstats = botPlayer.Character:FindFirstChild("leaderstats")
			if leaderstats then
				local score = leaderstats:FindFirstChild("Score")
				if score then
					score.Value = 0
				end
			end
		end
	end

	-- Notify clients that game has reset
	RemoteEvents.GameStateEvent:FireAllClients("reset")
end

-- Handle head stomp event from client (for human players)
local function onHeadStomp(player, victimPlayer)
	if not GameManager.GameActive then
		return
	end

	-- Validate that both players exist and are in game
	if not player or not player.Parent then
		return
	end

	if not victimPlayer or not victimPlayer.Parent then
		return
	end

	-- Award point to stomper
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local score = leaderstats:FindFirstChild("Score")
		if score then
			score.Value = score.Value + GameConfig.STOMP_SCORE
			print(player.Name .. " stomped " .. victimPlayer.Name .. "! Score: " .. score.Value)
		end
	end

	-- Check for winner
	checkForWinner()

	-- Respawn the victim after delay
	if victimPlayer.Character then
		task.wait(GameConfig.RESPAWN_DELAY)
		if victimPlayer and victimPlayer.Parent then
			victimPlayer:LoadCharacter()
		end
	end
end

-- Handle bot stomp (server-side, for bot stompers and/or bot victims)
function GameManager.HandleBotStomp(stomperCharacter, victimCharacter)
	if not GameManager.GameActive then
		return
	end

	if not stomperCharacter or not victimCharacter then
		return
	end

	-- Find the stomper's leaderstats
	local stomperStats = stomperCharacter:FindFirstChild("leaderstats")
	if stomperStats then
		local score = stomperStats:FindFirstChild("Score")
		if score then
			score.Value = score.Value + GameConfig.STOMP_SCORE

			local stomperName = stomperCharacter.Name
			local victimName = victimCharacter.Name
			print(stomperName .. " stomped " .. victimName .. "! Score: " .. score.Value)
		end
	end

	-- Check for winner
	checkForWinner()

	-- Respawn the victim after delay
	task.spawn(function()
		task.wait(GameConfig.RESPAWN_DELAY)

		-- Check if victim is a bot
		if BotManager:IsBot(victimCharacter) then
			-- Respawn bot by repositioning
			local SpawnManager = require(ServerScriptService.SpawnManager)
			local spawnLocation = SpawnManager:GetRandomSpawn()

			if spawnLocation and victimCharacter:FindFirstChild("HumanoidRootPart") then
				victimCharacter:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 3, 0))

				-- Reset humanoid health
				local humanoid = victimCharacter:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		else
			-- Find the player object for human players
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character == victimCharacter and player.Parent then
					player:LoadCharacter()
					break
				end
			end
		end
	end)
end

-- Player joined
Players.PlayerAdded:Connect(function(player)
	setupLeaderboard(player)

	-- Send current game state to new player
	if GameManager.Winner then
		RemoteEvents.WinnerEvent:FireClient(player, GameManager.Winner.Name, GameManager.Winner.leaderstats.Score.Value)
	end
end)

-- Connect remote events
RemoteEvents.HeadStompEvent.OnServerEvent:Connect(onHeadStomp)

-- Server-side stomp detection for bots
local lastStompTimes = {} -- Track cooldown per character

local function checkServerSideStomps()
	if not GameManager.GameActive then
		return
	end

	-- Get all characters in workspace (human and bot)
	local allCharacters = {}

	-- Add human player characters
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(allCharacters, player.Character)
		end
	end

	-- Add bot characters
	for _, botPlayer in pairs(BotManager:GetAllBotPlayers()) do
		if botPlayer.Character then
			table.insert(allCharacters, botPlayer.Character)
		end
	end

	-- Check all pairs for stomp conditions
	for _, stomperChar in ipairs(allCharacters) do
		local stomperRoot = stomperChar:FindFirstChild("HumanoidRootPart")
		local stomperHumanoid = stomperChar:FindFirstChild("Humanoid")

		if stomperRoot and stomperHumanoid and stomperHumanoid.Health > 0 then
			local stomperVelocity = stomperRoot.AssemblyLinearVelocity

			-- Check if stomper is falling fast enough
			if stomperVelocity.Y <= GameConfig.STOMP_VELOCITY_THRESHOLD then
				for _, victimChar in ipairs(allCharacters) do
					if victimChar ~= stomperChar then
						local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
						local victimHead = victimChar:FindFirstChild("Head")
						local victimHumanoid = victimChar:FindFirstChild("Humanoid")

						if victimRoot and victimHead and victimHumanoid and victimHumanoid.Health > 0 then
							-- Calculate positions
							local stomperFeet = stomperRoot.Position.Y - (stomperRoot.Size.Y / 2)
							local victimHeadTop = victimHead.Position.Y + (victimHead.Size.Y / 2)

							local horizontalDist = math.sqrt(
								(stomperRoot.Position.X - victimRoot.Position.X) ^ 2 + (stomperRoot.Position.Z - victimRoot.Position.Z) ^ 2
							)

							-- Check stomp conditions
							if
								horizontalDist < 4
								and stomperFeet >= victimHeadTop
								and stomperFeet - victimHeadTop < GameConfig.STOMP_HEAD_DISTANCE
							then
								-- Check cooldown
								local cooldownKey = tostring(stomperChar) .. "_" .. tostring(victimChar)
								local currentTime = tick()
								local lastTime = lastStompTimes[cooldownKey] or 0

								if currentTime - lastTime >= 0.5 then
									lastStompTimes[cooldownKey] = currentTime

									-- Apply bounce to stomper
									if stomperHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
										local currentVel = stomperRoot.AssemblyLinearVelocity
										stomperRoot.AssemblyLinearVelocity = Vector3.new(currentVel.X, GameConfig.STOMP_BOUNCE_VELOCITY, currentVel.Z)
									end

									-- Handle the stomp
									GameManager.HandleBotStomp(stomperChar, victimChar)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- Run server-side stomp detection
RunService.Heartbeat:Connect(checkServerSideStomps)

-- Initialize BotManager
BotManager:Init()

print("GameManager initialized - First to " .. GameConfig.SCORE_TO_WIN .. " wins!")
print("Bot system initialized - Minimum " .. BotManager.MIN_PLAYERS .. " players")

return GameManager
