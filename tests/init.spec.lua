-- init.spec.lua
-- Main test runner for Mario Wars

return function()
	-- Import all test suites
	describe("Mario Wars Test Suite", function()
		-- Configuration tests
		describe("Configuration", require(script.Parent:WaitForChild("GameConfig.spec")))
	end)
end
