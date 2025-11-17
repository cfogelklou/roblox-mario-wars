-- GameUI.lua
-- Client-side UI manager for Mario Wars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarioWarsUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create game instructions at top
local instructionsFrame = Instance.new("Frame")
instructionsFrame.Name = "Instructions"
instructionsFrame.Size = UDim2.new(0, 400, 0, 80)
instructionsFrame.Position = UDim2.new(0.5, -200, 0, 10)
instructionsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
instructionsFrame.BackgroundTransparency = 0.5
instructionsFrame.BorderSizePixel = 0
instructionsFrame.Parent = screenGui

local instructionsTitle = Instance.new("TextLabel")
instructionsTitle.Name = "Title"
instructionsTitle.Size = UDim2.new(1, -20, 0, 30)
instructionsTitle.Position = UDim2.new(0, 10, 0, 5)
instructionsTitle.BackgroundTransparency = 1
instructionsTitle.Text = "MARIO WARS"
instructionsTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
instructionsTitle.TextSize = 24
instructionsTitle.Font = Enum.Font.GothamBold
instructionsTitle.TextXAlignment = Enum.TextXAlignment.Center
instructionsTitle.Parent = instructionsFrame

local instructionsText = Instance.new("TextLabel")
instructionsText.Name = "Text"
instructionsText.Size = UDim2.new(1, -20, 0, 40)
instructionsText.Position = UDim2.new(0, 10, 0, 35)
instructionsText.BackgroundTransparency = 1
instructionsText.Text = "Jump on other players' heads to score!\nFirst to "
	.. GameConfig.SCORE_TO_WIN
	.. " points wins!"
instructionsText.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionsText.TextSize = 16
instructionsText.Font = Enum.Font.Gotham
instructionsText.TextXAlignment = Enum.TextXAlignment.Center
instructionsText.TextYAlignment = Enum.TextYAlignment.Top
instructionsText.Parent = instructionsFrame

-- Create winner announcement frame (hidden by default)
local winnerFrame = Instance.new("Frame")
winnerFrame.Name = "WinnerAnnouncement"
winnerFrame.Size = UDim2.new(0, 600, 0, 300)
winnerFrame.Position = UDim2.new(0.5, -300, 0.5, -150)
winnerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
winnerFrame.BackgroundTransparency = 0.2
winnerFrame.BorderSizePixel = 3
winnerFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
winnerFrame.Visible = false
winnerFrame.ZIndex = 10
winnerFrame.Parent = screenGui

-- Add corner radius
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)
uiCorner.Parent = winnerFrame

-- Winner title
local winnerTitle = Instance.new("TextLabel")
winnerTitle.Name = "Title"
winnerTitle.Size = UDim2.new(1, -40, 0, 80)
winnerTitle.Position = UDim2.new(0, 20, 0, 40)
winnerTitle.BackgroundTransparency = 1
winnerTitle.Text = "WINNER!"
winnerTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
winnerTitle.TextSize = 48
winnerTitle.Font = Enum.Font.GothamBold
winnerTitle.TextXAlignment = Enum.TextXAlignment.Center
winnerTitle.TextStrokeTransparency = 0.5
winnerTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
winnerTitle.Parent = winnerFrame

-- Winner name
local winnerName = Instance.new("TextLabel")
winnerName.Name = "PlayerName"
winnerName.Size = UDim2.new(1, -40, 0, 60)
winnerName.Position = UDim2.new(0, 20, 0, 130)
winnerName.BackgroundTransparency = 1
winnerName.Text = ""
winnerName.TextColor3 = Color3.fromRGB(255, 255, 255)
winnerName.TextSize = 36
winnerName.Font = Enum.Font.Gotham
winnerName.TextXAlignment = Enum.TextXAlignment.Center
winnerName.Parent = winnerFrame

-- Winner score
local winnerScore = Instance.new("TextLabel")
winnerScore.Name = "Score"
winnerScore.Size = UDim2.new(1, -40, 0, 40)
winnerScore.Position = UDim2.new(0, 20, 0, 200)
winnerScore.BackgroundTransparency = 1
winnerScore.Text = ""
winnerScore.TextColor3 = Color3.fromRGB(200, 200, 200)
winnerScore.TextSize = 24
winnerScore.Font = Enum.Font.Gotham
winnerScore.TextXAlignment = Enum.TextXAlignment.Center
winnerScore.Parent = winnerFrame

-- Reset message
local resetMessage = Instance.new("TextLabel")
resetMessage.Name = "ResetMessage"
resetMessage.Size = UDim2.new(1, -40, 0, 30)
resetMessage.Position = UDim2.new(0, 20, 1, -50)
resetMessage.BackgroundTransparency = 1
resetMessage.Text = "Game resets in 10 seconds..."
resetMessage.TextColor3 = Color3.fromRGB(150, 150, 150)
resetMessage.TextSize = 18
resetMessage.Font = Enum.Font.GothamItalic
resetMessage.TextXAlignment = Enum.TextXAlignment.Center
resetMessage.Parent = winnerFrame

-- Function to show winner
local function showWinner(winnerPlayerName, score)
	winnerName.Text = winnerPlayerName
	winnerScore.Text = score .. " points!"
	winnerFrame.Visible = true

	-- Hide after 10 seconds
	task.wait(10)
	winnerFrame.Visible = false
end

-- Function to handle game reset
local function onGameReset()
	winnerFrame.Visible = false
	print("Game has been reset!")
end

-- Connect to remote events
RemoteEvents.WinnerEvent.OnClientEvent:Connect(showWinner)
RemoteEvents.GameStateEvent.OnClientEvent:Connect(function(state)
	if state == "reset" then
		onGameReset()
	end
end)

print("GameUI initialized")
