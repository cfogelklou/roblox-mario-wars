-- RemoteEvents.lua
-- Creates and manages all remote events for client-server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

-- Create RemoteEvents folder if it doesn't exist
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Head Stomp Event - fired when a player stomps another
local headStompEvent = remoteEventsFolder:FindFirstChild("HeadStompEvent")
if not headStompEvent then
	headStompEvent = Instance.new("RemoteEvent")
	headStompEvent.Name = "HeadStompEvent"
	headStompEvent.Parent = remoteEventsFolder
end
RemoteEvents.HeadStompEvent = headStompEvent

-- Game State Update Event - fired when game state changes
local gameStateEvent = remoteEventsFolder:FindFirstChild("GameStateEvent")
if not gameStateEvent then
	gameStateEvent = Instance.new("RemoteEvent")
	gameStateEvent.Name = "GameStateEvent"
	gameStateEvent.Parent = remoteEventsFolder
end
RemoteEvents.GameStateEvent = gameStateEvent

-- Winner Announced Event - fired when someone wins
local winnerEvent = remoteEventsFolder:FindFirstChild("WinnerEvent")
if not winnerEvent then
	winnerEvent = Instance.new("RemoteEvent")
	winnerEvent.Name = "WinnerEvent"
	winnerEvent.Parent = remoteEventsFolder
end
RemoteEvents.WinnerEvent = winnerEvent

return RemoteEvents
