--[[
	Title: Basic Discord Webhook
	Written by: call23re2
	Description: Basic discord webhook module. Only has 2 functions. Created for personal use. (here comes some terrible documentation)
	
	new:
		Description: Creates a new webhook object.
		Arguments:
			-id (string): webhook id
			-token (string): webhook token
		Returns: table with fields id and token
		
	createEmbed:
		Description: Creates an embed object.
		Arguments:
			data (dictionary):
				-color (table): table consisting of an rgb value (i.e {255, 255, 255})
				-thumbnail (dictionary):
					-url (string): thumbnail url
					-dimensions (table): height and width dimensions (i.e {100, 100})
				-fields (dictionary):
					-dictionary
						-name (string): field name
						-value (string): field value
						-inline (bool): whether or not field is inlien
		Returns: A new dictionary with similar properties. This dictionary can be used with the execute function.
		Example:
			newWebhook:execute({
				username = 'Feedback';
				avatar_url = 'https://pbs.twimg.com/profile_images/801513448785879040/f3txAdY2_bigger.jpg';
				embeds = {embed}
			})
		where embed is the returned dictionary
	
	execute:
		Description: Sends message to discord server.
		Arguments:
			data (dictionary):
				-content (string): the message contents (up to 2000 characters)
				-username (string): override the default username of the webhook
				-avatar_url (string): override the default avatar of the webhook
				-TTS (bool): true if this is a TTS message
				-embeds (dictionary): embeded content, this can optionally be created with the createEmbed function
		Returns: Result of the http request.
--]]


local Http = game:GetService('HttpService')

local webhook = {}
webhook.__index = webhook

function webhook.new(id, token)
	local newWebhook = setmetatable({}, webhook)
	
	newWebhook.id = id
	newWebhook.token = token
	
	return newWebhook
end

function webhook:createEmbed(data)
	
	--[[ This function isn't really necessary as you could send in the embeding data that looks pretty similar to this functions arguments with the 
		 execute function.
	--]]
	
	local obj = {}
	if data.color then
		obj.color = data.color[1] .. data.color[2] .. data.color[3]
	end
	if data.thumbnail then
		obj.thumbnail = {url=data.thumbnail.url,height=data.thumbnail.dimensions[1],width=data.thumbnail.dimensions[2]}
	end
	if data.fields then
		obj.fields = data.fields
	end
	return obj
end

function webhook:execute(data)
	local sendData
	local res = pcall(function()
		data = Http:JSONEncode(data)
	end)
	assert(res, 'Failed to encode json.')
	local result Http:PostAsync('https://discordapp.com/api/webhooks/' .. self.id .. '/' .. self.token, data)
	return result
end

return webhook
