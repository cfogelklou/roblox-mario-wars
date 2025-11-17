-- GameManager.lua
-- Main server-side game logic for Mario Wars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local GameManager = {}
GameManager.GameActive = true
GameManager.Winner = nil

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

	return false
end

-- Reset the game
function resetGame()
	print("Resetting game...")
	GameManager.GameActive = true
	GameManager.Winner = nil

	-- Reset all player scores
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local score = leaderstats:FindFirstChild("Score")
			if score then
				score.Value = 0
			end
		end
	end

	-- Notify clients that game has reset
	RemoteEvents.GameStateEvent:FireAllClients("reset")
end

-- Handle head stomp event from client
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

print("GameManager initialized - First to " .. GameConfig.SCORE_TO_WIN .. " wins!")

return GameManager
