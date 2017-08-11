local module = {
	hex = {0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F'},
	dec = {0,1,2,3,4,5,6,7,8,9,['A']=10,['B']=11,['C']=12,['D']=13,['E']=14,['F']=15}
}

function module.ToHex(dec)
	local function hexify(remainder)
		if remainder > 9 then
			return module.hex[remainder+1]
		else
			return remainder
		end
	end
	local remainders = hexify(dec % 16)
	local last = dec
	repeat
		last = math.floor(last / 16)
		remainders = hexify(last % 16) .. remainders
	until
		last == 0
	return string.sub(remainders,2,string.len(remainders))
end

function module.ToDec(hex)
	local function decify(char)
		if not tonumber(char) then
			return module.dec[char]
		else
			return tonumber(char)
		end
	end
	hex = string.reverse(tostring(hex))
	local sum = 0
	for i = 1,string.len(hex) do
		sum = sum + (decify(hex:sub(i,i)) * (16^(i-1)))
	end
	return sum
end

return module
