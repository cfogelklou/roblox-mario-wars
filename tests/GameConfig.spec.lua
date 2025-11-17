-- GameConfig.spec.lua
-- Unit tests for GameConfig module

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

	describe("GameConfig", function()
		it("should have all required configuration values", function()
			expect(GameConfig.SCORE_TO_WIN).to.be.ok()
			expect(GameConfig.RESPAWN_DELAY).to.be.ok()
			expect(GameConfig.STOMP_VELOCITY_THRESHOLD).to.be.ok()
			expect(GameConfig.STOMP_HEAD_DISTANCE).to.be.ok()
			expect(GameConfig.STOMP_SCORE).to.be.ok()
			expect(GameConfig.STOMP_BOUNCE_VELOCITY).to.be.ok()
		end)

		it("should have valid score to win value", function()
			expect(GameConfig.SCORE_TO_WIN).to.be.a("number")
			expect(GameConfig.SCORE_TO_WIN).to.equal(20)
			expect(GameConfig.SCORE_TO_WIN > 0).to.equal(true)
		end)

		it("should have valid respawn delay", function()
			expect(GameConfig.RESPAWN_DELAY).to.be.a("number")
			expect(GameConfig.RESPAWN_DELAY).to.equal(3)
			expect(GameConfig.RESPAWN_DELAY > 0).to.equal(true)
		end)

		it("should have valid stomp velocity threshold", function()
			expect(GameConfig.STOMP_VELOCITY_THRESHOLD).to.be.a("number")
			expect(GameConfig.STOMP_VELOCITY_THRESHOLD).to.equal(-20)
			expect(GameConfig.STOMP_VELOCITY_THRESHOLD < 0).to.equal(true)
		end)

		it("should have valid stomp head distance", function()
			expect(GameConfig.STOMP_HEAD_DISTANCE).to.be.a("number")
			expect(GameConfig.STOMP_HEAD_DISTANCE).to.equal(3)
			expect(GameConfig.STOMP_HEAD_DISTANCE > 0).to.equal(true)
		end)

		it("should have valid stomp score", function()
			expect(GameConfig.STOMP_SCORE).to.be.a("number")
			expect(GameConfig.STOMP_SCORE).to.equal(1)
			expect(GameConfig.STOMP_SCORE > 0).to.equal(true)
		end)

		it("should have valid stomp bounce velocity", function()
			expect(GameConfig.STOMP_BOUNCE_VELOCITY).to.be.a("number")
			expect(GameConfig.STOMP_BOUNCE_VELOCITY).to.equal(50)
			expect(GameConfig.STOMP_BOUNCE_VELOCITY > 0).to.equal(true)
		end)
	end)
end
