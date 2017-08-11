--[[
	Title: Discord API
	Written by: call23re2
	Description: This module is for the discord application api. It is not complete.
	
	Created: (7/29/2017 | 9:46 pm)
	Updated: (8/10/2017 | 6:06 - 7:45 pm)
	
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
			Functions:
				CreateWebhook:
					Arguments:
						data (dictionary):
							-name (string) [optional]: Name of the webhook.
							-avatar (string) [optional]: Avatar url.
					Returns: Webhook object. (https://discordapp.com/developers/docs/resources/webhook#webhook-object)
					
				SendMessage:
					Arguments:
						data (dictionary):
							-content (string): the message contents (up to 2000 characters)
							-username (string) [optional]: override the default username of the webhook
							-avatar_url (string) [optional]: override the default avatar of the webhook
							-TTS (bool) [optional]: true if this is a TTS message
					Returns: Results of the http request.
					
				GetMessages:
					Arguments:
						-limit (integer): Maximum results. Defaults to 50.
						-area (string): Area to look for results.
							-options:
								'around=id_here'
								'before=id_here'
								'after=id_here'
					Returns: Table of messages objects. (https://discordapp.com/developers/docs/resources/channel#message-object)
							
			You can also use the returned channel's AddCommand function. (documentation below)
		
		GetMembers:
			Description: Returns a list of members with set limit. Maximum limit is 1000.
			Arguments:
				-limit (integer): Maximum amount of results.
			Returns: Table of user objects.
			
		GetUser:
			Description: Returns a specific user.
			Arguments:
				-name (string): Name of the user you are looking for.
			Returns: If it can only find one user by the requested name, it will return that user, otherwise it returns a table of every user it has
					 found matching your name argument.
					
		GetAuditLog:
			Description: Returns audit log object.
			Returns: Audit Log Entry Object (https://discordapp.com/developers/docs/resources/audit-log)
			
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
				
		Detailed information about returned objects can be found here: https://discordapp.com/developers/docs/intro
		Specifically under the "Resources" tab.
			
--]]

local http = game:GetService('HttpService')
local WebhookService = require(943430335)
local base = 'https://discordapp.com/api'

local discord = {}
discord.__index = discord

function discord.new(serverid, token)
	
	if not serverid then
		warn('discord.new - Include your Server ID.')
		return
	end
	if not token then
		warn('discord.new - Include your token.')
		return
	end
	
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
					if not command then
						warn('guild.' .. object.name .. ':AddCommand - Please specify command.')
						return
					end
					if not cb then
						warn('guild.' .. object.name .. ':AddCommand - Please add a callback.')
						return
					end
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
				function guild.object:CreateWebhook(data)
					local dataRes = pcall(function()
						data = http:JSONEncode(data)
					end)
					if not dataRes then
						warn('guild.' .. object.name .. ':CreateWebook - Could not encode data')
					end
					local res,msg = pcall(function() return http:JSONDecode(http:PostAsync('https://discordapp.com/api/channels/' .. guild.object.id .. '/webhooks', data, Enum.HttpContentType.ApplicationJson, false, discordObj.authorization)) end)
					if not res then
						warn('guild.' .. object.name .. ':CreateWebhook - Failed to create webhook. (' .. msg .. ')')
					end
					return msg
				end
				function guild.object:SendMessage(data)
					spawn(function()
						local webhooks = http:JSONDecode(http:GetAsync(base .. '/channels/' .. guild.object.id .. '/webhooks', false, discordObj.authorization))
						if #webhooks > 0 then
							local res,msg = pcall(function() return WebhookService.new(webhooks[1].id,webhooks[1].token):execute(data) end)
							if not res then
								warn('guild.' .. object.name .. ':SendMessage - Failed to send message. (' .. msg .. ')')
							end
							return msg
						else
							local webhook = guild.object:CreateWebhook({name='ROBLOX'})
							local res,msg = pcall(function() return WebhookService.new(webhook.id,webhook.token):execute(data) end)
							if not res then
								warn('guild.' .. object.name .. ':SendMessage - Failed to send message. (' .. msg .. ')')
							end
							return msg
						end
					end)
				end
				function guild.object:GetMessages(limit, area)
					local baseURL = base .. '/channels/' .. guild.object.id .. '/messages'
					if limit then
						baseURL = baseURL .. '?limit=' .. limit
					else
						baseURL = baseURL .. '?limit=50'
					end
					if area then
						baseURL = baseURL .. '&' .. area
					end
					local res,msg = pcall(function() return http:JSONDecode(http:GetAsync(baseURL, false, discordObj.authorization)) end)
					if not res then
						warn('guild.' .. object.name .. ':SendMessage - Failed to get messages. (' .. msg .. ')')
					end
					return msg
				end
			end
		end
		if #tab == 1 then
			return tab[1]
		else
			return tab
		end
	end
	
	function guild:GetMembers(limit, after)
		if not limit then
			warn('guild:GetMembers - Please specify limit.')
			return
		end
		if limit > 1000 then
			limit = 1000
		end
		if after then
			return http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=' .. limit .. '&after=' .. after, false, discordObj.authorization))
		else
			return http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=' .. limit, false, discordObj.authorization))
		end
	end	
	
	function guild:GetAuditLog()
		local success,data = pcall(function() return http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/audit-logs', false, discordObj.authorization)) end)
		if not success then
			warn('guild:GetAuditLog - Your bot does not have audit log permissions. (' .. data .. ')')
			return
		else
			return data
		end		
	end	
	
	function guild:GetUser(name, limit)
		local users
		if not limit then
			users = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=1000', false, discordObj.authorization))
		else
			if limit > 1000 then
				limit = 1000
			end
			users = http:JSONDecode(http:GetAsync(base .. '/guilds/' .. guild.id .. '/members?limit=' .. limit, false, discordObj.authorization))
		end
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
		if not command then
			warn('guild:AddCommand - Please specify command.')
			return
		end
		if not cb then
			warn('guild:AddCommand - Please add a callback.')
			return
		end
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
