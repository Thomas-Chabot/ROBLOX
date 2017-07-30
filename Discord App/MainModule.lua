--[[
	Title: Discord API
	Written by: call23re2
	Description: This module is for the discord application api. It is not complete. (7/29/2017 | 9:46 pm)
	
	new:
		Description: Creates a new discord object. Everything you do will be through this.
		Arguments:
			-serverid (string): The server id. To get this right click the icon of your server > click on "Copy ID"
			-token (string): App token. You can get this on your applications page. (https://discordapp.com/developers/applications/me)
		Returns: New discord object.
		
	Once you have created a new discord object, you can put it to use. Below, the new discord object will be referred to as "discordapp".
	
	discordapp.guild:
	
		GetChannel:
			Description: Gets channel within guild by name.
			Arguments:
				-name (string): The name of the channel.
			Returns: If it can only find one channel using the name argument it will return that channel, otherwise it returns a table of every
					 channel it has found matching your name argument.
					
			You can also use the returned channel's AddCommand function. (documentation below)
		
		GetMembers:
			Description: Returns a list of members with set limit. Maximum limit is 1000. It currently does not have support for the after argument.
			Arguments:
				-limit (integer): Maximum amount of results.
			Returns: Table of user objects.
			
		GetUser:
			Description: Returns a specific user.
			Arguments:
				-name (string): Name of the user you are looking for.
			Returns: If it can only find one user by the requested name, it will return that user, otherwise it returns a table of every user it has
					 found matching your name argument.
			
		AddCommand:
			Description: Allows you to add commands to all channels, or if you are calling this function through GetChannel, that specific channel.
			Arguments:
				-command (string): Command to search for. The command will be at the beggining of your string. (i.e /foo)
				-callback (function): The function that it will call when it has found someone using your command.
			Example:
				local discordapp = discord.new(id, token)
				local guild = discordapp.guild
				guild:AddCommand('/foo',function()
					print('bar')
				end)
--]]

local http = game:GetService('HttpService')
local base = 'https://discordapp.com/api'

local discord = {}
discord.__index = discord

function discord.new(serverid, token)
	local discordObj = setmetatable({}, discord)
	
	discordObj.serverid = serverid
	discordObj.token = token
	discordObj.authorization = {Authorization = 'Bot ' .. token}
	
	local guild = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. serverid, false, discordObj.authorization))
	discordObj.guild = setmetatable(guild, discordObj)
	
	function guild:GetChannel(name)
		local channels = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/channels', false, discordObj.authorization))
		local tab = {}
		for index = 1,#channels do
			local object = channels[index]
			if object.name == name then
				table.insert(tab, object)
				guild.object = setmetatable(object, guild)
				function guild.object:AddCommand(command, cb)
					spawn(function()
						local ids = {}
						while wait(0.5) do
							local messages = http:JSONDecode(http:GetAsync(base .. '/channels/' .. guild.object.id .. '/messages?limit=1', false, discordObj.authorization))
							pcall(function()
								if messages[1].content:sub(1, string.len(command)) == command then
									if not ids[messages[1].id] then
										ids[messages[1].id] = true
										cb()
									end
								end
							end)
						end
					end)
				end
			end
		end
		if #tab == 1 then
			return tab[1]
		else
			return tab
		end
	end
	
	function guild:GetMembers(limit)
		return http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=' .. limit, false, discordObj.authorization))
	end	
	
	function guild:GetUser(name)
		local users = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=1000', false, discordObj.authorization))
		local tab = {}
		for index = 1,#users do
			local object = users[index]
			if object.user.username == name then
				table.insert(tab, object)
			end
		end
		if #tab == 1 then
			return tab[1]
		else
			return tab
		end
	end
	
	function guild:AddCommand(command, cb)
		spawn(function()
			local ids = {}
			while wait(0.5) do
				local channels = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/channels', false, discordObj.authorization))
				for i = 1,#channels do
					local messages = http:JSONDecode(http:GetAsync(base .. '/channels/' .. channels[i].id .. '/messages?limit=1', false, discordObj.authorization))
					pcall(function()
						if messages[1].content:sub(1, string.len(command)) == command then
							if not ids[messages[1].id] then
								ids[messages[1].id] = true
								cb()
							end
						end
					end)
				end
			end
		end)
	end
	
	return discordObj
end

return discord
