-- This is an updated version of Merely's Recursion script. (https://github.com/MerelyRBLX/ROBLOX-Lua/blob/master/Recursion.lua)
-- It uses the GetDescendants function so no recursion is needed.

function getAll(obj, class, callback)
	for _, value in pairs(obj:GetDescendants()) do
		if value:IsA(class) then
			callback(value)
		end
	end
end

-- This anchors every BasePart in the Workspace.
getAll(game.Workspace, "BasePart", function(obj)
	obj.Anchored = true
end)
