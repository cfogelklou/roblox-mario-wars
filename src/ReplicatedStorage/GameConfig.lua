-- GameConfig.lua
-- Configuration settings for Mario Wars

local GameConfig = {
	-- Score needed to win the game
	SCORE_TO_WIN = 20,

	-- Respawn delay after being stomped (seconds)
	RESPAWN_DELAY = 3,

	-- Velocity threshold for a valid stomp (studs/second downward)
	STOMP_VELOCITY_THRESHOLD = -20,

	-- Distance from top of head to count as stomp (studs)
	STOMP_HEAD_DISTANCE = 3,

	-- Score awarded for stomping another player
	STOMP_SCORE = 1,

	-- Bounce velocity after stomping (studs/second upward)
	STOMP_BOUNCE_VELOCITY = 50,
}

return GameConfig
