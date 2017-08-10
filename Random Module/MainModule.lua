--[[
	Title: Random Module
	Written by: call23re2
	Description: Generates random numbers / strings. Originally intended for personal use.
	
	[Disclaimer]: You should be setting this at the top of a single server script that starts when the server starts.
				  Do not put it in more than one script.
	[Code]:
		math.randomseed(tick() % 1 * 10^6)
		for i = 1, 50 do math.random()end
		
	getNumber:
		Description: Returns a random number or table of random numbers.
		Arguments:
			-x (integer): First number.
			-y (integer): Second number.
			-amt (integer) [optional]: Amount of numbers to retrieve.
		Returns: If you supplied an amt argument it returns a table of random numbers with a length of amt. If you did not it returns a single random
				 number.
				
	getString:
		Description: Returns a random string or table of random strings.
		Arguments:
			-length (integer): Length of your string.
			-caps (boolean) [optional]: Whether or not capital letters are allowed. Defaults to false.
			-nums (boolean) [optional]: Whether or not numbers are allowed. Defaults to false.
			-amt (integer) [optional]: Amount of strings to retrieve.
		Returns: If you supplied an amt argument it returns a table of random strings with a length of amt. If you did not it returns a single
			 random string.
--]]

local random = {}

function random.getNumber(x, y, amt)
	if not amt or amt == 1 then
		return math.random(x, y)
	else
		local tab = {}
		for i = 1,amt do
			table.insert(tab, math.random(x, y))
		end
		return tab
	end
end

function random.getString(length, caps, numsBool, amt)
	local chars = {'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m'}
	local nums = {1,2,3,4,5,6,7,8,9}
	
	local function makeString()
		local newStr = ''
		
		local function addLetter()
			local isCap = math.random(1, 2)
			if isCap == 1 then
				newStr = newStr .. string.upper(chars[math.random(1,#chars)])
			else
				newStr = newStr .. chars[math.random(1,#chars)]
			end
		end
		
		local function addNumber()
			local isNum = math.random(1, 2)
			if isNum == 2 then
				if caps then
					addLetter()
				else
					newStr = newStr .. chars[math.random(1,#chars)]
				end
			else
				newStr = newStr .. nums[math.random(1,#nums)]
			end
		end		
		
		for i = 1,length do
			if caps then
				if numsBool then
					addNumber()
				else
					addLetter()
				end
			else
				if numsBool then
					addNumber()
				else
					newStr = newStr .. chars[math.random(1,#chars)]
				end
			end
		end
		return newStr
	end
	
	if not amt or amt == 1 then
		return makeString()
	else
		local tab = {}
		for i = 1,amt do
			table.insert(tab, makeString())
		end
		return tab
	end
end

return random
