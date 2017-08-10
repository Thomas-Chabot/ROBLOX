math.randomseed(tick() % 1 * 10^6)
for i = 1, 50 do math.random()end

local random = require(script.Parent)

local newNum = random.getNumber(1, 10)
local newNums = random.getNumber(1, 10, 3)

local newString = random.getString(10, true, true)
local newStrings = random.getString(10, true, true, 3)

local newString2 = random.getString(10, true, false)
local newStrings2 = random.getString(10, true, false, 3)

local newString3 = random.getString(10, false, true)
local newStrings3 = random.getString(10, false, true, 3)

local newString4 = random.getString(10, false, false)
local newStrings4 = random.getString(10, false, false, 3)

print('newNum', newNum)
local n1 = ''
for i,v in pairs(newNums) do n1 = n1 .. ' | ' .. v end print('newnums',n1)

print('newString', newString)
local n1s = ''
for i,v in pairs(newStrings) do n1s = n1s .. ' | ' .. v end print('newstrings',n1s)

print('newString2', newString2)
local n2s = ''
for i,v in pairs(newStrings2) do n2s = n2s .. ' | ' .. v end print('newstrings2',n2s)

print('newString3', newString3)
local n3s = ''
for i,v in pairs(newStrings3) do n3s = n3s .. ' | ' .. v end print('newstrings3',n3s)

print('newString4', newString4)
local n4s = ''
for i,v in pairs(newStrings4) do n4s = n4s .. ' | ' .. v end print('newstrings4',n4s)
