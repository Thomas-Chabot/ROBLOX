--[[
	Written by: call23re2
	Description: Basic timer module.
	Dependencies: Signal (https://www.roblox.com/library/165361891/Signal-Module)
	
	new:
		Description: Creates a timer object. Other functions are used through this.
		Arguments:
			-duration (integer): Duration of timer.
		Returns: New timer object.
		
	Timer:Start:
		Description: Starts your timer.
		Arguments: None
		Returns: Nothing
		
	Timer:Stop:
		Description: Stops your timer.
		Arguments: None
		Returns: Nothing
		
	Timer Object:
		Dictionary:
			{
				duration = duration,
				Complete = complete event
			}
--]]

Timer = {}
Timer.__index = Timer

local Signal = require(path_to_signal)

function Timer.new(duration)
	local newTimer = setmetatable({}, Timer)
	
	newTimer.duration = duration
	newTimer.Complete = Signal.new()
	
	return newTimer
end

function Timer:Start()
	spawn(function()
		repeat
			wait(1)
			self.duration = self.duration - 1
		until
			self.duration == 0
			self.Complete:fire()
			self.Complete:Destroy()
	end)
end

function Timer:Stop()
	self.duration = 0
end

return Timer
