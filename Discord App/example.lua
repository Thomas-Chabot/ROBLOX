local discord = require(script.Parent.discord)
local settings = {
	id = 'id',
	token = 'token'
}

local discordapp = discord.new(settings.id, settings.token)
local guild = discordapp.guild
local testchannel = guild:GetChannel('test-channel')

local user1 = guild:GetUser('user1')

guild:AddCommand('/dothing',function()
	print('command fired')
end)

guild:AddCommand('/dothing2',function()
	print('command fired 2')
end)
